# PRD — Harvesta: Tree & Orchard Management System

> **Dokumen ini adalah sumber kebenaran (single source of truth) proyek.** Semua anggota tim dan semua AI agent WAJIB membaca dokumen ini sebelum menulis kode. Jika ada konflik antara instruksi lain dan dokumen ini, dokumen ini yang menang. Jika dokumen ini perlu diubah, ubah lewat Pull Request dan beri tahu seluruh tim.

- **Mata kuliah:** EF234301 Web Programming (D) — Midterm Exam
- **Tim:** maksimal 3 mahasiswa (nama: `{{MEMBER_A}}`, `{{MEMBER_B}}`, `{{MEMBER_C}}`)
- **Deadline:** 28 Oktober 2026, pukul 23:59 WIB (denda keterlambatan 0,15% nilai **per menit**; terlambat 1 jam = potongan 9%)
- **Nama aplikasi:** `HARVESTA`

---

## 1. Ringkasan Produk

Harvesta adalah aplikasi web CRUD untuk mengelola kebun pohon skala kecil. Pengguna dapat mencatat blok lahan, jenis pohon (umum, bukan khusus satu spesies), data tiap pohon, riwayat perawatan, hasil panen, pengeluaran, dan penjualan, lalu melihat dashboard dan laporan untuk evaluasi produktivitas serta keuntungan kebun.

**Prinsip desain produk**
1. **Generik:** jenis pohon dan kategori adalah data master yang dikelola pengguna (bukan hardcode). Contoh: kategori "Fruit", jenis "Durian".
2. **Sederhana:** alur harian cukup 3 langkah: pilih pohon → catat perawatan/panen → lihat ringkasan.
3. **Mobile-friendly:** petugas menginput dari HP di kebun.

**Tujuan**
- Memenuhi seluruh syarat tugas midterm (bagian 2) dengan nilai maksimal.
- Menghasilkan aplikasi yang rapi, aman, konsisten, dan ter-deploy.

**Bukan tujuan (non-goals)**
- Tidak ada aplikasi mobile native, pembayaran online, integrasi IoT/sensor, multi-tenant, atau multi-bahasa.
- Tidak ada API publik (REST) kecuali dibutuhkan fitur internal.

---

## 2. Syarat Tugas (Wajib Dipenuhi)

| # | Syarat | Cara pemenuhan |
|---|--------|----------------|
| R1 | Website CRUD memakai Java/Jakarta JSP | Java 21, Jakarta Servlet 6, JSP 3.1, dan Tomcat 10.1 |
| R2 | Minimal 8 fitur, tidak termasuk autentikasi | 11 fitur (F-01 s.d. F-11), bagian 5 |
| R3 | Login, registrasi, dan logout | Java Servlet auth flow (bagian 5.0) |
| R4 | Skema database punya minimal 1 foreign key | Banyak FK (bagian 6) |
| R5 | Laporan: desain database (CDM & PDM) | Bagian 11 |
| R6 | Laporan: daftar fitur | Bagian 11 |
| R7 | Laporan: screenshot + penjelasan tiap fitur | Bagian 11 |
| R8 | Laporan: persentase dan kontribusi tiap anggota | Bagian 11 |
| R9 | Deploy aplikasi | Docker Compose di CasaOS; akses publik melalui Cloudflare Tunnel |
| R10 | Source code lengkap di GitHub **publik** | Bagian 9 |

**Rubrik:** Design 20 · Implementation 50 · Analysis/Evaluation 25 · Conclusion 5 = 100.

**Aturan pengumpulan (jangan sampai salah)**
- Kirim email ke dosen pengampu, CC ke dua asisten (alamat ada di soal ujian).
- Subjek email: `EF234301_WebPro_MID_StudentID1_Name1_StudentID2_Name2` (sesuaikan jumlah anggota).
- Lampiran: **satu** ZIP bernama `EF234301_WebPro_MID_StudentID1_Name1_StudentID2_Name2.ZIP` berisi tepat dua file: `Report.PDF` dan `Declaration.PDF` (pernyataan integritas akademik yang sudah ditandatangani).
- Isi email wajib memuat **link repository GitHub publik**.
- Target kirim: **paling lambat 28 Okt 2026 pukul 20:00 WIB**, jangan menunggu menit-menit terakhir.

