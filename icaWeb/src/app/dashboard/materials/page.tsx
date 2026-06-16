"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  BookOpen,
  Plus,
  Trash2,
  ExternalLink,
  FileText,
  Upload,
  Link as LinkIcon,
  Filter,
  Layers,
  ArrowUpRight,
} from "lucide-react";

interface Batch {
  id: string;
  name: string;
}

interface StudyMaterial {
  id: string;
  batch_id: string;
  title: string;
  file_url: string | null;
  link_url: string | null;
  created_at: string;
}

export default function StudyMaterialsPage() {
  const supabase = createClient();
  const [batches, setBatches] = useState<Batch[]>([]);
  const [selectedBatch, setSelectedBatch] = useState<string>("");
  const [materials, setMaterials] = useState<StudyMaterial[]>([]);
  const [loading, setLoading] = useState(true);

  // Form State
  const [showModal, setShowModal] = useState(false);
  const [title, setTitle] = useState("");
  const [type, setType] = useState<"file" | "link">("link");
  const [linkUrl, setLinkUrl] = useState("");
  const [uploadFile, setUploadFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    async function loadBatches() {
      try {
        const { data } = await supabase
          .from("batches")
          .select("id, name")
          .order("name", { ascending: true });
        setBatches(data || []);
        if (data && data.length > 0) {
          setSelectedBatch(data[0].id);
        } else {
          setLoading(false);
        }
      } catch (err) {
        console.error("Error loading batches for materials:", err);
        setLoading(false);
      }
    }
    loadBatches();
  }, [supabase]);

  const loadMaterials = async () => {
    if (!selectedBatch) return;
    setLoading(true);
    try {
      const { data } = await supabase
        .from("study_materials")
        .select("*")
        .eq("batch_id", selectedBatch)
        .order("created_at", { ascending: false });
      setMaterials(data || []);
    } catch (err) {
      console.error("Error loading materials:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMaterials();
  }, [selectedBatch]);

  const handleSaveMaterial = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !selectedBatch) return;

    setUploading(true);
    let finalFileUrl: string | null = null;
    let finalLinkUrl: string | null = null;

    try {
      if (type === "link") {
        if (!linkUrl) {
          alert("Please enter a link URL.");
          setUploading(false);
          return;
        }
        finalLinkUrl = linkUrl;
      } else {
        if (!uploadFile) {
          alert("Please select a file to upload.");
          setUploading(false);
          return;
        }

        // Upload to Supabase Storage (requires a bucket named 'study-materials')
        const fileExt = uploadFile.name.split(".").pop();
        const fileName = `${selectedBatch}/${Date.now()}_${Math.random().toString(36).substring(7)}.${fileExt}`;

        const { data: uploadData, error: uploadError } = await supabase.storage
          .from("study-materials")
          .upload(fileName, uploadFile, {
            cacheControl: "3600",
            upsert: false,
          });

        if (uploadError) {
          // If bucket doesn't exist, prompt user and fallback
          if (uploadError.message.includes("does not exist") || uploadError.message.includes("Object not found")) {
            throw new Error(
              "Storage bucket 'study-materials' not found. Please create a public bucket named 'study-materials' in your Supabase Dashboard -> Storage panel."
            );
          }
          throw uploadError;
        }

        const { data: urlData } = supabase.storage
          .from("study-materials")
          .getPublicUrl(uploadData.path);
        
        finalFileUrl = urlData.publicUrl;
      }

      // Save record in public.study_materials
      const { error: insertError } = await supabase
        .from("study_materials")
        .insert({
          batch_id: selectedBatch,
          title,
          file_url: finalFileUrl,
          link_url: finalLinkUrl,
        });

      if (insertError) throw insertError;

      setShowModal(false);
      setTitle("");
      setLinkUrl("");
      setUploadFile(null);
      loadMaterials();
    } catch (err: any) {
      alert(err.message || "Error uploading study materials");
      console.error(err);
    } finally {
      setUploading(false);
    }
  };

  const handleDeleteMaterial = async (id: string, fileUrl: string | null) => {
    if (!confirm("Are you sure you want to delete this resource?")) return;

    try {
      // If there is an uploaded file, delete it from storage first
      if (fileUrl) {
        // Extract storage path from url
        const pathPart = fileUrl.split("/storage/v1/object/public/study-materials/").pop();
        if (pathPart) {
          await supabase.storage.from("study-materials").remove([decodeURIComponent(pathPart)]);
        }
      }

      const { error } = await supabase.from("study_materials").delete().eq("id", id);
      if (error) throw error;

      loadMaterials();
    } catch (err) {
      alert("Error deleting study material");
      console.error(err);
    }
  };

  if (batches.length === 0 && !loading) {
    return (
      <div className="bg-white rounded-[12px] p-12 text-center border border-slate-100 shadow-sm">
        <BookOpen className="w-12 h-12 text-slate-300 mx-auto mb-3" />
        <p className="text-[14px] font-semibold text-navy">No batches created.</p>
        <p className="text-[12px] text-slate-400 mt-1">Please create a batch cohort before allocating study materials.</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">STUDY MATERIALS</h1>
          <p className="text-[14px] text-slate-500 mt-1">Share chess worksheets, Lichess analysis boards, and lecture notes.</p>
        </div>

        <div className="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
          {/* Batch Selector */}
          <div className="flex items-center gap-3 bg-white px-4 py-2 border border-slate-200 rounded-lg shadow-sm">
            <Layers className="w-4 h-4 text-slate-400" />
            <span className="text-xs font-bold text-navy uppercase tracking-wider">Cohort:</span>
            <select
              value={selectedBatch}
              onChange={(e) => setSelectedBatch(e.target.value)}
              className="bg-transparent border-none py-0.5 px-1 text-xs font-bold text-slate-700 focus:outline-none focus:ring-0 cursor-pointer"
            >
              {batches.map((b) => (
                <option key={b.id} value={b.id}>
                  {b.name}
                </option>
              ))}
            </select>
          </div>

          <button
            onClick={() => setShowModal(true)}
            className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center justify-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
          >
            <Plus className="w-4 h-4" strokeWidth={2.5} />
            <span>Upload Material</span>
          </button>
        </div>
      </div>

      {loading ? (
        <div className="py-20 text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 text-sm font-medium">Loading materials index...</p>
        </div>
      ) : materials.length === 0 ? (
        <div className="bg-white rounded-[12px] border border-slate-100 p-16 text-center shadow-sm">
          <BookOpen className="w-12 h-12 text-slate-350 mx-auto mb-3" />
          <p className="text-[14px] font-bold text-navy">No study materials in this batch.</p>
          <p className="text-[12px] text-slate-400 mt-1">Upload PDF worksheets or add external Chess.com/Lichess links.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {materials.map((mat) => {
            const isLink = !!mat.link_url;
            const targetUrl = mat.link_url || mat.file_url || "#";

            return (
              <div
                key={mat.id}
                className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between"
              >
                <div>
                  {/* Header info */}
                  <div className="flex justify-between items-start gap-2">
                    <span className={`p-2.5 rounded-lg ${
                      isLink ? "bg-cyan-50 text-cyan-600" : "bg-emerald-50 text-success"
                    }`}>
                      {isLink ? <LinkIcon className="w-4 h-4" /> : <FileText className="w-4 h-4" />}
                    </span>
                    <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider">
                      {isLink ? "Web Link" : "Document"}
                    </span>
                  </div>

                  <h3 className="font-bold text-[15px] text-navy mt-4 leading-snug line-clamp-2" title={mat.title}>
                    {mat.title}
                  </h3>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-50 flex items-center justify-between">
                  <a
                    href={targetUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-gold text-xs font-bold hover:text-navy flex items-center gap-1 group"
                  >
                    <span>Open Resource</span>
                    <ArrowUpRight className="w-3.5 h-3.5 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
                  </a>

                  <button
                    onClick={() => handleDeleteMaterial(mat.id, mat.file_url)}
                    className="p-1.5 text-slate-450 hover:text-destructive hover:bg-rose-50 rounded transition-colors"
                    title="Delete Resource"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* ====================================================
          MODAL: UPLOAD / ADD RESOURCE FORM
          ==================================================== */}
      {showModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">Share Study Material</h3>
              <button
                onClick={() => setShowModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveMaterial} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Resource Title *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. King & Pawn Endgame Basics"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium"
                />
              </div>

              {/* Resource Type Tabs */}
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Resource Type *</label>
                <div className="grid grid-cols-2 gap-2 bg-slate-100 p-1 rounded-lg">
                  <button
                    type="button"
                    onClick={() => setType("link")}
                    className={`py-1.5 rounded-md text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
                      type === "link" ? "bg-white text-navy shadow-sm" : "text-slate-500 hover:text-navy"
                    }`}
                  >
                    <LinkIcon className="w-3.5 h-3.5" />
                    <span>External Link</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setType("file")}
                    className={`py-1.5 rounded-md text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
                      type === "file" ? "bg-white text-navy shadow-sm" : "text-slate-500 hover:text-navy"
                    }`}
                  >
                    <Upload className="w-3.5 h-3.5" />
                    <span>File Upload</span>
                  </button>
                </div>
              </div>

              {type === "link" ? (
                <div className="space-y-1">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Link URL *</label>
                  <input
                    type="url"
                    placeholder="https://lichess.org/study/..."
                    value={linkUrl}
                    onChange={(e) => setLinkUrl(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium text-slate-800"
                  />
                </div>
              ) : (
                <div className="space-y-1.5">
                  <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">File Selector *</label>
                  <div className="border-2 border-dashed border-slate-200 rounded-lg p-5 text-center bg-slate-50 hover:bg-slate-100/50 cursor-pointer transition-colors relative">
                    <input
                      type="file"
                      onChange={(e) => setUploadFile(e.target.files?.[0] || null)}
                      className="absolute inset-0 opacity-0 w-full h-full cursor-pointer"
                    />
                    <Upload className="w-8 h-8 text-slate-400 mx-auto mb-2" />
                    <p className="text-xs font-bold text-slate-600">
                      {uploadFile ? uploadFile.name : "Click to select document (PDF, PNG, JPG)"}
                    </p>
                    <p className="text-[10px] text-slate-450 mt-1">Maximum size 10MB</p>
                  </div>
                </div>
              )}

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                  disabled={uploading}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={uploading}
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150 flex items-center gap-1.5 disabled:opacity-75 disabled:pointer-events-none"
                >
                  {uploading ? (
                    <>
                      <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>Uploading...</span>
                    </>
                  ) : (
                    <span>Share Resource</span>
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
