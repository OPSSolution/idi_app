-- IDI APP — Supabase schema, RLS policies, and demo seed data.
-- Run this once in your Supabase project's SQL editor (Dashboard -> SQL Editor -> New query).

-- =========================================================================
-- profiles (1:1 with auth.users)
-- =========================================================================
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default 'New Member',
  organization text not null default '',
  role text not null default 'Guest Member',
  tier text not null default 'Guest' check (tier in ('Admin','VIP','Premium','Standard','Guest')),
  is_admin boolean not null default false,
  can_publish boolean not null default false,
  can_campaign boolean not null default false,
  allowed_pages text[] not null default array['overview','directory','news','billing','events'],
  membership_expires date,
  payment_status text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles are self-readable" on public.profiles
  for select using (auth.uid() = id);

create policy "admins can read all profiles" on public.profiles
  for select using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin));

create policy "users can update their own basic info" on public.profiles
  for update using (auth.uid() = id);

-- Auto-create a Guest profile whenever someone signs up.
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, organization)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', 'New Member'), '');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =========================================================================
-- companies (business directory)
-- =========================================================================
create table public.companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  industry text,
  type text,
  membership text default 'Standard',
  location text,
  desc text,
  tags text[] default array[]::text[],
  color text default '#5b4bdb',
  score int default 0,
  approved boolean not null default false,
  verified boolean not null default false,
  profile_complete boolean not null default true,
  documents_verified boolean not null default true,
  payment_verified boolean not null default true,
  admin_verified boolean not null default true,
  owner_email text,
  owner_id uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

alter table public.companies enable row level security;

create policy "approved companies are public" on public.companies
  for select using (approved = true);

create policy "owners can see their own pending company" on public.companies
  for select using (auth.uid() = owner_id);

create policy "admins can see every company" on public.companies
  for select using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin));

create policy "authenticated users can list a company" on public.companies
  for insert with check (auth.uid() = owner_id);

create policy "admins can update any company" on public.companies
  for update using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin));

-- =========================================================================
-- news_items
-- =========================================================================
create table public.news_items (
  id uuid primary key default gen_random_uuid(),
  headline text not null,
  tagline text,
  details text,
  category text,
  hashtags text[] default array[]::text[],
  author text,
  dateline text,
  publish_at timestamptz default now(),
  image_caption text,
  source_type text,
  source text,
  level int default 1,
  audiences text[] not null default array['VIP','Premium','Standard','Guest'],
  channels text[] not null default array['app'],
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

alter table public.news_items enable row level security;

create policy "news visible to public tier" on public.news_items
  for select using ('Guest' = any(audiences));

create policy "news visible to matching member tier" on public.news_items
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and (p.tier = any(audiences) or p.is_admin)
    )
  );

create policy "publishers can insert news" on public.news_items
  for insert with check (
    exists (select 1 from public.profiles p where p.id = auth.uid() and (p.can_publish or p.is_admin))
  );