---

## 3. Bahasa, Konvensi Umum, dan Konfigurasi Dasar

### 3.1 Aturan bahasa (PENTING)
| Bagian | Bahasa |
|--------|--------|
| Dokumen PRD, README internal, komentar diskusi tim | Indonesia |
| **Seluruh UI aplikasi** (menu, label, tombol, placeholder, pesan validasi, flash message, email, judul halaman, teks kosong/empty state, seed data, nama kolom pada tabel/ekspor) | **Inggris dengan grammar yang benar** |
| Nama variabel, class, method, tabel, kolom, route, nama file, commit message, nama branch | Inggris |
| Laporan PDF | Boleh Indonesia (kecuali screenshot yang otomatis Inggris) |

Aturan tambahan UI:
- Gunakan Title Case untuk judul halaman dan menu ("Care Logs"), sentence case untuk tombol dan pesan ("Save changes", "The tree was created successfully.").
- Pesan validasi dan flash harus kalimat lengkap berakhiran titik.
- Jangan hardcode teks di banyak tempat tanpa perlu; gunakan file lang `lang/en/*.php` untuk pesan yang berulang. `APP_LOCALE=en`, `APP_FALLBACK_LOCALE=en`.
- Format tanggal tampilan: `21 Oct 2026` (`d M Y`). Format angka: `1,250,000.50`. Mata uang: `IDR 1,250,000` (tanpa simbol Rp). Zona waktu: `Asia/Jakarta` (`APP_TIMEZONE`).

### 3.2 Aturan kode umum
- Java 21 untuk kode aplikasi; gunakan Servlet untuk alur request dan JSP/JSTL untuk tampilan.
- Satu kelas satu tanggung jawab. Logika bisnis dan akses database tidak diletakkan di JSP.
- Validasi dan otorisasi wajib dilakukan di server sebelum mengubah data.
- Gunakan prepared statement untuk seluruh nilai SQL dari request; jangan menggabungkan input pengguna ke query.
- Query daftar wajib memakai pagination dan memuat relasi yang diperlukan tanpa N+1.
- Jangan pernah menulis rahasia ke repo.

### 3.3 Nama aplikasi
- Brand yang ditampilkan tetap `HARVESTA` agar sesuai dengan situs acuan.
- Judul tab memuat nama halaman dan brand; logo serta favicon menggunakan aset yang sudah ada.

---

## 4. Pengguna dan Peran

| Peran | Siapa | Hak akses |
|-------|-------|-----------|
| **Admin** | Pemilik/pengelola kebun | Akses penuh: semua CRUD, data master, keuangan, laporan, manajemen pengguna |
| **Staff** | Petugas lapangan | Lihat data; buat/ubah Trees, Care Logs, Harvests. **Tidak** bisa menghapus data, tidak bisa membuka Finance, Users, maupun mengubah data master |

Aturan:
- Pengguna yang mendaftar sendiri lewat halaman Register otomatis berperan **Staff**.
- Admin pertama dibuat oleh seeder. Hanya Admin yang dapat mengubah peran pengguna lain.
- Admin tidak boleh menghapus atau menurunkan peran dirinya sendiri jika ia satu-satunya Admin.
- Persona: (1) *Owner* yang butuh gambaran untung/rugi dan produktivitas; (2) *Field staff* yang butuh input cepat dari HP.

---

## 5. Fitur

Semua fitur: tabel dengan pencarian, filter, sortir, pagination (15/halaman), konfirmasi sebelum hapus, flash message sukses/gagal, dan empty state yang informatif.

### 5.0 Autentikasi (tidak dihitung dalam 8 fitur minimum)
- Register (name, email, password + confirmation), Login (email + password, remember me), Logout, dan Forgot/Reset password.
- Two-factor authentication tetap menjadi fitur yang diminta dari versi acuan. Akun yang mendaftar otomatis berperan `staff`; halaman lain dilindungi autentikasi.
- Halaman selain auth wajib diproteksi middleware `auth` (dan `verified` hanya jika email verification diaktifkan; **default: tidak diaktifkan** agar demo mudah).
- Registration, password confirmation, dan two-factor authentication termasuk kebutuhan dari aplikasi acuan. Email verification dan passkeys tidak termasuk kebutuhan.

