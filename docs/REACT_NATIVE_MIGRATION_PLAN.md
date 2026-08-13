# LessonTracker — React Native + Supabase Sıfırdan İnşa Planı (Yürütülebilir Spec)

- **Tarih:** 13 Ağustos 2026
- **Durum:** 🚧 Yürütülmeye hazır — mimari kararlar kesinleşti, açık soru §13'te
- **Bu doküman kimin için:** Bu implementasyonu yapacak (insan veya AI) mühendis/agent için. Mimari kararlar verildi; sorgulamadan uygula. Belirsizlik gördüğün yerde önce bu dokümanın ilgili bölümüne bak, yoksa §13'teki varsayımlar/açık sorular bölümüne.
- **Kaynak proje (referans, hedef değil):** `app/` (Flutter, ~61K satır Dart, 121 ekran dosyası, 30 servis, 11 provider, 11 SQLite tablosu, 4 dil). Bu plan Flutter kodunu **feature-parity referansı** olarak kullanır ama onu birebir kopyalamaz — veri modeli, senkron mimarisi ve güvenlik katmanı **sıfırdan, Supabase'e uygun şekilde** yeniden tasarlanır.
- **Hedef dizin:** Aynı monorepo içinde yeni bir kardeş klasör: `mobile-rn/` (kök dizinde, `app/` ile yan yana).
- **Bu doküman önceki sürümün yerine geçer:** Bir önceki sürüm, Flutter'daki SQLCipher yerel DB + Firebase'i **birebir koruyarak** taşımayı hedefliyordu (veri sürekliliği önceliği). Kullanıcı bilinçli olarak farklı bir yön seçti: **sıfırdan başlangıç + Supabase**. §0'daki kararlar bu değişikliği yansıtır; eski dokümanın disiplin kuralları (küçük PR, spike-önce, checkbox=kaynak gerçeği) geçerliliğini korur.

---

## 🚨 0 — Kesinleşen mimari kararlar (atlamadan oku)

Bu 4 karar kullanıcıyla birlikte netleştirildi, tartışmaya açık değil:

1. **Sıfırdan başlangıç, veri taşıma yok.** Flutter uygulamasındaki mevcut kullanıcı verisi (SQLCipher DB, Firestore, Firebase Storage) yeni uygulamaya taşınmaz. Bundle ID/Team ID/applicationId eskisiyle aynı kalmak **zorunda değil** — yeni bir uygulama olarak App Store/Play Store'a çıkılabilir. (Bu, iş/rollout kararı olarak insana onaylatılmalı, bkz. §13.)
2. **Supabase = tam backend.** Auth, Postgres (veritabanı), Storage (dosya/ses/görsel/çizim), Edge Functions, Realtime, `pg_cron` (zamanlanmış görevler) — hepsi Supabase üzerinde. **Firebase tamamen bırakılır** (Auth, Firestore, Storage, Cloud Functions, Crashlytics dahil — Crashlytics yerine Sentry önerilir, bkz. §1).
3. **Offline-first, ama sade senkron mimarisiyle.** Yerel cihazda SQLite cache (Expo SQLite) + bir "outbox" (giden değişiklik kuyruğu) tablosu ile offline yazma desteklenir; arka planda/foreground'da Supabase ile senkronize olur. Bu, Flutter'daki Firestore-tabanlı çift yönlü realtime senkrondan **daha basit, tek yönlü push + periyodik pull** bir model — çünkü veri tek kullanıcıya ait (collaborative değil), gerçek zamanlı çakışma çözümü gerekmiyor. Detay §5.
4. **Güvenlik katmanı sadeleştirildi.** Flutter'daki client-side E2E şifreleme (PBKDF2+AES-256-CBC, parola tabanlı) ve biyometrik uygulama kilidi **yeniden inşa edilmez**. Güvenlik sınırı Supabase Auth (oturum) + Row Level Security (RLS, veritabanı seviyesinde satır izolasyonu) + Storage policy'leri olur. Aktarımda TLS, Supabase'de "rest'te şifreleme" (disk düzeyinde, sağlayıcı tarafından) zaten var. **KVKK onay akışı bu kararın dışında** — o bir hukuki gereklilik, güvenlik özelliği değil, aynen korunur (bkz. §9).

**Bu kararların sonucu olarak plan önceki sürümden şu şekilde ayrışıyor:**
- Bare RN CLI yerine **Expo (prebuild / dev client)** öneriliyor — SQLCipher'ın ürettiği native-kısıt kalktı, Expo'nun config-plugin ekosistemi (Skia, kamera, konum, bildirim, arkaplan görev) yeterli; gerektiğinde `expo prebuild` ile native koda her zaman inilebilir, bu bir kilitlenme değil.
- DB şeması Flutter'ın ham temsillerine (`color INTEGER` ARGB, `scheduleDays` virgüllü string, `deadlines.type` integer enum) bağlı kalmak zorunda değil — Postgres'in native tiplerini (TEXT hex renk, `integer[]`, Postgres `enum`/`check constraint`) kullanan **daha temiz bir şema** tasarlanıyor (§4).
- Moodle senkronu ve bildirimler artık kısmen **sunucu tarafında** (Supabase Edge Functions + `pg_cron`) çalışabiliyor — Flutter'da yaşanan "arka plan görevi state'i bayat bırakıyor" hata sınıfı, Moodle senkronu için büyük ölçüde ortadan kalkıyor (§8.3).

