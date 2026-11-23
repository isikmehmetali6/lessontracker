# OCR Düzeltme Planı (23 Kasım 2026)

- **Durum:** ✅ Uygulandı — `flutter analyze` temiz, `flutter test` 149/149. Gerçek cihazda ML Kit testi yapılmadı (cihaz yok).
- **Kapsam:** Fotoğraftan metin tanıma (Google ML Kit, `OcrService`) ile ilgili tüm akış — giriş noktaları, rıza, kayıt, gösterim
- **Dal:** `fix/ocr-2026-11`
- **Not:** Uygulamada seslendirme (TTS) yok; "metin okuma" = OCR.

| # | Bulgu | Karar |
|---|---|---|
| O1 | Fotoğrafta metin bulunamasa da "OCR notu kaydedildi" deniyor, boş not oluşuyor | Metin yoksa not oluşturulmaz; "metin bulunamadı, ışığı/açıyı düzelt" uyarısı |
| O2 | OCR yalnız kameradan; galerideki fotoğraf okutulamıyor | Kaynak seçimi: Kamera / Galeri |
| O3 | KVKK OCR rızası (`consent_ocr`) hiç kontrol edilmiyor; "İzin Aldım" diyaloğu kullanıcının reddettiği kamera rızasını sessizce "verildi" yapıyor | Tek rıza kapısı `ConsentUtils.ensureCaptureConsent(kind)`: OCR için kamera **ve** OCR rızası; eksikse bilgilendirici açık rıza diyaloğu (amaç açıkça yazılı) |
| O4 | Sabit/İngilizce metinler: "Scan d/m" başlığı, "OCR Scan" rozeti, "OCR failed", rıza diyaloğu (sabit Türkçe), simülatör/web hataları | l10n (en/tr/de/es); hatalar kod → çeviri |
| O5 | OCR başarısız olunca kaydedilen fotoğraf diskte yetim kalıyor | Hata/boş metinde kaydedilen görsel silinir |
| O6 | Not detayında metin düzenleme dışında seçilemiyor/kopyalanamıyor | "Metni kopyala" düğmesi |
| O7 | İki giriş noktası (ana ekran, ders detayı) kopya mantık; ders detayı kullanılmayan `ocr_consent_timestamp` yazıyor | Ortak `runOcrCapture` akışı |
| O8 | Web'de kamera açılıp en sonda "desteklenmiyor" hatası | Desteklenmeyen platformda baştan çevrilmiş uyarı |

Testler: `NoteProvider.addOcrNote` (başarı, boş metin, servis hatası + görsel temizliği), rıza kapısı, OCR akışının kaynak seçimi.
