// Thin data-access layer over Supabase. Every loader returns objects already
// shaped the way app.js's render functions expect, so no other file needs to
// know Supabase exists.

async function loadCompanies() {
  if (!supabaseClient) return [];
  const { data, error } = await supabaseClient.from('companies').select('*').order('score', { ascending: false });
  if (error) { console.error('loadCompanies', error); return []; }
  return data.map(row => ({
    id: row.id,
    name: row.name,
    industry: row.industry,
    type: row.type,
    membership: row.membership,
    location: row.location,
    desc: row.desc,
    tags: row.tags || [],
    color: row.color,
    score: row.score,
    approved: row.approved,
    verified: row.verified,
    profileComplete: row.profile_complete,
    documentsVerified: row.documents_verified,
    paymentVerified: row.payment_verified,
    adminVerified: row.admin_verified,
    ownerEmail: row.owner_email,
  }));
}

async function insertCompany(company) {
  if (!supabaseClient) return company;
  const { data: { user } } = await supabaseClient.auth.getUser();
  const { data, error } = await supabaseClient.from('companies').insert({
    name: company.name,
    industry: company.industry,
    type: company.type,
    membership: company.membership,
    location: company.location,
    desc: company.desc,
    tags: company.tags,
    color: company.color,
    score: company.score || 0,
    approved: false,
    owner_email: company.ownerEmail,
    owner_id: user?.id || null,
  }).select().single();
  if (error) { console.error('insertCompany', error); return company; }
  return { ...company, id: data.id, approved: data.approved };
}

async function loadNews() {
  if (!supabaseClient) return [];
  const { data, error } = await supabaseClient.from('news_items').select('*').order('publish_at', { ascending: false });
  if (error) { console.error('loadNews', error); return []; }
  return data.map(row => ({
    id: row.id,
    headline: row.headline,
    tagline: row.tagline,
    details: row.details,
    category: row.category,
    hashtags: row.hashtags || [],
    author: row.author,
    dateline: row.dateline,
    publishAt: row.publish_at,
    imageCaption: row.image_caption,
    thumbnail: '',
    heroImage: '',
    photos: [],
    sourceType: row.source_type,
    source: row.source,
    level: row.level,
    audiences: row.audiences || [],
    channels: row.channels || [],
    release: new Date(row.publish_at) > new Date() ? `Scheduled ${row.publish_at}` : 'Published',
  }));
}

async function insertNews(news) {
  if (!supabaseClient) return news;
  const { data: { user } } = await supabaseClient.auth.getUser();
  const { data, error } = await supabaseClient.from('news_items').insert({
    headline: news.headline,
    tagline: news.tagline,
    details: news.details,
    category: news.category,
    hashtags: news.hashtags,
    author: news.author,
    dateline: news.dateline,
    publish_at: news.publishAt,
    image_caption: news.imageCaption,
    source_type: news.sourceType,
    source: news.source,
    level: news.level,
    audiences: news.audiences,
    channels: news.channels,
    created_by: user?.id || null,
  }).select().single();
  if (error) { console.error('insertNews', error); return news; }
  return { ...news, id: data.id };
}

async function loadEvents() {
  if (!supabaseClient) return [];
  const { data, error } = await supabaseClient.from('events').select('*').order('created_at', { ascending: true });
  if (error) { console.error('loadEvents', error); return []; }
  return data.map(row => ({
    id: row.id,
    day: row.day,
    month: row.month,
    type: row.type,
    title: row.title,
    place: row.place,
    description: row.description,
    accepted: row.accepted,
    maybe: row.maybe,
    pending: row.pending,
    theme: row.theme,
    public: row.public,
    capacity: row.capacity,
    status: row.status,
  }));
}

async function insertEvent(event) {
  if (!supabaseClient) return event;
  const { data: { user } } = await supabaseClient.auth.getUser();
  const { data, error } = await supabaseClient.from('events').insert({
    day: event.day,
    month: event.month,
    type: event.type,
    title: event.title,
    place: event.place,
    description: event.description,
    accepted: event.accepted || 0,
    maybe: event.maybe || 0,
    pending: event.pending || 0,
    theme: event.theme,
    public: event.public,
    capacity: event.capacity,
    status: event.status,
    created_by: user?.id || null,
  }).select().single();
  if (error) { console.error('insertEvent', error); return event; }
  return { ...event, id: data.id };
}

async function insertEventRegistration(eventId, name, email) {
  if (!supabaseClient) return null;
  const { error } = await supabaseClient.from('event_registrations').insert({ event_id: eventId, name, email });
  if (error) console.error('insertEventRegistration', error);
  return !error;
}

async function loadProfile(userId) {
  if (!supabaseClient) return null;
  const { data, error } = await supabaseClient.from('profiles').select('*').eq('id', userId).single();
  if (error) { console.error('loadProfile', error); return null; }
  return data;
}