### F-01 Dashboard
- **Akses:** Admin, Staff (konten finansial hanya untuk Admin).
- Kartu statistik: total trees, trees per status, total blocks, harvest bulan ini, *(Admin)* expenses bulan ini, sales bulan ini, net profit bulan ini.
- Widget: "Upcoming Care" (care log dengan `next_due_on` ≤ 7 hari ke depan atau terlambat), "Recent Harvests" (5 terakhir).
- Grafik: panen per bulan (12 bulan terakhir), *(Admin)* expenses vs sales per bulan.
- **Selesai jika:** angka cocok dengan data seeder dan tidak ada N+1 (maks. ±15 query).

### F-02 Categories (data master)
- Atribut: `name` (wajib, unik, maks. 100), `description` (opsional).
- **Akses:** Admin = CRUD; Staff = lihat.
- Aturan: kategori yang masih dipakai oleh Tree Type tidak boleh dihapus (tampilkan pesan: "This category cannot be deleted because it is still used by tree types.").

### F-03 Tree Types (data master)
- Atribut: `category_id` (wajib), `name` (wajib, unik per kategori), `scientific_name` (opsional), `description` (opsional).
- **Akses:** Admin = CRUD; Staff = lihat.
- Aturan: tidak bisa dihapus jika masih dipakai Tree. Filter daftar berdasarkan kategori.

### F-04 Blocks (blok/lahan)
- Atribut: `name` (wajib, unik), `area_sqm` (opsional, ≥ 0), `location_note` (opsional), `description` (opsional).
- **Akses:** Admin = CRUD; Staff = lihat.
- Halaman detail: daftar pohon di blok itu + ringkasan (jumlah pohon, total panen).
- Aturan: tidak bisa dihapus jika masih ada Tree.

### F-05 Trees (inti aplikasi)
- Atribut: `code` (wajib, unik, format bebas mis. `T-0001`; boleh digenerate otomatis), `tree_type_id`, `block_id`, `planted_on` (tanggal, tidak boleh di masa depan), `status` (`seedling`, `growing`, `productive`, `needs_attention`, `dead`), `height_cm` (opsional), `notes`, `photo_path` (opsional).
- **Foto:** satu foto per pohon, JPG/PNG/WebP, maks. 2 MB, disimpan lewat disk `photos` (bagian 10.3). Tampilkan thumbnail di daftar dan foto besar di detail.
- **Akses:** Admin = CRUD (hapus = soft delete); Staff = buat, lihat, ubah.
- Pencarian: kode/catatan. Filter: block, tree type, category, status. Sortir: code, planted_on.
- Halaman detail: info pohon, timeline care logs, daftar harvests, total panen.
- Aturan: pohon berstatus `dead` tidak boleh menerima care log atau harvest baru.

### F-06 Care Logs (riwayat perawatan)
- Atribut: `tree_id`, `activity_type` (`watering`, `fertilizing`, `pruning`, `pest_control`, `disease_treatment`, `weeding`, `inspection`, `other`), `performed_on` (tidak boleh di masa depan), `next_due_on` (opsional, harus ≥ `performed_on`), `notes`. `user_id` diisi otomatis dari pengguna yang login.
- **Akses:** Admin = CRUD; Staff = buat, lihat, ubah (hanya milik sendiri).
- Filter: tree, block, activity type, rentang tanggal.
- Tombol cepat "Add care log" dari halaman detail Tree (tree terisi otomatis).

### F-07 Harvests (hasil panen)
- Atribut: `tree_id`, `harvested_on` (tidak boleh di masa depan), `quantity` (> 0), `unit` (`kg` atau `pcs`), `grade` (`premium`, `good`, `fair`, `poor`), `notes`. `user_id` otomatis.
- **Akses:** Admin = CRUD; Staff = buat, lihat, ubah (hanya milik sendiri).
- Filter: tree, block, tree type, grade, rentang tanggal. Tampilkan total quantity per filter.
- Harvest tidak boleh dihapus jika sudah punya Sale.

### F-08 Expenses (pengeluaran)
- Atribut: `block_id` (opsional; kosong = pengeluaran umum), `category` (`fertilizer`, `pesticide`, `labor`, `equipment`, `water`, `transport`, `other`), `amount` (> 0), `spent_on`, `description`. `user_id` otomatis.
- **Akses:** Admin saja.
- Filter: block, category, rentang tanggal; tampilkan total.

