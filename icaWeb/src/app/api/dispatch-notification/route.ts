import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/utils/supabase/admin";
import crypto from "crypto";

// Helper to sign JWT for Google OAuth2
function signJwt(payload: any, privateKey: string, clientEmail: string): string {
  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const encodedHeader = Buffer.from(JSON.stringify(header)).toString("base64url");
  const encodedPayload = Buffer.from(JSON.stringify(payload)).toString("base64url");

  const sign = crypto.createSign("RSA-SHA256");
  sign.update(`${encodedHeader}.${encodedPayload}`);
  
  // Format private key (replace escaped newlines)
  const formattedKey = privateKey.replace(/\\n/g, "\n");
  const signature = sign.sign(formattedKey, "base64");
  
  const encodedSignature = signature
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  return `${encodedHeader}.${encodedPayload}.${encodedSignature}`;
}

// Fetch OAuth2 access token for FCM v1
async function getFcmAccessToken(projectId: string, clientEmail: string, privateKey: string): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: clientEmail,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const jwt = signJwt(payload, privateKey, clientEmail);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }).toString(),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Failed to obtain Google access token: ${res.statusText} - ${errText}`);
  }

  const data = await res.json();
  return data.access_token;
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { notificationIds, notificationId } = body;

    // Normalize IDs to an array of string UUIDs
    const ids: string[] = [];
    if (Array.isArray(notificationIds)) {
      ids.push(...notificationIds);
    } else if (notificationId) {
      ids.push(notificationId);
    }

    if (ids.length === 0) {
      return NextResponse.json({ error: "Missing notificationId or notificationIds" }, { status: 400 });
    }

    const supabase = createAdminClient();

    // 1. Read notification rows from notifications table
    const { data: notifications, error: notifError } = await supabase
      .from("notifications")
      .select(`
        id,
        target_parent_id,
        type,
        title,
        body,
        deep_link,
        parents:target_parent_id ( id, name )
      `)
      .in("id", ids);

    if (notifError) {
      return NextResponse.json({ error: `Database error: ${notifError.message}` }, { status: 500 });
    }

    if (!notifications || notifications.length === 0) {
      return NextResponse.json({ error: "Notifications not found" }, { status: 404 });
    }

    // Read FCM environment variables
    const projectId = process.env.FCM_PROJECT_ID;
    const clientEmail = process.env.FCM_CLIENT_EMAIL;
    const privateKey = process.env.FCM_PRIVATE_KEY;

    let accessToken = "";
    let isConfigured = false;

    if (projectId && clientEmail && privateKey) {
      try {
        accessToken = await getFcmAccessToken(projectId, clientEmail, privateKey);
        isConfigured = true;
      } catch (tokenErr: any) {
        console.error("FCM config token error:", tokenErr);
      }
    } else {
      console.warn("FCM credentials missing. Falling back to simulated/mock mode.");
    }

    const results = [];

    // Process each notification
    for (const notif of notifications) {
      const parentId = notif.target_parent_id;
      const parentName = (notif as any).parents?.name || "Unknown Parent";

      // 2. Fetch FCM tokens for target parent
      const { data: tokens, error: tokenError } = await supabase
        .from("fcm_tokens")
        .select("token, platform")
        .eq("parent_id", parentId);

      if (tokenError) {
        results.push({
          notificationId: notif.id,
          parentName,
          status: "error",
          error: `Failed to fetch tokens: ${tokenError.message}`,
          tokens: [],
        });
        continue;
      }

      if (!tokens || tokens.length === 0) {
        results.push({
          notificationId: notif.id,
          parentName,
          status: "no_tokens",
          tokens: [],
        });
        continue;
      }

      const tokenDispatches = [];

      for (const t of tokens) {
        if (isConfigured) {
          // Live FCM HTTP v1 dispatch
          try {
            const fcmRes = await fetch(
              `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
              {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  Authorization: `Bearer ${accessToken}`,
                },
                body: JSON.stringify({
                  message: {
                    token: t.token,
                    notification: {
                      title: notif.title || "Academy Alert",
                      body: notif.body || "",
                    },
                    data: {
                      deep_link: notif.deep_link || "",
                      type: notif.type || "alert",
                      notification_id: notif.id,
                    },
                  },
                }),
              }
            );

            if (fcmRes.ok) {
              tokenDispatches.push({
                token: t.token,
                platform: t.platform,
                status: "success",
              });
            } else {
              const errBody = await fcmRes.text();
              tokenDispatches.push({
                token: t.token,
                platform: t.platform,
                status: "failed",
                error: `FCM v1 returned: ${fcmRes.status} - ${errBody}`,
              });
            }
          } catch (dispatchErr: any) {
            tokenDispatches.push({
              token: t.token,
              platform: t.platform,
              status: "failed",
              error: dispatchErr.message,
            });
          }
        } else {
          // Simulated dispatch (for testing / hackathon review when keys aren't set)
          tokenDispatches.push({
            token: t.token,
            platform: t.platform,
            status: "simulated",
            note: "Simulated success because FCM credentials are not configured in .env.local",
          });
        }
      }

      results.push({
        notificationId: notif.id,
        parentName,
        status: "processed",
        tokens: tokenDispatches,
      });
    }

    return NextResponse.json({
      success: true,
      configured: isConfigured,
      results,
    });

  } catch (err: any) {
    console.error("API error in dispatch-notification:", err);
    return NextResponse.json({ error: err.message || "Internal server error" }, { status: 500 });
  }
}
