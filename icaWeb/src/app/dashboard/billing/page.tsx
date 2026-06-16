"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  CreditCard,
  Plus,
  Edit2,
  Trash2,
  ListFilter,
  Layers,
  Calendar,
  AlertTriangle,
  CheckCircle2,
  XCircle,
  Clock,
} from "lucide-react";

interface Plan {
  id: string;
  name: string;
  price: number;
  duration_type: "monthly" | "quarterly" | "annual";
  is_active: boolean;
}

interface Student {
  id: string;
  name: string;
}

interface Subscription {
  id: string;
  student_id: string;
  plan_id: string;
  status: "active" | "overdue" | "expired";
  start_date: string;
  end_date: string;
  students: Student | null;
  plans: Plan | null;
}

export default function BillingPage() {
  const supabase = createClient();
  const [plans, setPlans] = useState<Plan[]>([]);
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [students, setStudents] = useState<Student[]>([]);
  const [activeTab, setActiveTab] = useState<"subscriptions" | "plans">("subscriptions");
  const [loading, setLoading] = useState(true);

  // Modal State
  const [showPlanModal, setShowPlanModal] = useState(false);
  const [currentPlan, setCurrentPlan] = useState<Partial<Plan> | null>(null);

  const [showSubModal, setShowSubModal] = useState(false);
  const [currentSub, setCurrentSub] = useState<Partial<Subscription> | null>(null);

  // Filter State
  const [statusFilter, setStatusFilter] = useState<string>("all");

  const fetchBillingData = async () => {
    try {
      // 1. Fetch Plans
      const { data: plansData } = await supabase
        .from("plans")
        .select("*")
        .order("created_at", { ascending: false });
      setPlans(plansData || []);

      // 2. Fetch Subscriptions joined with Student & Plan info
      const { data: subsData } = await supabase
        .from("subscriptions")
        .select(`
          id,
          student_id,
          plan_id,
          status,
          start_date,
          end_date,
          students ( id, name ),
          plans ( id, name, price )
        `)
        .order("end_date", { ascending: true });
      setSubscriptions((subsData as any[]) || []);

      // 3. Fetch Students (for linking new subscriptions)
      const { data: studentsData } = await supabase
        .from("students")
        .select("id, name")
        .eq("is_deleted", false)
        .order("name", { ascending: true });
      setStudents(studentsData || []);
    } catch (err) {
      console.error("Error loading billing details:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBillingData();
  }, [supabase]);

  // Plan CRUD Handlers
  const handleSavePlan = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentPlan?.name || !currentPlan?.price || !currentPlan?.duration_type) return;

    try {
      const payload = {
        name: currentPlan.name,
        price: currentPlan.price,
        duration_type: currentPlan.duration_type,
        is_active: currentPlan.is_active !== undefined ? currentPlan.is_active : true,
      };

      if (currentPlan.id) {
        const { error } = await supabase.from("plans").update(payload).eq("id", currentPlan.id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from("plans").insert(payload);
        if (error) throw error;
      }

      setShowPlanModal(false);
      setCurrentPlan(null);
      fetchBillingData();
    } catch (err) {
      alert("Error saving pricing plan");
      console.error(err);
    }
  };

  const handleDeletePlan = async (id: string) => {
    if (!confirm("Are you sure you want to delete this billing plan?")) return;
    try {
      const { error } = await supabase.from("plans").delete().eq("id", id);
      if (error) throw error;
      fetchBillingData();
    } catch (err) {
      alert("Failed to delete plan. Check if active subscriptions depend on it.");
      console.error(err);
    }
  };

  // Subscription CRUD Handlers
  const handleSaveSub = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentSub?.student_id || !currentSub?.plan_id || !currentSub?.start_date || !currentSub?.end_date) {
      alert("Please fill out all required fields.");
      return;
    }

    try {
      const payload = {
        student_id: currentSub.student_id,
        plan_id: currentSub.plan_id,
        status: currentSub.status || "active",
        start_date: currentSub.start_date,
        end_date: currentSub.end_date,
      };

      if (currentSub.id) {
        const { error } = await supabase.from("subscriptions").update(payload).eq("id", currentSub.id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from("subscriptions").insert(payload);
        if (error) throw error;
      }

      setShowSubModal(false);
      setCurrentSub(null);
      fetchBillingData();
    } catch (err) {
      alert("Error saving subscription record");
      console.error(err);
    }
  };

  const handleDeleteSub = async (id: string) => {
    if (!confirm("Are you sure you want to cancel/delete this subscription?")) return;
    try {
      const { error } = await supabase.from("subscriptions").delete().eq("id", id);
      if (error) throw error;
      fetchBillingData();
    } catch (err) {
      alert("Failed to remove subscription.");
      console.error(err);
    }
  };

  // Filtering Logic
  const filteredSubs = subscriptions.filter((sub) => {
    if (statusFilter === "all") return true;
    return sub.status === statusFilter;
  });

  if (loading) {
    return (
      <div className="h-full flex items-center justify-center py-20">
        <div className="text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 font-medium text-sm">Loading billing database...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">BILLING & SUBSCRIPTIONS</h1>
          <p className="text-[14px] text-slate-500 mt-1">Configure pricing packages and audit student payment statuses.</p>
        </div>

        <div>
          {activeTab === "subscriptions" ? (
            <button
              onClick={() => {
                setCurrentSub({
                  student_id: students[0]?.id || "",
                  plan_id: plans[0]?.id || "",
                  start_date: new Date().toLocaleDateString("en-CA"),
                  end_date: new Date(Date.now() + 30 * 24 * 65 * 60000).toLocaleDateString("en-CA"), // ~30 days later
                  status: "active",
                });
                setShowSubModal(true);
              }}
              className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
            >
              <Plus className="w-4 h-4" strokeWidth={2.5} />
              <span>Add Subscription</span>
            </button>
          ) : (
            <button
              onClick={() => {
                setCurrentPlan({ name: "", price: 2000, duration_type: "monthly", is_active: true });
                setShowPlanModal(true);
              }}
              className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
            >
              <Plus className="w-4 h-4" strokeWidth={2.5} />
              <span>Create Plan</span>
            </button>
          )}
        </div>
      </div>

      {/* Tabs Selector */}
      <div className="flex border-b border-slate-200">
        <button
          onClick={() => setActiveTab("subscriptions")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "subscriptions"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <CreditCard className="w-4.5 h-4.5" />
          <span>Subscriptions Roster</span>
        </button>
        <button
          onClick={() => setActiveTab("plans")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "plans"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <Layers className="w-4.5 h-4.5" />
          <span>Membership Plans</span>
        </button>
      </div>

      {/* TAB 1: SUBSCRIPTIONS */}
      {activeTab === "subscriptions" && (
        <div className="space-y-6">
          {/* Status Filter */}
          <div className="bg-white p-4 rounded-[12px] border border-slate-100 shadow-sm flex items-center gap-3">
            <ListFilter className="w-4 h-4 text-slate-400" />
            <span className="text-[13px] font-semibold text-navy uppercase tracking-wider">Filter Status:</span>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="bg-slate-50 border border-slate-200 rounded-lg py-1.5 px-3 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold cursor-pointer"
            >
              <option value="all">All Subscriptions</option>
              <option value="active">Active only</option>
              <option value="overdue">Overdue only</option>
              <option value="expired">Expired only</option>
            </select>
          </div>

          {/* Subscriptions Table */}
          <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden animate-fadeIn">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                    <th className="py-4 px-6">Student Name</th>
                    <th className="py-4 px-6">Assigned Plan</th>
                    <th className="py-4 px-6 text-center">Amount</th>
                    <th className="py-4 px-6">Validity Dates</th>
                    <th className="py-4 px-6 text-center">Status</th>
                    <th className="py-4 px-6 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
                  {filteredSubs.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="text-center py-12 text-slate-450 font-medium">
                        No subscription records match this filter.
                      </td>
                    </tr>
                  ) : (
                    filteredSubs.map((sub) => {
                      const isAlert = sub.status === "overdue" || sub.status === "expired";

                      return (
                        <tr key={sub.id} className={`hover:bg-slate-50/50 transition-colors ${
                          isAlert ? "bg-rose-50/20" : ""
                        }`}>
                          <td className="py-4 px-6 font-bold text-navy">
                            {sub.students?.name || "Deleted Student"}
                          </td>
                          <td className="py-4 px-6 text-slate-700">
                            {sub.plans?.name || "Custom Plan"}
                          </td>
                          <td className="py-4 px-6 text-center font-bold text-slate-800">
                            ₹{sub.plans?.price ? sub.plans.price.toLocaleString("en-IN") : "0"}
                          </td>
                          <td className="py-4 px-6">
                            <div className="flex items-center gap-1.5 text-xs text-slate-600 font-medium">
                              <Calendar className="w-3.5 h-3.5 text-slate-400" />
                              <span>{sub.start_date}</span>
                              <span className="text-slate-400">to</span>
                              <span>{sub.end_date}</span>
                            </div>
                          </td>
                          <td className="py-4 px-6 text-center">
                            <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wider ${
                              sub.status === "active"
                                ? "bg-emerald-100 text-success"
                                : "bg-destructive text-white shadow-sm" // STRICT BRANDING: overdue/expired highlighted in Alert Red
                            }`}>
                              {sub.status === "overdue" && <AlertTriangle className="w-3 h-3" />}
                              {sub.status === "expired" && <XCircle className="w-3 h-3" />}
                              {sub.status === "active" && <CheckCircle2 className="w-3 h-3" />}
                              <span>{sub.status}</span>
                            </span>
                          </td>
                          <td className="py-4 px-6 text-right">
                            <div className="flex justify-end gap-2">
                              <button
                                onClick={() => {
                                  setCurrentSub(sub);
                                  setShowSubModal(true);
                                }}
                                className="p-2 border border-slate-100 hover:border-slate-200 text-slate-500 hover:text-navy rounded-lg transition-colors"
                              >
                                <Edit2 className="w-3.5 h-3.5" />
                              </button>
                              <button
                                onClick={() => handleDeleteSub(sub.id)}
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

      {/* TAB 2: PLANS */}
      {activeTab === "plans" && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-fadeIn">
          {plans.length === 0 ? (
            <div className="col-span-full bg-white rounded-[12px] p-12 text-center border border-slate-100 shadow-sm">
              <Layers className="w-12 h-12 text-slate-300 mx-auto mb-3" />
              <p className="text-sm font-semibold text-navy">No membership plans declared.</p>
              <button
                onClick={() => {
                  setCurrentPlan({ name: "", price: 2000, duration_type: "monthly", is_active: true });
                  setShowPlanModal(true);
                }}
                className="text-gold text-xs font-semibold hover:underline mt-1"
              >
                Create a membership tier
              </button>
            </div>
          ) : (
            plans.map((p) => (
              <div
                key={p.id}
                className={`bg-white rounded-[12px] border p-6 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between ${
                  !p.is_active ? "border-slate-200 bg-slate-50/50 opacity-75" : "border-slate-100"
                }`}
              >
                <div>
                  <div className="flex justify-between items-start gap-2">
                    <h3 className="font-bold text-[18px] text-navy leading-tight">{p.name}</h3>
                    <span className={`px-2 py-0.5 text-[9px] font-extrabold uppercase rounded-full tracking-wider ${
                      p.is_active ? "bg-emerald-100 text-success" : "bg-slate-200 text-slate-600"
                    }`}>
                      {p.is_active ? "Active" : "Archived"}
                    </span>
                  </div>

                  {/* Price display */}
                  <div className="mt-5 flex items-baseline gap-1">
                    <span className="text-3xl font-extrabold text-navy">₹{p.price.toLocaleString("en-IN")}</span>
                    <span className="text-slate-400 text-xs font-semibold">/ {p.duration_type}</span>
                  </div>

                  <div className="mt-4 bg-slate-50 p-3 rounded-lg border border-slate-100 flex items-center gap-2 text-[12px] font-semibold text-slate-600">
                    <Clock className="w-4 h-4 text-gold flex-shrink-0" />
                    <span>Validity duration: {p.duration_type.toUpperCase()}</span>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-50 flex justify-end gap-2">
                  <button
                    onClick={() => {
                      setCurrentPlan(p);
                      setShowPlanModal(true);
                    }}
                    className="p-2 border border-slate-100 hover:border-slate-200 text-slate-500 hover:text-navy rounded-lg transition-colors"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleDeletePlan(p.id)}
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
          MODAL: PLAN SAVE FORM
          ==================================================== */}
      {showPlanModal && currentPlan && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">
                {currentPlan.id ? "Edit Membership Plan" : "Create Membership Plan"}
              </h3>
              <button
                onClick={() => setShowPlanModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSavePlan} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Plan Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Monthly Standard, Quarterly Pro"
                  value={currentPlan.name || ""}
                  onChange={(e) => setCurrentPlan({ ...currentPlan, name: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium text-slate-800"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Price (₹) *</label>
                  <input
                    type="number"
                    required
                    min="1"
                    placeholder="2000"
                    value={currentPlan.price || ""}
                    onChange={(e) => setCurrentPlan({ ...currentPlan, price: parseFloat(e.target.value) })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-800"
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Duration *</label>
                  <select
                    required
                    value={currentPlan.duration_type || "monthly"}
                    onChange={(e) => setCurrentPlan({ ...currentPlan, duration_type: e.target.value as any })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                  >
                    <option value="monthly">Monthly</option>
                    <option value="quarterly">Quarterly</option>
                    <option value="annual">Annual</option>
                  </select>
                </div>
              </div>

              <div className="pt-2">
                <label className="flex items-center gap-2.5 px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg cursor-pointer hover:bg-slate-100/50 transition-colors">
                  <input
                    type="checkbox"
                    checked={currentPlan.is_active !== undefined ? currentPlan.is_active : true}
                    onChange={(e) => setCurrentPlan({ ...currentPlan, is_active: e.target.checked })}
                    className="w-3.5 h-3.5 accent-gold cursor-pointer"
                  />
                  <span className="text-xs font-semibold text-slate-600 select-none">Active (Show as purchasable)</span>
                </label>
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowPlanModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150"
                >
                  Save Package
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ====================================================
          MODAL: SUBSCRIPTION SAVE FORM
          ==================================================== */}
      {showSubModal && currentSub && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">
                {currentSub.id ? "Edit Subscription Record" : "Add Student Subscription"}
              </h3>
              <button
                onClick={() => setShowSubModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveSub} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Target Student *</label>
                <select
                  required
                  disabled={!!currentSub.id}
                  value={currentSub.student_id || ""}
                  onChange={(e) => setCurrentSub({ ...currentSub, student_id: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700 disabled:opacity-75 disabled:pointer-events-none"
                >
                  <option value="" disabled>Select Student</option>
                  {students.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Choose Plan *</label>
                <select
                  required
                  value={currentSub.plan_id || ""}
                  onChange={(e) => setCurrentSub({ ...currentSub, plan_id: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                >
                  <option value="" disabled>Select Plan</option>
                  {plans.filter(p => p.is_active || p.id === currentSub.plan_id).map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} (₹{p.price})
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Start Date *</label>
                  <input
                    type="date"
                    required
                    value={currentSub.start_date || ""}
                    onChange={(e) => setCurrentSub({ ...currentSub, start_date: e.target.value })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-750"
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">End Date *</label>
                  <input
                    type="date"
                    required
                    value={currentSub.end_date || ""}
                    onChange={(e) => setCurrentSub({ ...currentSub, end_date: e.target.value })}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-750"
                  />
                </div>
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Payment Status *</label>
                <select
                  required
                  value={currentSub.status || "active"}
                  onChange={(e) => setCurrentSub({ ...currentSub, status: e.target.value as any })}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                >
                  <option value="active">Active (Paid)</option>
                  <option value="overdue">Overdue (Unpaid / Alert)</option>
                  <option value="expired">Expired (Unpaid / Alert)</option>
                </select>
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowSubModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150"
                >
                  Confirm Subscription
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
