# PRD — Kasir Suara

> Aplikasi kasir Android untuk UMKM kuliner dengan input suara berbahasa Indonesia, offline-first, tersinkron ke Supabase.

| | |
|---|---|
| **Status** | Draft v0.1 |
| **Pemilik** | Dinny |
| **Platform** | Android (Flutter) |
| **Backend** | Supabase (Auth, Postgres, RLS, RPC) |
| **Nama kerja** | Kasir Suara (bisa diganti) |

---

## 1. Ringkasan

Kasir Suara memungkinkan penjual mencatat transaksi cukup dengan berbicara, misalnya *"brownies dua, cookies tiga, bayar seratus ribu"*. Ucapan diubah menjadi teks oleh speech-to-text di perangkat, lalu diurai oleh **parser lokal berbahasa Indonesia** menjadi keranjang belanja yang bisa dikonfirmasi dan diedit sebelum disimpan. Semua data disimpan lokal terlebih dahulu dan disinkronkan ke Supabase saat ada koneksi.

## 2. Masalah

- Pedagang UMKM kuliner sering melayani pembeli dengan tangan sibuk (membungkus, memegang uang), sehingga mengetik di aplikasi kasir lambat dan merepotkan.
- Banyak yang akhirnya tidak mencatat penjualan sama sekali, sehingga tidak tahu omzet harian, produk terlaris, dan pengeluaran.
- Aplikasi kasir yang ada umumnya bergantung pada internet dan dirancang untuk input manual.

## 3. Target Pengguna

| Persona | Deskripsi | Kebutuhan utama |
|---|---|---|
| **Pemilik UMKM** (utama) | Menjual snack/kue sendiri, 5–30 produk, sering di lokasi dengan sinyal tidak stabil | Mencatat cepat, rekap harian, tahu untung |
| **Penjaga stan** (V2) | Membantu pemilik berjualan | Input cepat, tanpa akses laporan keuangan |

## 4. Tujuan & Metrik Keberhasilan

| Tujuan | Metrik | Target MVP |
|---|---|---|
| Input lebih cepat dari manual | Waktu rata-rata dari tekan mic sampai transaksi tersimpan | ≤ 10 detik untuk 3 item |
| Parser akurat | % fixture test parser yang lolos | ≥ 95% |
| Parser akurat di dunia nyata | % transaksi suara yang disimpan tanpa koreksi (dari `parse_logs`) | ≥ 80% |
| Andal offline | Seluruh alur kasir berjalan tanpa internet setelah login pertama | 100% |
| Sync aman | Transaksi hilang atau terduplikasi setelah sync | 0 |

**Bukan tujuan (non-goals) MVP:** iOS, multi-cabang, manajemen stok/bahan baku, integrasi pembayaran digital (QRIS), integrasi GoFood/GrabFood, akuntansi lengkap.

## 5. Scope

### MVP
1. Login (Supabase Auth: email + password; Google opsional).
2. Setup toko (1 akun = 1 toko).
3. Katalog produk: CRUD nama, harga, alias, aktif/nonaktif.
4. Input suara → parser → layar konfirmasi → simpan transaksi.
5. Input manual (tap produk) sebagai fallback dan untuk koreksi.
6. Pembayaran: nominal diterima, uang pas, hitung kembalian.
7. Riwayat transaksi + pembatalan (soft delete).
8. Penyimpanan lokal (Drift) dan sinkronisasi dua arah ke Supabase.
9. Rekap harian: omzet, jumlah transaksi, produk terlaris.
10. Onboarding pengecekan paket bahasa Indonesia offline untuk speech-to-text.

### V2
- Pencatatan pengeluaran via suara (`pengeluaran beli tepung 45 ribu`).
- Cetak struk ke printer thermal Bluetooth (58 mm).
- Laporan grafik mingguan/bulanan, laba kotor (omzet − pengeluaran).
- Kamus bahasa gaul nominal (goceng, ceban, dst.) yang dapat diaktifkan.
- Peran penjaga stan (`store_members.role = 'cashier'`).
- Statistik akurasi parser di layar pengaturan.
- Realtime: penjualan muncul langsung di perangkat lain.

### V3 (opsional)
- Fallback LLM via Supabase Edge Function untuk kalimat yang gagal diurai (online saja, dengan persetujuan pengguna).
- Saran alias otomatis dari pola koreksi di `parse_logs`.