---

## 🧱 1 — Teknoloji yığını

| Katman | Seçim | Neden |
|---|---|---|
| Dil | **TypeScript, strict mode** | Tip güvenliği, Supabase'in üretilen tipleriyle uyum |
| Framework | **Expo (SDK en güncel stabil), prebuild/dev-client workflow** — managed değil ama Expo tooling'i (EAS Build/Update/Submit) kullanılır | SQLCipher zorunluluğu kalktığı için Expo'nun native modül kısıtları artık engel değil; EAS ile CI/CD, OTA update, mağaza gönderimi ciddi hızlanır |
| Navigasyon | **React Navigation v7** (`native-stack` + `bottom-tabs`) | RN standardı |
| State management | **Zustand** | Basit, Flutter provider'larına 1:1 çevrilebilir (§7.1) |
| Backend | **Supabase** — Postgres 15+, Auth, Storage, Edge Functions (Deno), Realtime, `pg_cron` + `pg_net` | Tek sağlayıcı, RLS ile satır-seviye güvenlik, açık kaynak |
| Supabase client | **`@supabase/supabase-js`** (+ `react-native-url-polyfill`, `@react-native-async-storage/async-storage` oturum persist için) | Resmi SDK |
| Yerel DB (offline cache) | **`expo-sqlite`** (şifresiz — §0.4 gereği artık şifreleme yok) | Expo native, prebuild gerektirmez |
| Secure storage (oturum token, Moodle token) | **`expo-secure-store`** | Keychain/Keystore sarmalayıcı |
| i18n | **`i18next` + `react-i18next`** | `.arb` → `.json` mekanik dönüşüm |
| Stil | Plain `StyleSheet.create` + merkezi `theme.ts` | Ekstra bağımlılık gereksiz |
| İkonlar | `react-native-svg` + `@expo/vector-icons` | — |
| Çizim/el yazısı | **`@shopify/react-native-skia`** (Expo config plugin destekli) | Basınç duyarlı path çizimi için tek gerçekçi seçenek |
| PDF görüntüleme | **`react-native-pdf`** (prebuild gerektirir, config plugin var) | — |
| PDF sayfa→görsel render | **`react-native-pdf-thumbnail`**, yetersizse özel native modül (spike, §8.4) | — |
| Takvim | **`react-native-calendars`** | — |
| Grafik | **`victory-native`** | GPA/istatistik grafikleri |
| Kamera | **`expo-camera`** | — |
| Görsel seçici | **`expo-image-picker`** | — |
| Görsel sıkıştırma | **`expo-image-manipulator`** | — |
| Ses kayıt/oynatma | **`expo-av`** (veya SDK güncel karşılığı) | — |
| OCR | **`@react-native-ml-kit/text-recognition`** (on-device, offline) | Flutter'daki `google_mlkit_text_recognition` karşılığı, çevrimdışı çalışır — offline-first felsefesine uygun |
| Konum | **`expo-location`** + **`expo-task-manager`** (arkaplan konum) | GPS tabanlı devamsızlık otomasyonu için şart |
| Bildirimler (yerel) | **`expo-notifications`** | Zamanlı yerel hatırlatmalar (ders başlangıcı vb.) |
| Bildirimler (sunucu tetikli) | **Expo Push API**, Supabase Edge Function + `pg_cron`'dan tetiklenir | Haftalık rapor, deadline hatırlatma — cihaz arka planda olmasa da çalışır |
| Arka plan görevleri (istemci) | **`expo-task-manager`** + **`expo-background-task`** | Sadece GPS devamsızlık otomasyonu için (Moodle sync artık sunucuda, bkz. §8.3) |
| Takvime ekleme | **`expo-calendar`** | — |
| İzinler | **`expo-*`** modüllerinin kendi izin API'leri (`expo-camera`, `expo-location` vb.) | Ayrı paket gerekmez |
| Ağ durumu | **`@react-native-community/netinfo`** | Offline banner + senkron tetikleme |
| Görsel cache | **`expo-image`** | Yerleşik disk cache |
| Env config | **`react-native-dotenv`** veya Expo'nun `app.config.ts` + `EAS Secrets`'ı | — |
| Hata izleme | **Sentry (`@sentry/react-native`)** | Firebase Crashlytics'in yerine — Supabase'in kendi crash reporting'i yok |
| Test | **Jest + `@testing-library/react-native`** | Detox (E2E) opsiyonel, düşük öncelik (§10) |

**Paket seçiminde sapma yok.** Listede olmayan bir ihtiyaç çıkarsa en yakın resmi/topluluk standardını seç ve bu tabloya ekle.

---

## 📁 2 — Proje iskeleti

