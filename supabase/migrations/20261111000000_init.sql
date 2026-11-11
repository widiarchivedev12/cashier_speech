-- Migration: 20261111000000_init.sql
-- Schema awal Kasir Suara
-- Semua uang dalam rupiah (bigint). Semua waktu timestamptz (UTC).

-- ============================================================
-- TABLES
-- ============================================================

create table stores (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  created_at  timestamptz not null default now()
);

create table store_members (
  store_id  uuid not null references stores on delete cascade,
  user_id   uuid not null references auth.users on delete cascade,
  role      text not null check (role in ('owner', 'cashier')),
  primary key (store_id, user_id)
);

create table products (
  id                uuid        primary key,
  store_id          uuid        not null references stores,
  name              text        not null,
  price             bigint      not null check (price > 0),
  aliases           text[]      not null default '{}',
  is_active         boolean     not null default true,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at        timestamptz
);

create table transactions (
  id                uuid        primary key,
  store_id          uuid        not null references stores,
  device_id         text        not null,
  receipt_no        text        not null,
  total             bigint      not null,
  paid              bigint      not null,
  change            bigint      not null,
  source            text        not null check (source in ('voice', 'manual', 'mixed')),
  raw_transcript    text,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at        timestamptz
);

create table transaction_items (
  id             uuid    primary key,
  transaction_id uuid    not null references transactions on delete cascade,
  product_id     uuid    references products,
  product_name   text    not null,
  unit_price     bigint  not null,
  qty            int     not null check (qty > 0),
  line_total     bigint  not null
);

create table parse_logs (
  id             uuid        primary key,
  store_id       uuid        not null references stores,
  transaction_id uuid        references transactions,
  transcript     text        not null,
  parsed         jsonb       not null,
  corrected      jsonb,
  parser_version text        not null,
  created_at     timestamptz not null
);

-- V2
create table expenses (
  id                uuid        primary key,
  store_id          uuid        not null references stores,
  note              text        not null,
  amount            bigint      not null check (amount > 0),
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at        timestamptz
);

-- ============================================================
-- HELPER FUNCTION
-- (dibuat setelah store_members ada)
-- ============================================================

create or replace function is_store_member(store_id uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1
    from store_members sm
    where sm.store_id = $1
      and sm.user_id  = (select auth.uid())
  );
$$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table stores           enable row level security;
alter table store_members    enable row level security;
alter table products         enable row level security;
alter table transactions     enable row level security;
alter table transaction_items enable row level security;
alter table parse_logs       enable row level security;
alter table expenses         enable row level security;

-- stores
create policy "stores: anggota dapat membaca"
  on stores for select
  to authenticated
  using (is_store_member(id));

-- store_members
create policy "store_members: lihat keanggotaan sendiri"
  on store_members for select
  to authenticated
  using (user_id = (select auth.uid()));

-- products
create policy "products: anggota dapat select"
  on products for select
  to authenticated
  using (is_store_member(store_id));

create policy "products: anggota dapat insert"
  on products for insert
  to authenticated
  with check (is_store_member(store_id));

create policy "products: anggota dapat update"
  on products for update
  to authenticated
  using  (is_store_member(store_id))
  with check (is_store_member(store_id));

-- transactions
create policy "transactions: anggota dapat select"
  on transactions for select
  to authenticated
  using (is_store_member(store_id));

create policy "transactions: anggota dapat insert"
  on transactions for insert
  to authenticated
  with check (is_store_member(store_id));

create policy "transactions: anggota dapat update"
  on transactions for update
  to authenticated
  using  (is_store_member(store_id))
  with check (is_store_member(store_id));

-- transaction_items (akses via join ke transactions)
create policy "transaction_items: anggota dapat select"
  on transaction_items for select
  to authenticated
  using (
    exists (
      select 1 from transactions t
      where t.id = transaction_items.transaction_id
        and is_store_member(t.store_id)
    )
  );

create policy "transaction_items: anggota dapat insert"
  on transaction_items for insert
  to authenticated
  with check (
    exists (
      select 1 from transactions t
      where t.id = transaction_items.transaction_id
        and is_store_member(t.store_id)
    )
  );

-- parse_logs
create policy "parse_logs: anggota dapat select"
  on parse_logs for select
  to authenticated
  using (is_store_member(store_id));

