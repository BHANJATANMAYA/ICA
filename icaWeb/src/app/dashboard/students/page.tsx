"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import { createOrUpdateParentAction } from "./actions";
import {
  Users,
  Search,
  Plus,
  Edit2,
  Trash2,
  Filter,
  User,
  ShieldAlert,
  SlidersHorizontal,
  CheckCircle,
  HelpCircle,
  Mail,
  Phone,
  Contact,
  Layers,
} from "lucide-react";

interface Batch {
  id: string;
  name: string;
}

interface Parent {
  id: string;
  auth_user_id?: string | null;
  name: string;
  email: string;
  phone: string | null;
  students?: { id: string; name: string }[];
}

interface Student {
  id: string;
  name: string;
  chess_rating: number;
  level: string;
  platform_id: string | null;
  parent_id: string | null;
  batch_id: string | null;
  is_deleted: boolean;
  batches: Batch | null;
  parents: Parent | null;
}

export default function StudentsPage() {
  const supabase = createClient();
  const [activeTab, setActiveTab] = useState<"students" | "parents">("students");
  const [students, setStudents] = useState<Student[]>([]);
  const [batches, setBatches] = useState<Batch[]>([]);
  const [parents, setParents] = useState<Parent[]>([]);
  const [loading, setLoading] = useState(true);

  // Students Filter States
  const [searchQuery, setSearchQuery] = useState("");
  const [levelFilter, setLevelFilter] = useState("all");
  const [batchFilter, setBatchFilter] = useState("all");
  const [unassignedParentFilter, setUnassignedParentFilter] = useState(false);

  // Parents Filter States
  const [parentSearchQuery, setParentSearchQuery] = useState("");
  const [parentStatusFilter, setParentStatusFilter] = useState("all");

  // Student Modal State
  const [showStudentModal, setShowStudentModal] = useState(false);
  const [currentStudent, setCurrentStudent] = useState<Partial<Student> | null>(null);

  // Parent Modal State
  const [showParentModal, setShowParentModal] = useState(false);
  const [currentParent, setCurrentParent] = useState<Partial<Parent> | null>(null);
  const [parentPassword, setParentPassword] = useState("");
  const [selectedStudentIds, setSelectedStudentIds] = useState<string[]>([]);
  const [savingParent, setSavingParent] = useState(false);

  const fetchRegistryData = async () => {
    try {
      // 1. Fetch Students
      const { data: studentList } = await supabase
        .from("students")
        .select(`
          id,
          name,
          chess_rating,
          level,
          platform_id,
          parent_id,
          batch_id,
          is_deleted,
          batches ( id, name ),
          parents ( id, name, email, phone )
        `)
        .eq("is_deleted", false)
        .order("name", { ascending: true });

      setStudents((studentList as any[]) || []);

      // 2. Fetch Batches
      const { data: batchList } = await supabase
        .from("batches")
        .select("id, name")
        .order("name", { ascending: true });
      setBatches(batchList || []);

      // 3. Fetch Parents with their child students linked
      const { data: parentList } = await supabase
        .from("parents")
        .select(`
          id,
          auth_user_id,
          name,
          email,
          phone,
          students (
            id,
            name
          )
        `)
        .order("name", { ascending: true });
      
      // Note: Filter out students who are soft-deleted from the parent's children array
      const mappedParents: Parent[] = (parentList as any[] || []).map(p => ({
        ...p,
        students: p.students ? p.students.filter((s: any) => {
          const studentObj = (studentList || []).find((x: any) => x.id === s.id);
          return studentObj && !studentObj.is_deleted;
        }) : []
      }));

      setParents(mappedParents);
    } catch (err) {
      console.error("Error loading student/parent registry:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRegistryData();
  }, [supabase]);

  // Student CRUD Save
  const handleSaveStudent = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentStudent?.name || !currentStudent?.level) return;

    try {
      const payload = {
        name: currentStudent.name,
        chess_rating: currentStudent.chess_rating || 1000,
        level: currentStudent.level,
        platform_id: currentStudent.platform_id || null,
        batch_id: currentStudent.batch_id || null,
        parent_id: currentStudent.parent_id || null,
      };

      if (currentStudent.id) {
        // Edit student
        const { error } = await supabase
          .from("students")
          .update(payload)
          .eq("id", currentStudent.id);
        if (error) throw error;
      } else {
        // Register new student
        const { error } = await supabase
          .from("students")
          .insert(payload);
        if (error) throw error;
      }

      setShowStudentModal(false);
      setCurrentStudent(null);
      fetchRegistryData();
    } catch (err) {
      alert("Error saving student information");
      console.error(err);
    }
  };

  // Student Soft Delete
  const handleSoftDeleteStudent = async (id: string) => {
    if (!confirm("Are you sure you want to delete this student profile? This is a soft-delete and will hide the student from lists.")) return;
    try {
      const { error } = await supabase
        .from("students")
        .update({ is_deleted: true })
        .eq("id", id);
      if (error) throw error;
      fetchRegistryData();
    } catch (err) {
      alert("Error deleting student profile");
      console.error(err);
    }
  };

  // Parent CRUD Save
  const handleSaveParent = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentParent?.name || !currentParent?.email) {
      alert("Please fill in Name and Email.");
      return;
    }

    if (!currentParent.id && !parentPassword) {
      alert("Password is required for new parent profiles.");
      return;
    }

    setSavingParent(true);
    try {
      const res = await createOrUpdateParentAction({
        name: currentParent.name,
        email: currentParent.email,
        phone: currentParent.phone || null,
        password: parentPassword || undefined,
        studentIds: selectedStudentIds
      }, currentParent.id);

      if (!res.success) {
        throw new Error(res.error);
      }

      setShowParentModal(false);
      setCurrentParent(null);
      setParentPassword("");
      setSelectedStudentIds([]);
      fetchRegistryData();
    } catch (err: any) {
      alert("Error saving parent profile: " + err.message);
      console.error(err);
    } finally {
      setSavingParent(false);
    }
  };

  // Parent Delete
  const handleDeleteParent = async (id: string) => {
    if (!confirm("Are you sure you want to delete this parent profile? Linked students will be unassigned but NOT deleted.")) return;
    try {
      const { error } = await supabase
        .from("parents")
        .delete()
        .eq("id", id);
      if (error) throw error;
      fetchRegistryData();
    } catch (err) {
      alert("Error deleting parent profile");
      console.error(err);
    }
  };

  // Student Filters
  const filteredStudents = students.filter((student) => {
    const matchesSearch =
      student.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (student.platform_id && student.platform_id.toLowerCase().includes(searchQuery.toLowerCase()));
    const matchesLevel = levelFilter === "all" || student.level === levelFilter;
    const matchesBatch = batchFilter === "all" || student.batch_id === batchFilter;
    const matchesUnassigned = !unassignedParentFilter || !student.parent_id;

    return matchesSearch && matchesLevel && matchesBatch && matchesUnassigned;
  });

  // Parent Filters
  const filteredParents = parents.filter((parent) => {
    const matchesSearch =
      parent.name.toLowerCase().includes(parentSearchQuery.toLowerCase()) ||
      parent.email.toLowerCase().includes(parentSearchQuery.toLowerCase()) ||
      (parent.phone && parent.phone.includes(parentSearchQuery));

    const isRegistered = !!parent.auth_user_id;
    const matchesStatus =
      parentStatusFilter === "all" ||
      (parentStatusFilter === "registered" && isRegistered) ||
      (parentStatusFilter === "pre-created" && !isRegistered);

    return matchesSearch && matchesStatus;
  });

  if (loading) {
    return (
      <div className="h-full flex items-center justify-center py-20">
        <div className="text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 font-medium text-sm">Loading registry database...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-fadeIn">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">ACADEMY REGISTRY</h1>
          <p className="text-[14px] text-slate-500 mt-1">
            {activeTab === "students" 
              ? "Review student ratings, class levels, and allocate cohorts." 
              : "Manage parent directories and pre-create accounts for mobile sync."}
          </p>
        </div>
        
        {activeTab === "students" ? (
          <button
            onClick={() => {
              setCurrentStudent({
                name: "",
                chess_rating: 1000,
                level: "Beginner",
                platform_id: "",
                batch_id: batches[0]?.id || null,
                parent_id: null,
              });
              setShowStudentModal(true);
            }}
            className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
          >
            <Plus className="w-4 h-4" strokeWidth={2.5} />
            <span>Add Student</span>
          </button>
        ) : (
          <button
            onClick={() => {
              setCurrentParent({ name: "", email: "", phone: "" });
              setParentPassword("");
              setSelectedStudentIds([]);
              setShowParentModal(true);
            }}
            className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
          >
            <Plus className="w-4 h-4" strokeWidth={2.5} />
            <span>Add Parent Profile</span>
          </button>
        )}
      </div>

      {/* Tabs Selector */}
      <div className="flex border-b border-slate-200">
        <button
          onClick={() => setActiveTab("students")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "students"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <Users className="w-4.5 h-4.5" />
          <span>Students Roster</span>
        </button>
        <button
          onClick={() => setActiveTab("parents")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "parents"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <Contact className="w-4.5 h-4.5" />
          <span>Parents Directory</span>
        </button>
      </div>

      {/* ====================================================
          TAB 1: STUDENTS ROSTER
          ==================================================== */}
      {activeTab === "students" && (
        <div className="space-y-6">
          {/* Interactive Controls & Filters */}
          <div className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm space-y-4 animate-fadeIn">
            <div className="flex items-center gap-2">
              <SlidersHorizontal className="w-4 h-4 text-slate-400" />
              <h3 className="text-xs font-bold text-navy uppercase tracking-wider">Search & Filters</h3>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              {/* Text Search */}
              <div className="relative">
                <span className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Search className="w-4 h-4 text-slate-400" />
                </span>
                <input
                  type="text"
                  placeholder="Search student or platform ID..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold text-slate-800"
                />
              </div>

              {/* Level Filter */}
              <select
                value={levelFilter}
                onChange={(e) => setLevelFilter(e.target.value)}
                className="bg-slate-50 border border-slate-200 rounded-lg py-2 px-3 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
              >
                <option value="all">All Skill Levels</option>
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
              </select>

              {/* Batch Filter */}
              <select
                value={batchFilter}
                onChange={(e) => setBatchFilter(e.target.value)}
                className="bg-slate-50 border border-slate-200 rounded-lg py-2 px-3 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
              >
                <option value="all">All Batches</option>
                {batches.map((b) => (
                  <option key={b.id} value={b.id}>
                    {b.name}
                  </option>
                ))}
              </select>

              {/* Unassigned Parent Filter */}
              <label className="flex items-center gap-2.5 px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg cursor-pointer hover:bg-slate-100/50 transition-colors">
                <input
                  type="checkbox"
                  checked={unassignedParentFilter}
                  onChange={(e) => setUnassignedParentFilter(e.target.checked)}
                  className="w-3.5 h-3.5 accent-gold cursor-pointer"
                />
                <span className="text-xs font-semibold text-slate-600 select-none">Unassigned Parents only</span>
              </label>
            </div>
          </div>

          {/* Students Table */}
          <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden animate-fadeIn">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                    <th className="py-4 px-6">Student Name</th>
                    <th className="py-4 px-6 text-center">Chess Rating</th>
                    <th className="py-4 px-6">Level</th>
                    <th className="py-4 px-6">Platform ID</th>
                    <th className="py-4 px-6">Allocated Batch</th>
                    <th className="py-4 px-6">Linked Parent</th>
                    <th className="py-4 px-6 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
                  {filteredStudents.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="text-center py-12 text-slate-400 font-medium">
                        No student profiles match the filter criteria.
                      </td>
                    </tr>
                  ) : (
                    filteredStudents.map((stu) => (
                      <tr key={stu.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="py-4 px-6 font-bold text-navy flex items-center gap-2.5">
                          <div className="w-7 h-7 rounded-full bg-navy/5 text-navy flex items-center justify-center font-bold text-xs uppercase">
                            {stu.name.charAt(0)}
                          </div>
                          <span>{stu.name}</span>
                        </td>
                        <td className="py-4 px-6 text-center">
                          <span className="font-semibold text-slate-800 bg-slate-100 py-1 px-2.5 rounded-lg border border-slate-200 text-xs">
                            {stu.chess_rating}
                          </span>
                        </td>
                        <td className="py-4 px-6">
                          <span className={`px-2 py-0.5 text-[10px] font-extrabold uppercase rounded-full tracking-wider ${
                            stu.level === "Advanced" ? "bg-amber-105 text-gold" :
                            stu.level === "Intermediate" ? "bg-blue-105 text-blue-800" : "bg-slate-105 text-slate-600"
                          }`}>
                            {stu.level}
                          </span>
                        </td>
                        <td className="py-4 px-6 text-slate-505 font-mono text-xs">
                          {stu.platform_id || "—"}
                        </td>
                        <td className="py-4 px-6">
                          <span className="font-bold text-navy">
                            {stu.batches?.name || (
                              <span className="text-destructive font-semibold flex items-center gap-1">
                                <ShieldAlert className="w-3.5 h-3.5" />
                                <span>Unallocated</span>
                              </span>
                            )}
                          </span>
                        </td>
                        <td className="py-4 px-6">
                          {stu.parents ? (
                            <div>
                              <p className="font-bold text-slate-850">{stu.parents.name}</p>
                              <p className="text-[10px] text-slate-400 font-semibold">{stu.parents.email}</p>
                            </div>
                          ) : (
                            <span className="text-slate-400 flex items-center gap-1 text-[11px] font-semibold">
                              <HelpCircle className="w-3.5 h-3.5" />
                              <span>Unassigned</span>
                            </span>
                          )}
                        </td>
                        <td className="py-4 px-6 text-right">
                          <div className="flex justify-end gap-2">
                            <button
                              onClick={() => {
                                setCurrentStudent(stu);
                                setShowStudentModal(true);
                              }}
                              className="p-2 border border-slate-100 hover:border-slate-200 text-slate-500 hover:text-navy rounded-lg transition-colors"
                            >
                              <Edit2 className="w-3.5 h-3.5" />
                            </button>
                            <button
                              onClick={() => handleSoftDeleteStudent(stu.id)}
                              className="p-2 border border-rose-50 hover:bg-rose-50 text-destructive rounded-lg transition-colors"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ====================================================
          TAB 2: PARENTS DIRECTORY
          ==================================================== */}
      {activeTab === "parents" && (
        <div className="space-y-6">
          {/* Interactive Controls & Filters */}
          <div className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm space-y-4 animate-fadeIn">
            <div className="flex items-center gap-2">
              <SlidersHorizontal className="w-4 h-4 text-slate-400" />
              <h3 className="text-xs font-bold text-navy uppercase tracking-wider">Search & Filters</h3>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              {/* Text Search */}
              <div className="relative sm:col-span-2">
                <span className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Search className="w-4 h-4 text-slate-400" />
                </span>
                <input
                  type="text"
                  placeholder="Search parent by name, email or phone..."
                  value={parentSearchQuery}
                  onChange={(e) => setParentSearchQuery(e.target.value)}
                  className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold text-slate-800"
                />
              </div>

              {/* Status Filter */}
              <select
                value={parentStatusFilter}
                onChange={(e) => setParentStatusFilter(e.target.value)}
                className="bg-slate-50 border border-slate-200 rounded-lg py-2 px-3 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold"
              >
                <option value="all">All Registrations</option>
                <option value="registered">Registered on Mobile (Auth Linked)</option>
                <option value="pre-created">Pre-created (Invited)</option>
              </select>
            </div>
          </div>

          {/* Parents Table */}
          <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden animate-fadeIn">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                    <th className="py-4 px-6">Parent Name</th>
                    <th className="py-4 px-6">Email Address</th>
                    <th className="py-4 px-6">Phone Number</th>
                    <th className="py-4 px-6 text-center">Registration Status</th>
                    <th className="py-4 px-6">Linked Children</th>
                    <th className="py-4 px-6 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
                  {filteredParents.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="text-center py-12 text-slate-400 font-medium">
                        No parent records match this search filter.
                      </td>
                    </tr>
                  ) : (
                    filteredParents.map((parent) => {
                      const isLinked = !!parent.auth_user_id;

                      return (
                        <tr key={parent.id} className="hover:bg-slate-50/50 transition-colors">
                          <td className="py-4 px-6 font-bold text-navy flex items-center gap-2.5">
                            <div className="w-7 h-7 rounded-full bg-navy/5 text-navy flex items-center justify-center font-bold text-xs uppercase">
                              {parent.name.charAt(0)}
                            </div>
                            <span>{parent.name}</span>
                          </td>
                          <td className="py-4 px-6">
                            <a href={`mailto:${parent.email}`} className="flex items-center gap-1 hover:text-gold text-slate-700 font-medium">
                              <Mail className="w-3.5 h-3.5 text-slate-400" />
                              <span>{parent.email}</span>
                            </a>
                          </td>
                          <td className="py-4 px-6">
                            {parent.phone ? (
                              <a href={`tel:${parent.phone}`} className="flex items-center gap-1 hover:text-gold text-slate-700 font-medium">
                                <Phone className="w-3.5 h-3.5 text-slate-400" />
                                <span>{parent.phone}</span>
                              </a>
                            ) : (
                              <span className="text-slate-405">—</span>
                            )}
                          </td>
                          <td className="py-4 px-6 text-center">
                            <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wider ${
                              isLinked
                                ? "bg-emerald-100 text-success border border-emerald-200"
                                : "bg-slate-100 text-slate-500 border border-slate-200"
                            }`}>
                              {isLinked ? "Registered" : "Pre-Created"}
                            </span>
                          </td>
                          <td className="py-4 px-6">
                            {parent.students && parent.students.length > 0 ? (
                              <div className="flex flex-wrap gap-1">
                                {parent.students.map((child) => (
                                  <span
                                    key={child.id}
                                    className="bg-navy/5 text-navy text-[11px] font-bold py-0.5 px-2 rounded-lg border border-navy/10"
                                  >
                                    {child.name}
                                  </span>
                                ))}
                              </div>
                            ) : (
                              <span className="text-[11px] text-slate-400 font-semibold italic">No Children Linked</span>
                            )}
                          </td>
                          <td className="py-4 px-6 text-right">
                            <div className="flex justify-end gap-2">
                              <button
                                onClick={() => {
                                  setCurrentParent(parent);
                                  setParentPassword("");
                                  setSelectedStudentIds(parent.students?.map(s => s.id) || []);
                                  setShowParentModal(true);
                                }}
                                className="p-2 border border-slate-100 hover:border-slate-200 text-slate-500 hover:text-navy rounded-lg transition-colors"
                              >
                                <Edit2 className="w-3.5 h-3.5" />
                              </button>
                              <button
                                onClick={() => handleDeleteParent(parent.id)}
                                className="p-2 border border-rose-50 hover:bg-rose-50 text-destructive rounded-lg transition-colors"
                              >
                                <Trash2 className="w-3.5 h-3.5" />
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ====================================================
          MODAL: STUDENT SAVE FORM
          ==================================================== */}
      {showStudentModal && currentStudent && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">
                {currentStudent.id ? "Edit Student Profile" : "Register New Student"}
              </h3>
              <button
                onClick={() => setShowStudentModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveStudent} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Full Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Aarav Kumar"
                  value={currentStudent.name || ""}
                  onChange={(e) => setCurrentStudent({ ...currentStudent, name: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Chess Rating</label>
                  <input
                    type="number"
                    min="100"
                    max="3500"
                    placeholder="1000"
                    value={currentStudent.chess_rating || ""}
                    onChange={(e) => setCurrentStudent({ ...currentStudent, chess_rating: parseInt(e.target.value) })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium"
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Academy Level *</label>
                  <select
                    required
                    value={currentStudent.level || "Beginner"}
                    onChange={(e) => setCurrentStudent({ ...currentStudent, level: e.target.value })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                  >
                    <option value="Beginner">Beginner</option>
                    <option value="Intermediate">Intermediate</option>
                    <option value="Advanced">Advanced</option>
                  </select>
                </div>
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Platform ID (Lichess/Chess.com)</label>
                <input
                  type="text"
                  placeholder="e.g. master_tactician"
                  value={currentStudent.platform_id || ""}
                  onChange={(e) => setCurrentStudent({ ...currentStudent, platform_id: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Assign Cohort Batch</label>
                <select
                  value={currentStudent.batch_id || ""}
                  onChange={(e) => setCurrentStudent({ ...currentStudent, batch_id: e.target.value || null })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                >
                  <option value="">No Batch Allocation</option>
                  {batches.map((b) => (
                    <option key={b.id} value={b.id}>
                      {b.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Link Parent Profile</label>
                <select
                  value={currentStudent.parent_id || ""}
                  onChange={(e) => setCurrentStudent({ ...currentStudent, parent_id: e.target.value || null })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                >
                  <option value="">No Parent Profile Linked</option>
                  {parents.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} ({p.email})
                    </option>
                  ))}
                </select>
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowStudentModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150"
                >
                  Save Profile
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ====================================================
          MODAL: PARENT SAVE FORM
          ==================================================== */}
      {showParentModal && currentParent && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">
                {currentParent.id ? "Edit Parent Profile" : "Register Parent Profile"}
              </h3>
              <button
                onClick={() => setShowParentModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveParent} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Parent Full Name *</label>
                <input
                  type="text"
                  required
                  disabled={savingParent}
                  placeholder="e.g. Rajesh Kumar"
                  value={currentParent.name || ""}
                  onChange={(e) => setCurrentParent({ ...currentParent, name: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium disabled:opacity-60"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Email Address (Unique for Mobile Login) *</label>
                <input
                  type="email"
                  required
                  disabled={savingParent}
                  placeholder="e.g. rajesh@gmail.com"
                  value={currentParent.email || ""}
                  onChange={(e) => setCurrentParent({ ...currentParent, email: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-405 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium text-slate-800 disabled:opacity-60"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Contact Phone Number</label>
                <input
                  type="text"
                  disabled={savingParent}
                  placeholder="e.g. +91 9876543210"
                  value={currentParent.phone || ""}
                  onChange={(e) => setCurrentParent({ ...currentParent, phone: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-405 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium text-slate-800 disabled:opacity-60"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">
                  {currentParent.id ? "Reset Password" : "Password *"}
                </label>
                <input
                  type="password"
                  required={!currentParent.id}
                  disabled={savingParent}
                  placeholder={currentParent.id ? "Leave blank to keep current password" : "Enter account password"}
                  value={parentPassword}
                  onChange={(e) => setParentPassword(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium disabled:opacity-60"
                />
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Linked Children (Students)</label>
                <div className="max-h-[140px] overflow-y-auto border border-slate-200 rounded-lg p-2.5 bg-slate-50 space-y-1.5 scrollbar-thin">
                  {students.map((stu) => (
                    <label key={stu.id} className="flex items-center gap-2 text-xs font-semibold text-slate-700 hover:text-navy cursor-pointer">
                      <input
                        type="checkbox"
                        disabled={savingParent}
                        checked={selectedStudentIds.includes(stu.id)}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedStudentIds([...selectedStudentIds, stu.id]);
                          } else {
                            setSelectedStudentIds(selectedStudentIds.filter(id => id !== stu.id));
                          }
                        }}
                        className="w-3.5 h-3.5 accent-gold rounded cursor-pointer disabled:opacity-60"
                      />
                      <span>{stu.name}</span>
                      {stu.batches?.name && (
                        <span className="text-[10px] text-slate-400 font-normal">({stu.batches.name})</span>
                      )}
                    </label>
                  ))}
                  {students.length === 0 && (
                    <p className="text-xs text-slate-400 italic py-1">No students registered in academy yet.</p>
                  )}
                </div>
              </div>

              <div className="p-3.5 bg-slate-50 border border-slate-200 rounded-lg text-[11px] text-slate-500 leading-normal flex items-start gap-2">
                <HelpCircle className="w-5 h-5 text-gold flex-shrink-0 mt-0.5" />
                <p>
                  <strong>Admin Account Provisioning:</strong> Setting a password here automatically creates/updates their login credentials in Supabase Auth. Parents will be able to log in directly on the mobile app using this email and password.
                </p>
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  disabled={savingParent}
                  onClick={() => setShowParentModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg disabled:opacity-60"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={savingParent}
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150 active:scale-[0.98] disabled:opacity-60 flex items-center gap-1.5"
                >
                  {savingParent ? (
                    <>
                      <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>Saving...</span>
                    </>
                  ) : (
                    <span>Save Profile</span>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