```
mobile-rn/
  src/
    app/                     # Navigasyon kökü, App.tsx, store providers
    screens/                 # bkz. §9
    components/
    stores/                  # Zustand store'lar (§7.1)
    services/                # İş mantığı servisleri (§7.2)
    api/
      supabase.ts             # Supabase client init (URL + anon key)
      queries/                # tabloya göre CRUD fonksiyonları (courses.ts, notes.ts, ...)
      moodle.ts                # Moodle Edge Function proxy çağrıları
    db/
      local-schema.ts          # expo-sqlite tablo tanımları (offline cache, §5)
      migrations/               # yerel şema migration'ları (v1'den başlar — legacy yok)
      sync/
        outbox.ts                # giden değişiklik kuyruğu (§5.2)
        syncEngine.ts             # push/pull döngüsü (§5.3)
    models/                    # TS interface/type (§7.3)
    theme/
    i18n/
      locales/
        tr.json en.json de.json es.json
    utils/
  supabase/
    migrations/                # `supabase db diff` ile üretilen SQL migration'lar (§4, tek doğruluk kaynağı)
    functions/                 # Edge Functions (Deno) — moodle-proxy, send-push, weekly-report, attendance-geofence-check
    seed.sql
  ios/
  android/
  __tests__/
  app.config.ts
  package.json
  tsconfig.json
  .env.example
```

- [ ] **P0.1** `npx create-expo-app mobile-rn -t expo-template-blank-typescript`, yukarıdaki `src/` ve `supabase/` yapısını oluştur.
- [ ] **P0.2** Supabase CLI kur (`supabase init` proje kökünde `supabase/` altında), yerel Supabase (`supabase start`, Docker gerektirir) ile geliştirme ortamı kur.

---

## 🗄️ 3 — Supabase proje kurulumu

- [ ] **P0.3** Supabase Dashboard'da yeni proje oluştur (bölge: kullanıcı kitlesine en yakın — TR kullanıcı ağırlıklıysa `eu-central-1`).
- [ ] **P0.4** Auth ayarları: Email/Password aç, e-posta doğrulama zorunlu kıl (Flutter'daki `email_verification_screen` karşılığı). İsteğe bağlı Google/Apple OAuth (Apple, iOS'ta üçüncü parti login varsa **App Store zorunluluğu** — Google OAuth eklenirse Apple Sign-In de eklenmeli).
- [ ] **P0.5** `pg_cron` ve `pg_net` extension'larını aç (Database → Extensions) — sunucu tarafı zamanlanmış görevler için (§8.3).
- [ ] **P0.6** Storage bucket'larını oluştur (§6).
- [ ] **P0.7** `.env.example` ve EAS Secrets'a `SUPABASE_URL`, `SUPABASE_ANON_KEY` ekle. **`service_role` anahtarı asla client'a/repo'ya girmez** — sadece Edge Functions ortam değişkeni olarak.

---

## 🔑 4 — Veritabanı şeması (Postgres, tek doğruluk kaynağı: `supabase/migrations/`)

Her tablo `user_id uuid not null references auth.users(id) on delete cascade` taşır ve RLS ile izole edilir. Flutter şemasından farklar bilinçli: `color` artık `TEXT` hex, `scheduleDays` artık `integer[]`, `deadlines.type` artık `TEXT` check constraint (okunabilirlik için) — bunlar birebir taşınmadı çünkü **sıfırdan başlıyoruz, legacy veriyle satır uyumluluğu kaygısı yok**.