### F-09 Sales (penjualan)
- Atribut: `harvest_id` (wajib), `buyer_name`, `sold_on`, `quantity` (> 0), `unit_price` (> 0), `total_amount` (**dihitung server**: `quantity × unit_price`, tidak boleh dari input pengguna), `notes`. `user_id` otomatis.
- **Aturan bisnis:** total `quantity` semua Sale pada satu Harvest tidak boleh melebihi `quantity` Harvest tersebut. Pesan error: "The quantity exceeds the remaining unsold amount of this harvest (X unit)."
- **Akses:** Admin saja.
- Filter: buyer, rentang tanggal, tree type; tampilkan total pendapatan.

### F-10 Reports
- **Akses:** Admin.
- Laporan: (a) Harvest summary per block / tree type / bulan; (b) Financial summary (sales − expenses) per bulan dan per block; (c) Care activity summary.
- Filter periode (from–to). Grafik (Chart.js). **Ekspor CSV** untuk tiap laporan (kolom berbahasa Inggris). PDF opsional (nice-to-have).
- Ekspor dibuat *streamed* (tanpa menulis file ke disk server).

### F-11 User Management
- **Akses:** Admin.
- CRUD pengguna (name, email, role, password opsional saat edit). Cari berdasarkan nama/email. Ubah peran. Nonaktifkan tidak diperlukan.
- Aturan perlindungan Admin terakhir (bagian 4).

### F-12 Profile (bonus)
- Ubah nama, email, password. Hapus akun dinonaktifkan untuk Admin terakhir.

> Total fitur di luar autentikasi: **11** (F-01 s.d. F-11) → memenuhi syarat ≥ 8 dengan cadangan.

---

## 6. Desain Database (PostgreSQL)

> Skema di bawah adalah **acuan CDM/PDM** (digambar di Vertabelo/Redgate) dan **acuan schema runtime**. Sumber kebenaran runtime adalah `src/main/resources/schema.sql`; perubahan skema harus memperbarui file tersebut, bagian ini, dan diagram, lalu dikabarkan ke tim.

Konvensi: nama tabel jamak snake_case; PK `id` (bigint, auto-increment); semua tabel punya `created_at`, `updated_at`; waktu `timestamp`; uang `decimal(14,2)`; nilai pilihan disimpan sebagai `varchar` dan divalidasi di Java (bukan tipe enum native DB).

### 6.1 Tabel

**users**
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | bigint PK | |
| name | string(255) | |
| email | string(255) unique | |
| password | string | hashed |
| role | string(20) default `staff` | `admin` / `staff` |

**categories**
| id | bigint PK |
|----|-----------|
| name | string(100) **unique** |
| description | text null |

**tree_types**
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | bigint PK | |
| category_id | bigint **FK → categories.id** | `restrictOnDelete` |
| name | string(100) | unique bersama `category_id` |
| scientific_name | string(150) null | |
| description | text null | |

**blocks**
| id | bigint PK |
|----|-----------|
| name | string(100) **unique** |
| area_sqm | decimal(12,2) null |
| location_note | string(255) null |
| description | text null |

**trees**
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | bigint PK | |
| code | string(30) **unique** | |
| tree_type_id | bigint **FK → tree_types.id** | `restrictOnDelete` |
| block_id | bigint **FK → blocks.id** | `restrictOnDelete` |
| created_by | bigint **FK → users.id** null | `nullOnDelete` |
| planted_on | date | |
| status | string(20) default `seedling` | `seedling/growing/productive/needs_attention/dead` |
| height_cm | decimal(8,2) null | |
| notes | text null | |
| photo_path | string(255) null | path relatif di disk `photos` |
| deleted_at | timestamp null | soft delete |

**care_logs**
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | bigint PK | |
| tree_id | bigint **FK → trees.id** | `cascadeOnDelete` |
| user_id | bigint **FK → users.id** null | `nullOnDelete` |
| activity_type | string(30) | lihat F-06 |
| performed_on | date | |
| next_due_on | date null | |
| notes | text null | |

