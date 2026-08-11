# Android Release İmzalama (Faz 0.6)

Bu doküman `docs/REFACTORING_PLAN.md` §0.6'nın uygulama prosedürüdür. Gradle tarafı (`android/app/build.gradle.kts`) zaten hazır — `android/key.properties` dosyası bulunduğunda otomatik olarak release build'i gerçek keystore ile imzalar. Dosya yoksa (henüz keystore oluşturulmadıysa) release debug key ile imzalanmaya devam eder, `flutter run --release` kırılmaz.

Kalan iş yalnızca keystore'u oluşturmak ve `key.properties`'i doldurmak — bu adım **kullanıcı tarafından** yapılmalı; keystore ve şifreler bu repoya veya bir sohbete asla yazılmamalı.

## 1. Keystore oluştur

```bash
keytool -genkey -v -keystore ~/lessontracker-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias lessontracker
```

`keytool` sırasında bir şifre (store password) ve isteğe bağlı olarak ayrı bir key password belirlemeni ister — aynısını kullanmak sorun değil.

## 2. Keystore'u güvenle sakla

- `~/lessontracker-release.jks` dosyasını **repo dışında**, şifreli bir yedekleme sistemine (parola yöneticisi, şifreli disk, bulut vault) kopyala.
- **Bu dosya kaybolursa mağazada yayınlanmış uygulama bir daha güncellenemez** — Google Play yeni bir keystore ile imzalanan APK'yı aynı uygulama olarak kabul etmez.
- En az iki farklı yerde yedek tut (örn. yerel şifreli disk + 1Password/Bitwarden ek dosya eki).

## 3. `key.properties` oluştur

`app/android/key.properties.example` dosyasını kopyala:

```bash
cd app/android
cp key.properties.example key.properties
```

`key.properties`'i gerçek değerlerle doldur:

```properties
storePassword=<keytool'da girdiğin store password>
keyPassword=<keytool'da girdiğin key password>
keyAlias=lessontracker
storeFile=/Users/sen/lessontracker-release.jks
```

`storeFile` **mutlak yol** olmalı. Bu dosya `.gitignore`'da zaten hariç tutuluyor (`app/android/.gitignore:12` ve kök `.gitignore:123`) — `git status` ile commit'e girmediğini doğrula.

## 4. Doğrula

```bash
cd app
flutter build apk --release
```

Build başarılı olduysa ve `key.properties` doluysa, üretilen APK artık gerçek keystore ile imzalanmıştır. Doğrulamak için:

```bash
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

Çıktıda `CN=` alanında keytool'da girdiğin bilgiler görünmeli (debug key'de `CN=Android Debug` görünür).

## 5. CI (ileride, isteğe bağlı)

Şu an CI (`​.github/workflows/flutter_ci.yml`) yalnızca **debug** APK build ediyor — bu adım secrets gerektirmediği için hâlâ geçerli. CI'da imzalı **release** build almak istersen:

1. Keystore'u base64'e çevirip GitHub repo secret'ı olarak ekle (`ANDROID_KEYSTORE_BASE64`), artı `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.
2. Workflow'a, checkout sonrası secret'lardan `key.properties`'i ve keystore dosyasını diske yazan bir adım ekle (`echo "$SECRET" | base64 -d > ...`).
3. `flutter build apk --release` adımını ekle.

Bu adım şimdilik **yapılmadı** — keystore henüz oluşturulmadığı için secret de yok. Keystore hazır olduğunda ayrı bir PR ile eklenebilir.