```sql
-- Ortak RLS deseni (her tabloya uygulanır):
--   alter table <t> enable row level security;
--   create policy "own rows" on <t> for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table courses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  subtitle text,
  professor text,
  professor_email text,
  professor_phone text,
  professor_office text,
  office_hours text,
  assistant_name text,
  location text,
  latitude double precision,
  longitude double precision,
  color text not null,                    -- '#RRGGBB'
  schedule_days integer[] not null,        -- 0=Pazartesi ... 6=Pazar
  start_time time not null,
  end_time time not null,
  absence_limit integer default 3,
  current_absences integer default 0,
  progress real default 0.0,
  icon_name text,
  next_exam_date date,
  credits integer default 3,
  status text default 'active' check (status in ('active','archived','completed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  type text not null check (type in ('text','ocr','audio','image','drawing')),
  title text not null,
  content text,
  file_path text,             -- Storage bucket içindeki path (§6)
  thumbnail_path text,
  audio_duration_seconds integer,
  tags text[],
  bookmarks jsonb,
  is_bookmarked boolean default false,
  search_content text,        -- OCR/transkript metni, full-text search için
  drawing_data jsonb,         -- {"v":2,"strokesByPage":{...}} — codec §8.2
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index idx_notes_search on notes using gin (to_tsvector('turkish', coalesce(search_content,'') || ' ' || title));

create table grades (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  name text not null,
  score real not null,
  max_score real not null default 100.0,
  weight real not null,
  created_at timestamptz not null default now()
);

create table absences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  date date not null,
  reason text default 'unexcused' check (reason in ('unexcused','excused','sick','automatic_gps')),
  created_at timestamptz not null default now()
);

create table course_files (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  storage_path text not null,
  name text not null,
  type text not null,
  external_url text,          -- Moodle'dan indirilen dosyalar için orijinal URL referansı
  created_at timestamptz not null default now()
);

create table deadlines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  title text not null,
  date timestamptz not null,
  type text not null check (type in ('exam','assignment','project','other')),
  reminder boolean default true,
  created_at timestamptz not null default now()
);

create table study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid references courses(id) on delete set null,
  duration_minutes integer not null,
  started_at timestamptz not null,
  ended_at timestamptz not null,
  session_type text default 'work' check (session_type in ('work','break'))
);

create table planner_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  type text not null,
  start_time timestamptz not null,
  end_time timestamptz not null,
  color text not null,
  notes text
);

-- Moodle token'ları client'tan asla düz metin okunmaz: sadece service_role (Edge Function) erişir.
create table moodle_accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  base_url text not null,
  site_title text not null,
  moodle_username text not null,
  full_name text not null,
  avatar_url text,
  wstoken text not null,        -- RLS: select yok, sadece service_role okuyabilir (aşağıda)
  last_synced timestamptz,
  is_active boolean default true
);
-- moodle_accounts.wstoken için ayrı, kısıtlı policy: kullanıcı kendi satırını INSERT/DELETE edebilir
-- ama SELECT'te wstoken sütunu bir view üzerinden maskelenir (moodle_accounts_public).
create view moodle_accounts_public as
  select id, user_id, base_url, site_title, moodle_username, full_name, avatar_url, last_synced, is_active
  from moodle_accounts;

create table moodle_cache (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  account_id uuid not null references moodle_accounts(id) on delete cascade,
  data_type text not null,      -- 'courses' | 'assignments' | 'grades' | 'announcements' | 'calendar' | 'messages'
  payload jsonb not null,
  cached_at timestamptz not null default now()
);
create index idx_moodle_cache_account on moodle_cache (account_id, data_type);

-- Standart indeksler
create index idx_notes_course on notes(course_id);
create index idx_notes_type on notes(type);
create index idx_grades_course on grades(course_id);
create index idx_absences_course on absences(course_id);
create index idx_deadlines_course on deadlines(course_id);
create index idx_deadlines_date on deadlines(date);
create index idx_study_sessions_course on study_sessions(course_id);
create index idx_courses_user on courses(user_id);
```

**Trigger:** her tabloya `updated_at` otomatik güncelleyen bir `before update` trigger'ı ekle (senkron çakışma çözümü `updated_at`'e dayanacak, §5.3).