**harvests**
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | bigint PK | |
| tree_id | bigint **FK → trees.id** | `cascadeOnDelete` |
| user_id | bigint **FK → users.id** null | `nullOnDelete` |
| harvested_on | date | |
| quantity | decimal(10,2) | > 0 |
| unit | string(10) | `kg` / `pcs` |
| grade | string(20) | `premium/good/fair/poor` |
| notes | text null | |

**expenses**
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | bigint PK | |
| block_id | bigint **FK → blocks.id** null | `nullOnDelete` |
| user_id | bigint **FK → users.id** null | `nullOnDelete` |
| category | string(30) | lihat F-08 |
| amount | decimal(14,2) | > 0 |
| spent_on | date | |
| description | string(255) null | |

**sales**
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | bigint PK | |
| harvest_id | bigint **FK → harvests.id** | `restrictOnDelete` |
| user_id | bigint **FK → users.id** null | `nullOnDelete` |
| buyer_name | string(150) | |
| sold_on | date | |
| quantity | decimal(10,2) | > 0 |
| unit_price | decimal(14,2) | > 0 |
| total_amount | decimal(14,2) | dihitung server |
| notes | text null | |

### 6.2 Relasi (kardinalitas)
- `categories 1 — N tree_types`
- `tree_types 1 — N trees`
- `blocks 1 — N trees`
- `blocks 1 — N expenses` (opsional)
- `trees 1 — N care_logs`
- `trees 1 — N harvests`
- `harvests 1 — N sales`
- `users 1 — N` trees (created_by), care_logs, harvests, expenses, sales

### 6.3 Indeks tambahan
`trees(block_id)`, `trees(tree_type_id)`, `trees(status)`, `care_logs(tree_id, performed_on)`, `care_logs(next_due_on)`, `harvests(tree_id, harvested_on)`, `expenses(spent_on)`, `sales(sold_on)`.

### 6.4 Seeder (wajib, bahasa Inggris)
- 1 Admin (`admin@example.com`) dan 1 Staff (`staff@example.com`), password dev: `password` (**wajib diganti di produksi**; email dan password produksi dibaca dari env, bukan hardcode). Variabel: `SEED_ADMIN_*`, `SEED_STAFF_*`, `SEED_DEMO_DATA` (lihat `config/seeding.php`). Seeder menolak berjalan di produksi bila password kosong.
- Seeder Java memakai random seed tetap agar nilai demo konsisten; tanggal demo dihitung relatif terhadap tanggal startup.
- 4 categories (Fruit, Timber, Ornamental, Spice), ±10 tree types (contoh: Durian, Mango, Rambutan, Teak, Mahogany, Clove, dll.), 3 blocks, ±40 trees, ±100 care logs, ±40 harvests, ±30 expenses, ±20 sales dengan tanggal tersebar 12 bulan terakhir (agar grafik tampak hidup).
- Seeder hanya mengisi data awal saat tabel terkait masih kosong; schema dan seed dijalankan oleh aplikasi saat startup.

---

## 7. Struktur Menu dan Route

### 7.1 Sidebar (urutan dan label — Inggris)
1. **Dashboard** — `/dashboard`
2. **Trees** — `/trees`
3. **Care Logs** — `/care-logs`
4. **Harvests** — `/harvests`
5. **Master Data** (grup)
   - Categories — `/categories`
   - Tree Types — `/tree-types`
   - Blocks — `/blocks`
6. **Finance** (grup, Admin saja)
   - Expenses — `/expenses`
   - Sales — `/sales`
7. **Reports** (Admin) — `/reports`
8. **Users** (Admin) — `/users`
9. Menu pengguna (footer/topbar): **Profile**, **Log out**

Item yang tidak boleh diakses peran tertentu **tidak ditampilkan** dan route-nya tetap diproteksi (403).

### 7.2 Konvensi route
- Resource-style: `index`, `create`, `show`, `edit` (+ aksi store/update/destroy). Nama route: `trees.index`, `trees.create`, dst.
- Semua route aplikasi di dalam grup `auth`. Group Admin-only memakai middleware peran (`role:admin`) atau policy.
- Halaman publik hanya: landing/redirect ke login, login, register, forgot password.

---

## 8. Desain UI/UX

**Karakter:** natural, bersih, hangat, mudah dibaca, ramah HP.

