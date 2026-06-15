"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  Calendar as CalendarIcon,
  Plus,
  Edit2,
  Trash2,
  Clock,
  BookOpen,
  Filter,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Layers,
  ChevronRight,
} from "lucide-react";

interface Batch {
  id: string;
  name: string;
  description: string;
  default_timing: string;
}

interface Schedule {
  id: string;
  batch_id: string;
  class_date: string;
  start_time: string;
  end_time: string;
  status: "scheduled" | "completed" | "cancelled";
  batches: Batch | null;
}

export default function BatchesSchedulesPage() {
  const supabase = createClient();
  const [batches, setBatches] = useState<Batch[]>([]);
  const [schedules, setSchedules] = useState<Schedule[]>([]);
  const [activeTab, setActiveTab] = useState<"schedules" | "batches">("schedules");
  const [loading, setLoading] = useState(true);

  // Filter state
  const [selectedBatchFilter, setSelectedBatchFilter] = useState<string>("all");

  // Modals / Form States
  const [showBatchModal, setShowBatchModal] = useState(false);
  const [currentBatch, setCurrentBatch] = useState<Partial<Batch> | null>(null);

  const [showScheduleModal, setShowScheduleModal] = useState(false);
  const [currentSchedule, setCurrentSchedule] = useState<Partial<Schedule> | null>(null);

  // Fetch initial data
  const fetchData = async () => {
    try {
      const { data: batchesData } = await supabase
        .from("batches")
        .select("*")
        .order("name", { ascending: true });
      setBatches(batchesData || []);

      const { data: schedulesData } = await supabase
        .from("schedules")
        .select(`
          id,
          batch_id,
          class_date,
          start_time,
          end_time,
          status,
          batches (
            id,
            name,
            description,
            default_timing
          )
        `)
        .order("class_date", { ascending: false })
        .order("start_time", { ascending: true });
      setSchedules((schedulesData as any[]) || []);
    } catch (err) {
      console.error("Error fetching batches/schedules data:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();

    // Subscribe to REALTIME updates on schedules table
    // Any insert/update/delete will refresh our local view instantly
    const channel = supabase
      .channel("schedules_crud_realtime")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "schedules" },
        () => {
          fetchData();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  // Batch CRUD handlers
  const handleSaveBatch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentBatch?.name) return;

    try {
      if (currentBatch.id) {
        // Update
        const { error } = await supabase
          .from("batches")
          .update({
            name: currentBatch.name,
            description: currentBatch.description || "",
            default_timing: currentBatch.default_timing || "",
          })
          .eq("id", currentBatch.id);
        if (error) throw error;
      } else {
        // Insert
        const { error } = await supabase
          .from("batches")
          .insert({
            name: currentBatch.name,
            description: currentBatch.description || "",
            default_timing: currentBatch.default_timing || "",
          });
        if (error) throw error;
      }
      setShowBatchModal(false);
      setCurrentBatch(null);
      fetchData();
    } catch (err) {
      alert("Error saving batch profile");
      console.error(err);
    }
  };

  const handleDeleteBatch = async (id: string) => {
    if (!confirm("Are you sure you want to delete this batch? All linked students and schedules will be updated/removed.")) return;
    try {
      const { error } = await supabase.from("batches").delete().eq("id", id);
      if (error) throw error;
      fetchData();
    } catch (err) {
      alert("Failed to delete batch.");
      console.error(err);
    }
  };

  // Schedule CRUD handlers
  const handleSaveSchedule = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentSchedule?.batch_id || !currentSchedule?.class_date || !currentSchedule?.start_time || !currentSchedule?.end_time) {
      alert("Please fill out all required fields.");
      return;
    }

    try {
      const payload = {
        batch_id: currentSchedule.batch_id,
        class_date: currentSchedule.class_date,
        start_time: currentSchedule.start_time,
        end_time: currentSchedule.end_time,
        status: currentSchedule.status || "scheduled",
        updated_at: new Date().toISOString(),
      };

      if (currentSchedule.id) {
        // Update
        const { error } = await supabase
          .from("schedules")
          .update(payload)
          .eq("id", currentSchedule.id);
        if (error) throw error;
      } else {
        // Insert
        const { error } = await supabase
          .from("schedules")
          .insert(payload);
        if (error) throw error;
      }
      setShowScheduleModal(false);
      setCurrentSchedule(null);
      fetchData();
    } catch (err) {
      alert("Error saving schedule event");
      console.error(err);
    }
  };

  const handleDeleteSchedule = async (id: string) => {
    if (!confirm("Are you sure you want to delete this schedule instance?")) return;
    try {
      const { error } = await supabase.from("schedules").delete().eq("id", id);
      if (error) throw error;
      fetchData();
    } catch (err) {
      alert("Failed to delete schedule instance.");
      console.error(err);
    }
  };

  // Filtering
  const filteredSchedules = schedules.filter((sch) => {
    if (selectedBatchFilter === "all") return true;
    return sch.batch_id === selectedBatchFilter;
  });

  if (loading) {
    return (
      <div className="h-full flex items-center justify-center py-20">
        <div className="text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 font-medium text-sm">Loading batches and schedules...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">BATCHES & SCHEDULES</h1>
          <p className="text-[14px] text-slate-500 mt-1">Manage training cohorts and daily training schedules.</p>
        </div>

        <div className="flex gap-3">
          {activeTab === "schedules" ? (
            <button
              onClick={() => {
                setCurrentSchedule({
                  batch_id: batches[0]?.id || "",
                  class_date: new Date().toLocaleDateString("en-CA"),
                  start_time: "17:00:00",
                  end_time: "18:30:00",
                  status: "scheduled",
                });
                setShowScheduleModal(true);
              }}
              className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
            >
              <Plus className="w-4 h-4" strokeWidth={2.5} />
              <span>Schedule Class</span>
            </button>
          ) : (
            <button
              onClick={() => {
                setCurrentBatch({ name: "", description: "", default_timing: "" });
                setShowBatchModal(true);
              }}
              className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
            >
              <Plus className="w-4 h-4" strokeWidth={2.5} />
              <span>Create Batch</span>
            </button>
          )}
        </div>
      </div>

      {/* Tabs Selector */}
      <div className="flex border-b border-slate-200">
        <button
          onClick={() => setActiveTab("schedules")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "schedules"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <CalendarIcon className="w-4.5 h-4.5" />
          <span>Class Schedules</span>
        </button>
        <button
          onClick={() => setActiveTab("batches")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "batches"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <Layers className="w-4.5 h-4.5" />
          <span>Cohorts (Batches)</span>
        </button>
      </div>

      {/* Tab Contents: Schedules */}
      {activeTab === "schedules" && (
        <div className="space-y-6">
          {/* Filters Area */}
          <div className="bg-white p-4 rounded-[12px] border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-4 items-center justify-between">
            <div className="flex items-center gap-2.5 w-full sm:w-auto">
              <Filter className="w-4 h-4 text-slate-400" />
              <span className="text-[13px] font-semibold text-navy uppercase tracking-wider">Filter Batch:</span>
              <select
                value={selectedBatchFilter}
                onChange={(e) => setSelectedBatchFilter(e.target.value)}
                className="bg-slate-50 border border-slate-200 rounded-lg py-1.5 px-3 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
              >
                <option value="all">All Batches</option>
                {batches.map((b) => (
                  <option key={b.id} value={b.id}>
                    {b.name}
                  </option>
                ))}
              </select>
            </div>
            
            <div className="text-[12px] text-slate-400 font-medium self-end sm:self-center">
              Realtime auto-refresh active. Updates publish live.
            </div>
          </div>

          {/* Schedule List */}
          {filteredSchedules.length === 0 ? (
            <div className="bg-white rounded-[12px] border border-slate-100 p-12 text-center shadow-sm">
              <CalendarIcon className="w-12 h-12 text-slate-300 mx-auto mb-3" />
              <p className="text-[14px] font-semibold text-navy">No scheduled classes found.</p>
              <p className="text-[12px] text-slate-400 mt-1">Try changing your filter or add a new scheduled session.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredSchedules.map((sch) => (
                <div
                  key={sch.id}
                  className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between"
                >
                  <div>
                    {/* Header: Batch name and status */}
                    <div className="flex justify-between items-start gap-3">
                      <div>
                        <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-widest block">Class Instance</span>
                        <h3 className="font-bold text-base text-navy mt-1 leading-snug">{sch.batches?.name || "Unnamed Batch"}</h3>
                      </div>
                      <span className={`px-2 py-0.5 text-[9px] font-extrabold uppercase rounded-full tracking-wider ${
                        sch.status === "completed" ? "bg-emerald-100 text-success" :
                        sch.status === "cancelled" ? "bg-rose-100 text-destructive" : "bg-blue-100 text-blue-800"
                      }`}>
                        {sch.status}
                      </span>
                    </div>

                    {/* Date and Times */}
                    <div className="mt-4 space-y-2.5">
                      <div className="flex items-center gap-2 text-[13px] font-medium text-slate-600">
                        <CalendarIcon className="w-4 h-4 text-slate-400" />
                        <span>{new Date(sch.class_date).toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric", year: "numeric" })}</span>
                      </div>
                      <div className="flex items-center gap-2 text-[13px] font-medium text-slate-600">
                        <Clock className="w-4 h-4 text-slate-400" />
                        <span>{sch.start_time.slice(0, 5)} - {sch.end_time.slice(0, 5)}</span>
                      </div>
                    </div>
                  </div>

                  {/* Actions buttons */}
                  <div className="mt-6 pt-4 border-t border-slate-50 flex justify-end gap-2">
                    <button
                      onClick={() => {
                        setCurrentSchedule(sch);
                        setShowScheduleModal(true);
                      }}
                      className="p-2 border border-slate-100 hover:border-slate-200 text-slate-500 hover:text-navy rounded-lg transition-colors"
                      title="Edit Schedule"
                    >
                      <Edit2 className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => handleDeleteSchedule(sch.id)}
                      className="p-2 border border-rose-50 hover:bg-rose-50 text-destructive rounded-lg transition-colors"
                      title="Delete Instance"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Tab Contents: Batches */}
      {activeTab === "batches" && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {batches.length === 0 ? (
            <div className="col-span-full bg-white rounded-[12px] border border-slate-100 p-12 text-center shadow-sm">
              <Layers className="w-12 h-12 text-slate-300 mx-auto mb-3" />
              <p className="text-[14px] font-semibold text-navy">No cohorts/batches registered.</p>
              <button
                onClick={() => {
                  setCurrentBatch({ name: "", description: "", default_timing: "" });
                  setShowBatchModal(true);
                }}
                className="text-gold text-[12px] font-semibold hover:underline mt-1 inline-block"
              >
                Create a cohort batch now
              </button>
            </div>
          ) : (
            batches.map((b) => (
              <div
                key={b.id}
                className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between"
              >
                <div>
                  <div className="flex justify-between items-start gap-2">
                    <h3 className="font-bold text-[18px] text-navy leading-snug">{b.name}</h3>
                    <div className="p-2 bg-navy/5 text-navy rounded-lg">
                      <BookOpen className="w-4 h-4" />
                    </div>
                  </div>

                  <p className="text-[13px] text-slate-500 mt-2.5 leading-relaxed line-clamp-3">
                    {b.description || "No description provided."}
                  </p>

                  <div className="mt-4 bg-slate-50 p-3 rounded-lg border border-slate-100 flex items-center gap-2">
                    <Clock className="w-4 h-4 text-gold flex-shrink-0" />
                    <div>
                      <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider block">Default Timing</span>
                      <span className="text-[12px] font-semibold text-slate-700">{b.default_timing || "Not Configured"}</span>
                    </div>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-50 flex justify-end gap-2">
                  <button
                    onClick={() => {
                      setCurrentBatch(b);
                      setShowBatchModal(true);
                    }}
                    className="p-2 border border-slate-100 hover:border-slate-200 text-slate-500 hover:text-navy rounded-lg transition-colors"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleDeleteBatch(b.id)}
                    className="p-2 border border-rose-50 hover:bg-rose-50 text-destructive rounded-lg transition-colors"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* ====================================================
          MODAL: BATCH FORM
          ==================================================== */}
      {showBatchModal && currentBatch && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">
                {currentBatch.id ? "Edit Batch Cohort" : "Create Batch Cohort"}
              </h3>
              <button
                onClick={() => setShowBatchModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveBatch} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Batch Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Grandmasters, Beginners Batch C"
                  value={currentBatch.name || ""}
                  onChange={(e) => setCurrentBatch({ ...currentBatch, name: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-450 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Timing Schedule *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Mon/Wed 6:00 PM - 7:30 PM"
                  value={currentBatch.default_timing || ""}
                  onChange={(e) => setCurrentBatch({ ...currentBatch, default_timing: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-450 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Description</label>
                <textarea
                  rows={3}
                  placeholder="Provide syllabus notes or skill brackets..."
                  value={currentBatch.description || ""}
                  onChange={(e) => setCurrentBatch({ ...currentBatch, description: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-450 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
                />
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowBatchModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150"
                >
                  Save Batch
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ====================================================
          MODAL: SCHEDULE INSTANCE FORM
          ==================================================== */}
      {showScheduleModal && currentSchedule && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">
                {currentSchedule.id ? "Edit Schedule Event" : "Schedule Class Event"}
              </h3>
              <button
                onClick={() => setShowScheduleModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveSchedule} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Target Batch *</label>
                <select
                  required
                  value={currentSchedule.batch_id || ""}
                  onChange={(e) => setCurrentSchedule({ ...currentSchedule, batch_id: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                >
                  <option value="" disabled>Select Cohort Batch</option>
                  {batches.map((b) => (
                    <option key={b.id} value={b.id}>
                      {b.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Class Date *</label>
                <input
                  type="date"
                  required
                  value={currentSchedule.class_date || ""}
                  onChange={(e) => setCurrentSchedule({ ...currentSchedule, class_date: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Start Time *</label>
                  <input
                    type="time"
                    required
                    step="60"
                    value={currentSchedule.start_time || ""}
                    onChange={(e) => setCurrentSchedule({ ...currentSchedule, start_time: e.target.value })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">End Time *</label>
                  <input
                    type="time"
                    required
                    step="60"
                    value={currentSchedule.end_time || ""}
                    onChange={(e) => setCurrentSchedule({ ...currentSchedule, end_time: e.target.value })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                  />
                </div>
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Session Status *</label>
                <select
                  required
                  value={currentSchedule.status || "scheduled"}
                  onChange={(e) => setCurrentSchedule({ ...currentSchedule, status: e.target.value as any })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                >
                  <option value="scheduled">Scheduled</option>
                  <option value="completed">Completed</option>
                  <option value="cancelled">Cancelled</option>
                </select>
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowScheduleModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150"
                >
                  Publish Schedule
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
