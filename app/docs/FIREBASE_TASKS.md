# Firebase Hata Ayıklama Görevleri

Bu uygulama macOS üzerinde "imzasız" (unsigned) geliştirme modunda çalıştığı için Apple'ın güvenlik (Keychain) kısıtlamalarına takılmaktadır. Aşağıdaki adımları takip ederek sorunun tam kaynağını ve alternatifleri test edebilirsiniz.

## 1. Ağ ve Yapılandırma Kontrolü
- [ ] **Wrong Password Testi:** Giriş ekranında rastgele yanlış bir şifre girin.
    - **Beklenen:** "Wrong password" veya "User not found" hatası.
    - **Anlamı:** İnternet erişimi ve Firebase bağlantısı sorunsuz çalışıyor demektir.
    - **Sonuç:** Keychain hatası almıyorsanız, bağlantı sağlamdır.

- [ ] **Kayıt (Sign Up) Testi:** Yeni bir e-posta adresi ile "Kayıt Ol" işlemi yapın.
    - **Beklenen:** Başarılı bir şekilde ana ekrana yönlendirilmek.
    - **Nedeni:** Kayıt olma işlemi sırasında Firebase oturum bilgisini `currentUser` olarak belleğe yazar. Kalıcı depolama başarısız olsa bile o anlık oturum açılabilir.
    
## 2. Kalıcılık (Persistence) Sorunu
- [ ] **Uygulamayı Yeniden Başlatma:** Başarılı bir kayıttan sonra uygulamayı tamamen kapatıp açın.
    - **Beklenen:** Giriş ekranına dönmesi (Oturumun hatırlanmaması).
    - **Nedeni:** macOS debug modunda şifreler Keychain'e yazılamadığı için uygulama her açılışta oturumu unutacaktır. Bu beklenen bir durumdur.

## 3. Giriş (Sign In) Hatası
- [ ] **Doğru Şifre ile Giriş:** Kayıt olduğunuz e-posta ve şifre ile giriş yapmayı deneyin.
    - **Olası Hata:** `keychain-error` veya `MacOS Debug Keychain Error` (Program tarafından eklenen özel mesaj).
    - **Çözüm:** Bu hata macOS Debug kısıtlamasıdır. Uygulama geliştirimine devam etmek için **Misafir Girişi (Guest Login)** kullanmanız veya Apple Developer Hesabı ile uygulamayı imzalamanız gerekir.

## 4. Alternatif Test Yöntemleri
- [ ] **Guest Mode (Misafir Modu):** Giriş ekranındaki "Misafir Girişi" seçeneğini kullanın.
    - Bu mod veritabanı yazma işlemlerini kısıtlayabilir ancak Arayüz (UI) ve Sayfa geçişlerini test etmek için en hızlı yoldur.
    
- [ ] **Android / iOS Simulator:** Eğer imkanınız varsa, uygulamayı Android Emulator veya iOS Simulator üzerinde çalıştırın.
    - `flutter run -d <device_id>`
    - Bu platformlarda Keychain kısıtlaması (Debug modda) yoktur.

## Not
Geliştirme süreci boyunca "Veri Yazma" ve "Veri Okuma" testlerini yapabilmek için **Sign Up (Kayıt Ol)** işlemini her test seansında bir kez yaparak geçici bir oturum oluşturabilirsiniz.