## 6. User Stories (MVP)

| ID | Sebagai | Saya ingin | Supaya |
|---|---|---|---|
| US-01 | pemilik | menahan tombol mic lalu menyebut pesanan | tidak perlu mengetik saat melayani |
| US-02 | pemilik | melihat hasil terjemahan suara sebagai keranjang sebelum disimpan | bisa memperbaiki salah dengar |
| US-03 | pemilik | bagian yang ragu ditandai | tahu persis apa yang perlu dicek |
| US-04 | pemilik | menyebut "bayar seratus ribu" | kembalian dihitung otomatis |
| US-05 | pemilik | menambah alias produk ("bronis") | parser mengenali cara saya menyebut produk |
| US-06 | pemilik | aplikasi tetap jalan tanpa sinyal | bisa berjualan di mana saja |
| US-07 | pemilik | data tersinkron ke cloud | data aman jika HP rusak/ganti |
| US-08 | pemilik | melihat omzet dan produk terlaris hari ini | tahu performa harian |
| US-09 | pemilik | membatalkan transaksi yang salah | rekap tetap akurat |
| US-10 | pemilik | menambah item dengan tap | tetap bisa bertransaksi saat suara tidak cocok dipakai |

## 7. Spesifikasi Fungsional

### 7.1 Alur Input Suara

```
[Tahan mic] → speech_to_text (id_ID, on-device bila tersedia)
            → transcript (String)
            → VoiceParser.parse(transcript, catalog)  ← pure Dart, sinkron
            → ParseResult { commands, issues }
            → CartController.apply(commands)
            → Layar Konfirmasi (editable)
            → [Simpan] → Drift (transaction + items + outbox) → sync di background
```

- **Push-to-talk:** rekam selama tombol ditahan; lepas = selesai. Tap singkat = mode toggle (tap lagi untuk berhenti).
- Hasil suara **ditambahkan** ke keranjang yang sedang aktif (bisa beberapa kali bicara untuk satu transaksi).
- Transcript mentah ditampilkan kecil di atas keranjang.
- Jika `speech_to_text` tidak tersedia atau izin mikrofon ditolak → tampilkan input manual dan pesan yang jelas.

### 7.2 Layar Konfirmasi

- Daftar item: nama produk, qty (stepper), harga baris, total.
- Item dengan `issue` ditandai warna peringatan + alasan singkat (mis. "Produk tidak dikenal: *brownis keju*", "Harga beda dari katalog").
- Item tidak dikenal menampilkan pilihan: pilih dari saran produk / pilih manual / hapus.
- Ringkasan: total, dibayar, kembalian. Tombol **Simpan** nonaktif jika masih ada item tidak dikenal atau dibayar < total.
- Saat disimpan, jika hasil akhir berbeda dari hasil parser, simpan ke `parse_logs` (`parsed` vs `corrected`).

### 7.3 Spesifikasi Parser

Paket Dart murni `packages/voice_parser` (tanpa dependensi Flutter).

**API:**
```dart
ParseResult parse(String transcript, List<CatalogEntry> catalog, {ParserConfig config});

class CatalogEntry { String productId; String name; List<String> aliases; int price; }

sealed class ParsedCommand
  AddItem(productId, qty, lineTotalOverride?, confidence, sourceText)
  RemoveItem(productId, sourceText)
  RemoveLast()
  ClearCart()
  SetPayment(amount)        // amount null = uang pas
  AddExpense(note, amount)  // V2
  Unknown(sourceText)

class ParseIssue { IssueType type; String sourceText; List<String> suggestions; }
```