-- =========================================================================
-- events
-- =========================================================================
create table public.events (
  id uuid primary key default gen_random_uuid(),
  day text not null,
  month text not null,
  type text,
  title text not null,
  place text,
  description text,
  accepted int not null default 0,
  maybe int not null default 0,
  pending int not null default 0,
  theme text default '',
  "public" boolean not null default true,
  capacity int default 0,
  status text not null default 'upcoming',
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

alter table public.events enable row level security;

create policy "events are public" on public.events
  for select using (true);

create policy "publishers can insert events" on public.events
  for insert with check (
    exists (select 1 from public.profiles p where p.id = auth.uid() and (p.can_publish or p.is_admin))
  );

create policy "publishers can update events" on public.events
  for update using (
    exists (select 1 from public.profiles p where p.id = auth.uid() and (p.can_publish or p.is_admin))
  );

-- =========================================================================
-- event_registrations (backs the public "Register now" form)
-- =========================================================================
create table public.event_registrations (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  name text not null,
  email text not null,
  created_at timestamptz not null default now()
);

alter table public.event_registrations enable row level security;

create policy "anyone can register for an event" on public.event_registrations
  for insert with check (true);

create policy "admins can read registrations" on public.event_registrations
  for select using (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

-- Registering bumps the event's accepted count so renderPublicEvents' "seats
-- available" math (capacity - accepted) stays correct without a client round trip.
create function public.handle_new_registration()
returns trigger as $$
begin
  update public.events set accepted = accepted + 1 where id = new.event_id;
  return new;
end;
$$ language plpgsql security definer;

create trigger on_event_registration
  after insert on public.event_registrations
  for each row execute function public.handle_new_registration();

-- =========================================================================
-- Seed data — mirrors the demo content currently hardcoded in www/app.js
-- =========================================================================
insert into public.companies (name, industry, type, membership, location, desc, tags, color, score, approved, verified) values
  ('Mekong AgriTech','Agriculture','Startup','Premium','Phnom Penh','Smart irrigation and farm analytics helping Cambodian growers improve yield and reduce water use.',array['AgriTech','IoT','Growth'],'#3ca37b',92,true,true),
  ('Koompi Digital','Technology','SME','Premium','Phnom Penh','Local technology company building accessible devices, software, and digital education tools.',array['Software','Education','Verified'],'#4267b5',89,true,true);

insert into public.events (day, month, type, title, place, description, accepted, maybe, pending, theme, "public", capacity, status) values
  ('12','JUL','Flagship event','Cambodia Investment Forum 2026','Sofitel Phnom Penh • 8:30 AM','Meet investors, business leaders, public institutions, and founders shaping Cambodia''s next growth chapter.',284,46,31,'',true,500,'upcoming'),
  ('25','JUL','Demo day','SME Growth & Investment Pitch','Factory Phnom Penh • 1:00 PM','Watch investment-ready SMEs present their growth plans and connect with capital and strategic partners.',126,18,42,'green-cover',true,250,'upcoming'),
  ('08','AUG','Workshop','Investment Readiness Bootcamp','Online + IDI Center • 9:00 AM','A practical workshop on pitch decks, financial preparation, valuation, and investor conversations.',82,12,25,'orange-cover',true,150,'upcoming');

insert into public.news_items (headline, tagline, details, category, hashtags, author, dateline, publish_at, source_type, source, level, audiences, channels) values
  ('New investment incentives for priority sectors announced','The new framework offers qualified projects tax incentives and streamlined investment approvals.','PHNOM PENH — A new package of investment incentives has been announced for priority sectors, with a focus on technology, agriculture, logistics and the green economy.','Government & Policy',array['#Cambodia','#Investment','#Policy'],'IDI Newsroom','Phnom Penh, Cambodia','2026-06-30T08:30:00+07','Government','Council for the Development of Cambodia',3,array['VIP'],array['app','email','sms']),
  ('Cambodia Investment Forum opens public registration','Business leaders, investors, founders and professionals can now reserve their place for the July forum.','Public registration is now open for the Cambodia Investment Forum 2026, bringing together investors, entrepreneurs, government representatives and regional business leaders.','Events',array['#InvestmentForum','#Cambodia','#Networking'],'IDI Events Desk','Phnom Penh, Cambodia','2026-06-28T10:00:00+07','IDI Association','IDI APP',1,array['VIP','Premium','Standard','Guest'],array['app','email']);

-- =========================================================================
-- Demo accounts — create these manually in Dashboard -> Authentication -> Users
-- (the SQL editor cannot create auth.users directly), then run the matching
-- UPDATE below for each so the profile fields match the app's demo logins.
-- After creating a user, the handle_new_user trigger already inserted a
-- default Guest profile row for it — these UPDATEs upgrade that row.
-- =========================================================================
-- admin@idiapp.org       / Admin@2026
-- sokha@uniholding.com   / (choose a password)   -> VIP
-- maly@mekongagri.com    / (choose a password)   -> Premium
-- dara@sabaylogistics.com/ (choose a password)   -> Standard
-- chenda@gmail.com       / (choose a password)   -> Guest
-- rina@impactasia.vc     / (choose a password)   -> VIP (VC Partner)
-- vireak@ballangk.com    / (choose a password)   -> Premium (Strategic Partner)

-- Example (run once per demo user, after creating them in the dashboard):
-- update public.profiles set name='Website Administrator', organization='IDI APP', role='Super Admin',
--   tier='Admin', is_admin=true, can_publish=true, can_campaign=true,
--   allowed_pages=array['overview','directory','news','partners','investment-flow','investment-operations','funding-request','memberships','pitching','events','pipeline','messages','reports','staff']
-- where id = (select id from auth.users where email = 'admin@idiapp.org');
