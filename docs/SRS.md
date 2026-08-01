# LessonTracker — Yazılım Gereksinim Spesifikasyonu (SRS)
**Software Requirements Specification (ISO/IEC/IEEE 29148 & IEEE 830 Standartlarına Uygun)**

- **Proje Adı:** LessonTracker
- **Sürüm:** 1.1.0
- **Tarih:** 1 Ağustos 2026
- **Durum:** Güncellenmiş Mimari ve İş Akış Diyagramları Destekli Spesifikasyon

---

## 1. Giriş (Introduction)

### 1.1 Amaç
Bu doküman, **LessonTracker** (Çok Modlu Ders ve Not Takip Uygulaması) yazılım sisteminin fonksiyonel ve fonksiyonel olmayan gereksinimlerini, mimari yapısını, harici arayüz entegrasyonlarını, iş akışlarını ve güvenlik kriterlerini görsel diyagramlarla destekleyerek tanımlamak üzere hazırlanmıştır. Doküman; geliştiriciler, test mühendisleri ve proje paydaşları için ortak bir referans kaynağı oluşturur.

### 1.2 Kapsam
LessonTracker; öğrencilerin ders programlarını düzenlemelerini, devamsızlık durumlarını konum bazlı otomasyonla takip etmelerini, Moodle LMS sistemlerinden ders materyali ve ödev bilgilerini senkronize etmelerini, çok modlu notlar (metin, ses, OCR/görsel, el yazısı/çizim) almalarını ve PDF materyalleri üzerinde dijital defter deneyimi yaşamalarını sağlayan çok platformlu (Flutter tabanlı) bir mobil/web uygulamasıdır.

### 1.3 Tanımlar ve Kısaltmalar
| Kısaltma | Açıklama |
|---|---|
| **SRS** | Software Requirements Specification (Yazılım Gereksinim Spesifikasyonu) |
| **LMS** | Learning Management System (Öğrenme Yönetim Sistemi - Moodle) |
| **OCR** | Optical Character Recognition (Optik Karakter Tanıma) |
| **E2EE** | End-to-End Encryption (Uçtan Uca Şifreleme) |
| **KVKK** | Kişisel Verilerin Korunması Kanunu |
| **CRUD** | Create, Read, Update, Delete (Oluştur, Oku, Güncelle, Sil) |
| **GPS** | Global Positioning System (Küresel Konumlama Sistemi) |

