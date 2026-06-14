"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  Users,
  Calendar,
  UserCheck,
  CreditCard,
  Wifi,
  WifiOff,
  Activity,
  ArrowRight,
  RefreshCw,
  Clock,
} from "lucide-react";
import Link from "next/link";

interface DashboardStats {
  activeStudents: number;
  classesToday: number;
  pendingTrials: number;
  activeSubscriptions: number;
}

interface RealtimeEvent {
  event: "INSERT" | "UPDATE" | "DELETE" | null;
  timestamp: string | null;
  recordId: string | null;
  details: string | null;
}

interface ScheduleWithBatch {
  id: string;
  class_date: string;
  start_time: string;
  end_time: string;
  status: string;
  batches: {
    name: string;
    default_timing: string;
  } | null;
}

export default function DashboardPage() {
  const supabase = createClient();
  const [stats, setStats] = useState<DashboardStats>({
    activeStudents: 0,
    classesToday: 0,
    pendingTrials: 0,
    activeSubscriptions: 0,
  });
  const [loading, setLoading] = useState(true);
  const [realtimeConnected, setRealtimeConnected] = useState(false);
  const [latestChange, setLatestChange] = useState<RealtimeEvent>({
    event: null,
    timestamp: null,
    recordId: null,
    details: null,
  });
  const [todayClasses, setTodayClasses] = useState<ScheduleWithBatch[]>([]);

  // Function to fetch database counts and today's schedule
  const fetchDashboardData = async () => {
    try {
      const todayStr = new Date().toLocaleDateString("en-CA"); // YYYY-MM-DD

      // 1. Total Active Students
      const { count: studentCount } = await supabase
        .from("students")
        .select("*", { count: "exact", head: true })
        .eq("is_deleted", false);

      // 2. Classes Today
      const { count: classCount } = await supabase
        .from("schedules")
        .select("*", { count: "exact", head: true })
        .eq("class_date", todayStr);

      // 3. Pending Trials
      const { count: trialCount } = await supabase
        .from("trial_requests")
        .select("*", { count: "exact", head: true })
        .eq("status", "new");

      // 4. Active Subscriptions
      const { count: subCount } = await supabase
        .from("subscriptions")
        .select("*", { count: "exact", head: true })
        .eq("status", "active");

      setStats({
        activeStudents: studentCount || 0,
        classesToday: classCount || 0,
        pendingTrials: trialCount || 0,
        activeSubscriptions: subCount || 0,
      });

      // Fetch today's schedule instances
      const { data: schedulesData } = await supabase
        .from("schedules")
        .select(`
          id,
          class_date,
          start_time,
          end_time,
          status,
          batches (
            name,
            default_timing
          )
        `)
        .eq("class_date", todayStr)
        .order("start_time", { ascending: true });

      setTodayClasses((schedulesData as any[]) || []);
    } catch (err) {
      console.error("Error fetching dashboard statistics:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();

    // Set up Supabase Realtime channel subscription on 'schedules'
    const channel = supabase
      .channel("dashboard_schedules_realtime")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "schedules" },
        (payload) => {
          const eventType = payload.eventType;
          const targetRow = (payload.new && Object.keys(payload.new).length > 0 ? payload.new : payload.old) as any;
          
          setLatestChange({
            event: eventType as any,
            timestamp: new Date().toLocaleTimeString(),
            recordId: targetRow?.id || "N/A",
            details: `Batch: ${targetRow?.batch_id || "N/A"} | Date: ${targetRow?.class_date || "N/A"} | Status: ${targetRow?.status || "N/A"}`,
          });

          // Reload data to reflect live inserts/deletes/updates
          fetchDashboardData();
        }
      );

    channel.subscribe((status) => {
      if (status === "SUBSCRIBED") {
        setRealtimeConnected(true);
      } else {
        setRealtimeConnected(false);
      }
    });

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  // Loading Skeleton State
  if (loading) {
    return (
      <div className="space-y-8 animate-pulse">
        <div className="flex justify-between items-center">
          <div>
            <div className="h-7 w-48 bg-slate-200 rounded"></div>
            <div className="h-4 w-64 bg-slate-200 rounded mt-2"></div>
          </div>
          <div className="h-10 w-24 bg-slate-200 rounded-lg"></div>
        </div>

        {/* Stats Grid Skeleton */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-28 bg-white rounded-[12px] shadow-sm border border-slate-100 p-6"></div>
          ))}
        </div>

        {/* Layout Split Skeleton */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div className="h-80 bg-white rounded-[12px] shadow-sm p-6"></div>
          <div className="h-80 bg-white rounded-[12px] shadow-sm p-6"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header section */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">DASHBOARD OVERVIEW</h1>
          <p className="text-[14px] text-slate-500 mt-1">Live metrics and real-time synchronization stats.</p>
        </div>
        <button
          onClick={() => {
            setLoading(true);
            fetchDashboardData();
          }}
          className="flex items-center gap-2 px-4 py-2 border border-slate-200 hover:border-gold hover:text-gold text-slate-600 bg-white text-xs font-semibold rounded-lg shadow-sm transition-colors duration-150"
        >
          <RefreshCw className="w-3.5 h-3.5" />
          <span>Refresh Data</span>
        </button>
      </div>

      {/* Overview Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Total Active Students */}
        <div className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 group hover:-translate-y-0.5">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-[12px] font-semibold text-slate-400 uppercase tracking-wider">Active Students</p>
              <h3 className="text-3xl font-bold text-navy mt-2 group-hover:text-gold transition-colors">{stats.activeStudents}</h3>
            </div>
            <div className="p-3 bg-navy/5 text-navy rounded-lg group-hover:bg-gold/10 group-hover:text-gold transition-colors">
              <Users className="w-5 h-5" strokeWidth={1.5} />
            </div>
          </div>
          <div className="mt-4 pt-4 border-t border-slate-50 flex items-center text-[12px] text-slate-500">
            <Link href="/dashboard/students" className="hover:text-gold font-medium flex items-center gap-1">
              <span>Manage student database</span>
              <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
        </div>

        {/* Classes Scheduled Today */}
        <div className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 group hover:-translate-y-0.5">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-[12px] font-semibold text-slate-400 uppercase tracking-wider">Classes Today</p>
              <h3 className="text-3xl font-bold text-navy mt-2 group-hover:text-gold transition-colors">{stats.classesToday}</h3>
            </div>
            <div className="p-3 bg-navy/5 text-navy rounded-lg group-hover:bg-gold/10 group-hover:text-gold transition-colors">
              <Calendar className="w-5 h-5" strokeWidth={1.5} />
            </div>
          </div>
          <div className="mt-4 pt-4 border-t border-slate-50 flex items-center text-[12px] text-slate-500">
            <Link href="/dashboard/batches" className="hover:text-gold font-medium flex items-center gap-1">
              <span>View full calendar</span>
              <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
        </div>

        {/* Pending Trial Requests */}
        <div className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 group hover:-translate-y-0.5">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-[12px] font-semibold text-slate-400 uppercase tracking-wider">Pending Trials</p>
              <h3 className="text-3xl font-bold text-navy mt-2 group-hover:text-gold transition-colors">{stats.pendingTrials}</h3>
            </div>
            <div className="p-3 bg-navy/5 text-navy rounded-lg group-hover:bg-gold/10 group-hover:text-gold transition-colors">
              <UserCheck className="w-5 h-5" strokeWidth={1.5} />
            </div>
          </div>
          <div className="mt-4 pt-4 border-t border-slate-50 flex items-center text-[12px] text-slate-500">
            <Link href="/dashboard/trials" className="hover:text-gold font-medium flex items-center gap-1">
              <span>Review new leads</span>
              <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
        </div>

        {/* Active Subscriptions */}
        <div className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 group hover:-translate-y-0.5">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-[12px] font-semibold text-slate-400 uppercase tracking-wider">Active Plans</p>
              <h3 className="text-3xl font-bold text-navy mt-2 group-hover:text-gold transition-colors">{stats.activeSubscriptions}</h3>
            </div>
            <div className="p-3 bg-navy/5 text-navy rounded-lg group-hover:bg-gold/10 group-hover:text-gold transition-colors">
              <CreditCard className="w-5 h-5" strokeWidth={1.5} />
            </div>
          </div>
          <div className="mt-4 pt-4 border-t border-slate-50 flex items-center text-[12px] text-slate-500">
            <Link href="/dashboard/billing" className="hover:text-gold font-medium flex items-center gap-1">
              <span>View sub rosters</span>
              <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
        </div>
      </div>

      {/* Realtime Widget & Today's Schedule columns */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        
        {/* Realtime Sync Auditor Widget */}
        <div className="lg:col-span-5 bg-navy text-white rounded-[12px] shadow-sm p-6 border border-slate-800 flex flex-col justify-between">
          <div>
            <div className="flex justify-between items-start mb-6">
              <div>
                <h3 className="text-[18px] font-semibold text-offwhite flex items-center gap-2">
                  <Activity className="w-4.5 h-4.5 text-gold animate-pulse" />
                  <span>Realtime Sync Auditor</span>
                </h3>
                <p className="text-[12px] text-slate-300 mt-1">Proof-of-concept feed for Supabase Realtime schedule sync.</p>
              </div>

              {/* Live Connection Badge */}
              <div className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider flex items-center gap-1.5 shadow-inner ${
                realtimeConnected ? "bg-emerald-950 text-emerald-300 border border-emerald-800" : "bg-rose-950 text-rose-300 border border-rose-800"
              }`}>
                {realtimeConnected ? (
                  <>
                    <Wifi className="w-3.5 h-3.5 animate-bounce" />
                    <span>Live Connected</span>
                  </>
                ) : (
                  <>
                    <WifiOff className="w-3.5 h-3.5" />
                    <span>Disconnected</span>
                  </>
                )}
              </div>
            </div>

            {/* Auditor Details Screen */}
            <div className="bg-slate-900 border border-slate-800 rounded-lg p-5 font-mono text-xs space-y-4 shadow-inner">
              <div className="flex justify-between pb-2 border-b border-slate-800">
                <span className="text-slate-400">Target Channel:</span>
                <span className="text-gold">public:schedules</span>
              </div>

              <div className="flex justify-between pb-2 border-b border-slate-800">
                <span className="text-slate-400">Broadcast Event:</span>
                <span className={`font-bold ${
                  latestChange.event === "INSERT" ? "text-emerald-400" :
                  latestChange.event === "UPDATE" ? "text-cyan-400" :
                  latestChange.event === "DELETE" ? "text-rose-400" : "text-slate-500"
                }`}>
                  {latestChange.event || "AWAITING BROADCAST..."}
                </span>
              </div>

              <div className="flex justify-between pb-2 border-b border-slate-800">
                <span className="text-slate-400">Change Clock:</span>
                <span className="text-slate-300">{latestChange.timestamp || "--:--:--"}</span>
              </div>

              <div className="flex justify-between pb-2 border-b border-slate-800">
                <span className="text-slate-400">Record UUID:</span>
                <span className="text-slate-300 truncate max-w-[160px]" title={latestChange.recordId || ""}>
                  {latestChange.recordId || "null"}
                </span>
              </div>

              <div className="pt-2">
                <span className="text-slate-400 block mb-1">Payload Context:</span>
                <p className="text-slate-300 text-[11px] leading-relaxed break-words bg-slate-950 p-2.5 rounded border border-slate-850 max-h-[80px] overflow-y-auto">
                  {latestChange.details || "Ready & listening. Create or edit a class schedule to trigger realtime sync notification."}
                </p>
              </div>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-800 flex items-center justify-between text-[11px] text-slate-400 font-medium">
            <span>Client ID: WebPanel-Admin</span>
            <span className="text-slate-300">Supabase JS client v2.43</span>
          </div>
        </div>

        {/* Today's Schedule Panel */}
        <div className="lg:col-span-7 bg-white rounded-[12px] shadow-sm p-6 border border-slate-100 flex flex-col justify-between">
          <div>
            <h3 className="text-[18px] font-semibold text-navy">Today's Class Schedule</h3>
            <p className="text-[12px] text-slate-500 mt-1">Upcoming sessions for {new Date().toLocaleDateString("en-US", { weekday: "long", month: "short", day: "numeric" })}.</p>

            <div className="mt-5 space-y-3">
              {todayClasses.length === 0 ? (
                <div className="text-center py-10 border border-dashed border-slate-200 rounded-lg bg-slate-50">
                  <Calendar className="w-8 h-8 text-slate-300 mx-auto mb-2" strokeWidth={1.5} />
                  <p className="text-[13px] text-slate-500 font-medium">No classes scheduled for today.</p>
                  <Link href="/dashboard/batches" className="text-gold text-[12px] font-semibold hover:underline mt-1 inline-block">
                    Add new class schedule
                  </Link>
                </div>
              ) : (
                todayClasses.map((cls) => (
                  <div key={cls.id} className="flex justify-between items-center p-4 border border-slate-100 rounded-lg hover:bg-slate-50 transition-all duration-150">
                    <div className="flex items-center gap-3">
                      <div className="w-2.5 h-2.5 rounded-full bg-gold animate-pulse" />
                      <div>
                        <h4 className="font-semibold text-slate-800 text-sm">{cls.batches?.name || "Unnamed Batch"}</h4>
                        <p className="text-[11px] text-slate-400 flex items-center gap-1 mt-0.5">
                          <Clock className="w-3 h-3 text-slate-400" />
                          <span>{cls.start_time.slice(0, 5)} - {cls.end_time.slice(0, 5)}</span>
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <span className={`px-2 py-0.5 text-[10px] font-bold rounded-full uppercase tracking-wider ${
                        cls.status === "completed" ? "bg-emerald-100 text-emerald-700" :
                        cls.status === "cancelled" ? "bg-rose-100 text-rose-700" : "bg-blue-100 text-blue-700"
                      }`}>
                        {cls.status}
                      </span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-100 text-center">
            <Link href="/dashboard/batches" className="text-gold text-[13px] font-bold hover:text-navy hover:underline flex items-center justify-center gap-1">
              <span>View all scheduled classes</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>

      </div>
    </div>
  );
}
