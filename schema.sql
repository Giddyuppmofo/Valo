-- Vaylo Peptides: starter Supabase schema
-- Run in the Supabase SQL editor. Review before production use.

create table if not exists products (
  slug        text primary key,
  sort        int  not null default 0,
  category    text not null check (category in ('peptide','other','blend','stack','supply')),
  name        text not null,
  aka         text,
  residues    jsonb,          -- array of residue tokens, drawn as the bead chain
  contents    jsonb,          -- array of strings, for blends and stacks
  note        text,
  formula     text,
  mol_weight  text,
  cas         text,
  form        text,
  size        text,           -- TODO: not yet supplied
  price_usd   numeric(10,2),  -- TODO: not yet supplied
  active      boolean not null default true,
  updated_at  timestamptz not null default now()
);

create table if not exists inquiries (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  name          text not null,
  organization  text not null,
  email         text not null,
  message       text,
  product_slugs text[] not null default '{}',
  research_use_confirmed boolean not null check (research_use_confirmed),
  status        text not null default 'new'
);

alter table products  enable row level security;
alter table inquiries enable row level security;

-- Anyone can read active products.
create policy "public read products" on products
  for select to anon, authenticated using (active);

-- Anyone can submit an inquiry; nobody can read them with the public key.
create policy "public insert inquiries" on inquiries
  for insert to anon, authenticated with check (research_use_confirmed);

-- Staff read inquiries from the Supabase dashboard or with the service role key
-- (server side only; never ship the service role key in the browser).
