# Supabase Kurulumu

LessonTracker bulut tarafında Supabase kullanır (Eylül 2026'da Firebase'in yerine geçti):

| Eski (Firebase) | Yeni (Supabase) |
|---|---|
| Firebase Auth | Supabase Auth (e-posta + şifre) |
| Firestore `users/{uid}` | `public.profiles` tablosu |
| Firestore `users/{uid}/{koleksiyon}/{id}` | `public.user_records` tablosu (`collection`, `id`, `data jsonb`) |
| Firebase Storage `users/{uid}/...` | Storage bucket'ı `user-files`, yol `{uid}/{photos\|audio\|documents}/...` |
| Cloud Function `sendVeliVerificationEmail` | Edge Function `send-veli-verification-email` |
| Firestore Security Rules | Row Level Security (RLS) politikaları |
| Crashlytics | Kaldırıldı (yerine bir şey konmadı) |

Bulut verisi eskisi gibi istemcide şifrelenir (`{"encryptedData": ...}`). Sunucu yalnızca şifreli içeriği ve ilişki kurmak için `course_id` sütununu görür.

> **Bu repo için proje:** `slpsyormnfbgooaevzhb` (eu-central-1). Şema 28.09.2026'da uygulandı. IPv4 ağlardan veritabanına `aws-0-eu-central-1.pooler.supabase.com:5432` (kullanıcı `postgres.slpsyormnfbgooaevzhb`) üzerinden bağlanılır.

## 1. Proje oluşturma

1. <https://supabase.com/dashboard> üzerinden yeni bir proje açın. KVKK açısından bölge olarak Frankfurt (`eu-central-1`) önerilir.
2. **Project Settings → API** sayfasından `Project URL` ve `Publishable key` değerlerini alın.
3. `app/.env` dosyasını oluşturun (`app/.env.example` dosyasını şablon olarak kullanabilirsiniz):

   ```env
   SUPABASE_URL=https://<proje-ref>.supabase.co
   SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
   ```

   Uygulamayı bu değerlerle çalıştırmak için:

   ```bash
   cd app
   flutter run --dart-define-from-file=.env
   flutter build apk --dart-define-from-file=.env   # release derlemeleri için de gerekli
   ```

   VS Code için yerel bir `.vscode/launch.json` dosyasına `"toolArgs": ["--dart-define-from-file=.env"]` eklenebilir (`.vscode/` git'e girmez). `.env` asset olarak paketlenmez (CI bunu engeller), bu yüzden parametre verilmezse uygulama yine açılır ama yalnızca misafir/çevrimdışı modda çalışır.

## 2. Şema, RLS ve Storage

[Supabase CLI](https://supabase.com/docs/guides/cli) ile:

```bash
supabase login
supabase link --project-ref <proje-ref>
supabase db push            # supabase/migrations/*.sql
```

CLI kullanmıyorsanız `supabase/migrations/20260928000000_init.sql` dosyasının içeriğini Dashboard'daki **SQL Editor**'e yapıştırıp çalıştırmanız yeterli.

Bu migration şunları oluşturur:
- `profiles` tablosu ve kayıt olunca profil satırını açan `on_auth_user_created` trigger'ı
- `user_records` tablosu ve kullanıcıya özel RLS politikaları
- Hesap silmek için `delete_current_user()` RPC fonksiyonu (KVKK md. 7)
- Gizli `user-files` bucket'ı ve klasör bazlı Storage politikaları

## 3. Edge Function (veli onay e-postası)

```bash
supabase secrets set EMAIL_USER=<gmail> EMAIL_PASS=<uygulama-şifresi> \
  EMAIL_FROM="LessonTracker <noreply@lessontracker.com>"
supabase functions deploy send-veli-verification-email
```

## 4. Auth ayarları (Dashboard → Authentication)

- **Email provider:** Açık. "Confirm email" açıksa kullanıcı onay bağlantısına tıklamadan giriş yapamaz. Bu durumda E2E anahtarı kayıt anında değil, ilk girişte üretilir.
- **Minimum password length:** 6 (uygulamadaki mesajla uyumlu).
- **Şifre sıfırlama:** `resetPasswordForEmail` bir bağlantı gönderir. Kullanıcının yeni şifre belirleyebilmesi için ya bir deep link (`redirectTo` + uygulamada `passwordRecovery` olayını dinleyen bir ekran) ya da **Site URL** altında barındırılan bir şifre sıfırlama sayfası gerekir. Bu adım henüz uygulanmadı.
- **SMTP:** Supabase'in yerleşik e-posta servisi saatlik düşük bir limitle gelir. Canlı ortamda **Custom SMTP** tanımlanmalıdır.

## Firebase'den veri taşıma

Eski Firebase verisi otomatik olarak taşınmaz. Kullanıcıların yerel verisi cihazda (SQLCipher) durduğu için, Supabase hesabıyla giriş yapıp **Ayarlar → Yedekle** dediklerinde veri yeni backend'e yüklenir. Firebase Auth hesapları Supabase'e aktarılmadığından kullanıcıların yeniden kayıt olması gerekir.