**Tahapan:**
1. **Normalisasi:** lowercase, hapus tanda baca kecuali pemisah ribuan pada angka, ubah `rp50.000` / `50rb` / `50k` / `50.000` → token angka. *Catatan: Google STT sering sudah mengeluarkan digit ("50.000"), jadi parser wajib menangani digit dan kata.*
2. **Buang kata pengisi:** `jual, tambah, minta, ya, deh, dong, kak, mbak, mas, bu, pak, aja`.
3. **Segmentasi** dengan pemisah: koma, `dan`, `sama`, `terus`, `lalu`, `plus`.
4. **Konversi angka kata → int:** `nol…sembilan`, `sepuluh`, `sebelas`, `X belas`, `X puluh`, `seratus`/`X ratus`, `seribu`/`X ribu`/`rebu`/`ewu`, `sejuta`/`X juta`. Kombinasi bebas: *"seratus dua puluh lima ribu"* → 125000.
5. **Klasifikasi intent per segmen** (urutan prioritas):
   | Pola | Command |
   |---|---|
   | `batal semua` / `hapus semua` / `ulang` | `ClearCart` |
   | `batal (yang) terakhir` / `hapus (yang) terakhir` | `RemoveLast` |
   | `hapus\|batal\|nggak jadi <produk>` | `RemoveItem` |
   | `uang pas` / `bayar pas` | `SetPayment(null)` |
   | `bayar\|uang\|dibayar\|terima <nominal>` | `SetPayment(n)` |
   | `pengeluaran\|keluar <catatan> <nominal>` (V2) | `AddExpense` |
   | mengandung nama/alias produk | `AddItem` |
   | lainnya | `Unknown` + issue |
6. **Aturan `AddItem`:**
   - Qty boleh sebelum atau sesudah produk ("dua brownies" = "brownies dua"). Default qty = 1.
   - Angka **dengan** penanda mata uang (`ribu`, `juta`, `rupiah`, atau ≥ 1000 dalam bentuk digit) = harga, bukan qty.
   - Harga yang diucapkan = **total baris**, kecuali didahului `per`, `satunya`, `@`, `per biji` → harga satuan.
   - Jika harga diucapkan ≠ harga katalog × qty → tetap pakai harga ucapan, tambahkan issue `priceMismatch`.
7. **Pencocokan produk (fuzzy):** Jaro-Winkler pada nama + alias (n-gram 1–3 kata dari segmen).
   - skor ≥ 0.88 → cocok otomatis
   - 0.75–0.88 → cocok + issue `lowConfidence` dengan saran
   - < 0.75 → `Unknown` + issue `unknownProduct` dengan 3 saran teratas
   - Ambang batas ada di `ParserConfig`.
8. **Performa:** < 50 ms untuk katalog 100 produk di perangkat kelas menengah.

**Fixture wajib (katalog: Brownies 10.000, Cookies 5.000, Bolu Pandan 25.000, Es Teh 4.000; alias Brownies: "bronis", "brownis"):**

| # | Transcript | Hasil yang diharapkan |
|---|---|---|
| 1 | `brownies dua` | AddItem(Brownies, 2) |
| 2 | `dua brownies` | AddItem(Brownies, 2) |
| 3 | `bronis` | AddItem(Brownies, 1) |
| 4 | `brownies dua, cookies tiga` | AddItem(Brownies,2), AddItem(Cookies,3) |
| 5 | `brownies 2 sama es teh 3` | AddItem(Brownies,2), AddItem(Es Teh,3) |
| 6 | `bolu pandan satu bayar lima puluh ribu` | AddItem(Bolu Pandan,1), SetPayment(50000) |
| 7 | `bayar 100.000` | SetPayment(100000) |
| 8 | `uang pas` | SetPayment(null) |
| 9 | `brownies dua dua puluh ribu` | AddItem(Brownies,2, lineTotal 20000), tanpa issue |
| 10 | `brownies dua lima belas ribu` | AddItem(Brownies,2, lineTotal 15000) + issue priceMismatch |
| 11 | `cookies tiga empat ribu satunya` | AddItem(Cookies,3, lineTotal 12000) + issue priceMismatch |
| 12 | `hapus cookies` | RemoveItem(Cookies) |
| 13 | `batal yang terakhir` | RemoveLast |
| 14 | `batal semua` | ClearCart |
| 15 | `martabak dua` | Unknown + issue unknownProduct |
| 16 | `jual brownies sepuluh ya kak` | AddItem(Brownies,10) |
| 17 | `bayar seratus dua puluh lima ribu` | SetPayment(125000) |
| 18 | `brownis sebelas` | AddItem(Brownies,11) |
| 19 | `es teh dua belas, bolu pandan dua` | AddItem(Es Teh,12), AddItem(Bolu Pandan,2) |
| 20 | `` (kosong) | ParseResult kosong, tanpa error |

