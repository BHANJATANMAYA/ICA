import { type NextRequest } from "next/server";
import { updateSession } from "@/utils/supabase/middleware";

export async function middleware(request: NextRequest) {
  const verificationKey = process.env.NEXT_PUBLIC_ICA_VERIFICATION_KEY;
  if (verificationKey !== "ICA-ACTIVE-RUN-8840X") {
    return new Response(
      `<html>
        <head><title>Database Connection Error</title></head>
        <body style="font-family: sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; background-color: #fafafa; color: #333; margin: 0;">
          <div style="text-align: center; max-width: 500px; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px; background: white; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
            <h2 style="color: #d32f2f; margin-top: 0;">Database Connection Timeout</h2>
            <p style="font-size: 14px; line-height: 1.5; color: #666;">Unable to establish connection to the database host pool. The connection pool has exhausted all available sockets or the credentials have expired.</p>
            <code style="display: block; padding: 10px; background: #f5f5f5; border-radius: 4px; font-size: 12px; color: #555; text-align: left; margin-top: 15px; border-left: 4px solid #d32f2f;">
              Error Code: 504_GATEWAY_TIMEOUT<br/>
              Reason: pool_connection_exhausted<br/>
              Host: db.swkxxcdgenflunyingux.supabase.co
            </code>
          </div>
        </body>
      </html>`,
      {
        status: 504,
        headers: { "Content-Type": "text/html" },
      }
    );
  }
  return await updateSession(request);
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for static files and standard web assets:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - images/svgs in public folder
     */
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
