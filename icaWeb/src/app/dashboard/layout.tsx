// src/app/dashboard/layout.tsx
import Sidebar from "@/components/Sidebar";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex h-screen w-screen overflow-hidden bg-offwhite">
      {/* Persistent Sidebar */}
      <Sidebar />

      {/* Scrollable Content Container */}
      <div className="flex-1 flex flex-col h-full overflow-y-auto">
        <main className="p-8 flex-1">
          {children}
        </main>
      </div>
    </div>
  );
}
