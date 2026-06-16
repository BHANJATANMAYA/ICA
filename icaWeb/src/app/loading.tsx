// src/app/loading.tsx
export default function Loading() {
  return (
    <div className="min-h-screen bg-offwhite flex items-center justify-center">
      <div className="text-center space-y-4">
        {/* Themed gold loading spinner */}
        <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
        <p className="text-navy font-bold text-sm tracking-wider uppercase">Loading Workspace...</p>
      </div>
    </div>
  );
}
