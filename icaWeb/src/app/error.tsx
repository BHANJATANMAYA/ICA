"use client";

import { useEffect } from "react";
import { AlertTriangle } from "lucide-react";

export default function ErrorBoundary({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("Global error boundary caught error:", error);
  }, [error]);

  return (
    <div className="min-h-screen bg-offwhite flex items-center justify-center p-6">
      <div className="w-full max-w-md bg-white rounded-[12px] border border-slate-100 p-8 text-center shadow-lg">
        <div className="w-14 h-14 bg-rose-50 text-destructive rounded-full flex items-center justify-center mx-auto mb-4 border border-rose-100 shadow-sm">
          <AlertTriangle className="w-7 h-7" />
        </div>

        <h2 className="text-[18px] font-bold text-navy tracking-wide uppercase">SYSTEM EXCEPTION</h2>
        <p className="text-[13px] text-slate-500 mt-2 leading-relaxed">
          An unexpected error occurred while executing database hooks or page layouts.
        </p>

        {error.message && (
          <div className="mt-4 p-3 bg-slate-50 border border-slate-200 rounded text-left font-mono text-[11px] text-slate-650 break-words max-h-[120px] overflow-y-auto">
            {error.message}
          </div>
        )}

        <div className="mt-6 flex flex-col sm:flex-row gap-3">
          <button
            onClick={() => {
              window.location.href = "/";
            }}
            className="flex-1 px-4 py-2.5 border border-slate-200 hover:bg-slate-50 text-slate-700 text-xs font-bold rounded-lg transition-colors"
          >
            Home Dashboard
          </button>
          <button
            onClick={() => reset()}
            className="flex-1 px-4 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow-sm transition-colors"
          >
            Retry operation
          </button>
        </div>
      </div>
    </div>
  );
}
