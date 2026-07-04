"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  Bell,
  Send,
  Users,
  Filter,
  CheckCircle,
  XCircle,
  Calendar,
  Clock,
  ArrowRight,
  User,
  AlertCircle,
  Link as LinkIcon,
  RefreshCw,
} from "lucide-react";

interface Parent {
  id: string;
  name: string;
  email: string;
}

interface NotificationRow {
  id: string;
  target_parent_id: string;
  title: string;
  body: string;
  type: string;
  deep_link: string;
  created_at: string;
  read_at: string | null;
  parents: {
    name: string;
  } | null;
}

const NOTIFICATION_TYPES = [
  { value: "class_reminder", label: "Class Reminder" },
  { value: "attendance_marked", label: "Attendance Marked" },
  { value: "assignment_due", label: "Assignment Due" },
  { value: "payment_due", label: "Payment Due" },
  { value: "new_material", label: "New Study Material" },
  { value: "chat_mention", label: "Chat Mention" },
];

export default function NotificationsPage() {
  const supabase = createClient();
  const [parents, setParents] = useState<Parent[]>([]);
  const [history, setHistory] = useState<NotificationRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);

  // Form State
  const [title, setTitle] = useState("");
  const [bodyText, setBodyText] = useState("");
  const [notifType, setNotifType] = useState("class_reminder");
  const [targetType, setTargetType] = useState<"all" | "specific">("all");
  const [targetParentId, setTargetParentId] = useState("");
  const [deepLink, setDeepLink] = useState("");

  // Filter & Sort State
  const [filterType, setFilterType] = useState("all");
  const [sortOrder, setSortOrder] = useState<"desc" | "asc">("desc");

  // Status/Response state
  const [statusMsg, setStatusMsg] = useState<{ type: "success" | "error"; text: string } | null>(null);

  // Fetch initial data
  const fetchData = async () => {
    try {
      // 1. Fetch parents
      const { data: parentsData } = await supabase
        .from("parents")
        .select("id, name, email")
        .order("name", { ascending: true });
      setParents(parentsData || []);

      if (parentsData && parentsData.length > 0) {
        setTargetParentId(parentsData[0].id);
      }

      // 2. Fetch Notifications history
      await fetchHistory();
    } catch (err) {
      console.error("Error loading data:", err);
    } finally {
      setLoading(false);
    }
  };

  const fetchHistory = async () => {
    const { data: historyData, error } = await supabase
      .from("notifications")
      .select(`
        id,
        target_parent_id,
        title,
        body,
        type,
        deep_link,
        created_at,
        read_at,
        parents:target_parent_id ( name )
      `)
      .order("created_at", { ascending: sortOrder === "asc" });

    if (!error && historyData) {
      setHistory(historyData as any[]);
    }
  };

  useEffect(() => {
    fetchData();

    // Live subscription for notifications
    const channel = supabase
      .channel("notifications_realtime_changes")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "notifications" },
        () => {
          fetchHistory();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase, sortOrder]);

  // Handle compose submit
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !bodyText.trim()) {
      setStatusMsg({ type: "error", text: "Please fill in title and body text." });
      return;
    }

    setSending(true);
    setStatusMsg(null);

    try {
      let targets: string[] = [];

      if (targetType === "all") {
        targets = parents.map((p) => p.id);
      } else {
        if (!targetParentId) {
          throw new Error("No parent selected");
        }
        targets = [targetParentId];
      }

      if (targets.length === 0) {
        throw new Error("No target parents available to notify.");
      }

      // Create notification payloads
      const payloads = targets.map((pId) => ({
        target_parent_id: pId,
        title: title.trim(),
        body: bodyText.trim(),
        type: notifType,
        deep_link: deepLink.trim() || null,
        is_read: false,
      }));

      // Insert notifications table row(s)
      const { data: insertedRows, error: insertError } = await supabase
        .from("notifications")
        .insert(payloads)
        .select("id");

      if (insertError) {
        throw insertError;
      }

      if (!insertedRows || insertedRows.length === 0) {
        throw new Error("Failed to insert notification records.");
      }

      const insertedIds = insertedRows.map((r) => r.id);

      // Trigger dispatch-notification API
      const apiRes = await fetch("/api/dispatch-notification", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          notificationIds: insertedIds,
        }),
      });

      const apiData = await apiRes.json();

      if (!apiRes.ok) {
        throw new Error(apiData.error || "FCM route dispatch error");
      }

      // Compute status message details
      const count = insertedIds.length;
      let mockNote = "";
      if (!apiData.configured) {
        mockNote = " (Simulated FCM dispatch - credentials not configured)";
      }

      setStatusMsg({
        type: "success",
        text: `Successfully created and dispatched ${count} notification${count > 1 ? "s" : ""}${mockNote}!`,
      });

      // Clear Form inputs
      setTitle("");
      setBodyText("");
      setDeepLink("");
      
      // Refresh list
      await fetchHistory();

    } catch (err: any) {
      console.error(err);
      setStatusMsg({ type: "error", text: err.message || "Failed to submit notifications" });
    } finally {
      setSending(false);
    }
  };

  // Filter history list
  const filteredHistory = history.filter((item) => {
    if (filterType === "all") return true;
    return item.type === filterType;
  });

  if (loading) {
    return (
      <div className="py-20 text-center space-y-4">
        <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
        <p className="text-slate-500 text-sm font-medium">Opening dispatch command center...</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-[22px] font-bold text-navy tracking-wide">PUSH NOTIFICATIONS</h1>
        <p className="text-[14px] text-slate-500 mt-1">Compose alerts, trigger mobile FCM push dispatches, and audit delivery history.</p>
      </div>

      {/* Main Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        
        {/* Left Hand: Compose Panel */}
        <div className="lg:col-span-5 bg-white p-6 rounded-[12px] border border-slate-100 shadow-sm self-start">
          <div className="flex items-center gap-2 mb-6">
            <Bell className="w-5 h-5 text-gold" />
            <h2 className="text-base font-bold text-navy uppercase tracking-wide">Compose Dispatch</h2>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            
            {/* Title Input */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Notification Title *</label>
              <input
                type="text"
                required
                placeholder="e.g. Chess Tournament Update"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium text-slate-800"
              />
            </div>

            {/* Body Input */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Message Body *</label>
              <textarea
                required
                rows={4}
                placeholder="Type the message content that will display in the mobile notification banner..."
                value={bodyText}
                onChange={(e) => setBodyText(e.target.value)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-450 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium text-slate-800"
              />
            </div>

            {/* Type & Deep Link side-by-side */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Notification Type</label>
                <select
                  value={notifType}
                  onChange={(e) => setNotifType(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700 cursor-pointer"
                >
                  {NOTIFICATION_TYPES.map((t) => (
                    <option key={t.value} value={t.value}>
                      {t.label}
                    </option>
                  ))}
                </select>
              </div>

              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Deep Link (Optional)</label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-2.5 flex items-center text-slate-400 pointer-events-none">
                    <LinkIcon className="w-3.5 h-3.5" />
                  </span>
                  <input
                    type="text"
                    placeholder="e.g. /attendance"
                    value={deepLink}
                    onChange={(e) => setDeepLink(e.target.value)}
                    className="w-full pl-8 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700"
                  />
                </div>
              </div>
            </div>

            {/* Target Select */}
            <div className="bg-slate-50 p-4 rounded-lg border border-slate-100 space-y-3">
              <span className="text-[11px] font-bold text-navy uppercase tracking-wider block">Target Parents Scope</span>
              
              <div className="flex gap-4">
                <label className="flex items-center gap-2 text-xs font-semibold text-slate-650 cursor-pointer select-none">
                  <input
                    type="radio"
                    checked={targetType === "all"}
                    onChange={() => setTargetType("all")}
                    className="w-3.5 h-3.5 accent-gold"
                  />
                  <span>All Parents ({parents.length})</span>
                </label>

                <label className="flex items-center gap-2 text-xs font-semibold text-slate-650 cursor-pointer select-none">
                  <input
                    type="radio"
                    checked={targetType === "specific"}
                    onChange={() => setTargetType("specific")}
                    className="w-3.5 h-3.5 accent-gold"
                  />
                  <span>Specific Parent</span>
                </label>
              </div>

              {targetType === "specific" && (
                <div className="pt-2">
                  <select
                    value={targetParentId}
                    onChange={(e) => setTargetParentId(e.target.value)}
                    className="w-full px-3 py-2 bg-white border border-slate-250 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-700 cursor-pointer"
                  >
                    {parents.map((p) => (
                      <option key={p.id} value={p.id}>
                        {p.name} ({p.email})
                      </option>
                    ))}
                  </select>
                </div>
              )}
            </div>

            {/* Status alerts */}
            {statusMsg && (
              <div className={`p-3 rounded-lg border flex gap-2.5 text-xs font-medium ${
                statusMsg.type === "success" 
                  ? "bg-emerald-50 border-emerald-200 text-emerald-800"
                  : "bg-rose-50 border-rose-200 text-rose-800"
              }`}>
                <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
                <span>{statusMsg.text}</span>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={sending}
              className="w-full h-[48px] bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center justify-center gap-2 shadow transition-all duration-150 active:scale-[0.98] disabled:opacity-75 disabled:pointer-events-none"
            >
              {sending ? (
                <>
                  <RefreshCw className="w-4 h-4 animate-spin" />
                  <span>Dispatching Alerts...</span>
                </>
              ) : (
                <>
                  <Send className="w-4 h-4" />
                  <span>Send Push Notification</span>
                </>
              )}
            </button>

          </form>
        </div>

        {/* Right Hand: Delivery History */}
        <div className="lg:col-span-7 bg-white p-6 rounded-[12px] border border-slate-100 shadow-sm">
          
          {/* History Header & Filters */}
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 pb-6 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <Users className="w-5 h-5 text-navy" />
              <h2 className="text-base font-bold text-navy uppercase tracking-wide">Dispatch History</h2>
            </div>

            <div className="flex items-center gap-3 w-full sm:w-auto">
              {/* Type Filter */}
              <div className="flex items-center gap-1.5 bg-slate-50 px-3 py-1.5 border border-slate-200 rounded-lg text-xs font-semibold text-slate-600">
                <Filter className="w-3.5 h-3.5 text-slate-400" />
                <span>Type:</span>
                <select
                  value={filterType}
                  onChange={(e) => setFilterType(e.target.value)}
                  className="bg-transparent border-none p-0 cursor-pointer font-bold text-navy focus:ring-0 focus:outline-none"
                >
                  <option value="all">All Types</option>
                  {NOTIFICATION_TYPES.map((t) => (
                    <option key={t.value} value={t.value}>
                      {t.label}
                    </option>
                  ))}
                </select>
              </div>

              {/* Sort Order */}
              <button
                onClick={() => setSortOrder(sortOrder === "desc" ? "asc" : "desc")}
                className="px-3 py-1.5 border border-slate-200 rounded-lg text-xs font-bold text-slate-650 hover:bg-slate-50 transition-colors"
                title="Toggle sort direction"
              >
                Sort: {sortOrder === "desc" ? "Newest First" : "Oldest First"}
              </button>
            </div>
          </div>

          {/* History Table */}
          <div className="overflow-x-auto mt-4 max-h-[500px] overflow-y-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-navy text-white text-[11px] font-bold tracking-wider uppercase border-b border-slate-700">
                  <th className="py-3 px-4">Recipient</th>
                  <th className="py-3 px-4">Title / Body</th>
                  <th className="py-3 px-4">Type</th>
                  <th className="py-3 px-4">Sent At</th>
                  <th className="py-3 px-4 text-center">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-[12.5px] font-semibold text-slate-700">
                {filteredHistory.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-12 text-center text-slate-450 font-medium">
                      No sent notifications match your filter criteria.
                    </td>
                  </tr>
                ) : (
                  filteredHistory.map((item) => {
                    const isRead = !!item.read_at;
                    const typeLabel = NOTIFICATION_TYPES.find((t) => t.value === item.type)?.label || item.type;

                    return (
                      <tr key={item.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="py-3.5 px-4 font-bold text-navy">
                          {item.parents?.name || "Unknown Parent"}
                        </td>
                        <td className="py-3.5 px-4 max-w-[200px]">
                          <p className="font-bold text-slate-800 line-clamp-1">{item.title}</p>
                          <p className="text-slate-450 font-medium line-clamp-2 text-[11px] mt-0.5">{item.body}</p>
                          {item.deep_link && (
                            <span className="inline-flex items-center gap-0.5 mt-1 px-1.5 py-0.5 rounded bg-slate-100 text-[9px] text-slate-500 font-bold">
                              <LinkIcon className="w-2.5 h-2.5" />
                              {item.deep_link}
                            </span>
                          )}
                        </td>
                        <td className="py-3.5 px-4">
                          <span className="text-[10px] font-bold text-slate-500 block uppercase tracking-wider">
                            {typeLabel}
                          </span>
                        </td>
                        <td className="py-3.5 px-4">
                          <div className="flex flex-col text-[11px] font-medium text-slate-500">
                            <span className="flex items-center gap-1">
                              <Calendar className="w-3 h-3" />
                              {new Date(item.created_at).toLocaleDateString()}
                            </span>
                            <span className="flex items-center gap-1 mt-0.5 text-slate-400">
                              <Clock className="w-3 h-3" />
                              {new Date(item.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                            </span>
                          </div>
                        </td>
                        <td className="py-3.5 px-4 text-center">
                          <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[9px] font-extrabold uppercase tracking-wider ${
                            isRead ? "bg-emerald-100 text-success" : "bg-slate-150 text-slate-500"
                          }`}>
                            {isRead ? (
                              <>
                                <CheckCircle className="w-2.5 h-2.5" />
                                <span>Read</span>
                              </>
                            ) : (
                              <>
                                <Clock className="w-2.5 h-2.5" />
                                <span>Unread</span>
                              </>
                            )}
                          </span>
                          {isRead && item.read_at && (
                            <span className="block text-[8px] text-slate-400 font-medium mt-0.5">
                              {new Date(item.read_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                            </span>
                          )}
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
    </div>
  );
}
