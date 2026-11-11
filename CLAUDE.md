# CLAUDE.md — Kasir Suara

Aplikasi kasir Android (Flutter) dengan input suara bahasa Indonesia, offline-first, sync ke Supabase.
**Spesifikasi lengkap ada di `PRD.md` — baca bagian terkait sebelum mengerjakan fitur.**

## Perintah

```bash
# Dependensi & codegen
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # setelah ubah drift/freezed/riverpod

# Kualitas
flutter analyze
dart format .
flutter test                                # test app
(cd packages/voice_parser && dart test)     # test parser

# Jalankan (env.json di-gitignore, lihat env.example.json)
flutter run --dart-define-from-file=env.json

# Supabase lokal
supabase start
supabase db reset                           # terapkan ulang migrations + seed
supabase migration new <nama_snake_case>
supabase gen types typescript --local > /dev/null   # opsional, cek skema
```

## Struktur

```
lib/
  app/                 # router (go_router), theme, bootstrap
  core/                # db (Drift), sync engine, supabase client, utils (money, time)
  features/
    auth/  catalog/  cashier/  voice/  history/  reports/
      data/            # repository, DAO, remote datasource
      domain/          # entity (freezed), use case
      presentation/    # pages, widgets, providers
packages/voice_parser/ # pure Dart, TANPA import Flutter
supabase/migrations/   # SQL berurutan, sumber kebenaran skema
test/                  # mirror struktur lib/
```

## Aturan Wajib

**Data & uang**
- Uang selalu `int` rupiah (Dart) / `bigint` (Postgres). Jangan pernah `double` untuk uang.
- Waktu disimpan UTC; konversi ke `Asia/Jakarta` hanya di layer presentasi/rekap.
- ID entity dibuat di klien dengan UUID v4 (`package:uuid`).
- Tidak ada hard delete; pakai `deleted_at`.
- `transaction_items` menyimpan snapshot `product_name` dan `unit_price`.

**Offline-first & sync**
- UI/providers **tidak boleh** memanggil Supabase langsung untuk data bisnis. Semua baca/tulis lewat repository → Drift.
- Setiap tulis lokal yang perlu disinkron harus menulis baris `sync_outbox` **di transaksi Drift yang sama**.
- Cursor pull memakai `server_updated_at`; konflik memakai LWW pada `updated_at`.
- Transaksi + item di-push lewat RPC `upsert_transaction` (atomik, idempoten).

**Parser (`packages/voice_parser`)**
- Pure Dart, deterministik, tanpa I/O, tanpa dependensi Flutter.
- **TDD:** untuk perilaku baru atau bug, tambahkan fixture/test yang gagal dulu, baru implementasi.
- Fixture wajib ada di PRD §7.3 — semuanya harus selalu lolos.
- Jangan menebak diam-diam: kondisi ambigu menghasilkan `ParseIssue`, bukan asumsi tersembunyi.
- Naikkan `parserVersion` setiap perubahan perilaku.

**Supabase**
- Perubahan skema hanya lewat migration baru; jangan edit migration yang sudah ada/diterapkan.
- Setiap tabel baru: `enable row level security` + policy berbasis `is_store_member(store_id)` di migration yang sama.
- Fungsi `security definer` wajib `set search_path = public`.
- Klien hanya memakai **publishable key** (`sb_publishable_...`); anon key lama hanya untuk kompatibilitas. `service_role`/secret key **tidak boleh** ada di app.
- Jangan commit URL/key; gunakan `env.json` (gitignored) dengan `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY`.
- Otorisasi RLS tidak boleh memakai `user_metadata` (bisa diedit user); keanggotaan toko dicek lewat tabel `store_members`.

**Kode**
- Riverpod dengan `riverpod_generator` (`@riverpod`); entity pakai `freezed`.
- Lint: `very_good_analysis` (atau `flutter_lints` jika belum dipasang) — `flutter analyze` harus bersih.
- Teks UI dalam Bahasa Indonesia; identifier, komentar kode, dan nama file dalam bahasa Inggris.
- Jangan commit file hasil generate yang di-gitignore; jangan edit manual `*.g.dart` / `*.freezed.dart`.
- Perubahan kecil dan terfokus; jangan refactor di luar scope tugas.

## Skills

Skill terpasang global di `~/.agents/skills`. Muat dengan Skill tool **sebelum** mulai mengerjakan:

| Kapan | Muat skill |
|---|---|
| Apa pun yang menyentuh Supabase: Auth, `supabase_flutter`, CLI, Edge Function, Realtime, konfigurasi proyek | `supabase` |
| Menulis/mengubah migration, tabel, tipe kolom, RLS policy, index, trigger, fungsi/RPC (`upsert_transaction`, `is_store_member`, dll.) | `supabase-postgres-best-practices` (bersama `supabase`) |
| Merancang fitur atau perubahan perilaku baru sebelum menulis kode | `brainstorming` |
| Membuat/mengubah layar & teks UI | `antislop`, `antislop-ui`, `antislop-human`, `antislop-copywriting` (ambil prinsipnya; contoh CSS/web diterjemahkan ke widget Flutter) |
| Merapikan komentar kode | `antislop-code` |

**Jangan dipakai di proyek ini:**
- `drizzle` — itu ORM **TypeScript**, bukan **Drift** (database lokal Flutter yang dipakai di sini). Untuk Drift, ikuti dokumentasi resmi drift.simonbinder.eu.
- `shadcn`, `migrate-radix-to-base` — khusus React/web.
- `agent-browser`, `browser-use` — tidak ada UI web di proyek ini.
- `antislop-layoutmobile` — fokus layout responsif web; app ini Android-only.

## Definition of Done

1. `flutter analyze` bersih dan `dart format` sudah dijalankan.
2. Semua test lolos (app + `voice_parser`).
3. Fitur baru punya test: unit untuk logika/parser, widget test untuk layar konfirmasi & kasir, test repository untuk alur outbox.
4. Migration baru diuji dengan `supabase db reset`.
5. Jika perilaku berbeda dari PRD, perbarui `PRD.md` dalam perubahan yang sama dan sebutkan alasannya.

## Urutan Pengerjaan

Ikuti milestone PRD §12: M0 setup → M1 parser → M2 katalog & kasir offline → M3 suara → M4 auth & sync → M5 rekap & polish. Jangan mulai milestone berikutnya sebelum DoD milestone saat ini terpenuhi.