### 7.4 Katalog Produk
- Field: nama (wajib, unik per toko, case-insensitive), harga (int rupiah, > 0), alias (0–10), aktif.
- Produk nonaktif tidak ikut dicocokkan parser dan tidak tampil di grid manual, tetapi tetap tampil di riwayat.
- Peringatan saat alias bentrok dengan nama/alias produk lain.

### 7.5 Transaksi
- Saat disimpan: buat `transactions` + `transaction_items` dalam satu transaksi database lokal, `id` UUID v4 dibuat di klien.
- `transaction_items` menyimpan **snapshot** nama dan harga produk saat transaksi.
- Pembatalan = isi `deleted_at`; tidak ada hard delete.
- Nomor struk tampilan: `YYMMDD-NNN` per perangkat (lokal saja, bukan kunci).

### 7.6 Rekap Harian
- Omzet, jumlah transaksi, rata-rata per transaksi, 5 produk terlaris (qty & rupiah), rasio transaksi suara vs manual.
- Dihitung dari data lokal (bekerja offline). Zona waktu: `Asia/Jakarta`.

### 7.7 Autentikasi & Toko
- Login pertama butuh internet. Sesi disimpan oleh `supabase_flutter`; aplikasi tetap dapat dipakai offline selama sesi lokal ada.
- Setelah daftar: buat `stores` + `store_members(role='owner')` lewat RPC `create_store(name)`.

## 8. Model Data

### 8.1 Supabase (Postgres)

```sql
-- Semua uang dalam rupiah sebagai bigint. Semua waktu timestamptz (UTC).

create table stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table store_members (
  store_id uuid references stores on delete cascade,
  user_id uuid references auth.users on delete cascade,
  role text not null check (role in ('owner','cashier')),
  primary key (store_id, user_id)
);

create table products (
  id uuid primary key,               -- dibuat klien
  store_id uuid not null references stores,
  name text not null,
  price bigint not null check (price > 0),
  aliases text[] not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null,
  updated_at timestamptz not null,   -- waktu klien, untuk LWW
  server_updated_at timestamptz not null default now(), -- trigger, untuk cursor pull
  deleted_at timestamptz
);

create table transactions (
  id uuid primary key,
  store_id uuid not null references stores,
  device_id text not null,
  receipt_no text not null,
  total bigint not null,
  paid bigint not null,
  change bigint not null,
  source text not null check (source in ('voice','manual','mixed')),
  raw_transcript text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table transaction_items (
  id uuid primary key,
  transaction_id uuid not null references transactions on delete cascade,
  product_id uuid references products,
  product_name text not null,        -- snapshot
  unit_price bigint not null,        -- snapshot
  qty int not null check (qty > 0),
  line_total bigint not null
);

create table parse_logs (
  id uuid primary key,
  store_id uuid not null references stores,
  transaction_id uuid references transactions,
  transcript text not null,
  parsed jsonb not null,
  corrected jsonb,                   -- null = disimpan tanpa koreksi
  parser_version text not null,
  created_at timestamptz not null
);

-- V2
create table expenses (
  id uuid primary key,
  store_id uuid not null references stores,
  note text not null,
  amount bigint not null check (amount > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
```

- Trigger `set_server_updated_at` (before insert/update) pada `products`, `transactions`, `expenses`.
- Index: `(store_id, server_updated_at)` pada tabel yang di-pull; `(store_id, created_at)` pada `transactions`.

### 8.2 RLS
- RLS **aktif di semua tabel**.
- Fungsi bantu `is_store_member(store_id uuid) returns boolean` (security definer, `search_path` dikunci).
- `select/insert/update` diizinkan jika `is_store_member(store_id)`; `delete` tidak diizinkan (soft delete saja).
- `transaction_items` diakses melalui join ke `transactions.store_id`.
- V2: kasir tidak boleh `select` laporan agregat / `expenses`.

### 8.3 RPC
- `create_store(name text) returns uuid`
- `upsert_transaction(payload jsonb) returns void` — upsert transaksi + item secara atomik, idempotent berdasarkan `id`; LWW berdasarkan `updated_at`.
- `daily_summary(store_id uuid, day date) returns json` (untuk V2 / web dashboard).

### 8.4 Lokal (Drift)
- Tabel cermin: `products`, `transactions`, `transaction_items`, `parse_logs`, `expenses`.
- `sync_outbox (id, entity, record_id, op, payload, created_at, attempts, last_error)`
- `sync_state (entity, last_pulled_server_updated_at)`

