"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  FileText,
  Plus,
  Trash2,
  CheckCircle,
  ExternalLink,
  Layers,
  Calendar,
  ClipboardList,
  Clock,
  Eye,
  CheckCircle2,
} from "lucide-react";

interface Batch {
  id: string;
  name: string;
}

interface Assignment {
  id: string;
  batch_id: string;
  title: string;
  description: string | null;
  due_date: string | null;
  created_at: string;
}

interface Student {
  id: string;
  name: string;
}

interface Submission {
  id: string;
  assignment_id: string;
  student_id: string;
  drive_link: string;
  status: "pending" | "submitted" | "reviewed";
  submitted_at: string;
  students: Student | null;
  assignments: {
    title: string;
  } | null;
}

export default function AssignmentsPage() {
  const supabase = createClient();
  const [batches, setBatches] = useState<Batch[]>([]);
  const [selectedBatch, setSelectedBatch] = useState<string>("");
  const [assignments, setAssignments] = useState<Assignment[]>([]);
  const [submissions, setSubmissions] = useState<Submission[]>([]);
  const [activeTab, setActiveTab] = useState<"assignments" | "submissions">("assignments");
  const [loading, setLoading] = useState(true);

  // Form State for new assignment
  const [showModal, setShowModal] = useState(false);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [dueDate, setDueDate] = useState("");

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
        console.error("Error loading batches for assignments:", err);
        setLoading(false);
      }
    }
    loadBatches();
  }, [supabase]);

  const loadAssignmentData = async () => {
    if (!selectedBatch) return;
    setLoading(true);
    try {
      // 1. Fetch assignments for selected batch
      const { data: assignmentsData } = await supabase
        .from("assignments")
        .select("*")
        .eq("batch_id", selectedBatch)
        .order("created_at", { ascending: false });
      setAssignments(assignmentsData || []);

      // 2. Fetch homework submissions for the batch's assignments
      const { data: subsData } = await supabase
        .from("homework_submissions")
        .select(`
          id,
          assignment_id,
          student_id,
          drive_link,
          status,
          submitted_at,
          students ( id, name ),
          assignments!inner ( id, title, batch_id )
        `)
        .eq("assignments.batch_id", selectedBatch)
        .order("submitted_at", { ascending: false });

      setSubmissions((subsData as any[]) || []);
    } catch (err) {
      console.error("Error loading assignments/submissions:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAssignmentData();
  }, [selectedBatch]);

  // Create Assignment
  const handleSaveAssignment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !selectedBatch) return;

    try {
      const { error } = await supabase
        .from("assignments")
        .insert({
          batch_id: selectedBatch,
          title,
          description: description || "",
          due_date: dueDate ? new Date(dueDate).toISOString() : null,
        });

      if (error) throw error;

      setShowModal(false);
      setTitle("");
      setDescription("");
      setDueDate("");
      loadAssignmentData();
    } catch (err) {
      alert("Error sharing assignment");
      console.error(err);
    }
  };

  const handleDeleteAssignment = async (id: string) => {
    if (!confirm("Are you sure you want to delete this assignment? All homework submissions will be removed!")) return;
    try {
      const { error } = await supabase.from("assignments").delete().eq("id", id);
      if (error) throw error;
      loadAssignmentData();
    } catch (err) {
      alert("Error deleting assignment");
      console.error(err);
    }
  };

  // Mark Submission Reviewed
  const handleMarkReviewed = async (id: string) => {
    try {
      const { error } = await supabase
        .from("homework_submissions")
        .update({ status: "reviewed" })
        .eq("id", id);

      if (error) throw error;
      loadAssignmentData();
    } catch (err) {
      alert("Error updating submission status");
      console.error(err);
    }
  };

  if (batches.length === 0 && !loading) {
    return (
      <div className="bg-white rounded-[12px] p-12 text-center border border-slate-100 shadow-sm">
        <FileText className="w-12 h-12 text-slate-300 mx-auto mb-3" />
        <p className="text-[14px] font-semibold text-navy">No batches created.</p>
        <p className="text-[12px] text-slate-400 mt-1">Please create a batch cohort before distributing assignments.</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">ASSIGNMENTS & HOMEWORK</h1>
          <p className="text-[14px] text-slate-500 mt-1">Assign tasks to chess cohorts and review drive file submissions.</p>
        </div>

        <div className="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
          {/* Batch Selector */}
          <div className="flex items-center gap-3 bg-white px-4 py-2 border border-slate-200 rounded-lg shadow-sm">
            <Layers className="w-4 h-4 text-slate-400" />
            <span className="text-xs font-bold text-navy uppercase tracking-wider">Cohort:</span>
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

          {activeTab === "assignments" && (
            <button
              onClick={() => setShowModal(true)}
              className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center justify-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
            >
              <Plus className="w-4 h-4" strokeWidth={2.5} />
              <span>Create Assignment</span>
            </button>
          )}
        </div>
      </div>

      {/* Tabs Selector */}
      <div className="flex border-b border-slate-200">
        <button
          onClick={() => setActiveTab("assignments")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "assignments"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <ClipboardList className="w-4 h-4" />
          <span>Assignments Shared</span>
        </button>
        <button
          onClick={() => setActiveTab("submissions")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "submissions"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <Eye className="w-4 h-4" />
          <span>Submissions Review ({submissions.length})</span>
        </button>
      </div>

      {loading ? (
        <div className="py-20 text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 text-sm font-medium">Fetching homework rosters...</p>
        </div>
      ) : (
        <>
          {/* TAB 1: ASSIGNMENTS */}
          {activeTab === "assignments" && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-fadeIn">
              {assignments.length === 0 ? (
                <div className="col-span-full bg-white rounded-[12px] p-16 text-center border border-slate-100 shadow-sm">
                  <ClipboardList className="w-12 h-12 text-slate-355 mx-auto mb-3" />
                  <p className="text-sm font-bold text-navy">No homework assigned to this batch.</p>
                  <p className="text-xs text-slate-400 mt-1">Distribute worksheets or chess puzzles for practice.</p>
                </div>
              ) : (
                assignments.map((ass) => (
                  <div
                    key={ass.id}
                    className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between"
                  >
                    <div>
                      <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider block">Homework</span>
                      <h3 className="font-bold text-[16px] text-navy mt-1.5 leading-snug line-clamp-2" title={ass.title}>
                        {ass.title}
                      </h3>

                      <p className="text-[13px] text-slate-500 mt-3 leading-relaxed line-clamp-3">
                        {ass.description || "No description provided."}
                      </p>

                      {ass.due_date && (
                        <div className="mt-4 bg-slate-50 p-2.5 rounded-lg border border-slate-100 flex items-center gap-2 text-xs font-semibold text-slate-600">
                          <Clock className="w-4 h-4 text-gold" />
                          <span>Due: {new Date(ass.due_date).toLocaleDateString("en-US", { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })}</span>
                        </div>
                      )}
                    </div>

                    <div className="mt-6 pt-4 border-t border-slate-50 flex justify-end">
                      <button
                        onClick={() => handleDeleteAssignment(ass.id)}
                        className="p-1.5 text-slate-450 hover:text-destructive hover:bg-rose-50 rounded transition-colors"
                        title="Delete Assignment"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          )}

          {/* TAB 2: SUBMISSIONS */}
          {activeTab === "submissions" && (
            <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden animate-fadeIn">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                    <th className="py-4 px-6">Student Name</th>
                    <th className="py-4 px-6">Assignment Title</th>
                    <th className="py-4 px-6">Drive Link</th>
                    <th className="py-4 px-6">Submitted At</th>
                    <th className="py-4 px-6 text-center">Status</th>
                    <th className="py-4 px-6 text-right">Review Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
                  {submissions.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="text-center py-12 text-slate-450 font-medium">
                        No submissions uploaded yet by students in this batch.
                      </td>
                    </tr>
                  ) : (
                    submissions.map((sub) => (
                      <tr key={sub.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="py-4 px-6 font-bold text-navy">
                          {sub.students?.name || "Deleted Student"}
                        </td>
                        <td className="py-4 px-6 text-slate-800">
                          {sub.assignments?.title || "Deleted Assignment"}
                        </td>
                        <td className="py-4 px-6">
                          <a
                            href={sub.drive_link}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center gap-1 text-gold hover:underline"
                          >
                            <span>Open Google Drive</span>
                            <ExternalLink className="w-3.5 h-3.5" />
                          </a>
                        </td>
                        <td className="py-4 px-6 text-slate-500 font-mono text-xs">
                          {new Date(sub.submitted_at).toLocaleDateString("en-US", { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })}
                        </td>
                        <td className="py-4 px-6 text-center">
                          <span className={`px-2.5 py-1 rounded-full text-[9px] font-extrabold uppercase tracking-wider ${
                            sub.status === "reviewed"
                              ? "bg-emerald-100 text-success"
                              : "bg-amber-100 text-amber-800"
                          }`}>
                            {sub.status}
                          </span>
                        </td>
                        <td className="py-4 px-6 text-right">
                          {sub.status !== "reviewed" ? (
                            <button
                              onClick={() => handleMarkReviewed(sub.id)}
                              className="px-3.5 py-1.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow-sm transition-all duration-150 flex items-center gap-1.5 ml-auto active:scale-95"
                            >
                              <CheckCircle2 className="w-3.5 h-3.5" />
                              <span>Mark Reviewed</span>
                            </button>
                          ) : (
                            <span className="text-slate-400 font-medium text-xs flex items-center justify-end gap-1 px-2">
                              <CheckCircle className="w-4 h-4 text-success" />
                              <span>Reviewed</span>
                            </span>
                          )}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}

      {/* ====================================================
          MODAL: NEW ASSIGNMENT FORM
          ==================================================== */}
      {showModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">Assign Homework</h3>
              <button
                onClick={() => setShowModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveAssignment} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Assignment Title *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Knight Fork Puzzles (Sheet 3)"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Due Date & Time</label>
                <input
                  type="datetime-local"
                  value={dueDate}
                  onChange={(e) => setDueDate(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Instructions</label>
                <textarea
                  rows={4}
                  placeholder="Describe homework objectives, target ratings, or link instructions..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium"
                />
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150"
                >
                  Publish Homework
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
