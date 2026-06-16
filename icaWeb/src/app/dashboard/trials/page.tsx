"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  UserCheck,
  Search,
  ListFilter,
  Phone,
  Mail,
  Calendar,
  Layers,
  ArrowUpDown,
  CheckSquare,
  Clock,
} from "lucide-react";

interface Batch {
  id: string;
  name: string;
}

interface TrialRequest {
  id: string;
  name: string;
  contact_phone: string | null;
  contact_email: string | null;
  preferred_batch_id: string | null;
  status: "new" | "contacted" | "scheduled" | "closed";
  created_at: string;
  batches: Batch | null;
}

export default function TrialRequestsPage() {
  const supabase = createClient();
  const [trials, setTrials] = useState<TrialRequest[]>([]);
  const [loading, setLoading] = useState(true);

  // Search & Filter State
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [sortOrder, setSortOrder] = useState<"desc" | "asc">("desc");

  const fetchTrialsData = async () => {
    setLoading(true);
    try {
      const { data } = await supabase
        .from("trial_requests")
        .select(`
          id,
          name,
          contact_phone,
          contact_email,
          preferred_batch_id,
          status,
          created_at,
          batches ( id, name )
        `)
        .order("created_at", { ascending: sortOrder === "asc" });

      setTrials((data as any[]) || []);
    } catch (err) {
      console.error("Error loading trial requests:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTrialsData();
  }, [supabase, sortOrder]);

  // Update Status Handler
  const handleUpdateStatus = async (id: string, newStatus: string) => {
    try {
      const { error } = await supabase
        .from("trial_requests")
        .update({ status: newStatus })
        .eq("id", id);
      if (error) throw error;

      // Update local state directly for speedy feedback
      setTrials((prev) =>
        prev.map((t) => (t.id === id ? { ...t, status: newStatus as any } : t))
      );
    } catch (err) {
      alert("Failed to update status");
      console.error(err);
    }
  };

  // Toggle Sorting Chronology
  const toggleSort = () => {
    setSortOrder(prev => prev === "desc" ? "asc" : "desc");
  };

  // Filter Logic
  const filteredTrials = trials.filter((trial) => {
    const matchesSearch =
      trial.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (trial.contact_email && trial.contact_email.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (trial.contact_phone && trial.contact_phone.includes(searchQuery));

    const matchesStatus = statusFilter === "all" || trial.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  if (loading && trials.length === 0) {
    return (
      <div className="h-full flex items-center justify-center py-20">
        <div className="text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 font-medium text-sm">Opening leads dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-[22px] font-bold text-navy tracking-wide">TRIAL REQUEST LEADS</h1>
        <p className="text-[14px] text-slate-500 mt-1">Review admissions requests and update contact pipelines.</p>
      </div>

      {/* Controls & Filter bar */}
      <div className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm flex flex-col md:flex-row gap-4 items-center justify-between">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 w-full md:w-auto md:flex-1 md:max-w-2xl">
          {/* Text Search */}
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="w-4 h-4 text-slate-400" />
            </span>
            <input
              type="text"
              placeholder="Search by name, email or phone..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-medium placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold text-slate-800"
            />
          </div>

          {/* Status Filter */}
          <div className="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-lg py-1 px-3">
            <ListFilter className="w-3.5 h-3.5 text-slate-450" />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="bg-transparent border-none py-1 px-1 text-xs font-semibold text-slate-700 focus:outline-none cursor-pointer"
            >
              <option value="all">All Pipelines</option>
              <option value="new">new Lead</option>
              <option value="contacted">contacted</option>
              <option value="scheduled">scheduled Trial</option>
              <option value="closed">closed</option>
            </select>
          </div>
        </div>

        {/* Sort Trigger */}
        <button
          onClick={toggleSort}
          className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 hover:border-gold hover:text-gold text-slate-650 text-xs font-semibold rounded-lg shadow-sm transition-colors w-full sm:w-auto justify-center"
        >
          <ArrowUpDown className="w-3.5 h-3.5" />
          <span>Sort: {sortOrder === "desc" ? "Newest First" : "Oldest First"}</span>
        </button>
      </div>

      {/* Leads table grid */}
      <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm overflow-hidden animate-fadeIn">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-navy text-white text-[12px] font-bold tracking-wider uppercase border-b border-slate-700">
                <th className="py-4 px-6">Prospect Name</th>
                <th className="py-4 px-6">Phone Number</th>
                <th className="py-4 px-6">Email Address</th>
                <th className="py-4 px-6">Preferred Cohort</th>
                <th className="py-4 px-6">Inquiry Date</th>
                <th className="py-4 px-6 text-center">Pipeline Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-[13px] font-semibold text-slate-700">
              {filteredTrials.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-slate-455 font-medium">
                    No lead inquiries found.
                  </td>
                </tr>
              ) : (
                filteredTrials.map((lead) => (
                  <tr key={lead.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="py-4 px-6 font-bold text-navy flex items-center gap-2.5">
                      <div className="w-7 h-7 bg-navy/5 text-navy rounded-full flex items-center justify-center font-bold text-xs uppercase">
                        {lead.name.charAt(0)}
                      </div>
                      <span>{lead.name}</span>
                    </td>
                    <td className="py-4 px-6">
                      {lead.contact_phone ? (
                        <a href={`tel:${lead.contact_phone}`} className="flex items-center gap-1.5 hover:text-gold text-slate-650">
                          <Phone className="w-3.5 h-3.5 text-slate-400" />
                          <span>{lead.contact_phone}</span>
                        </a>
                      ) : (
                        <span className="text-slate-400">—</span>
                      )}
                    </td>
                    <td className="py-4 px-6">
                      {lead.contact_email ? (
                        <a href={`mailto:${lead.contact_email}`} className="flex items-center gap-1.5 hover:text-gold text-slate-650">
                          <Mail className="w-3.5 h-3.5 text-slate-400" />
                          <span>{lead.contact_email}</span>
                        </a>
                      ) : (
                        <span className="text-slate-400">—</span>
                      )}
                    </td>
                    <td className="py-4 px-6 font-bold text-navy">
                      {lead.batches?.name || (
                        <span className="text-slate-400 font-semibold flex items-center gap-1 text-[11px]">
                          <Layers className="w-3.5 h-3.5" />
                          <span>Not Specified</span>
                        </span>
                      )}
                    </td>
                    <td className="py-4 px-6 text-slate-500 font-mono text-xs">
                      {new Date(lead.created_at).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit" })}
                    </td>
                    <td className="py-4 px-6 text-center">
                      <select
                        value={lead.status}
                        onChange={(e) => handleUpdateStatus(lead.id, e.target.value)}
                        className={`font-extrabold text-[10px] uppercase rounded-full tracking-wider py-1 px-3 border focus:outline-none cursor-pointer text-center ${
                          lead.status === "new" ? "bg-blue-50 text-blue-700 border-blue-200" :
                          lead.status === "contacted" ? "bg-amber-50 text-[#8F6516] border-amber-200" :
                          lead.status === "scheduled" ? "bg-emerald-50 text-success border-emerald-200" :
                          "bg-slate-100 text-slate-600 border-slate-300"
                        }`}
                      >
                        <option value="new">new</option>
                        <option value="contacted">contacted</option>
                        <option value="scheduled">scheduled</option>
                        <option value="closed">closed</option>
                      </select>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