create policy "parse_logs: anggota dapat insert"
  on parse_logs for insert
  to authenticated
  with check (is_store_member(store_id));

-- expenses (V2)
create policy "expenses: anggota dapat select"
  on expenses for select
  to authenticated
  using (is_store_member(store_id));

create policy "expenses: anggota dapat insert"
  on expenses for insert
  to authenticated
  with check (is_store_member(store_id));

create policy "expenses: anggota dapat update"
  on expenses for update
  to authenticated
  using  (is_store_member(store_id))
  with check (is_store_member(store_id));

-- ============================================================
-- TRIGGERS — set_server_updated_at
-- ============================================================

create or replace function set_server_updated_at()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  new.server_updated_at = now();
  return new;
end;
$$;

create trigger set_products_server_updated_at
  before insert or update on products
  for each row execute function set_server_updated_at();

create trigger set_transactions_server_updated_at
  before insert or update on transactions
  for each row execute function set_server_updated_at();

create trigger set_expenses_server_updated_at
  before insert or update on expenses
  for each row execute function set_server_updated_at();

-- ============================================================
-- INDEXES
-- ============================================================

create index on products      (store_id, server_updated_at);
create index on transactions  (store_id, server_updated_at);
create index on transactions  (store_id, created_at);
create index on expenses      (store_id, server_updated_at);

-- ============================================================
-- GRANTS (Data API — PostgREST)
-- ============================================================

grant select, insert, update on stores            to authenticated;
grant select                  on store_members     to authenticated;
grant select, insert, update on products          to authenticated;
grant select, insert, update on transactions      to authenticated;
grant select, insert          on transaction_items to authenticated;
grant select, insert          on parse_logs        to authenticated;
grant select, insert, update on expenses          to authenticated;

-- ============================================================
-- RPCs
-- ============================================================

create or replace function create_store(store_name text)
returns uuid
language plpgsql security definer
set search_path = public
as $$
declare
  new_store_id uuid := gen_random_uuid();
begin
  insert into stores (id, name, created_at)
  values (new_store_id, store_name, now());

  insert into store_members (store_id, user_id, role)
  values (new_store_id, (select auth.uid()), 'owner');

  return new_store_id;
end;
$$;

create or replace function upsert_transaction(payload jsonb)
returns void
language plpgsql security definer
set search_path = public
as $$
declare
  txn        jsonb := payload -> 'transaction';
  store_uuid uuid  := (txn ->> 'store_id')::uuid;
begin
  if not is_store_member(store_uuid) then
    raise exception 'access denied';
  end if;

  insert into transactions (
    id, store_id, device_id, receipt_no,
    total, paid, change, source,
    raw_transcript, created_at, updated_at, deleted_at
  ) values (
    (txn ->> 'id')::uuid,
    store_uuid,
    txn ->> 'device_id',
    txn ->> 'receipt_no',
    (txn ->> 'total')::bigint,
    (txn ->> 'paid')::bigint,
    (txn ->> 'change')::bigint,
    txn ->> 'source',
    txn ->> 'raw_transcript',
    (txn ->> 'created_at')::timestamptz,
    (txn ->> 'updated_at')::timestamptz,
    (txn ->> 'deleted_at')::timestamptz
  )
  on conflict (id) do update set
    total          = excluded.total,
    paid           = excluded.paid,
    change         = excluded.change,
    source         = excluded.source,
    raw_transcript = excluded.raw_transcript,
    updated_at     = excluded.updated_at,
    deleted_at     = excluded.deleted_at
  where transactions.updated_at < excluded.updated_at;

  -- Hanya re-insert items jika baris transaksi benar-benar diperbarui
  if found then
    delete from transaction_items
    where transaction_id = (txn ->> 'id')::uuid;

    insert into transaction_items (
      id, transaction_id, product_id,
      product_name, unit_price, qty, line_total
    )
    select
      (item ->> 'id')::uuid,
      (txn  ->> 'id')::uuid,
      nullif(item ->> 'product_id', '')::uuid,
      item ->> 'product_name',
      (item ->> 'unit_price')::bigint,
      (item ->> 'qty')::int,
      (item ->> 'line_total')::bigint
    from jsonb_array_elements(payload -> 'items') item;
  end if;
end;
$$;

grant execute on function create_store(text)      to authenticated;
grant execute on function upsert_transaction(jsonb) to authenticated;
