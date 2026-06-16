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
  
  console.log('Auth Success! Token:', authData.session.access_token.substring(0, 20) + '...');
  
  // Set the session header implicitly by using the client instance which handles it
  const { data: parents, error: parentsError } = await supabase.from('parents').select('*');
  console.log('Parents:', parents, 'Error:', parentsError);

  const { data: students, error: studentsError } = await supabase.from('students').select('*');
  console.log('Students:', students, 'Error:', studentsError);

  const { data: batches, error: batchesError } = await supabase.from('batches').select('*');
  console.log('Batches:', batches, 'Error:', batchesError);
  
  const { data: schedules, error: schedulesError } = await supabase.from('schedules').select('*');
  console.log('Schedules:', schedules, 'Error:', schedulesError);
}

run();
