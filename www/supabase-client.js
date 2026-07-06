const supabaseConfigured = window.SUPABASE_CONFIG?.url && !window.SUPABASE_CONFIG.url.includes('YOUR-PROJECT-REF');
const supabaseClient = supabaseConfigured
  ? window.supabase.createClient(window.SUPABASE_CONFIG.url, window.SUPABASE_CONFIG.anonKey)
  : null;

if (!supabaseConfigured) {
  console.warn('Supabase is not configured yet — edit www/supabase-config.js with your project URL and anon key.');
}