**Palet warna (token Tailwind/CSS variable)**
| Peran | Warna | Hex |
|-------|-------|-----|
| Primary | Leaf green | `#2F7D4F` |
| Primary dark (hover) | Forest | `#1F5C3A` |
| Background | Cream | `#FAF7F0` |
| Surface (kartu) | White | `#FFFFFF` |
| Accent | Soil brown | `#8B5E3C` |
| Success / Warning / Danger / Info | `#2F7D4F` / `#D9A406` / `#C0392B` / `#2B6CB0` |
| Teks utama / sekunder | `#1F2937` / `#6B7280` |

**Komponen dan pola**
- Layout: sidebar kiri (collapse jadi drawer di mobile) dengan dropdown akun berisi profil, tema, dan logout.
- Kartu dengan sudut membulat (`rounded-xl`), bayangan halus. Tipografi sans-serif bersih (mis. Inter). Heading jelas, spasi lega.
- Tabel: header lengket, aksi berupa ikon (View/Edit/Delete) dengan tooltip, baris responsif (di mobile menjadi kartu atau scroll horizontal).
- **Badge status pohon:** `seedling` = biru, `growing` = hijau muda, `productive` = hijau tua, `needs_attention` = kuning, `dead` = merah.
- Form: label di atas input, pesan error merah di bawah field, tombol utama hijau, tombol sekunder abu, tombol hapus merah dengan dialog konfirmasi.
- Empty state: ikon + kalimat Inggris + tombol aksi ("No trees yet. Add your first tree.").
- Loading state pada tombol submit; flash message sukses/gagal di pojok atas.
- Aksesibilitas: kontras cukup, label untuk semua input, fokus terlihat, `alt` pada gambar.
- Reuse shared JSP tags and the existing Tailwind CSS assets before adding new UI components.

---

## 9. Tech Stack, Struktur Proyek, dan Alur Git

### 9.1 Stack (dikunci — jangan ganti tanpa kesepakatan tim)
| Lapisan | Pilihan |
|---------|---------|
| Bahasa/runtime | Java 21 |
| Web | Jakarta Servlet 6, JSP 3.1, JSTL 3, Apache Tomcat 10.1 |
| Database | PostgreSQL 16+ |
| Tampilan | JSP, Tailwind CSS 4 build statis, Chart.js |
| Build dan tes | Maven (`mvn test`, `mvn package`) |
| Deploy | Docker Compose di CasaOS; Cloudflare Tunnel untuk akses publik |

Setup lokal tiap anggota:
```bash
git clone <repo-url> && cd <repo>
createdb harvesta_jsp
DB_HOST=127.0.0.1 DB_PORT=5432 DB_DATABASE=harvesta_jsp \
  DB_USERNAME=harvesta_jsp DB_PASSWORD='<password>' mvn jetty:run
```
PostgreSQL tetap digunakan untuk lokal dan produksi. Untuk menjalankan unit test dan membuat WAR, gunakan `mvn test` dan `mvn package`.

Kebutuhan lokal: JDK 21, Maven 3.8+, dan PostgreSQL 16+. Alternatifnya, jalankan seluruh stack melalui Docker Compose.

### 9.2 Struktur folder
```
src/main/java/com/harvesta/        # servlet, database helper, validation, and seed logic
src/main/resources/schema.sql     # PostgreSQL schema
src/main/webapp/WEB-INF/views/     # JSP pages
src/main/webapp/WEB-INF/tags/      # shared JSP tags/layout
src/main/webapp/build/assets/      # static CSS, fonts, and icons used by JSP
src/test/java/                     # Maven tests
docs/                              # deployment guides
```
Servlet menangani request dan aturan bisnis; JSP hanya merender data yang disiapkan servlet. Konvensi teknis dicatat di `AGENTS.md`.

