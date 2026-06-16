"use server";

import { createClient as createCookieClient } from "@/utils/supabase/server";
import { createAdminClient } from "@/utils/supabase/admin";

interface CreateParentParams {
  name: string;
  email: string;
  phone?: string | null;
  password?: string; // If provided, creates or resets credentials
  studentIds?: string[]; // List of student IDs to link to this parent
}

export async function createOrUpdateParentAction(params: CreateParentParams, parentId?: string) {
  try {
    // 1. Verify Admin Session
    const cookieClient = createCookieClient();
    const { data: { user }, error: userError } = await cookieClient.auth.getUser();
    if (userError || !user) {
      return { success: false, error: "Authentication failed. Please log in again." };
    }

    const { data: adminCheck, error: adminError } = await cookieClient
      .from("admins")
      .select("id")
      .eq("auth_user_id", user.id)
      .single();

    if (adminError || !adminCheck) {
      return { success: false, error: "Access Denied: Only admins can perform this action." };
    }

    // 2. Initialize Admin Client
    let adminClient;
    try {
      adminClient = createAdminClient();
    } catch (err: any) {
      return { success: false, error: err.message };
    }

    const { name, email, phone, password, studentIds = [] } = params;

    // 3. Upsert parent profile & Auth User
    let targetParentId = parentId;
    let authUserId: string | null = null;

    // Check if parent already exists by email
    const { data: existingParent } = await adminClient
      .from("parents")
      .select("id, auth_user_id")
      .eq("email", email)
      .maybeSingle();

    if (existingParent) {
      targetParentId = existingParent.id;
      authUserId = existingParent.auth_user_id;
    }

    // 4. Handle authentication credentials (Supabase Auth)
    if (password) {
      if (!authUserId) {
        // Create new auth user
        const { data: authUser, error: authCreateError } = await adminClient.auth.admin.createUser({
          email,
          password,
          email_confirm: true,
          user_metadata: { name }
        });

        if (authCreateError) {
          return { success: false, error: `Auth Account Creation Error: ${authCreateError.message}` };
        }

        authUserId = authUser.user.id;
      } else {
        // Reset password for existing auth user
        const { error: authUpdateError } = await adminClient.auth.admin.updateUserById(authUserId, {
          password
        });

        if (authUpdateError) {
          return { success: false, error: `Auth Password Update Error: ${authUpdateError.message}` };
        }
      }
    }

    // 5. Upsert parent record in public.parents
    const parentPayload = {
      name,
      email,
      phone: phone || null,
      auth_user_id: authUserId
    };

    let parentDbId = targetParentId;

    if (targetParentId) {
      // Update existing parent
      const { error: updateError } = await adminClient
        .from("parents")
        .update(parentPayload)
        .eq("id", targetParentId);

      if (updateError) {
        return { success: false, error: `Database Error (Parents Update): ${updateError.message}` };
      }
    } else {
      // Insert new parent
      const { data: newParent, error: insertError } = await adminClient
        .from("parents")
        .insert(parentPayload)
        .select("id")
        .single();

      if (insertError) {
        return { success: false, error: `Database Error (Parents Insert): ${insertError.message}` };
      }

      parentDbId = newParent.id;
    }

    // 6. Manage Linked Students (Children assignment/removal)
    if (parentDbId) {
      // Fetch currently linked students
      const { data: currentLinked } = await adminClient
        .from("students")
        .select("id")
        .eq("parent_id", parentDbId);

      const currentIds = currentLinked?.map(s => s.id) || [];

      // Unlink removed students
      const idsToUnlink = currentIds.filter(id => !studentIds.includes(id));
      if (idsToUnlink.length > 0) {
        const { error: unlinkError } = await adminClient
          .from("students")
          .update({ parent_id: null })
          .in("id", idsToUnlink);

        if (unlinkError) {
          return { success: false, error: `Database Error (Unlinking Students): ${unlinkError.message}` };
        }
      }

      // Link newly assigned students
      const idsToLink = studentIds.filter(id => !currentIds.includes(id));
      if (idsToLink.length > 0) {
        const { error: linkError } = await adminClient
          .from("students")
          .update({ parent_id: parentDbId })
          .in("id", idsToLink);

        if (linkError) {
          return { success: false, error: `Database Error (Linking Students): ${linkError.message}` };
        }
      }
    }

    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || "An unexpected error occurred." };
  }
}