### 1.4 Referanslar
1. [`docs/AUDIT_REPORT_2026-07-17.md`](AUDIT_REPORT_2026-07-17.md) — Sistem Denetim Raporu
2. [`docs/IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md) — İyileştirme ve Aksiyon Planı
3. [`app/pubspec.yaml`](../app/pubspec.yaml) — Bağımlılık ve Yapılandırma Manifestosu

---

## 2. Genel Açıklama ve Mimari Diyagramlar (Overall Description)

### 2.1 Ürün Perspektifi ve Sistem Mimarisi
LessonTracker, istemci tarafında Flutter (Dart) framework'ü ile geliştirilmiş, yerel SQLCipher (şifreli SQLite) veritabanı ile çevrimdışı öncelikli (offline-first) çalışan, arka planda Firebase (Auth, Firestore, Storage, Cloud Functions) ve Moodle REST API servisleri ile senkronize olan hibrit bir sistemdir.

#### 🏛️ Şekil 2.1: Genel Sistem Mimari Diyagramı
```mermaid
graph TD
    subgraph "İstemci Katmanı (Client Layer)"
        UI["Flutter UI (Material Design 3 / Lexend Font)"]
        PROV["State Management (Provider Pattern)"]
        UI --> PROV
    end

    subgraph "Yerel Mantık & Depolama (Local Core & Storage)"
        SEC_STORE["Flutter Secure Storage (Keys/Tokens)"]
        SQL["SQLCipher Encrypted DB (Offline First)"]
        SERVICES["Core Services (Attendance, Note, Sync)"]
        PROV --> SERVICES
        SERVICES --> SQL
        SERVICES --> SEC_STORE
    end

    subgraph "Donanım Arayüzleri (Hardware Sensors)"
        CAM["Kamera (Camera)"]
        MIC["Mikrofon (Microphone)"]
        GPS["GPS Konum Servisi (Geolocator)"]
        STYLUS["Tablet Kalemi / Touch Screen"]
        SERVICES --> CAM
        SERVICES --> MIC
        SERVICES --> GPS
        SERVICES --> STYLUS
    end

    subgraph "Harici ve Bulut Servisleri (External Cloud Services)"
        FIRE_AUTH["Firebase Auth (Identity)"]
        FIRESTORE["Cloud Firestore (Cloud Sync)"]
        FIRE_STORE["Firebase Storage (Media/Voice/Pdfs)"]
        MOODLE_API["Moodle REST API (Courses, Content, Grades)"]
        ML_KIT["Google ML Kit (OCR Engine)"]
        
        SERVICES --> FIRE_AUTH
        SERVICES --> FIRESTORE
        SERVICES --> FIRE_STORE
        SERVICES --> MOODLE_API
        SERVICES --> ML_KIT
    end
```

---

### 2.2 Kullanım Senaryosu Diyagramı (Use Case Diagram)
Uygulama üzerindeki birincil aktör olan öğrencilerin gerçekleştirdiği ana işlevsel etkileşimler aşağıda modellenmiştir.

#### 👥 Şekil 2.2: Kullanım Senaryoları (Use Cases)
```mermaid
graph LR
    Actor["Öğrenci (Birincil Kullanıcı)"]

    subgraph "LessonTracker Kullanım Senaryoları"
        UC1["Ders Ekleme ve Zaman Tablosu Görüntüleme"]
        UC2["Moodle Hesabı Bağlama ve Senkronizasyon"]
        UC3["Devamsızlık Takibi (Manuel / Otomatik GPS)"]
        UC4["Çok Modlu Not Alma (Metin, Ses, OCR)"]
        UC5["PDF / Defter Üzerinde Çizim Yapma (Stylus)"]
        UC6["Biyometrik Giriş Yapma (Face ID / Touch ID)"]
    end

    Actor --> UC1
    Actor --> UC2
    Actor --> UC3
    Actor --> UC4
    Actor --> UC5
    Actor --> UC6

    UC3 ..> |"İçerir (Includes)"| UC7["GPS Coğrafi Sınır (Geofence) Kontrolü"]
    UC4 ..> |"Genişletir (Extends)"| UC8["Görsel Belgeden OCR ile Metin Çıkarma"]
    UC2 ..> |"İçerir (Includes)"| UC9["Moodle REST API Token İçe Aktarma"]
```

---

## 3. Sistem Özellikleri ve İş Akış Diyagramları

### 3.1 Ders & Çakışma Yönetimi
- **FR-1.1:** Kullanıcı yeni bir ders oluşturabilmeli, ders adı, kodu, öğretim elemanı, sınıf konumu (enlem/boylam ve metin) ve saat bilgilerini girebilmelidir.
- **FR-1.2:** Sistem, eklenen dersin mevcut ders saatleri ile çakışıp çakışmadığını (`hasScheduleConflict`) kontrol etmeli ve kullanıcıyı uyarmalıdır.
- **FR-1.3:** Eklenen dersler haftalık ızgara (`WeeklyTimetableScreen`) ve günlük akış kartları üzerinde görüntülenmelidir.
- **FR-1.4:** Moodle'dan çekilen ders isimleri, yeni ders ekleme formunda otomatik tamamlama önerisi olarak sunulmalıdır.

---

### 3.2 Devamsızlık Takibi & GPS Coğrafi Sınır Akışı
Ders saatinde öğrencinin derse katılımı cihazın GPS konumu vasıtasıyla coğrafi sınır (Geofencing) doğrulamasından geçerek otomatik olarak kaydedilebilir.

#### 📍 Şekil 3.1: GPS Tabanlı Otomatik Yoklama ve Devamsızlık Akış Şeması
```mermaid
flowchart TD
    Start(["Ders Zamanı Başlangıcı"]) --> CheckGPS{"Cihaz GPS İzni ve Lokasyon Açık mı?"}
    
    CheckGPS -- "Hayır" --> ManualNotice["Manuel Devamsızlık Kaydı Bekleniyor"]
    CheckGPS -- "Evet" --> FetchLoc["Cihazın Anlık Konumunu Al (Geolocator)"]
    
    FetchLoc --> CalcDist["Derslik Enlem/Boylamı ile Mesafe Hesapla"]
    CalcDist --> WithinFence{"Mesafe <= Coğrafi Sınır (Örn: 50m)?"}
    
    WithinFence -- "Evet" --> AttendanceOK["Derse Katılım Onaylandı (Yoklama Var)"]
    WithinFence -- "Hayır" --> RecordAbsence["Devamsızlık Kaydı Oluştur"]
    
    AttendanceOK --> SyncProvider["CourseProvider State Güncelle"]
    RecordAbsence --> SyncProvider
    
    SyncProvider --> DBUpdate["SQLCipher Yerel DB'ye Yaz"]
    DBUpdate --> UIUpdate["Ana Ekran ve Sayaç Kartlarını Güncelle"]
    UIUpdate --> End(["İşlem Tamamlandı"])
```

---

### 3.3 Moodle LMS Entegrasyonu ve Senkronizasyon Sıralaması
Moodle REST API entegrasyonu tek yönlü senkronizasyon (Moodle → İstemci) yaklaşımını benimser.

#### 🔄 Şekil 3.2: Moodle Senkronizasyon Sıralama Diyagramı (Sequence Diagram)
```mermaid
sequenceDiagram
    autonumber
    actor Student as Öğrenci
    participant UI as Moodle Screen UI
    participant Provider as MoodleProvider
    participant SyncService as MoodleSyncService
    participant RestAPI as Moodle REST API
    participant LocalDB as SQLCipher Local DB

    Student->>UI: "Senkronize Et" Butonuna Basar
    UI->>Provider: syncMoodleData()
    Provider->>SyncService: fetchLatestCoursesAndMaterials()
    
    alt İnternet Bağlantısı Var
        SyncService->>RestAPI: GET core_course_get_contents (Token ile)
        RestAPI-->>SyncService: 200 OK (Dersler, Dosyalar, Ödevler JSON)
        SyncService->>LocalDB: Verileri Güncelle ve Önbelleğe Al
        SyncService-->>Provider: Senkronizasyon Başarılı Döner
        Provider-->>UI: Ekranı Yeni Materyallerle Yenile
    else İnternet Bağlantısı Yok (Offline)
        SyncService->>LocalDB: Önbellekteki Son Verileri Oku
        LocalDB-->>SyncService: Çevrimdışı Moodle Önbelleği
        SyncService-->>Provider: Çevrimdışı Verileri Gönder
        Provider-->>UI: "Çevrimdışı Mod: Önbellekteki Veriler Gösteriliyor" Uyarısı Ver
    end
```

---

### 3.4 Çok Modlu (Multimodal) Not & Çizim Modülü İş Akışı
Kullanıcı metin, ses kaydı, OCR görsel tarama veya PDF üzerine tablet kalemi ile çizim yaparak notlar oluşturur.

#### ✏️ Şekil 3.3: Çok Modlu Not Alma ve Çok Sayfalı PDF Çizim Akış Şeması
```mermaid
flowchart TD
    CreateNote["Yeni Not / Materyal Aç"] --> SelectMode{"Not Modu Seçimi"}
    
    SelectMode -- "Metin" --> TextMode["Klavye ile Metin Notu Gir"]
    SelectMode -- "Ses Kaydı" --> RecordMode["Dahili Mikrofonla Ses Kaydet (record)"]
    SelectMode -- "Görsel / OCR" --> OCRMode["Fotoğraf Çek / Galeriden Seç"]
    SelectMode -- "Tablet Çizim (PDF)" --> DrawMode["PDFViewer ve Çizim Kanvasını Aç"]
    
    OCRMode --> MLKit["Google ML Kit ile Metin Algıla"]
    MLKit --> TextMode
    
    DrawMode --> LoadPage["İlgili PDF Sayfasını Yükle (Page N)"]
    LoadPage --> RenderCanvas["strokesByPage[currentPage] Katmanını Çiz"]
    RenderCanvas --> StylusInput["perfect_freehand ile Çizim Yap (Stylus)"]
    StylusInput --> SaveStrokes["Stroke Verisini ilgili Sayfa İndeksi ile Eşle"]

    TextMode --> SaveNote["Note Modelini Oluştur / Güncelle"]
    RecordMode --> SaveNote
    SaveStrokes --> SaveNote
    
    SaveNote --> SaveLocal["SQLCipher Şifreli Depolamaya Kaydet"]
    SaveLocal --> CloudSync["Firebase Storage / Firestore'a Senkronize Et"]
```

---

## 4. Veri Modeli ve Varlık-İlişki Diyagramı (ER Diagram)

Uygulamanın şifreli SQLite (SQLCipher) üzerinde tuttuğu temel ilişkisel veri mimarisi aşağıda gösterilmiştir.

#### 🗄️ Şekil 4.1: Varlık-İlişki (Entity Relationship - ER) Diyagramı
```mermaid
erDiagram
    COURSE ||--o{ SCHEDULE : "sahiptir"
    COURSE ||--o{ ABSENCE : "takip eder"
    COURSE ||--o{ NOTE : "içerir"
    COURSE ||--o{ MOODLE_MATERIAL : "senkronize eder"
    NOTE ||--o{ NOTE_STROKE : "PDF çizim katmanları içerir"

    COURSE {
        string id PK
        string code
        string name
        string instructor
        string location_name
        double latitude
        double longitude
        int max_absences
    }

    SCHEDULE {
        string id PK
        string course_id FK
        int day_of_week
        string start_time
        string end_time
    }

    ABSENCE {
        string id PK
        string course_id FK
        string date
        string reason
        boolean is_auto_gps
    }

    NOTE {
        string id PK
        string course_id FK
        string title
        string text_content
        string audio_path
        string ocr_image_path
        string pdf_path
        string created_at
    }

    NOTE_STROKE {
        string id PK
        string note_id FK
        int page_number
        string stroke_points_json
        string color_hex
        double stroke_width
    }

    MOODLE_MATERIAL {
        string id PK
        string course_id FK
        string moodle_item_id
        string title
        string file_url
        string file_type
        boolean is_downloaded
    }
```

---

## 5. Fonksiyonel Olmayan Gereksinimler (Non-Functional Requirements)

### 5.1 Performans (Performance)
- **NFR-1.1:** Uygulama soğuk açılış (cold start) süresi mobil cihazlarda 2.5 saniyenin altında olmalıdır.
- **NFR-1.2:** Çizim kanvasındaki kalem tepki süresi (latency) ve kare hızı 60 FPS akıcılığında tutulmalıdır.
- **NFR-1.3:** Çevrimdışı SQLite veritabanı sorguları 100 ms'nin altında yanıt vermelidir.

### 5.2 Güvenlik ve Gizlilik (Security & Privacy)
- **NFR-2.1 (KVKK / GDPR):** Kullanıcı verileri ve alınan notlar kullanıcının rızası olmadan üçüncü taraf servislerle paylaşılmamalıdır.
- **NFR-2.2 (Release Imzalama):** Android derlemeleri üretim ortamına gönderilmeden önce geçerli bir üretim anahtarı (production keystore) ile imzalanmalıdır.
- **NFR-2.3 (Çevre Değişkenleri):** Hassas API anahtarları `.env` dosyası üzerinden okunmalı, ham halleriyle koda gömülmemeli ve derlenmiş asset'lerde açık şekilde paketlenmemelidir.

### 5.3 Kullanılabilirlik ve Erişilebilirlik (Usability & Accessibility)
- **NFR-3.1 (Tipografi):** Uygulama tipografisi tüm ekran ve platformlarda standart marka fontu (Lexend) ile tutarlı şekilde render edilmelidir.
- **NFR-3.2 (Metin Ölçekleme):** Erişilebilirlik metin ölçeği (`TextScaler`) kullanıcının cihaz ayarlarına uygun esneklikte (0.8x - 1.5x) çalışmalı, arayüzü bozmamalıdır.
- **NFR-3.3 (Karanlık Tema):** Sistem Material Design 3 ilkelerine uygun Aydınlık ve Karanlık (Dark Mode) tema desteği sunmalıdır.

### 5.4 Güvenilirlik ve Test Edilebilirlik (Reliability & Testability)
- **NFR-4.1:** Otomatik test paketindeki (unit/provider/widget) başarı oranı %100 olmalı; test altyapısındaki SQLite mock uyumsuzlukları giderilmelidir.
- **NFR-4.2:** İnternet kesintilerinde veri kaybı yaşanmamalı; işlemler yerel veritabanında sıraya alınıp bağlantı sağlandığında buluta aktarılmalıdır.

---

## 6. Arayüz ve Donanım Entegrasyonları

### 6.1 Donanım Arayüzleri
- **Kamera:** Belge fotoğraflama ve OCR işlemi için (`camera`, `image_picker`).
- **Mikrofon:** Sesli not kaydı için (`record`, `audioplayers`).
- **GPS / Lokasyon:** Derslik bazlı otomatik yoklama için (`geolocator`).
- **Stylus / Tablet Kalemi:** Basınca duyarlı veya standart çizim etkileşimi için (`perfect_freehand`).

### 6.2 Yazılım Arayüzleri
- **Moodle Web Services REST API:** `core_course_get_contents`, `gradereport_user_get_grade_items` vb.
- **Firebase SDK:** `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`.
- **Google ML Kit:** Metin tanıma (OCR) servisi.

---

## 7. Mevcut Sistem Açıkları ve İyileştirme Planı

Audit Raporu (17 Temmuz 2026) doğrultusunda SRS kapsama alınan acil düzeltme maddeleri:

1. **Brand Font Onarımı:** Bozuk HTML kaynaklı Lexend `.ttf` dosyalarının orijinal Google Fonts TTF verileriyle güncellenmesi.
2. **Görsel Asset Ekleme:** `assets/images/app_icon.png` ve `splash_logo.png` dosyalarının tamamlanarak launcher ve splash araçlarının yapılandırılması.
3. **Test Altyapısı (SqlCipher Mock):** `test_helpers.dart` içindeki test SQLite altyapısının `sqflite_common_ffi` ile modernize edilip 72/72 testin yeşile çekilmesi.
4. **Devamsızlık Durum Senkronu:** Takvim sekmesindeki devamsızlık girdilerinin `CourseProvider` ile merkezi state'e bağlanması.
5. **Çok Sayfalı PDF Çizim Düzeltmesi:** `note_detail_screen.dart` içinde sayfa indeksleme ve `strokesByPage` eşlemesinin çok sayfalı yapılara genişletilmesi.
