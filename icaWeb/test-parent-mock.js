const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://swkxxcdgenflunyingux.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3a3h4Y2RnZW5mbHVueWluZ3V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNDg4NzcsImV4cCI6MjA5NjgyNDg3N30.KKRoh7bxx6_0SwTc_Gf63q4PzjLiqscZVp8eEoCaHVM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function run() {
  console.log('Logging in as admin...');
  const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
    email: 'admin@ica.com',
    password: 'AdminChess123!'
  });
  
  if (authError) {
    console.error('Auth Error:', authError);
    return;
  }
  
  const adminUid = authData.user.id;
  console.log('Admin UID:', adminUid);
  
  // Update Rajesh Kumar's auth_user_id to adminUid
  console.log("Updating Rajesh Kumar's auth_user_id to adminUid...");
  const { data: updateData, error: updateError } = await supabase
    .from('parents')
    .update({ auth_user_id: adminUid })
    .eq('id', 'd1111111-1111-1111-1111-111111111111')
    .select();
    
  console.log('Update Result:', updateData, 'Error:', updateError);
}

run();