- [ ] **P0.8** Yukarıdaki şemayı `supabase/migrations/0001_init.sql` olarak yaz, `supabase db push` ile uygula.
- [ ] **P0.9** Her tablo için RLS policy'lerini yaz (yukarıdaki "own rows" deseni + `moodle_accounts` için özel maskeleme policy'si).
- [ ] **P0.10 (spike, R0'da)** Test kullanıcısıyla RLS'in gerçekten izole ettiğini doğrula: kullanıcı A'nın anon-key session'ıyla kullanıcı B'nin `courses` satırına `SELECT`/`UPDATE` denemesi **0 satır** dönmeli.

---

## 📴 5 — Offline-first senkron mimarisi

### 5.1 Yerel şema (`expo-sqlite`)

`db/local-schema.ts` içinde §4'teki Postgres şemasının **aynı sütun isimleriyle** (snake_case) bir aynası tutulur, artı senkron için 2 ek sütun her tabloda:
- `_dirty INTEGER DEFAULT 0` — yerelde değişti, henüz sunucuya push edilmedi
- `_deleted INTEGER DEFAULT 0` — soft delete işareti (offline'ken silinen kayıt, sync'te sunucudan da silinir)

### 5.2 Outbox (giden değişiklik kuyruğu)

```sql
create table outbox (
  id integer primary key autoincrement,
  table_name text not null,
  record_id text not null,
  operation text not null check (operation in ('insert','update','delete')),
  payload text,              -- JSON, insert/update için tam satır
  created_at text not null,
  attempts integer default 0
);
```
Her yerel yazma işlemi (repository katmanı üzerinden) hem ilgili tabloya hem `outbox`'a yazar (tek SQLite transaction içinde).

### 5.3 Sync engine

- **Push:** `outbox`'taki kayıtları sırayla Supabase'e gönder (`upsert`/`delete`), başarılı olursa outbox'tan sil ve yerel satırın `_dirty`'sini temizle. Başarısız olursa `attempts++`, exponential backoff ile tekrar dene.
- **Pull:** Her tablo için `updated_at > last_pulled_at` filtresiyle Supabase'den çek, yerel SQLite'a upsert et. `last_pulled_at` her tablo için ayrı, `sync_meta` tablosunda tutulur.
- **Çakışma çözümü:** **Last-write-wins, `updated_at` bazlı.** Aynı satırın hem yerelde hem sunucuda değiştiği nadir durumda (aynı kullanıcının 2 cihazı offline'ken aynı kaydı düzenlemesi) sunucudaki `updated_at` daha yeniyse sunucu kazanır, değilse push edilen versiyon kazanır. Bu, collaborative-editing seviyesinde bir çözüm değil — **tek kullanıcı, çoklu cihaz** senaryosu için yeterli, karmaşık CRDT/OT gerekmiyor.
- **Tetikleme:** (a) uygulama foreground'a geçtiğinde, (b) `NetInfo` offline→online geçişini yakaladığında, (c) her yerel yazmadan sonra debounce'lu (2sn) push denemesi.
- **Arka plan görevi kuralı (Flutter'dan öğrenilmiş ders, aynen geçerli):** Arka plan task'ı (§8.3 GPS otomasyonu) DB'ye/store'a **doğrudan yazmaz** — outbox'a yazar ve bir "state invalidation" event'i yayınlar; UI bu event'i dinleyip ilgili Zustand store slice'ını yeniden okur. Aksi halde Flutter'daki "kart restart'a kadar bayat kalıyor" hatası tekrarlanır.

- [ ] **P1.1 (spike, R0 sonunda)** `courses` tablosuyla uçtan uca sync engine prototipi: offline yazma → outbox → online olunca push → başka bir "cihaz" (ikinci simulator) pull ile görüyor mu, doğrula.
- [ ] **P1.2** Sync engine'i tüm tablolara genişlet, `sync_meta` + hata/backoff mekanizmasını üret.
- [ ] **Kaçış yolu (risk azaltma):** Eğer custom sync engine üretimde kırılgan çıkarsa (çakışma/edge-case hataları çoğalırsa), **PowerSync** (Supabase için resmi offline-first senkron altyapısı, yerel SQLite + otomatik senkron sağlar) alternatif olarak değerlendirilmeli — ek bir hosted servis bağımlılığı getirir ama senkron mantığının büyük kısmını devralır. Bu, R1 sonunda custom engine'in stabilitesine göre karar verilecek bir **checkpoint**, baştan seçilmiyor çünkü tek-kullanıcı veri modeli custom çözüm için yeterince basit.

---

## 🗂️ 6 — Storage (dosya/medya)

Supabase Storage bucket'ları, hepsi **private** (public değil, signed URL ile erişim):

| Bucket | İçerik | Path deseni |
|---|---|---|
| `note-attachments` | Not resimleri, ses kayıtları, çizim thumbnail'leri | `{user_id}/{note_id}/{filename}` |
| `course-files` | Ders dosyaları (kullanıcı yüklediği + Moodle'dan indirilen) | `{user_id}/{course_id}/{filename}` |
| `avatars` | Profil fotoğrafı (varsa) | `{user_id}/avatar.jpg` |

Storage RLS policy deseni: `bucket_id = '<bucket>' and (storage.foldername(name))[1] = auth.uid()::text` — yani path'in ilk segmenti `user_id` olmalı, kullanıcı sadece kendi klasörüne yazabilir/okuyabilir.

- [ ] **P1.3** 3 bucket'ı oluştur, RLS policy'lerini yaz.
- [ ] **P1.4** `services/fileService.ts`: upload (yerelden Storage'a, offline'ken yerel dosya yolu tutulur + outbox'a "pending upload" eklenir), signed URL üretimi (görüntüleme için, 1 saat TTL), silme.
- [ ] **P1.5** Görsel sıkıştırma (`expo-image-manipulator`, Flutter'daki `image_compressor_service.dart` davranışına eşdeğer: max genişlik/kalite ayarı) upload öncesi.

---

## 🎨 7 — Uygulama katmanları

### 7.1 State (Zustand store'lar) — Flutter provider'larından esinlenilmiş, 1:1 değil

| Flutter provider | Zustand store | Not |
|---|---|---|
| `course_provider.dart` | `useCourseStore.ts` | CRUD + local-first okuma (SQLite'tan), yazma outbox'a |
| `note_provider.dart` | `useNoteStore.ts` | |
| `grade_provider.dart` | `useGradeStore.ts` | |
| `attendance_provider.dart` | `useAttendanceStore.ts` | |
| `deadline_provider.dart` | `useDeadlineStore.ts` | |
| `planner_event_provider.dart` | `usePlannerEventStore.ts` | |
| `moodle_provider.dart` | `useMoodleStore.ts` | Moodle verisi artık Supabase `moodle_cache` üzerinden okunur (bkz. §8.3), doğrudan Moodle API'ye client'tan gidilmez |
| `sync_provider.dart` | `useSyncStore.ts` | Yeni sync engine'in (§5.3) durumunu (son sync zamanı, bekleyen outbox sayısı, hata) tutar |
| `auth_provider.dart` | `useAuthStore.ts` | Supabase Auth session state |
| `theme_provider.dart` | `useThemeStore.ts` | |
| `language_provider.dart` | `useLanguageStore.ts` | |

**Not:** `e2e_*` ve `biometric`/`app_lock` için store yok — §0.4 gereği kaldırıldı.

### 7.2 Servisler (`src/services/`)

Öncelik sırasıyla:

- [ ] `authService.ts` (Supabase Auth wrapper: login/signup/reset/logout, session persist via `expo-secure-store`)
- [ ] `syncEngine` (§5.3), `fileService.ts` (§6)
- [ ] `audioService.ts` (`expo-av` kayıt/oynatma, Flutter `audio_service.dart` referans)
- [ ] `ocrService.ts` (`@react-native-ml-kit/text-recognition`, Flutter `ocr_service.dart` referans)
- [ ] `notificationService.ts` (`expo-notifications` yerel zamanlı hatırlatmalar), `smartAlertService.ts`, `weeklyReportService.ts` (bu ikisi kısmen sunucu tarafına taşınıyor, §8.3)
- [ ] `calendarService.ts` (`expo-calendar`, takvime ekleme)
- [ ] `locationService.ts`, `attendanceAutomationService.ts` (§8.3)
- [ ] `homeWidgetService.ts` (§8.5)
- [ ] `kvkkConsentService.ts`, `securityQuestionsService.ts` (hesap kurtarma güvenlik soruları — E2E'den bağımsız, kalabilir)
- [ ] `moodleService.ts` — client tarafı, tüm çağrılar Edge Function proxy'sine gider (§8.3), Moodle token'ı client'ta hiç görünmez

### 7.3 Modeller (`src/models/`)

Supabase'in `supabase gen types typescript` komutuyla üretilen tipler **tek doğruluk kaynağı**; `models/` altında sadece bunların üzerine ince domain tipleri (enum'lar, computed alanlar) eklenir. Flutter'daki Freezed modellerinin alan isimlerini referans al ama snake_case→camelCase dönüşümünü Supabase client'ın kendi konfigürasyonuna bırak.

- [ ] **P2.1** `supabase gen types typescript --local > src/models/database.types.ts` script'ini `package.json`'a ekle, her şema değişikliğinde çalıştırılacak şekilde dokümante et.

### 7.4 Yerelleştirme

- [ ] **P2.2** `app/lib/l10n/app_{tr,en,de,es}.arb` (761 anahtar/dil) → `i18n/locales/{tr,en,de,es}.json` mekanik dönüşüm scripti.

---

## 🔴 8 — Yüksek riskli sistemler

### 8.1 Tema/tasarım sistemi
- [ ] **P1.6** `app_colors.dart`'taki renk sabitlerini `theme/colors.ts`'e taşı, ışık/koyu tema toggle.

### 8.2 Çizim/el yazısı motoru (Skia) — EN YÜKSEK RİSK

Kaynak (referans, davranış paritesi için): `drawing_canvas.dart`, `drawing_data_codec.dart` (`{"v":2,"strokesByPage":{...}}` formatı).

- [ ] **P1.7 (spike)** Skia ile basınç duyarlı çizim prototipi: parmak/Apple Pencil ayrımı, palm rejection, basınç→kalınlık.
- [ ] **P1.8** `drawingDataCodec.ts`: aynı `{v:2, strokesByPage}` formatını kullan (yeni format, legacy v1 okuma desteği **gerekmiyor** — sıfırdan başlıyoruz). Postgres'te `notes.drawing_data jsonb` sütununa doğrudan yazılır.
- [ ] **P1.9** Çok sayfalı PDF üzerine anotasyon ekranı: mode seçici (blank/photo/pdf), her mod için ayrı Skia canvas katmanı.
- [ ] **P1.10** Not görüntüleyicide PDF arka planı + üstüne stroke render.

### 8.3 Moodle entegrasyonu + arka plan senkron (mimari değişiklik: kısmen sunucu tarafına taşındı)

**Neden değişti:** Flutter'da Moodle senkronu tamamen cihazda (Workmanager periyodik task) çalışıyordu ve arka plan task'larının state'i bayat bırakması bilinen bir hata sınıfıydı. Supabase Edge Functions + `pg_cron` ile bu işin büyük kısmı **sunucuda, cihazdan bağımsız** çalışabilir.

- [ ] **P1.11** `supabase/functions/moodle-proxy/`: client'tan gelen Moodle API isteklerini (Moodle REST, `wstoken` ile) sunucu tarafında yapan Edge Function. Token `moodle_accounts.wstoken`'dan `service_role` ile okunur, client'a asla dönmez.
- [ ] **P1.12** `supabase/functions/moodle-sync-cron/`: `pg_cron` ile her N dakikada bir tetiklenir, aktif tüm `moodle_accounts` için Moodle API'den courses/assignments/grades/announcements/calendar/messages çeker, `moodle_cache` tablosuna `upsert` eder. Client bu tabloyu **Supabase Realtime ile dinler** — yeni veri geldiğinde otomatik UI güncellemesi, arka plan task'ı gerekmez.
- [ ] **P1.13** `pg_cron` job'unu kaydet: `select cron.schedule('moodle-sync', '*/30 * * * *', $$ select net.http_post(url:='https://<project>.functions.supabase.co/moodle-sync-cron', headers:='{"Authorization":"Bearer <service_role_or_secret>"}'::jsonb) $$);`
- [ ] **P1.14** Moodle tab ekranları (`courses`, `assignments`, `grades`, `announcements`, `calendar`, `messages`) — `moodle_cache` + Realtime'dan okur, "yenile" butonu manuel bir Edge Function tetikler.

**GPS tabanlı devamsızlık otomasyonu — bu kısım sunucuya taşınamaz** (cihazın konumu gerekir):
- [ ] **P1.15** `expo-task-manager` + `expo-location` ile arka plan konum kontrolü (ders saatinde geofence kontrolü, Flutter `attendance_automation_service.dart` mantığı referans). **Kural (§5.3'te belirtildi):** doğrudan DB yazmaz, outbox + invalidation event kullanır.

### 8.4 PDF sayfa render
- [ ] **P1.16 (spike)** `react-native-pdf-thumbnail` ile PDF sayfasını görsele çevirip Skia canvas arkasına koy; yetersizse native modül (iOS `PDFKit`, Android `PdfRenderer`).

### 8.5 iOS/Android home widget
- [ ] **P1.17** Yeni bundle ID ile sıfırdan WidgetKit uzantısı (iOS) + App Widget (Android) — Flutter'daki `home_widget_service.dart` mantığı referans, App Group/SharedPreferences yerine hafif bir yerel JSON dosyası (widget'ın okuyabileceği shared container'da) kullan.

### 8.6 Bildirimler (hibrit: yerel + sunucu)
- [ ] **P1.18** Yakın zamanlı hatırlatmalar (ders başlıyor, çalışma zamanlayıcısı bitti) → `expo-notifications` yerel zamanlı bildirim, offline çalışır.
- [ ] **P1.19** Uzak/periyodik hatırlatmalar (haftalık rapor, yaklaşan deadline) → `supabase/functions/send-push-cron/`, `pg_cron` ile tetiklenir, Expo Push API'ye push token'lı kullanıcılara gönderir. Push token, login sonrası `profiles` tablosuna (veya `auth.users` metadata'sına) kaydedilir.

---

## 📋 9 — Ekran/özellik envanteri

### Auth & onboarding
- [ ] Login / Signup / E-posta doğrulama / Şifre sıfırlama (Supabase Auth)
- [ ] Veli onayı ekranı + KVKK akışı (aydınlatma metni, açık rıza) — **korunuyor**, hukuki gereklilik
- [ ] Onboarding tanıtım ekranları

### Ana akış
- [ ] Ana ekran (bugünün dersleri, offline banner, senkron durumu göstergesi)
- [ ] Ders ekleme/düzenleme (çakışma kontrolü — `hasScheduleConflict` mantığı, konum seçimi)
- [ ] Ders detay + tab'lar: notlar, notlar(grades), dosyalar, devamsızlık takvimi
- [ ] El yazısı/çizim canvas ekranı (§8.2)
- [ ] Not detay (ses oynatıcı, çizim/PDF görüntüleyici, resim tam ekran)
- [ ] Arama (Postgres full-text search, `notes` tablosundaki `search_content` üzerinden — §4'teki `gin` index)
- [ ] Deadline listesi/takvimi
- [ ] GPA hesaplayıcı
- [ ] Study timer + geçmiş

### Moodle
- [ ] Moodle hesap bağlama (base URL + token/login), hesaplar listesi
- [ ] Moodle ders detay (section/module kartları)
- [ ] Tab'lar: courses, assignments, grades, announcements, calendar, messages — hepsi `moodle_cache` + Realtime tabanlı (§8.3)

### Ayarlar
- [ ] Profil, tercihler, veri yönetimi (dışa aktar/hesap sil)
- [ ] Depolama ekranı (yerel SQLite cache + Storage kullanım özeti, cache temizleme)
- [ ] Bildirim ayarları, onay yönetimi (KVKK)
- [ ] Statik içerik ekranları (gizlilik politikası, kullanım koşulları, çerez politikası, yardım) — en düşük risk, isterse en başta bitirilir

---

## 📅 10 — Faz planı

### Faz R0 — Temel + fizibilite kanıtı (DURDURMA NOKTASI)
- [ ] P0.1–P0.10 (iskelet, Supabase kurulum, şema, RLS doğrulama spike'ı)
- [ ] P1.1 sync engine spike'ı (tek tablo, uçtan uca)
- [ ] React Navigation iskeleti (tüm ekranlar placeholder)
- [ ] i18n kurulumu + P2.2 (4 dil tam çeviri)
- [ ] Tema sistemi (P1.6)
- **Gate:** P0.10 (RLS izolasyon testi) ve P1.1 (sync spike) geçmeden R1'e geçilmez.

### Faz R1 — Düşük riskli CRUD
- [ ] Auth ekranları (gerçek Supabase Auth akışı)
- [ ] Statik ayar ekranları
- [ ] Ders CRUD, devamsızlık takibi (manuel, GPS hariç)
- [ ] Not defteri — sadece metin tipi notlar
- [ ] GPA hesaplayıcı, deadline listesi
- [ ] P1.2 sync engine'i tüm tablolara genişlet
- **Checkpoint:** sync engine stabilitesi değerlendirilir, gerekirse PowerSync'e geçiş kararı burada alınır (§5.3).

### Faz R2 — Orta riskli entegrasyonlar
- [ ] Moodle proxy + cron + tüm Moodle tab'ları (§8.3, P1.11–P1.14)
- [ ] Kamera/galeri/ses kayıt, görsel sıkıştırma, Storage upload (§6)
- [ ] OCR entegrasyonu
- [ ] Yerel bildirimler + sunucu tetikli push (§8.6)
- [ ] Arama ekranı (full-text search)

### Faz R3 — Yüksek riskli çekirdek
- [ ] §8.2 tam çizim/el yazısı sistemi
- [ ] §8.4 PDF sayfa render + not görüntüleyicide PDF arka planı
- [ ] §8.3 GPS devamsızlık otomasyonu (arka plan konum + outbox deseni)
- [ ] §8.5 home widget
- [ ] Study timer (arka planda süre tutma)

### Faz R4 — Doğrulama + rollout
- [ ] Uçtan uca manuel smoke test (tüm ekranlar, offline→online senaryoları dahil)
- [ ] RLS güvenlik gözden geçirmesi (başka bir kullanıcının verisine hiçbir yoldan erişilemediğinin doğrulanması — otomatikleştirilmiş test seti)
- [ ] EAS Build + Submit ile mağaza gönderimi (yeni uygulama olarak, §13'teki karara göre)

---

## 🧪 11 — Test stratejisi

- **Birim testleri:** Repository/service katmanı için Jest.
- **Component testleri:** `@testing-library/react-native`, kritik ekranlar (auth, ders CRUD, sync).
- **RLS/güvenlik testleri:** Supabase'e karşı gerçek HTTP istekleriyle (2 farklı test kullanıcısı session'ı) izolasyon testleri — bkz. P0.10, R4'te otomatikleştirilir.
- **Sync engine testleri:** offline yazma → outbox → push → çakışma senaryoları (iki "cihaz" simülasyonu).
- **E2E (Detox):** Düşük öncelik, opsiyonel, R4'e ertelenebilir.

---

## ⚠️ 12 — Riskler

| Risk | Etki | Azaltma |
|---|---|---|
| Custom sync engine üretimde kırılgan çıkıyor (çakışma, kayıp yazma) | Yüksek | R1 checkpoint'inde PowerSync'e geçiş kaçış yolu (§5.3) |
| Skia çizim performansı/UX'i hedefin gerisinde kalıyor | Yüksek | P1.7 spike'ı erken, gerçek cihazda test |
| RLS policy'lerinde bir tablo unutulur/yanlış yazılır → veri sızıntısı | Kritik | P0.10 + R4'te otomatik RLS test seti zorunlu |
| Moodle `wstoken`'ın client'a sızması (proxy'yi bypass eden bir kod yolu) | Kritik | Token sadece `service_role` ile erişilir tabloda, client `moodle_accounts_public` view'ını kullanır, code review'da bu sınır özellikle kontrol edilir |
| PDF sayfa render için hazır paket yetersiz | Orta | P1.16 spike'ı, gerekirse native modül |
| Expo prebuild ile bir native modülün config plugin'i yok çıkar | Orta | `expo prebuild` her zaman native koda inip elle patch atmaya izin verir, kilitlenme değil |
| GPS arka plan görevi state senkron hatası (Flutter'da bilinen desen) tekrarlanır | Orta | §5.3'teki outbox+invalidation kuralı zorunlu, code review'da kontrol edilir |

---

## 🤔 13 — İnsana onaylatılması gereken açık konular

- **Mağaza stratejisi:** Yeni uygulama olarak mı (yeni bundle ID/Play Store listing) yoksa mevcut listing'i güncelleyerek mi (aynı bundle ID, ama veri sıfırdan başladığı için kullanıcılar login olduğunda boş bir hesap görecek) yayınlanacak? Bu plan **yeni uygulama** varsayımıyla yazıldı ama karar netleşmedi.
- **Mevcut Flutter kullanıcılarına iletişim:** Sıfırdan başlangıç, mevcut kullanıcıların verisinin (dersler, notlar, çizimler) yeni sürümde görünmeyeceği anlamına geliyor. Bu, kullanıcılara nasıl duyurulacak (uygulama içi banner, e-posta) — ürün/iletişim kararı, bu planın kapsamı dışında ama R4 öncesi netleşmeli.
- **Supabase bölgesi ve ücretlendirme planı:** Kullanıcı sayısı/Storage hacmi büyüdükçe Supabase'in Pro plan eşiklerine (DB boyutu, Storage, Edge Function invocation) ne zaman geçileceği — bu bir maliyet kararı, plana dahil edilmedi.

Bunun dışında bu doküman kendi başına yürütülebilir.
