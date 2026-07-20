# Aktif QA Durumu

**Son güncelleme:** 17 Temmuz 2026
**Kaynak denetim:** [`../AUDIT_REPORT_2026-07-17.md`](../AUDIT_REPORT_2026-07-17.md)

Bu belge, `archive/qa/` altındaki 8 eski raporun yerini alır. Kök dizinde tek bir güncel QA kaynağı olması amaçlanmıştır.

---

## 1. Test Komutları

| Amaç | Komut (repo kökünden) |
|---|---|
| Tüm testler | `cd app && flutter test` |
| Statik analiz | `cd app && flutter analyze` |
| Chrome'da çalıştır | `cd app && flutter run -d chrome` |
| Belirli test | `cd app && flutter test test/providers/absence_provider_test.dart` |

## 2. Mevcut Durum (17 Temmuz 2026 ölçümü)

| Metrik | Değer | Kaynak |
|---|---|---|
| `flutter test` geçen | **33 / 72 (%46)** | §04 denetim raporu |
| `flutter analyze` uyarısı | **63** (0 derleme hatası) | §01 |
| Başarısız testlerin kök nedeni | `test/test_helpers.dart` SqlCipher mock'u hatalı | §04 |
| Etkilenen testler | 30 iş-mantığı testi + 3 mockito import hatası | §04 |

## 3. Bilinen Kırık Testler ve Kök Nedenleri

### A. SqlCipher mock hatası (30 test etkilenir)

**Hata:**
```
Unsupported operation: Unsupported queryResult type null
package:sqflite_common/src/database_mixin.dart … txnRawQuery
package:lesson_tracker/core/database/database_helper.dart:48 DatabaseHelper.database
test/providers/absence_provider_test.dart:22 (setUp → clearAllData)
```

**Kök neden:** `test/test_helpers.dart` içindeki `setupSqlCipherMock()` gerçek `sqflite_sqlcipher` platform kanalını tam modellenemiyor; her testin `setUp` adımındaki `clearAllData()` çağrısında istisna fırlatıyor.

**Etkilenen dosyalar (tamamı):**
- `app/test/providers/absence_provider_test.dart`
- `app/test/providers/course_provider_test.dart`
- `app/test/providers/deadline_provider_test.dart`
- `app/test/providers/deadline_provider_extended_test.dart`
- `app/test/providers/grade_provider_test.dart`
- `app/test/providers/note_provider_test.dart`

**Çözüm planı:** Bkz. `../IMPLEMENTATION_PLAN.md` madde #3. Önerilen: `sqflite_common_ffi` ile testlerde `databaseFactoryFfi` kullanmak.

### B. Mockito import hatası (3 test etkilenir)

**Hata:** `test/auth_flow_test.dart` `package:mockito/mockito.dart` import ediyor ama `pubspec.yaml` `dev_dependencies`'de `mockito` yok.

**Çözüm:** `mocktail` (zaten bağımlılıkta) ile yeniden yazmak VEYA `mockito` paketini eklemek.

### C. Diğer 6 başarısız test

Bu 6 test kök neden olarak SqlCipher mock hatasıyla aynı kategoriye girmez; ayrı tanı gerekir. `flutter test --reporter expanded` çıktısı incelenmeli.

## 4. Aksiyon Planı (özet)

Tam liste: `IMPLEMENTATION_PLAN.md`. QA ile doğrudan ilgili olanlar:

| # | Aksiyon | Öncelik |
|---|---|---|
| 3 | SqlCipher mock → `sqflite_common_ffi` | Yüksek |
| 4 | Android release imzalama → gerçek keystore | Yüksek |
| 5 | Kök `.gitignore` + log/txt temizliği | Yüksek |
| 9 | 17 rapor → `docs/` konsolidasyonu (bu belge) | Yüksek |

## 5. Çalıştırılmamış / Kapsam Dışı

Aşağıdakiler bu ortamda yapılamadı, manuel test gerektirir:

- Gerçek parmak/kalemle UI gezinme (ekran görüntüsü otomasyonu yok).
- Gerçek Moodle sunucusuna uçtan uca senkronizasyon.
- Android/iOS cihaz veya emülatör (bu makinede yalnızca Windows/Chrome/Edge hedefleri).
- Gerçek stylus donanımıyla basınç testi.

Bunlar kod okuma yoluyla değerlendirildi; gerçek QA oturumlarıyla doğrulanmalı.