### 9.3 Alur Git
- Repo GitHub **publik**. **Semua anggota bekerja langsung di branch `main`** (keputusan tim, 22 Okt); tidak memakai feature branch atau PR. Karena itu `main` harus tetap bisa jalan setiap kali di-push.
- Commit kecil dan sering, memakai Conventional Commits berbahasa Inggris: `feat(trees): add tree photo upload`, `fix(sales): validate remaining quantity`, `docs: update prd`.
- Alur harian: `git pull --rebase origin main` sebelum mulai kerja dan sebelum push → jalankan `mvn test` dan `mvn package` tanpa error → `git push origin main`.
- Konflik saat rebase diselesaikan oleh anggota yang sedang push; jika konflik menyentuh area anggota lain, diskusikan dulu.
- `.gitignore` wajib mencakup file env lokal, `target/`, dan berkas IDE.
- **Jangan pernah commit** `.env`, kunci API, password, atau data pribadi. Jika bocor, rotasi kunci.

### 9.4 Perubahan skema
- Perbarui `src/main/resources/schema.sql`, bagian 6, dan ERD bersama-sama.
- Pastikan skema aman dijalankan pada database yang sudah ada; backup data sebelum perubahan yang menghapus atau mengubah kolom.

---

## 10. Deployment dan Penyimpanan

### 10.1 Target deploy: CasaOS dengan Cloudflare Tunnel
Panduan langkah demi langkah tersedia di [`docs/DEPLOY_CASAOS.md`](docs/DEPLOY_CASAOS.md).

- **Aplikasi dan database:** Tomcat dan PostgreSQL berjalan sebagai container Compose; named volume `postgres_data` menyimpan data PostgreSQL.
- **Akses publik:** Cloudflare Tunnel menghubungkan hostname domain ke service `app` di jaringan Compose. Server tidak memerlukan IP publik dan tidak perlu membuka port masuk pada router.
- **Rahasia:** kredensial database, password seed, dan token tunnel disimpan di `.env.docker` pada server, bukan di repository.

### 10.2 Persistensi dan pembaruan
- Jangan menghapus volume `postgres_data` saat memperbarui container.
- Buat backup PostgreSQL secara berkala dan uji proses restore.
- Pembaruan dari repository dilakukan dengan `git pull` lalu `docker compose up --build -d`; dokumentasi lengkap ada pada panduan CasaOS.

### 10.3 Foto pohon
- Validasi unggah: JPG/PNG/WebP, maksimum 2 MB.
- Foto yang dipakai aplikasi harus tersedia pada penyimpanan/database yang tetap tersedia setelah container aplikasi dibangun ulang.
- URL foto dirender melalui helper aplikasi dan tidak dirangkai dari input pengguna.

---

## 11. Laporan (Deliverable) dan Pemetaan Rubrik

| Bagian laporan | Isi | Poin |
|----------------|-----|------|
| **Design (20)** | CDM, PDM (ekspor dari Vertabelo/Redgate), arsitektur singkat, desain UI (palet, wireframe/mockup) | 20 |
| **Implementation (50)** | Daftar fitur (F-01..F-11 + auth), screenshot + penjelasan tiap fitur, cuplikan kode penting (validasi, otorisasi, aturan bisnis), link GitHub dan URL deploy | 50 |
| **Analysis/Evaluation (25)** | Hasil pengujian (tabel kasus uji), kelebihan dan keterbatasan, keamanan (auth, otorisasi, validasi, CSRF, hashing), performa (eager loading, indeks), kendala deployment dan solusinya, saran pengembangan | 25 |
| **Conclusion (5)** | Ringkasan hasil dan pembelajaran | 5 |
| **Kontribusi** | Persentase dan uraian kontribusi tiap anggota (target seimbang, mis. 33/33/34) | wajib |

Kumpulkan sejak awal: screenshot tiap halaman (data seeder sudah terisi), catatan bug dan solusi, serta bukti tes. Siapkan `Declaration.PDF` yang ditandatangani semua anggota.

---

## 12. Pembagian Tugas dan Kepemilikan File

Pembagian area per anggota pada versi awal tidak lagi berlaku. Setiap anggota dapat mengerjakan area mana pun; koordinasikan perubahan yang menyentuh layout, database, atau konfigurasi deployment agar integrasi tetap konsisten.

Semua anggota bertanggung jawab menjaga `main` tetap dapat dibangun, menambahkan tes untuk perilaku baru, dan menyiapkan bukti fitur untuk laporan. Persentase kontribusi dihitung dari pekerjaan yang benar-benar dilakukan.

---

## 13. Jadwal (21 – 28 Oktober 2026)

