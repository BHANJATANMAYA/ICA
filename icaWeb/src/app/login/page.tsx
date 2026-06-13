"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { createClient } from "@/utils/supabase/client";
import { Loader2, Lock, Mail, AlertCircle, ShieldAlert } from "lucide-react";

// Form validation schema with Zod
const loginSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

type LoginFormValues = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  });

  const onSubmit = async (data: LoginFormValues) => {
    setLoading(true);
    setErrorMsg(null);

    try {
      // Authenticate via Supabase
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: data.password,
      });

      if (authError) {
        throw new Error(authError.message);
      }

      // Check if user is actually an administrator
      console.log("Logged in Auth User ID:", authData.user.id);
      const { data: adminProfile, error: dbError } = await supabase
        .from("admins")
        .select("id, role")
        .eq("auth_user_id", authData.user.id)
        .maybeSingle();

      if (dbError) {
        console.error("Database query error during login:", dbError);
      }
      console.log("Fetched admin profile:", adminProfile);

      if (dbError || !adminProfile) {
        // Log out because not authorized admin
        await supabase.auth.signOut();
        const debugReason = dbError 
          ? ` (DB Error: ${dbError.message})` 
          : " (Account not linked in admins table)";
        throw new Error(`Access Denied: Only Indian Chess Academy administrators can log in here.${debugReason}`);
      }

      // Successful login
      router.refresh();
      router.push("/dashboard");
    } catch (err: any) {
      setErrorMsg(err.message || "An unexpected error occurred. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-offwhite flex items-center justify-center p-6 relative overflow-hidden">
      {/* Decorative Chess Theme Elements */}
      <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-navy/5 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-[-10%] right-[-10%] w-[45%] h-[45%] bg-gold/5 rounded-full blur-3xl pointer-events-none" />

      <div className="w-full max-w-md bg-white rounded-[12px] shadow-lg border border-slate-100 overflow-hidden relative z-10 hover:shadow-xl transition-all duration-300">
        {/* Navy Header Panel */}
        <div className="bg-navy p-8 text-center text-white border-b border-slate-700">
          <img
            src="/logo.png"
            alt="Indian Chess Academy Logo"
            className="w-16 h-16 object-contain rounded-full bg-white p-0.5 shadow-md mx-auto mb-4"
          />
          <h2 className="text-[22px] font-bold tracking-wide text-offwhite">ICA ADMIN WEB PANEL</h2>
          <p className="text-[12px] text-slate-300 mt-1 font-medium">Indian Chess Academy Management portal</p>
        </div>

        {/* Login Form */}
        <form onSubmit={handleSubmit(onSubmit)} className="p-8 space-y-6">
          {errorMsg && (
            <div className="p-4 bg-rose-50 border-l-4 border-destructive rounded flex items-start gap-3">
              <ShieldAlert className="w-5 h-5 text-destructive flex-shrink-0 mt-0.5" />
              <p className="text-[12px] text-destructive font-medium leading-relaxed">{errorMsg}</p>
            </div>
          )}

          {/* Email field */}
          <div className="space-y-2">
            <label className="text-[12px] font-semibold text-navy uppercase tracking-wider block">
              Email Address
            </label>
            <div className="relative">
              <span className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                <Mail className="w-[16px] h-[16px] text-slate-400" strokeWidth={1.5} />
              </span>
              <input
                type="email"
                placeholder="admin@ica.com"
                disabled={loading}
                className={`w-full pl-10 pr-4 py-3 bg-slate-50 border rounded-lg text-slate-800 placeholder-slate-400 text-sm focus:outline-none focus:ring-2 focus:ring-gold/40 focus:border-gold transition-colors ${
                  errors.email ? "border-destructive focus:ring-destructive/20 focus:border-destructive" : "border-slate-200"
                }`}
                {...register("email")}
              />
            </div>
            {errors.email && (
              <span className="text-[11px] text-destructive font-medium flex items-center gap-1.5 mt-1">
                <AlertCircle className="w-[12px] h-[12px]" />
                {errors.email.message}
              </span>
            )}
          </div>

          {/* Password field */}
          <div className="space-y-2">
            <label className="text-[12px] font-semibold text-navy uppercase tracking-wider block">
              Password
            </label>
            <div className="relative">
              <span className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                <Lock className="w-[16px] h-[16px] text-slate-400" strokeWidth={1.5} />
              </span>
              <input
                type="password"
                placeholder="••••••••"
                disabled={loading}
                className={`w-full pl-10 pr-4 py-3 bg-slate-50 border rounded-lg text-slate-800 placeholder-slate-400 text-sm focus:outline-none focus:ring-2 focus:ring-gold/40 focus:border-gold transition-colors ${
                  errors.password ? "border-destructive focus:ring-destructive/20 focus:border-destructive" : "border-slate-200"
                }`}
                {...register("password")}
              />
            </div>
            {errors.password && (
              <span className="text-[11px] text-destructive font-medium flex items-center gap-1.5 mt-1">
                <AlertCircle className="w-[12px] h-[12px]" />
                {errors.password.message}
              </span>
            )}
          </div>

          {/* Gold Submit Button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full h-[48px] bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center justify-center gap-2 shadow hover:shadow-md transition-all duration-150 active:scale-[0.98] disabled:opacity-75 disabled:pointer-events-none"
          >
            {loading ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin" />
                <span>Signing In...</span>
              </>
            ) : (
              <span>Sign In to Dashboard</span>
            )}
          </button>
        </form>

        <div className="px-8 pb-8 text-center border-t border-slate-50 pt-5">
          <p className="text-[11px] text-slate-400 leading-normal">
            Indian Chess Academy © 2026. All rights reserved. Registered staff only.
          </p>
        </div>
      </div>
    </div>
  );
}
