"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/utils/supabase/client";
import { useEffect, useState } from "react";
import {
  LayoutDashboard,
  Calendar,
  Users,
  CheckSquare,
  CreditCard,
  BookOpen,
  FileText,
  MessageSquare,
  UserCheck,
  LogOut,
  User,
} from "lucide-react";

interface NavItem {
  name: string;
  href: string;
  icon: any;
}

const navItems: NavItem[] = [
  { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { name: "Batches & Schedules", href: "/dashboard/batches", icon: Calendar },
  { name: "Students", href: "/dashboard/students", icon: Users },
  { name: "Attendance", href: "/dashboard/attendance", icon: CheckSquare },
  { name: "Billing Plans & Subs", href: "/dashboard/billing", icon: CreditCard },
  { name: "Study Materials", href: "/dashboard/materials", icon: BookOpen },
  { name: "Assignments & Subs", href: "/dashboard/assignments", icon: FileText },
  { name: "Group Chat & Polls", href: "/dashboard/chat-polls", icon: MessageSquare },
  { name: "Trial Requests", href: "/dashboard/trials", icon: UserCheck },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const supabase = createClient();
  const [adminName, setAdminName] = useState<string>("ICA Admin");

  useEffect(() => {
    async function fetchAdminProfile() {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        const { data } = await supabase
          .from("admins")
          .select("name")
          .eq("auth_user_id", user.id)
          .single();
        if (data?.name) {
          setAdminName(data.name);
        } else {
          setAdminName(user.email || "Admin");
        }
      }
    }
    fetchAdminProfile();

    // Auto-logout helper for inactivity (30 minutes)
    let timeoutId: NodeJS.Timeout;
    const resetTimeout = () => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(async () => {
        await supabase.auth.signOut();
        router.push("/login");
      }, 30 * 60 * 1000); // 30 minutes in ms
    };

    // Listen to mouse/keyboard events to reset timer
    const events = ["mousedown", "mousemove", "keypress", "scroll", "touchstart"];
    events.forEach((name) => document.addEventListener(name, resetTimeout));

    // Initialize timer
    resetTimeout();

    return () => {
      clearTimeout(timeoutId);
      events.forEach((name) => document.removeEventListener(name, resetTimeout));
    };
  }, [supabase, router]);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.refresh();
    router.push("/login");
  };

  return (
    <aside className="w-64 bg-navy text-white flex flex-col h-full border-r border-slate-700 select-none">
      {/* Brand Header */}
      <div className="p-6 border-b border-slate-700 flex items-center gap-3">
        <img
          src="/logo.png"
          alt="Indian Chess Academy Logo"
          className="w-10 h-10 object-contain rounded-full bg-white p-0.5 shadow-md flex-shrink-0"
        />
        <div>
          <h1 className="font-bold text-base leading-tight tracking-wider text-offwhite uppercase">ICA Admin</h1>
          <p className="text-[10px] text-slate-300 font-medium">Think. Plan. Triumph.</p>
        </div>
      </div>

      {/* Navigation List */}
      <nav className="flex-1 px-4 py-6 space-y-1.5 overflow-y-auto">
        {navItems.map((item) => {
          // Check if pathname starts with item.href (but exact match for root dashboard)
          const isActive =
            item.href === "/dashboard"
              ? pathname === "/dashboard"
              : pathname.startsWith(item.href);

          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center gap-3 px-4 py-3 text-[13px] font-medium rounded-lg transition-all duration-200 ${
                isActive
                  ? "bg-gold text-navy shadow-sm font-semibold transform translate-x-1"
                  : "text-slate-300 hover:bg-slate-800 hover:text-white"
              }`}
            >
              <item.icon className="w-[18px] h-[18px] flex-shrink-0" strokeWidth={1.8} />
              <span>{item.name}</span>
            </Link>
          );
        })}
      </nav>

      {/* Profile & Logout Section */}
      <div className="p-4 border-t border-slate-700 bg-slate-900/50">
        <div className="flex items-center gap-3 px-2 py-2 mb-3">
          <div className="w-8 h-8 rounded-full bg-slate-800 flex items-center justify-center border border-slate-700">
            <User className="w-4 h-4 text-slate-300" />
          </div>
          <div className="overflow-hidden">
            <p className="text-[12px] font-semibold text-offwhite truncate">{adminName}</p>
            <p className="text-[10px] text-slate-400 font-medium">Academy Staff</p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-4 py-2.5 text-[12px] font-semibold text-rose-400 hover:bg-rose-950/30 hover:text-rose-300 rounded-lg transition-all duration-150 border border-transparent hover:border-rose-900/40"
        >
          <LogOut className="w-[16px] h-[16px]" strokeWidth={1.8} />
          <span>Sign Out</span>
        </button>
      </div>
    </aside>
  );
}
