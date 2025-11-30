import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Get JWT token from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const token = authHeader.replace("Bearer ", "");

    // Initialize Supabase client with service role for admin operations
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // Verify the JWT token and get user
    const {
      data: { user },
      error: authError,
    } = await supabaseAdmin.auth.getUser(token);

    if (authError || !user) {
      console.error("Authentication error:", authError);
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const userId = user.id;
    console.log(`Starting account deletion for user: ${userId}`);

    // STEP 1: Delete user's search history
    const { error: searchesError } = await supabaseAdmin
      .from("searches")
      .delete()
      .eq("user_id", userId);

    if (searchesError) {
      console.error("Error deleting searches:", searchesError);
      return new Response(
        JSON.stringify({
          error: "Failed to delete search history",
          details: searchesError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(`Deleted searches for user: ${userId}`);

    // STEP 2: Delete user's credit transactions
    const { error: transactionsError } = await supabaseAdmin
      .from("credit_transactions")
      .delete()
      .eq("user_id", userId);

    if (transactionsError) {
      console.error("Error deleting transactions:", transactionsError);
      return new Response(
        JSON.stringify({
          error: "Failed to delete credit transactions",
          details: transactionsError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(`Deleted credit transactions for user: ${userId}`);

    // STEP 3: Delete user from users table
    const { error: usersError } = await supabaseAdmin
      .from("users")
      .delete()
      .eq("id", userId);

    if (usersError) {
      console.error("Error deleting user record:", usersError);
      return new Response(
        JSON.stringify({
          error: "Failed to delete user record",
          details: usersError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(`Deleted user record for user: ${userId}`);

    // STEP 4: Delete user from auth.users (authentication)
    const { error: authDeleteError } = await supabaseAdmin.auth.admin.deleteUser(
      userId
    );

    if (authDeleteError) {
      console.error("Error deleting auth user:", authDeleteError);
      return new Response(
        JSON.stringify({
          error: "Failed to delete authentication account",
          details: authDeleteError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(`Deleted auth user: ${userId}`);

    // SUCCESS: All data deleted
    return new Response(
      JSON.stringify({
        success: true,
        message: "Account successfully deleted",
        user_id: userId,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Unexpected error during account deletion:", error);
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        details: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