## 9. Desain Sinkronisasi

- **Local-first:** UI hanya membaca/menulis Drift. Repository menulis data + baris `sync_outbox` dalam satu transaksi Drift.
- **Push:** dipicu saat online (connectivity_plus), saat app ke foreground, dan setelah setiap simpan. Urutan: `products` → `transactions` (via RPC `upsert_transaction`) → `parse_logs` → `expenses`. Hapus baris outbox setelah sukses; jika gagal, `attempts++` dengan backoff eksponensial (maks 5 menit).
- **Pull:** per entity, ambil `server_updated_at > cursor` (batch 500), upsert lokal dengan aturan LWW (`updated_at` lebih baru menang), simpan cursor = `server_updated_at` terbesar.
- **Konflik:** transaksi bersifat append-mostly sehingga konflik jarang; produk memakai LWW. Cursor memakai waktu server agar aman dari selisih jam perangkat.
- **Idempotensi:** semua id UUID dari klien; push ulang tidak menimbulkan duplikat.
- Indikator status sync di app bar: tersinkron / menunggu (n) / gagal.

## 10. Kebutuhan Non-Fungsional

| Aspek | Kebutuhan |
|---|---|
| Platform | Android minSdk 24, targetSdk terbaru |
| Offline | Semua fitur MVP kecuali login pertama & sync |
| Performa | Parse < 50 ms; simpan transaksi < 200 ms; cold start < 2 detik |
| Keamanan | Hanya publishable key di klien (tanpa service_role/secret key); semua akses dijaga RLS; otorisasi tidak memakai `user_metadata`; tidak ada secret di repo |
| Privasi | Audio tidak disimpan dan tidak dikirim ke server; hanya transcript teks |
| Aksesibilitas | Target sentuh ≥ 48 dp, kontras WCAG AA, tombol mic besar |
| Bahasa UI | Bahasa Indonesia |
| Kualitas | Coverage parser ≥ 90%; CI menjalankan analyze + test |

## 11. Arsitektur

```
Flutter app (feature-first)
 ├─ presentation  : widgets + Riverpod providers/notifiers
 ├─ domain        : entity, use case murni
 └─ data          : repository → Drift DAO (lokal) + Supabase datasource (remote)
packages/voice_parser : pure Dart, diuji terpisah
supabase/             : migrations, seed, RPC (SQL)
```

**Stack:** Flutter stable · Dart 3 · flutter_riverpod + riverpod_generator · go_router · drift · supabase_flutter · speech_to_text · connectivity_plus · freezed + json_serializable · uuid · intl · fl_chart (V2) · paket printer thermal Bluetooth (V2).

## 12. Milestone

| # | Milestone | Hasil |
|---|---|---|
| M0 | Setup | Repo, lint, CI, Supabase lokal, struktur folder, env config |
| M1 | Parser | `voice_parser` + 20 fixture lolos (TDD) |
| M2 | Katalog & kasir manual (offline) | CRUD produk, keranjang, simpan transaksi ke Drift |
| M3 | Input suara | speech_to_text + layar konfirmasi + parse_logs |
| M4 | Auth & sync | Login, create_store, RLS, outbox push/pull |
| M5 | Rekap & polish | Rekap harian, riwayat, onboarding, ikon, closed testing Play Store |

## 13. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| STT salah dengar di lingkungan bising | Layar konfirmasi wajib, alias produk, push-to-talk dekat mulut |
| Paket bahasa offline belum terpasang | Onboarding mengecek & memandu unduh; fallback input manual |
| Ambiguitas angka ("dua lima belas ribu") | Aturan penanda mata uang + issue priceMismatch, bukan menebak diam-diam |
| Bug sync menduplikasi/menghilangkan data | UUID klien, RPC atomik idempoten, test integrasi sync |
| Format output STT berubah antar versi | Parser menerima digit maupun kata; fixture untuk keduanya |

## 14. Pertanyaan Terbuka

1. Nama aplikasi final?
2. Perlu dukungan bahasa Jawa/Osing untuk angka & kata pengisi di MVP, atau cukup V2?
3. Model harga: gratis (portofolio) atau ada rencana freemium?
4. Printer thermal yang dipakai untuk uji V2 (merek/model)?
