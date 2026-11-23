# LessonTracker — UI & Akış Düzeltme Planı (23 Kasım 2026)

- **Kaynak:** 23.11.2026 uçtan uca UI testi (Chrome, 390×844, açık/koyu tema, 33 ekran görüntüsü) + kod doğrulaması
- **Dal:** `fix/ui-audit-2026-11` (`feat/auth-deep-links` üzerine)
- **Kurallar:** [`REFACTORING_PLAN.md`](REFACTORING_PLAN.md) §2.0 (constructor injection, `provider`), metinler 4 dilde `l10n/*.arb` + `flutter gen-l10n`
- **Durum:** 🚧 Kısmen uygulandı — commit 1–3 tamam (U2–U8, U13, U14 kısmen); kalan: U1, U9–U12, U15–U19

## Bulgular → Karar

| # | Bulgu | Karar |
|---|---|---|
| U1 | Misafir "hesaba geç" yolu yok; tek yol Sign Out ve tüm yerel veriyi siliyor | Misafir kartı "Giriş yap / hesap oluştur" diyaloğu açar → `AuthProvider.leaveGuestMode()` **veriyi silmeden** giriş ekranına döner. Misafir için "Çıkış" → "Misafir modundan çık (veriler silinir)" uyarısıyla; "Hesabı sil" gizlenir |
| U2 | Ana ekran geri oku `SystemNavigator.pop()` | Kaldırılır |
| U3 | Varsayılan dil sabit `en`; ~30 sabit metin | Kayıtlı tercih yoksa cihaz dili (desteklenirse); onboarding, Moodle, sayaçlar, kartlar, form ipuçları l10n'e taşınır |
| U4 | Giriş/kayıt şifre alanı "New Password"; ipucu "Enter your {label}" | `password` anahtarı; her alan için ayrı ipucu anahtarı |
| U5 | "Priority Focus" tüm dersleri gösteriyor | Tüm derslerin gösterilmesi bilinçli ürün kararı (kod yorumu) → korunur; dikkat gerektirenler (sınav ≤7 gün, geride <%50, devamsızlık ≥%70) başa sıralanır ve etiketlenir |
| U6 | "At Risk"/"Deadlines" sayaçları etiketlerle çelişiyor | Risk = U5 kümesi; Deadlines = 7 gün içindeki teslimler + sınavlar |
| U7 | Örnek veride çakışma, notlar yanlış derslerde, kırık görsel | Linear Algebra Sal/Per; notlar ders adına göre eşlenir; dosyasız görsel notu yerine metin notu |
| U8 | "Spring Semester" sabit | Dersin alt başlığı gösterilir; yoksa yalnız hoca |
| U9 | Haftalık programda çakışan dersler üst üste | Çakışan bloklar yan yana sütunlara bölünür |
| U10 | Haftalık programda kelime ortadan bölünüyor | Tek satır + üç nokta |
| U11 | "Create Course" butonu düşük kontrast | Beyaz yazı |
| U12 | Stil tutarsızlıkları (mor buton, switch, bağlantı arka planı) | `switchTheme` temaya; şifre ekranları ana renk; bağlantılar aynı stil |
| U13 | Form hataları kutunun içine sıkışıyor | Dolgu/kenarlık `InputDecoration`'a taşınır, hata alanın altında |
| U14 | Alt menü etiketi kesiliyor, Ayarlar ortada; devamsızlık kartı 3× tekrar; son onboarding sayfasında Skip; "+ tuşuna bas" | Kısa etiket, sıra Ana/Plan/Hafta/Moodle/Ayarlar; "kalan hak" satırı kaldırılır; son sayfada Skip gizli; boş durum metni düzeltilir |
| U15 | Web'de veri kalıcı değil | Web'de kalıcı "Demo modu — veriler kaydedilmez" bandı (tam web desteği kapsam dışı) |
| U16 | Her değişiklik tüm veriyi yeniden yüklüyor | Değişen kayıt takibi (`pending_changes` `upsert`); backup yalnız değişenleri gönderir, ilk/elle yedek tam |
| U17 | CourseProvider her işlemde yeni Grade/AttendanceProvider | Tek örnek, constructor injection |
| U18 | Misafir KVKK akışını görmüyor | KVKK kontrolü misafiri de kapsar |
| U19 | `EmailVerificationScreen` erişilemez | Girişte "e-posta onaylanmadı" hatasında "Onay e-postasını tekrar gönder"; ekran kaldırılır |

## Commit sırası
1. i18n + form metinleri (U3, U4, U14-etiket)
2. Ana ekran mantığı + örnek veri (U2, U5, U6, U7, U14-boş durum)
3. Ders detayı (U8, U14-devamsızlık)
4. Haftalık program (U9, U10)
5. Tema/stil (U11, U12, U13, U14-onboarding)
6. Kimlik akışı (U1, U18, U19)
7. CourseProvider (U17)
8. Artımlı yedek (U16)
9. Web bandı (U15)
10. Testler + doküman

Her commit: `flutter analyze` temiz, `flutter test` yeşil; sonda tarayıcıda ekran görüntüleriyle yeniden kontrol.