| Tanggal | Target | Penanggung jawab |
|---------|--------|------------------|
| 21 Okt | PRD disepakati; CDM/PDM dibuat; repo GitHub + setup lokal berjalan di ketiga OS | Semua |
| 22 Okt | Schema, seeder, layout, dan sidebar awal | A, C |
| 22–25 Okt | Fitur dikerjakan paralel sesuai area (commit kecil dan sering ke `main`) | A, B, C |
| 25 Okt | Semua fitur F-01..F-11 *feature-complete* | Semua |
| 26 Okt | Integrasi, perbaikan bug, polish UI, uji lintas peran, uji mobile | Semua |
| 27 Okt | Deploy final, foto di produksi, screenshot final, tulis laporan, tanda tangan Declaration | Semua |
| 28 Okt | Final check dan **kirim email paling lambat 20:00 WIB** (buffer 4 jam) | Semua |

Jika jadwal meleset, potong dulu: PDF export, grafik tambahan, dan fitur foto di produksi (fitur inti tetap prioritas).

---

## 14. Kualitas, Pengujian, dan Definition of Done

**Pengujian minimum (Feature tests)**
- Auth: register (peran default staff), login, logout, akses tanpa login ditolak.
- Otorisasi: Staff tidak bisa membuka Finance/Users/Master write; Admin bisa.
- CRUD happy path untuk tiap modul + validasi gagal untuk kasus penting.
- Aturan bisnis: sale melebihi sisa panen ditolak; kategori/jenis/blok yang dipakai tidak bisa dihapus; pohon `dead` tidak menerima care log/harvest.
- Manual test lintas peran dan di layar HP.

**Definition of Done (per fitur)**
1. Sesuai spesifikasi dan aturan di bagian 5 (atribut, validasi, akses).
2. UI mengikuti bagian 8 dan **seluruh teks berbahasa Inggris benar secara grammar**.
3. Otorisasi dan validasi server-side ada.
4. Tidak ada N+1 pada halaman daftar; ada pagination.
5. Tes otomatis untuk perilaku yang berubah lulus; `mvn test` dan `mvn package` bersih.
6. Berjalan dengan schema dan seed pada PostgreSQL di lingkungan anggota.
7. Sudah di-push ke `main` dan dicek anggota lain; screenshot tersedia untuk laporan.

**Keamanan dasar:** password di-hash, validasi input dan unggahan, prepared statement untuk input SQL, hak akses diperiksa server-side, dan rahasia hanya disimpan di environment/server.

**Catatan deployment:** validasi build image, startup Tomcat/PostgreSQL, koneksi Cloudflare Tunnel, dan backup/restore database sebelum rilis.

---

## 15. Keputusan Proyek

| # | Topik | Keputusan |
|---|-------|-----------|
| 1 | Nama aplikasi | HARVESTA |
| 2 | Stack runtime | Java 21, Jakarta Servlet/JSP, Tomcat 10.1 |
| 3 | Database | PostgreSQL 16+ |
| 4 | Deployment | Docker Compose di CasaOS; akses publik melalui Cloudflare Tunnel |
| 5 | Export PDF | Opsional; CSV tetap wajib |
| 6 | Alur Git | Semua kerja langsung di `main`, tanpa feature branch/PR; push dilakukan manusia |

---

## 16. Aturan untuk AI Agent

Berlaku untuk semua agent di laptop semua anggota:
1. **Baca** `PRD.md` dan `AGENTS.md` sebelum mengubah apa pun; ikuti stack dan konvensi yang dicatat.
2. Koordinasikan perubahan skema PostgreSQL, layout bersama, dan konfigurasi deployment sebelum integrasi.
3. Jangan menambah dependency besar atau mengganti stack tanpa persetujuan tim.
4. **Seluruh teks UI dalam bahasa Inggris yang benar**; kode dan commit juga Inggris.
5. Render escaping untuk output; gunakan prepared statement, pagination, dan eager loading/query terencana.
6. Jangan commit rahasia; jangan push kecuali diminta (push dilakukan oleh manusia).
7. Jalankan `mvn test` dan `mvn package` sebelum menyatakan tugas selesai.
8. Pertahankan perubahan sekecil mungkin dan terarah; jangan merapikan file yang tidak terkait tugas.
9. Jelaskan secara singkat perubahan dan validasi tanpa mengulang seluruh kode.
