"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  CheckSquare,
  Users,
  Calendar,
  CheckCircle,
  XCircle,
  ChevronDown,
  ChevronUp,
  Percent,
  SlidersHorizontal,
  MapPin,
  Search,
  Filter,
} from "lucide-react";

interface Batch {
  id: string;
  name: string;
}

interface Student {
  id: string;
  name: string;
}

interface Schedule {
  id: string;
  class_date: string;
}

interface AttendanceRecord {
  student_id: string;
  class_date: string;
  status: "present" | "absent";
  geofence_verified?: boolean;
}

interface GeofenceLog {
  id: string;
  student_id: string;
  lat: number;
  lng: number;
  accuracy: number;
  event_type: "enter" | "exit";
  timestamp: string;
  students: {
    name: string;
    batch_id: string;
  } | null;
}

export default function AttendancePage() {
  const supabase = createClient();
  const [batches, setBatches] = useState<Batch[]>([]);
  const [selectedBatch, setSelectedBatch] = useState<string>("");
  const [students, setStudents] = useState<Student[]>([]);
  const [schedules, setSchedules] = useState<Schedule[]>([]);
  const [attendance, setAttendance] = useState<AttendanceRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [viewMode, setViewMode] = useState<"grid" | "rollup" | "geofence_logs">("grid");
  const [geofenceLogs, setGeofenceLogs] = useState<GeofenceLog[]>([]);

  // Geofence Logs Filter States
  const [logStudentFilter, setLogStudentFilter] = useState("all");
  const [logStartDate, setLogStartDate] = useState("");
  const [logEndDate, setLogEndDate] = useState("");

  // Load batches on component mount
  useEffect(() => {
    async function loadBatches() {
      try {
        const { data } = await supabase
          .from("batches")
          .select("id, name")
          .order("name", { ascending: true });
        setBatches(data || []);
        if (data && data.length > 0) {
          setSelectedBatch(data[0].id);
        } else {
          setLoading(false);
        }
      } catch (err) {
        console.error("Error loading batches for attendance:", err);
        setLoading(false);
      }
    }
    loadBatches();
  }, [supabase]);

  // Load students, class dates (schedules), and attendance logs when selected batch changes
  useEffect(() => {
    if (!selectedBatch) return;
    setLoading(true);

    async function loadAttendanceData() {
      try {
        // 1. Load active students for this batch
        const { data: studentData } = await supabase
          .from("students")
          .select("id, name")
          .eq("batch_id", selectedBatch)
          .eq("is_deleted", false)
          .order("name", { ascending: true });

        // 2. Load schedules (class dates) for this batch (limit to past & today's 10 classes)
        const { data: scheduleData } = await supabase
          .from("schedules")
          .select("id, class_date")
          .eq("batch_id", selectedBatch)
          .order("class_date", { ascending: false })
          .limit(10); // columns count

        // 3. Load attendance logs for this batch
        const { data: attendanceData } = await supabase
          .from("attendance_records")
          .select("student_id, class_date, status, geofence_verified")
          .eq("batch_id", selectedBatch);

        setStudents(studentData || []);
        // Sort schedules chronologically for table column headers (left-to-right)
        setSchedules((scheduleData || []).reverse());
        setAttendance((attendanceData as any[]) || []);

        // 4. Fetch Geofence Logs
        const { data: logsData } = await supabase
          .from("geofence_logs")
          .select(`
            id,
            student_id,
            lat,
            lng,
            accuracy,
            event_type,
            timestamp,
            students:student_id ( name, batch_id )
          `)
          .order("timestamp", { ascending: false });

        const batchLogs = (logsData || []).filter((log: any) => log.students?.batch_id === selectedBatch);
        setGeofenceLogs(batchLogs as any[]);
      } catch (err) {
        console.error("Error loading batch attendance data:", err);
      } finally {
        setLoading(false);
      }
    }

    loadAttendanceData();
  }, [selectedBatch, supabase]);

  // Toggle attendance status in cell
  const handleToggleAttendance = async (studentId: string, classDate: string, currentStatus: "present" | "absent" | undefined) => {
    // Cycle status: undefined -> present -> absent -> undefined (delete)
    let newStatus: "present" | "absent" | null = null;
    if (!currentStatus) {
      newStatus = "present";
    } else if (currentStatus === "present") {
      newStatus = "absent";
    } else {
      newStatus = null; // Remove record
    }

    try {
      if (newStatus === null) {
        // Delete attendance log
        const { error } = await supabase
          .from("attendance_records")
          .delete()
          .match({
            student_id: studentId,
            batch_id: selectedBatch,
            class_date: classDate,
          });
        if (error) throw error;

        // Update local state
        setAttendance((prev) =>
          prev.filter((a) => !(a.student_id === studentId && a.class_date === classDate))
        );
      } else {
        // Upsert attendance log
        const { error } = await supabase
          .from("attendance_records")
          .upsert(
            {
              student_id: studentId,
              batch_id: selectedBatch,
              class_date: classDate,
              status: newStatus,
            },
            { onConflict: "student_id,batch_id,class_date" }
          );
        if (error) throw error;

        // Update local state
        setAttendance((prev) => {
          const exists = prev.some((a) => a.student_id === studentId && a.class_date === classDate);
          if (exists) {
            return prev.map((a) =>
              a.student_id === studentId && a.class_date === classDate
                ? { ...a, status: newStatus as "present" | "absent" }
                : a
            );
          } else {
            return [...prev, { student_id: studentId, class_date: classDate, status: newStatus as "present" | "absent" }];
          }
        });
      }
    } catch (err) {
      alert("Error saving attendance record");
      console.error(err);
    }
  };

  // Calculate Rollup Stats per Student
  const calculateRollup = (studentId: string) => {
    const studentLogs = attendance.filter((a) => a.student_id === studentId);
    const presentCount = studentLogs.filter((a) => a.status === "present").length;
    const absentCount = studentLogs.filter((a) => a.status === "absent").length;
    const totalMarked = presentCount + absentCount;
    const rate = totalMarked > 0 ? Math.round((presentCount / totalMarked) * 100) : 100;

    return {
      present: presentCount,
      absent: absentCount,
      total: totalMarked,
      rate,
    };
  };

  if (batches.length === 0 && !loading) {
    return (
      <div className="bg-white rounded-[12px] p-12 text-center border border-slate-100 shadow-sm">
        <CheckSquare className="w-12 h-12 text-slate-300 mx-auto mb-3" />
        <p className="text-[14px] font-semibold text-navy">No batches configured yet.</p>
        <p className="text-[12px] text-slate-400 mt-1">Please create a batch cohort before marking student attendance.</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">ATTENDANCE SHEET</h1>
          <p className="text-[14px] text-slate-500 mt-1">Record presence logs and audit student attendance rollups.</p>
        </div>

        {/* Batch Selector */}
        <div className="flex items-center gap-3 bg-white px-4 py-2 border border-slate-200 rounded-lg shadow-sm w-full sm:w-auto">
          <Users className="w-4 h-4 text-slate-400" />
          <span className="text-xs font-bold text-navy uppercase tracking-wider">Cohort Batch:</span>
          <select
            value={selectedBatch}
            onChange={(e) => setSelectedBatch(e.target.value)}
            className="bg-transparent border-none py-0.5 px-1 text-xs font-bold text-slate-700 focus:outline-none focus:ring-0 cursor-pointer"
          >
            {batches.map((b) => (
              <option key={b.id} value={b.id}>
                {b.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Mode Selectors */}
      <div className="flex border-b border-slate-200">
        <button
          onClick={() => setViewMode("grid")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            viewMode === "grid"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <CheckSquare className="w-4 h-4" />
          <span>Mark Grid (Class-by-Class)</span>
        </button>
        <button
          onClick={() => setViewMode("rollup")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            viewMode === "rollup"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <Percent className="w-4 h-4" />
          <span>Monthly Analytics Rollup</span>
        </button>
        <button
          onClick={() => setViewMode("geofence_logs")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            viewMode === "geofence_logs"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <MapPin className="w-4 h-4" />
          <span>Geofence Logs</span>
        </button>
      </div>

      {loading ? (
        <div className="py-20 text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 text-sm font-medium">Fetching attendance workbook...</p>
        </div>
      ) : students.length === 0 ? (
        <div className="bg-white rounded-[12px] border border-slate-100 p-12 text-center shadow-sm">
          <Users className="w-10 h-10 text-slate-300 mx-auto mb-2" />
          <p className="text-sm font-semibold text-navy">No students allocated to this batch.</p>
          <p className="text-xs text-slate-400 mt-1">Please assign students to this batch cohort in the Students Registry.</p>
        </div>
      ) : (
        <>
          {/* TAB 1: GRID VIEW */}
          {viewMode === "grid" && (
            <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden">
              {schedules.length === 0 ? (
                <div className="p-12 text-center text-slate-400 font-medium">
                  <Calendar className="w-10 h-10 text-slate-200 mx-auto mb-2" />
                  <p className="text-sm font-semibold text-navy">No schedule instances created for this batch.</p>
                  <p className="text-xs text-slate-400 mt-1">Please add schedules first on the Batches & Schedules tab.</p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                        <th className="py-4 px-6 min-w-[200px] border-r border-slate-700">Student Name</th>
                        {schedules.map((sch) => (
                          <th key={sch.id} className="py-4 px-4 text-center min-w-[100px] border-r border-slate-750">
                            {new Date(sch.class_date).toLocaleDateString("en-US", { month: "short", day: "numeric" })}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
                      {students.map((student) => (
                        <tr key={student.id} className="hover:bg-slate-50/50 transition-colors">
                          <td className="py-4 px-6 font-bold text-navy border-r border-slate-100 flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-navy/5 text-navy flex items-center justify-center font-bold text-[10px] uppercase">
                              {student.name.charAt(0)}
                            </span>
                            <span>{student.name}</span>
                          </td>

                          {schedules.map((sch) => {
                            const record = attendance.find(
                              (a) => a.student_id === student.id && a.class_date === sch.class_date
                            );
                            const status = record?.status;
                            const isVerified = record?.geofence_verified;

                            return (
                              <td key={sch.id} className="p-3 text-center border-r border-slate-100">
                                <div className="inline-flex flex-col items-center gap-1.5">
                                  <button
                                    onClick={() => handleToggleAttendance(student.id, sch.class_date, status)}
                                    className={`w-12 h-8 rounded-lg font-bold text-xs transition-all duration-150 border active:scale-95 shadow-sm inline-flex items-center justify-center ${
                                      status === "present"
                                        ? "bg-success text-white border-success"
                                        : status === "absent"
                                        ? "bg-destructive text-white border-destructive"
                                        : "bg-slate-50 text-slate-400 border-slate-200 hover:bg-slate-100"
                                    }`}
                                    title="Click to toggle: Unmarked -> Present -> Absent -> Unmarked"
                                  >
                                    {status === "present" ? "P" : status === "absent" ? "A" : "—"}
                                  </button>
                                  <div className="h-4 flex items-center justify-center">
                                    {isVerified ? (
                                      <div title="Geofence Verified">
                                        <MapPin className="w-3.5 h-3.5 text-gold fill-gold/25" />
                                      </div>
                                    ) : (
                                      <span className="text-[10px] text-slate-300 font-bold">—</span>
                                    )}
                                  </div>
                                </div>
                              </td>
                            );
                          })}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
              {schedules.length > 0 && (
                <div className="bg-slate-50 px-6 py-4 border-t border-slate-100 text-[11px] text-slate-400 font-medium flex items-center gap-6">
                  <span>Legend:</span>
                  <span className="flex items-center gap-1.5"><span className="w-3.5 h-5 bg-success text-white font-bold rounded flex items-center justify-center text-[10px]">P</span> Present</span>
                  <span className="flex items-center gap-1.5"><span className="w-3.5 h-5 bg-destructive text-white font-bold rounded flex items-center justify-center text-[10px]">A</span> Absent</span>
                  <span className="flex items-center gap-1.5"><span className="w-3.5 h-5 bg-slate-50 border border-slate-200 text-slate-400 font-bold rounded flex items-center justify-center text-[10px]">—</span> Unmarked</span>
                  <span className="ml-auto text-slate-450">Tapping cell cycles: unmarked → Present (Green) → Absent (Red) → unmarked.</span>
                </div>
              )}
            </div>
          )}

          {/* TAB 2: ROLLUP VIEW */}
          {viewMode === "rollup" && (
            <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                    <th className="py-4 px-6">Student Name</th>
                    <th className="py-4 px-6 text-center">Classes Attended</th>
                    <th className="py-4 px-6 text-center">Classes Absent</th>
                    <th className="py-4 px-6 text-center">Total Sessions Marked</th>
                    <th className="py-4 px-6 text-right">Attendance Rate</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
                  {students.map((student) => {
                    const stats = calculateRollup(student.id);

                    return (
                      <tr key={student.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="py-4 px-6 font-bold text-navy flex items-center gap-2">
                          <span className="w-6 h-6 rounded-full bg-navy/5 text-navy flex items-center justify-center font-bold text-[10px] uppercase">
                            {student.name.charAt(0)}
                          </span>
                          <span>{student.name}</span>
                        </td>
                        <td className="py-4 px-6 text-center font-bold text-success">
                          {stats.present}
                        </td>
                        <td className="py-4 px-6 text-center font-bold text-destructive">
                          {stats.absent}
                        </td>
                        <td className="py-4 px-6 text-center text-slate-500">
                          {stats.total}
                        </td>
                        <td className="py-4 px-6 text-right">
                          <span className={`inline-block px-3 py-1 rounded-full text-xs font-bold ${
                            stats.rate >= 90 ? "bg-emerald-100 text-success" :
                            stats.rate >= 75 ? "bg-amber-105 text-[#8F6516]" : "bg-rose-100 text-destructive"
                          }`}>
                            {stats.rate}%
                          </span>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}

          {/* TAB 3: GEOFENCE LOGS */}
          {viewMode === "geofence_logs" && (
            <div className="space-y-6">
              {/* Geofence Logs Filter panel */}
              <div className="bg-white p-4 rounded-[12px] border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-4 items-center justify-between">
                <div className="flex flex-wrap items-center gap-4 w-full sm:w-auto">
                  {/* Filter Student */}
                  <div className="flex items-center gap-2">
                    <Users className="w-4 h-4 text-slate-400" />
                    <span className="text-xs font-bold text-navy uppercase tracking-wider">Student:</span>
                    <select
                      value={logStudentFilter}
                      onChange={(e) => setLogStudentFilter(e.target.value)}
                      className="bg-slate-50 border border-slate-200 rounded-lg py-1.5 px-3 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold cursor-pointer"
                    >
                      <option value="all">All Students</option>
                      {students.map((s) => (
                        <option key={s.id} value={s.id}>
                          {s.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Date range filters */}
                  <div className="flex items-center gap-2">
                    <Calendar className="w-4 h-4 text-slate-400" />
                    <span className="text-xs font-bold text-navy uppercase tracking-wider">From:</span>
                    <input
                      type="date"
                      value={logStartDate}
                      onChange={(e) => setLogStartDate(e.target.value)}
                      className="bg-slate-50 border border-slate-200 rounded-lg py-1 px-2.5 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
                    />
                  </div>

                  <div className="flex items-center gap-2">
                    <span className="text-xs font-bold text-navy uppercase tracking-wider">To:</span>
                    <input
                      type="date"
                      value={logEndDate}
                      onChange={(e) => setLogEndDate(e.target.value)}
                      className="bg-slate-50 border border-slate-200 rounded-lg py-1 px-2.5 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
                    />
                  </div>
                </div>

                <button
                  onClick={() => {
                    setLogStudentFilter("all");
                    setLogStartDate("");
                    setLogEndDate("");
                  }}
                  className="text-xs font-bold text-gold hover:underline"
                >
                  Clear Filters
                </button>
              </div>

              {/* Logs Table */}
              <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden animate-fadeIn">
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                        <th className="py-4 px-6">Student Name</th>
                        <th className="py-4 px-6 text-center">Event Type</th>
                        <th className="py-4 px-6 text-center">Coordinates (Lat, Lng)</th>
                        <th className="py-4 px-6 text-center">Accuracy (Meters)</th>
                        <th className="py-4 px-6 text-right">Event Timestamp</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
                      {(() => {
                        const filteredLogs = geofenceLogs.filter((log) => {
                          if (logStudentFilter !== "all" && log.student_id !== logStudentFilter) return false;
                          if (logStartDate && new Date(log.timestamp) < new Date(logStartDate)) return false;
                          if (logEndDate) {
                            const endDateTime = new Date(logEndDate);
                            endDateTime.setHours(23, 59, 59, 999);
                            if (new Date(log.timestamp) > endDateTime) return false;
                          }
                          return true;
                        });

                        if (filteredLogs.length === 0) {
                          return (
                            <tr>
                              <td colSpan={5} className="py-12 text-center text-slate-450 font-medium">
                                No geofence event logs found matching the filter criteria.
                              </td>
                            </tr>
                          );
                        }

                        return filteredLogs.map((log) => {
                          const isEnter = log.event_type === "enter";

                          return (
                            <tr key={log.id} className="hover:bg-slate-50/50 transition-colors">
                              <td className="py-4 px-6 font-bold text-navy">
                                {log.students?.name || "Deleted Student"}
                              </td>
                              <td className="py-4 px-6 text-center">
                                <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wider ${
                                  isEnter ? "bg-emerald-100 text-success" : "bg-amber-100 text-[#8F6516]"
                                }`}>
                                  <MapPin className="w-3 h-3" />
                                  <span>{isEnter ? "Enter" : "Exit"}</span>
                                </span>
                              </td>
                              <td className="py-4 px-6 text-center font-medium text-slate-550">
                                {log.lat.toFixed(6)}, {log.lng.toFixed(6)}
                              </td>
                              <td className="py-4 px-6 text-center font-medium text-slate-550">
                                {log.accuracy ? `${log.accuracy.toFixed(1)}m` : "N/A"}
                              </td>
                              <td className="py-4 px-6 text-right text-slate-500 font-medium">
                                <span className="block">{new Date(log.timestamp).toLocaleDateString()}</span>
                                <span className="block text-[11px] text-slate-400 mt-0.5">
                                  {new Date(log.timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                                </span>
                              </td>
                            </tr>
                          );
                        });
                      })()}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
