"use client";

import { useEffect, useState, useRef } from "react";
import { createClient } from "@/utils/supabase/client";
import {
  MessageSquare,
  Send,
  Plus,
  Trash2,
  BarChart3,
  Layers,
  Clock,
  User,
  Vote,
  AlertCircle,
  HelpCircle,
} from "lucide-react";

interface Batch {
  id: string;
  name: string;
}

interface Message {
  id: string;
  batch_id: string;
  sender_id: string;
  sender_name: string;
  sender_type: "admin" | "parent" | "student";
  message: string;
  created_at: string;
}

interface PollOption {
  id: string;
  poll_id: string;
  option_text: string;
  voteCount?: number;
}

interface Poll {
  id: string;
  batch_id: string;
  question: string;
  created_at: string;
  options?: PollOption[];
}

interface PollVote {
  id: string;
  poll_id: string;
  option_id: string;
  voter_id: string;
}

export default function ChatPollsPage() {
  const supabase = createClient();
  const [batches, setBatches] = useState<Batch[]>([]);
  const [selectedBatch, setSelectedBatch] = useState<string>("");
  const [messages, setMessages] = useState<Message[]>([]);
  const [polls, setPolls] = useState<Poll[]>([]);
  const [activeTab, setActiveTab] = useState<"chat" | "polls">("chat");
  const [loading, setLoading] = useState(true);

  // Current Admin Profile
  const [adminProfile, setAdminProfile] = useState<{ id: string; name: string } | null>(null);

  // Input States
  const [typedMessage, setTypedMessage] = useState("");
  const [pollQuestion, setPollQuestion] = useState("");
  const [pollOptions, setPollOptions] = useState<string[]>(["", ""]);
  const [showPollModal, setShowPollModal] = useState(false);

  // Chat scroll container ref
  const chatEndRef = useRef<HTMLDivElement>(null);

  // 1. Fetch admin details and batches
  useEffect(() => {
    async function initPage() {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
          const { data: admin } = await supabase
            .from("admins")
            .select("id, name")
            .eq("auth_user_id", user.id)
            .single();
          if (admin) {
            setAdminProfile(admin);
          }
        }

        const { data: batchList } = await supabase
          .from("batches")
          .select("id, name")
          .order("name", { ascending: true });
        setBatches(batchList || []);
        if (batchList && batchList.length > 0) {
          setSelectedBatch(batchList[0].id);
        } else {
          setLoading(false);
        }
      } catch (err) {
        console.error("Error initializing Chat/Polls dashboard:", err);
        setLoading(false);
      }
    }
    initPage();
  }, [supabase]);

  // 2. Fetch Chat messages and Polls for the selected batch
  const loadChatAndPolls = async () => {
    if (!selectedBatch) return;
    setLoading(true);
    try {
      // Fetch messages
      const { data: messagesData } = await supabase
        .from("group_messages")
        .select("*")
        .eq("batch_id", selectedBatch)
        .order("created_at", { ascending: true });
      setMessages(messagesData || []);

      // Fetch Polls & Options & Votes
      const { data: pollsData } = await supabase
        .from("polls")
        .select(`
          id,
          batch_id,
          question,
          created_at,
          poll_options (
            id,
            poll_id,
            option_text
          )
        `)
        .eq("batch_id", selectedBatch)
        .order("created_at", { ascending: false });

      // Fetch all votes for these polls to compute counts
      const pollIds = (pollsData || []).map((p: any) => p.id);
      let votesData: PollVote[] = [];
      if (pollIds.length > 0) {
        const { data: votes } = await supabase
          .from("poll_votes")
          .select("*")
          .in("poll_id", pollIds);
        votesData = (votes as any[]) || [];
      }

      // Map vote counts to options
      const mappedPolls: Poll[] = (pollsData || []).map((p: any) => {
        const optionsWithVotes = p.poll_options.map((opt: any) => {
          const count = votesData.filter((v) => v.option_id === opt.id).length;
          return { ...opt, voteCount: count };
        });
        return {
          id: p.id,
          batch_id: p.batch_id,
          question: p.question,
          created_at: p.created_at,
          options: optionsWithVotes,
        };
      });

      setPolls(mappedPolls);
    } catch (err) {
      console.error("Error loading chat & polls feed:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadChatAndPolls();
  }, [selectedBatch]);

  // Scroll to bottom of chat when new message arrives
  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, activeTab]);

  // 3. Setup REALTIME subscriptions for chat and votes
  useEffect(() => {
    if (!selectedBatch) return;

    // Realtime channel for live messages and votes
    const channel = supabase
      .channel("chat_polls_live_channel")
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "group_messages", filter: `batch_id=eq.${selectedBatch}` },
        (payload: any) => {
          setMessages((prev) => [...prev, payload.new as Message]);
        }
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "poll_votes" },
        () => {
          // Re-calculate vote rates on change
          loadChatAndPolls();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [selectedBatch, supabase]);

  // Post Chat message as Admin
  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!typedMessage.trim() || !selectedBatch || !adminProfile) return;

    try {
      const { error } = await supabase.from("group_messages").insert({
        batch_id: selectedBatch,
        sender_id: adminProfile.id,
        sender_name: adminProfile.name,
        sender_type: "admin",
        message: typedMessage.trim(),
      });

      if (error) throw error;
      setTypedMessage("");
    } catch (err) {
      alert("Failed to send message");
      console.error(err);
    }
  };

  // Create Poll
  const handleCreatePoll = async (e: React.FormEvent) => {
    e.preventDefault();
    const validOptions = pollOptions.filter((o) => o.trim() !== "");
    if (!pollQuestion.trim() || validOptions.length < 2 || !selectedBatch) {
      alert("Please enter a question and at least 2 valid options.");
      return;
    }

    try {
      // 1. Insert Poll
      const { data: pollRow, error: pollError } = await supabase
        .from("polls")
        .insert({
          batch_id: selectedBatch,
          question: pollQuestion.trim(),
        })
        .select()
        .single();

      if (pollError) throw pollError;

      // 2. Insert Poll Options
      const optionsPayload = validOptions.map((opt) => ({
        poll_id: pollRow.id,
        option_text: opt.trim(),
      }));

      const { error: optionsError } = await supabase
        .from("poll_options")
        .insert(optionsPayload);

      if (optionsError) throw optionsError;

      setShowPollModal(false);
      setPollQuestion("");
      setPollOptions(["", ""]);
      loadChatAndPolls();
    } catch (err) {
      alert("Failed to publish poll");
      console.error(err);
    }
  };

  // Delete Poll
  const handleDeletePoll = async (id: string) => {
    if (!confirm("Are you sure you want to delete this poll? All vote logs will be removed!")) return;
    try {
      const { error } = await supabase.from("polls").delete().eq("id", id);
      if (error) throw error;
      loadChatAndPolls();
    } catch (err) {
      alert("Failed to delete poll");
      console.error(err);
    }
  };

  if (batches.length === 0 && !loading) {
    return (
      <div className="bg-white rounded-[12px] p-12 text-center border border-slate-100 shadow-sm">
        <MessageSquare className="w-12 h-12 text-slate-350 mx-auto mb-3" />
        <p className="text-[14px] font-semibold text-navy">No batches created.</p>
        <p className="text-[12px] text-slate-400 mt-1">Please create a batch cohort to enable communications and polls.</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-[22px] font-bold text-navy tracking-wide">GROUP CHAT & POLLS</h1>
          <p className="text-[14px] text-slate-500 mt-1">Broadcast realtime messages and review parent response polls.</p>
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

          {activeTab === "polls" && (
            <button
              onClick={() => setShowPollModal(true)}
              className="h-[48px] px-6 bg-gold hover:bg-[#B78120] text-white font-bold rounded-[8px] flex items-center justify-center gap-2 shadow transition-all duration-150 active:scale-[0.98]"
            >
              <Plus className="w-4 h-4" strokeWidth={2.5} />
              <span>Create Poll</span>
            </button>
          )}
        </div>
      </div>

      {/* Tabs */}
      <div className="flex border-b border-slate-200">
        <button
          onClick={() => setActiveTab("chat")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "chat"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <MessageSquare className="w-4 h-4" />
          <span>Cohort Group Chat Feed</span>
        </button>
        <button
          onClick={() => setActiveTab("polls")}
          className={`px-6 py-3 text-sm font-semibold border-b-2 transition-all flex items-center gap-2 ${
            activeTab === "polls"
              ? "border-gold text-gold font-bold"
              : "border-transparent text-slate-500 hover:text-navy"
          }`}
        >
          <BarChart3 className="w-4 h-4" />
          <span>Interactive Polls</span>
        </button>
      </div>

      {loading && messages.length === 0 ? (
        <div className="py-20 text-center space-y-4">
          <div className="w-12 h-12 border-4 border-gold border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-500 text-sm font-medium">Opening communication lines...</p>
        </div>
      ) : (
        <>
          {/* TAB 1: CHAT FEED */}
          {activeTab === "chat" && (
            <div className="bg-white rounded-[12px] border border-slate-100 shadow-sm flex flex-col h-[500px] overflow-hidden animate-fadeIn">
              {/* Message History Scroller */}
              <div className="flex-1 p-6 overflow-y-auto space-y-4 bg-slate-50/50">
                {messages.length === 0 ? (
                  <div className="text-center py-20 text-slate-400">
                    <MessageSquare className="w-10 h-10 mx-auto mb-2 text-slate-300" strokeWidth={1.5} />
                    <p className="text-sm font-semibold text-navy">No messages in this cohort chat.</p>
                    <p className="text-xs text-slate-400 mt-0.5">Send a message below to broadcast to parents.</p>
                  </div>
                ) : (
                  messages.map((msg) => {
                    const isSelf = msg.sender_type === "admin";

                    return (
                      <div
                        key={msg.id}
                        className={`flex ${isSelf ? "justify-end" : "justify-start"} animate-fadeIn`}
                      >
                        <div className={`max-w-md rounded-lg p-4 shadow-sm relative ${
                          isSelf
                            ? "bg-navy text-white rounded-br-none"
                            : "bg-white text-slate-800 rounded-bl-none border border-slate-100"
                        }`}>
                          {/* Sender name badge */}
                          <p className={`text-[10px] font-bold uppercase tracking-wider mb-1 ${
                            isSelf ? "text-gold" : "text-navy"
                          }`}>
                            {msg.sender_name} ({msg.sender_type})
                          </p>

                          {/* Message content */}
                          <p className="text-sm leading-relaxed">{msg.message}</p>

                          {/* Timestamp */}
                          <span className={`text-[9px] block text-right mt-2 ${
                            isSelf ? "text-slate-350" : "text-slate-400"
                          }`}>
                            {new Date(msg.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                          </span>
                        </div>
                      </div>
                    );
                  })
                )}
                <div ref={chatEndRef} />
              </div>

              {/* Chat Input form */}
              <form onSubmit={handleSendMessage} className="p-4 bg-white border-t border-slate-100 flex gap-3">
                <input
                  type="text"
                  placeholder="Type a message to broadcast to all cohort members..."
                  value={typedMessage}
                  onChange={(e) => setTypedMessage(e.target.value)}
                  className="flex-1 px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium"
                />
                <button
                  type="submit"
                  className="w-12 h-12 bg-gold hover:bg-[#B78120] text-white rounded-lg flex items-center justify-center shadow transition-all active:scale-95"
                >
                  <Send className="w-5 h-5" />
                </button>
              </form>
            </div>
          )}

          {/* TAB 2: INTERACTIVE POLLS */}
          {activeTab === "polls" && (
            <div className="space-y-6 animate-fadeIn">
              {polls.length === 0 ? (
                <div className="bg-white rounded-[12px] p-16 text-center border border-slate-100 shadow-sm">
                  <Vote className="w-12 h-12 text-slate-350 mx-auto mb-3" />
                  <p className="text-[14px] font-bold text-navy">No active polls for this batch.</p>
                  <button
                    onClick={() => setShowPollModal(true)}
                    className="text-gold text-xs font-semibold hover:underline mt-1"
                  >
                    Launch a feedback poll
                  </button>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {polls.map((poll) => {
                    // Calculate total votes for this poll
                    const totalVotes = poll.options?.reduce((acc, opt) => acc + (opt.voteCount || 0), 0) || 0;

                    return (
                      <div
                        key={poll.id}
                        className="bg-white rounded-[12px] border border-slate-100 p-6 shadow-sm hover:shadow-md transition-all flex flex-col justify-between"
                      >
                        <div>
                          <div className="flex justify-between items-start gap-3">
                            <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider flex items-center gap-1">
                              <Clock className="w-3.5 h-3.5" />
                              <span>{new Date(poll.created_at).toLocaleDateString()}</span>
                            </span>
                            <button
                              onClick={() => handleDeletePoll(poll.id)}
                              className="p-1 text-slate-400 hover:text-destructive hover:bg-rose-50 rounded transition-colors"
                              title="Delete Poll"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>

                          <h3 className="font-bold text-base text-navy mt-3 leading-snug">{poll.question}</h3>

                          {/* Poll options list with percentages progress bar */}
                          <div className="mt-5 space-y-4">
                            {poll.options?.map((opt) => {
                              const count = opt.voteCount || 0;
                              const pct = totalVotes > 0 ? Math.round((count / totalVotes) * 100) : 0;

                              return (
                                <div key={opt.id} className="space-y-1">
                                  <div className="flex justify-between text-xs font-semibold text-slate-700">
                                    <span>{opt.option_text}</span>
                                    <span>{count} votes ({pct}%)</span>
                                  </div>
                                  {/* Progress bar */}
                                  <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                                    <div
                                      className="bg-gold h-2 rounded-full transition-all duration-500"
                                      style={{ width: `${pct}%` }}
                                    />
                                  </div>
                                </div>
                              );
                            })}
                          </div>
                        </div>

                        <div className="mt-6 pt-4 border-t border-slate-50 flex items-center justify-between text-[11px] text-slate-400 font-semibold">
                          <span>Total Response Size: {totalVotes} voters</span>
                          <span className="text-emerald-600 animate-pulse flex items-center gap-1">
                            <Vote className="w-3.5 h-3.5" />
                            Live Updating
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          )}
        </>
      )}

      {/* ====================================================
          MODAL: NEW POLL FORM
          ==================================================== */}
      {showPollModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-[12px] shadow-xl border border-slate-100 w-full max-w-md overflow-hidden transform scale-100 transition-all duration-200">
            {/* Header */}
            <div className="bg-navy p-5 text-white flex justify-between items-center">
              <h3 className="font-bold text-base tracking-wide">Launch Cohort Poll</h3>
              <button
                onClick={() => setShowPollModal(false)}
                className="text-slate-300 hover:text-white font-bold text-lg"
              >
                &times;
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleCreatePoll} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Question *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Preferred timing for upcoming tournament?"
                  value={pollQuestion}
                  onChange={(e) => setPollQuestion(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-medium text-slate-800"
                />
              </div>

              {/* Dynamic Options List */}
              <div className="space-y-2">
                <label className="text-[11px] font-bold text-navy uppercase tracking-wider block">Poll Options *</label>
                {pollOptions.map((opt, index) => (
                  <div key={index} className="flex gap-2 items-center">
                    <input
                      type="text"
                      required={index < 2}
                      placeholder={`Option ${index + 1}`}
                      value={opt}
                      onChange={(e) => {
                        const updated = [...pollOptions];
                        updated[index] = e.target.value;
                        setPollOptions(updated);
                      }}
                      className="flex-1 px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-gold focus:border-gold font-semibold text-slate-750"
                    />
                    {pollOptions.length > 2 && (
                      <button
                        type="button"
                        onClick={() => {
                          const updated = pollOptions.filter((_, i) => i !== index);
                          setPollOptions(updated);
                        }}
                        className="text-destructive hover:bg-rose-50 p-2 rounded"
                      >
                        &times;
                      </button>
                    )}
                  </div>
                ))}

                {pollOptions.length < 5 && (
                  <button
                    type="button"
                    onClick={() => setPollOptions([...pollOptions, ""])}
                    className="text-gold text-xs font-semibold hover:underline flex items-center gap-1 mt-1"
                  >
                    + Add option
                  </button>
                )}
              </div>

              <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowPollModal(false)}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-600 text-xs font-semibold rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-gold hover:bg-[#B78120] text-white text-xs font-bold rounded-lg shadow transition-all duration-150"
                >
                  Publish Poll
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
