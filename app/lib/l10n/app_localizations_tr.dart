// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ders Takip';

  @override
  String get homeParams => 'Ana Sayfa';

  @override
  String get planParams => 'Plan';

  @override
  String get statsParams => 'İstatistik';

  @override
  String get settingsParams => 'Ayarlar';

  @override
  String get priorityFocus => 'Öncelikli Odak';

  @override
  String get viewAll => 'Hepsini Gör';

  @override
  String get quickCapture => 'Hızlı Kayıt';

  @override
  String get recentNotes => 'Son Notlar';

  @override
  String get noNotesYet => 'Henüz not yok. Kaydetmeye başla!';

  @override
  String get noNotesDescription => 'İlk notunuzu almak için aşağıdaki araçları kullanın!';

  @override
  String get goodMorning => 'Günaydın,';

  @override
  String get goodAfternoon => 'Tünaydın,';

  @override
  String get goodEvening => 'İyi Akşamlar,';

  @override
  String get weeklySchedule => 'Haftalık Program';

  @override
  String get todaysClasses => 'Bugünün Dersleri';

  @override
  String get noClassesScheduled => 'Planlanmış ders yok';

  @override
  String get addCourseToSeeSchedule => 'Takviminizi görmek için ders ekleyin';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get trackYourProgress => 'Öğrenme ilerlemeni takip et';

  @override
  String get addNewCourse => 'Yeni Ders Ekle';

  @override
  String get courseName => 'Ders Adı';

  @override
  String get courseNameHint => 'örn. Matematik';

  @override
  String get classSchedule => 'Ders Programı';

  @override
  String get addTimeSlot => 'Zaman Aralığı Ekle';

  @override
  String get classroomLocation => 'Sınıf / Konum';

  @override
  String get classroomHint => 'örn. Fen Fakültesi 304';

  @override
  String get professorOptional => 'Profesör (İsteğe Bağlı)';

  @override
  String get professorHint => 'örn. Dr. Yılmaz';

  @override
  String get absenceLimit => 'Devamsızlık Limiti';

  @override
  String get maxAllowedPerSemester => 'Dönem başına izin verilen maks.';

  @override
  String get cardColor => 'Kart Rengi';

  @override
  String get createCourse => 'Ders Oluştur';

  @override
  String get pleaseEnterCourseName => 'Lütfen bir ders adı girin';

  @override
  String get pleaseAddClassTime => 'Lütfen en az bir ders saati ekleyin';

  @override
  String get failedToCreateSchedule => 'Bazı program öğeleri oluşturulamadı';

  @override
  String get courseProgress => 'Ders İlerlemesi';

  @override
  String get lessonMaterials => 'Ders Materyalleri';

  @override
  String get newNote => 'Yeni Not';

  @override
  String get title => 'Başlık';

  @override
  String get writeYourNote => 'Notunuzu yazın...';

  @override
  String get saveNote => 'Notu Kaydet';

  @override
  String get deleteCourse => 'Dersi Sil';

  @override
  String get deleteCourseConfirmation => 'Bu işlem, bu dersle ilişkili tüm notları silecektir.';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get keyboard => 'Klavye';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get lightMode => 'Aydınlık Mod';

  @override
  String get systemMode => 'Sistem';

  @override
  String get noClassTimesAdded => 'Henüz ders saati eklenmedi.';

  @override
  String get voiceMemo => 'Ses Kaydı';

  @override
  String get notesHeader => 'Notlar';

  @override
  String get deleteNoteTitle => 'Notu Sil?';

  @override
  String get thisActionCannotBeUndone => 'Bu işlem geri alınamaz.';

  @override
  String get totalCourses => 'Toplam Ders';

  @override
  String get totalNotes => 'Toplam Not';

  @override
  String get avgProgress => 'Ort. İlerleme';

  @override
  String get studyStreak => 'Çalışma Serisi';

  @override
  String get activeCourses => 'Aktif dersler';

  @override
  String get notesCaptured => 'Kaydedilen notlar';

  @override
  String get overallProgress => 'Genel ilerleme';

  @override
  String get daysInRow => 'Gün üst üste';

  @override
  String get weeklyGoal => 'Haftalık Hedef';

  @override
  String get syncBackup => 'Senkronizasyon';

  @override
  String get storage => 'Depolama';

  @override
  String get helpSupport => 'Yardım & Destek';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get settingsHeader => 'Ayarlar';

  @override
  String get settingsSubHeader => 'Deneyiminizi özelleştirin';

  @override
  String get profileName => 'Alex Öğrenci';

  @override
  String get profileEmail => 'alex@universite.edu.tr';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get weeklyGoalSub => '5/7 gün';

  @override
  String get courseAbsence => 'Devamsızlık';

  @override
  String get remainingAbsences => 'kalan';

  @override
  String get addAbsence => 'Devamsızlık Ekle';

  @override
  String get removeAbsence => 'Devamsızlık Sil';

  @override
  String absenceLimitExceeded(Object excess) {
    return 'Limit aşıldı! ($excess fazla)';
  }

  @override
  String get noAbsenceRightsLeft => 'Hiç hakkın kalmadı!';

  @override
  String absenceRightsLeft(Object count) {
    return '$count hak kaldı';
  }

  @override
  String get absenceLabel => 'Devamsızlık';

  @override
  String get remainingLabel => 'Kaldı';

  @override
  String get addAbsenceAction => 'Devamsızlık ekle';

  @override
  String get removeAbsenceAction => 'Son devamsızlığı kaldır';

  @override
  String get viewHistory => 'Geçmişi Görüntüle';

  @override
  String get gpa => 'GNO';

  @override
  String get academicStanding => 'Akademik Durum';

  @override
  String get atRisk => 'Riskli Devamsızlık';

  @override
  String get coursePerformance => 'Ders Performansı';

  @override
  String get recentGrades => 'Son Notlar';

  @override
  String get noGradesData => 'Henüz not verisi yok.';

  @override
  String get excellent => 'Mükemmel';

  @override
  String get good => 'İyi';

  @override
  String get average => 'Orta';

  @override
  String get improvementNeeded => 'Geliştirilmeli';

  @override
  String get gradesTab => 'Notlar';

  @override
  String get filesTab => 'Dosyalar';

  @override
  String get notesTab => 'Notlar';

  @override
  String get addGrade => 'Puan Ekle';

  @override
  String get noGradesYet => 'Henüz puan eklenmedi.';

  @override
  String get noFilesYet => 'Henüz dosya yok';

  @override
  String get uploadFile => 'Dosya Yükle';

  @override
  String get addFile => 'Dosya Ekle';

  @override
  String nextExamIn(int days) {
    return '$days gün sonra sınav';
  }

  @override
  String get semesterDefault => 'Bahar Dönemi';

  @override
  String get noProfessor => 'Profesör Yok';

  @override
  String get weight => 'Ağırlık';

  @override
  String get averageShort => 'Ort';

  @override
  String get searchHint => 'Not, etiket ara (#sınav)...';

  @override
  String get noResults => 'Eşleşen not bulunamadı';

  @override
  String get searchStartPrompt => 'Başlık, içerik veya etiket ile ara';

  @override
  String get deadlinesHeader => 'Teslim Tarihleri';

  @override
  String get deadlinesSubtitle => 'Görevlerini zamanında tamamla';

  @override
  String get noUpcomingDeadlines => 'Yaklaşan teslim tarihi yok';

  @override
  String get addFirstDeadline => 'İlk teslim tarihini ekle';

  @override
  String get deadlineOverdue => 'Gecikmiş';

  @override
  String get deadlineToday => 'Bugün';

  @override
  String daysLeft(int days) {
    return '$days gün kaldı';
  }

  @override
  String get addDeadlineTitle => 'Teslim Tarihi Ekle';

  @override
  String get editDeadline => 'Teslim Tarihini Düzenle';

  @override
  String get updateDeadline => 'Teslim Tarihini Güncelle';

  @override
  String get fillAllFields => 'Lütfen tüm alanları doldurun';

  @override
  String get titleHint => 'Başlık (örn. Vize, Proje)';

  @override
  String get selectCourse => 'Ders Seç';

  @override
  String get noCoursesAvailable => 'Ders bulunamadı. Önce ders ekleyin.';

  @override
  String get addToCalendar => 'Takvime Ekle';

  @override
  String get saveToDeviceCalendar => 'Cihaz takvimine kaydet';

  @override
  String get assignmentNameHint => 'Ödev Adı (örn. Vize)';

  @override
  String get score => 'Puan';

  @override
  String get max => 'Maks';

  @override
  String get weightPercent => 'Ağırlık (%)';

  @override
  String get saveGrade => 'Puanı Kaydet';

  @override
  String get addNoteToImage => 'Resme Not Ekle';

  @override
  String get titleOptional => 'Başlık (İsteğe Bağlı)';

  @override
  String get imageContentHint => 'Bu resim hakkında bir şeyler yaz...';

  @override
  String get tagsHint => 'Etiketler (örn. #sınav, #tarih)';

  @override
  String get absenceHistory => 'Devamsızlık Geçmişi';

  @override
  String get noAbsenceHistory => 'Henüz devamsızlık yok.';

  @override
  String get welcomeToClass => 'Derse hoşgeldin! 🎓';

  @override
  String get youAreInArea => 'Ders konumundasın.';

  @override
  String get syncDescription => 'Verilerinizi buluta yedekleyin veya bu cihaza geri yükleyin.';

  @override
  String get processing => 'İşleniyor...';

  @override
  String get backupData => 'Verileri Yedekle';

  @override
  String get backupDescription => 'Yerel verileri buluta yükle';

  @override
  String get restoreData => 'Verileri Geri Yükle';

  @override
  String get restoreDescription => 'Buluttan indir (Yerel verinin üzerine yazar)';

  @override
  String get confirmRestore => 'Geri Yüklemeyi Onayla';

  @override
  String get restoreWarning => 'Bu işlem bazı yerel verilerin üzerine bulut verilerini yazacaktır. Devam et?';

  @override
  String get restoreAction => 'Geri Yükle';

  @override
  String get save => 'Kaydet';

  @override
  String get attendanceStatus => 'Devamsızlık Durumu';

  @override
  String get perfectAttendance => 'Mükemmel katılım! Böyle devam et!';

  @override
  String absences(int current, int limit) {
    return '$current / $limit Devamsızlık';
  }

  @override
  String get riskLabel => 'RİSK';

  @override
  String get todaySchedule => 'Bugünkü Program';

  @override
  String get noClassesToday => 'Bugün ders yok — keyfine bak! 🎉';

  @override
  String get guestUser => 'Misafir';

  @override
  String get searchPlaceholder => 'Ders, not veya etiket ara...';

  @override
  String get noCourses => 'Henüz ders yok';

  @override
  String get addYourFirstCourse => 'İlk dersini eklemek için + butonuna dokun!';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get name => 'İsim';

  @override
  String get email => 'E-posta';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get currentPassword => 'Mevcut Şifre';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get confirmPassword => 'Şifre Tekrarı';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get passwordTooShort => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi';

  @override
  String get emailVerificationSent => 'Yeni adrese doğrulama e-postası gönderildi';

  @override
  String get passwordChanged => 'Şifre başarıyla değiştirildi';

  @override
  String get faqTitle => 'Sık Sorulan Sorular';

  @override
  String get faqQ1 => 'Yeni ders nasıl eklenir?';

  @override
  String get faqA1 => 'Ana ekrandaki + butonuna dokunun ve ders adı, program ve profesör bilgilerini doldurun.';

  @override
  String get faqQ2 => 'Devamsızlıklarımı nasıl takip edebilirim?';

  @override
  String get faqA2 => 'Herhangi bir dersi açın ve devamsızlık sayacını kullanarak devamsızlık ekleyin veya çıkarın. Limite yaklaştığınızda uyarı alırsınız.';

  @override
  String get faqQ3 => 'Verilerimi yedekleyebilir miyim?';

  @override
  String get faqA3 => 'Evet! Ayarlar > Senkronizasyon bölümüne giderek verilerinizi buluta yükleyebilirsiniz. Bu özelliği kullanmak için giriş yapmanız gerekir.';

  @override
  String get faqQ4 => 'Sesli not nasıl kaydedilir?';

  @override
  String get faqA4 => 'Bir ders açın, + butonuna dokunun ve mikrofon simgesini seçerek ses kaydı başlatın.';

  @override
  String get faqQ5 => 'Uygulama dilini nasıl değiştiririm?';

  @override
  String get faqA5 => 'Ayarlar\'a gidin ve Dil seçeneğine dokunun. İngilizce, Türkçe, İspanyolca ve Almanca arasında seçim yapabilirsiniz.';

  @override
  String get contactUs => 'İletişim';

  @override
  String get emailSupport => 'E-posta Destek';

  @override
  String get reportBug => 'Hata Bildir';

  @override
  String get reportBugDescription => 'Bir sorun mu buldunuz? Bize bildirin';

  @override
  String get featureRequest => 'Özellik İsteği';

  @override
  String get featureRequestDescription => 'Yeni bir özellik önerin';

  @override
  String get aboutApp => 'Hakkında';

  @override
  String get aboutDescription => 'Lesson Tracker, öğrencilerin derslerini organize etmelerine, devamsızlıklarını takip etmelerine, not almalarına ve teslim tarihlerini yönetmelerine yardımcı olur.';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfService => 'Kullanım Koşulları';

  @override
  String get totalStorageUsed => 'Toplam Kullanılan Alan';

  @override
  String get storageBreakdown => 'Depolama Dağılımı';

  @override
  String get database => 'Veritabanı';

  @override
  String get mediaFiles => 'Medya Dosyaları';

  @override
  String get cache => 'Önbellek';

  @override
  String get dataStats => 'Veri İstatistikleri';

  @override
  String get clearCache => 'Önbelleği Temizle';

  @override
  String get clearCacheConfirmation => 'Geçici dosyalar silinecektir. Verileriniz etkilenmez. Devam et?';

  @override
  String get cacheCleared => 'Önbellek başarıyla temizlendi!';

  @override
  String get signOutConfirmation => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get lastBackup => 'Son yedekleme';

  @override
  String get never => 'Hiç';

  @override
  String get loginRequiredForSync => 'Senkronizasyon için giriş yapın';

  @override
  String get autoSync => 'Otomatik Senkronizasyon';

  @override
  String get tapToEdit => 'Profili düzenlemek için dokunun';

  @override
  String get studyTimer => 'Çalışma Zamanlayıcısı';

  @override
  String get focusTime => 'Odaklanma Zamanı';

  @override
  String get breakTime => 'Mola Zamanı';

  @override
  String get session => 'Oturum';

  @override
  String get sessionComplete => 'Harika! Oturum tamamlandı 🎉';

  @override
  String get breakComplete => 'Mola bitti! Odaklanmaya hazır mısın?';

  @override
  String get studyingFor => 'Çalışılan ders';

  @override
  String get noCourseSelected => 'Ders seçilmedi';

  @override
  String get timerPresets => 'Süre Seçenekleri';

  @override
  String get short => 'Kısa';

  @override
  String get classic => 'Klasik';

  @override
  String get long => 'Uzun';

  @override
  String get marathon => 'Maraton';

  @override
  String get completedSessions => 'Tamamlanan oturumlar';

  @override
  String get gpaCalculator => 'GPA Hesaplayıcı';

  @override
  String get overallGPA => 'Genel GPA';

  @override
  String get totalCredits => 'Kredi';

  @override
  String get gpaCourses => 'Ders';

  @override
  String get letterGrade => 'Harf Notu';

  @override
  String get gpaScale => 'GPA Skalası';

  @override
  String get courseBreakdown => 'Ders Bazlı Detay';

  @override
  String get credits => 'kredi';

  @override
  String get gpaNoGrades => 'Henüz not yok';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get studyTimerDesc => 'Pomodoro Zamanlayıcı';

  @override
  String get gpaCalcDesc => 'GPA Hesaplayıcı';

  @override
  String get absenceCalendar => 'Devamsızlık Takvimi';

  @override
  String get viewAbsenceCalendar => 'Devamsızlık Takvimini Gör';

  @override
  String get noAbsencesOnDay => 'Bu günde devamsızlık yok';

  @override
  String get unexcused => 'Mazeretsiz';

  @override
  String get medical => 'Sağlık';

  @override
  String get excused => 'İzinli';

  @override
  String get personal => 'Kişisel';

  @override
  String absencePredictionWarning(String weeks) {
    return 'Bu hızla $weeks hafta sonra limiti aşarsın';
  }

  @override
  String get professorDetails => 'Profesör Detayları';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get officeRoom => 'Ofis Odası';

  @override
  String get officeHoursLabel => 'Ofis Saatleri';

  @override
  String get teachingAssistant => 'Asistan';

  @override
  String get emailCopied => 'E-posta kopyalandı';

  @override
  String get phoneCopied => 'Telefon kopyalandı';

  @override
  String get addLink => 'Link Ekle';

  @override
  String get linkName => 'Link Adı';

  @override
  String get linkAdded => 'Link eklendi';

  @override
  String get webLink => 'Web Linki';

  @override
  String get templateCornellNotes => 'Cornell Notları';

  @override
  String get templateLectureSummary => 'Ders Özeti';

  @override
  String get templateExamNotes => 'Sınav Notları';

  @override
  String get startFromTemplate => 'Şablondan Başla';

  @override
  String get transcript => 'Transkript';

  @override
  String get inProgress => 'Devam Ediyor';

  @override
  String get semesterReport => 'Dönem Sonu Raporu';

  @override
  String get generatePdfReport => 'PDF raporu oluştur';

  @override
  String get exportDataCsv => 'Verileri Dışa Aktar (CSV)';

  @override
  String get exportData => 'Verileri Dışa Aktar';

  @override
  String get gradesCsv => 'Notlar (CSV)';

  @override
  String get absencesCsv => 'Devamsızlıklar (CSV)';

  @override
  String get studySessionsCsv => 'Çalışma Süreleri (CSV)';

  @override
  String get selectAbsenceReason => 'Devamsızlık sebebini seç';

  @override
  String get editCourse => 'Dersi Düzenle';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get setLocationGeofence => 'Konum Belirle (Geofence)';

  @override
  String get absenceUnexcused => 'Mazeretsiz';

  @override
  String get absenceMedical => 'Sağlık Raporu';

  @override
  String get absenceExcused => 'İzinli';

  @override
  String get absencePersonal => 'Kişisel';

  @override
  String get absenceOverview => 'Devamsızlık Durumu';

  @override
  String get absencesUsed => 'devamsızlık kullanıldı';

  @override
  String get totalAbsences => 'toplam devamsızlık';

  @override
  String get editAbsence => 'Devamsızlığı Düzenle';

  @override
  String get deleteAbsence => 'Devamsızlığı Sil';

  @override
  String get selectReason => 'Sebep seçin:';

  @override
  String get convertToPdf => 'PDF\'e Çevir';

  @override
  String get allNotesToPdf => 'Tüm Notlar → PDF';

  @override
  String get photosToPdf => 'Fotoğraflar → PDF';

  @override
  String get courseReportPdf => 'Ders Raporu → PDF';

  @override
  String get appLock => 'Uygulama Kilidi';

  @override
  String get appLockDisabled => 'Kapalı';

  @override
  String get appLockAuthReason => 'Uygulama kilidini etkinleştirmek için doğrulayın';

  @override
  String get shareNotes => 'Notlarını Görüntüle';

  @override
  String get archiveCourse => 'Dersi Arşivle';

  @override
  String get welcomeBack => 'Tekrar hoş geldin!';

  @override
  String get loginSubtitle => 'Öğrenme yolculuğuna devam etmek için giriş yap.';

  @override
  String get emailAddress => 'E-posta Adresi';

  @override
  String get emailRequired => 'Lütfen e-posta adresinizi girin';

  @override
  String get validEmailRequired => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get passwordRequired => 'Lütfen şifrenizi girin';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get logIn => 'Giriş Yap';

  @override
  String get orDivider => 'VEYA';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get signUp => 'Kaydol';

  @override
  String get continueAsGuest => 'Misafir Olarak Devam Et';

  @override
  String get resetPassword => 'Şifre Sıfırla';

  @override
  String get resetPasswordDescription => 'E-posta adresinizi girin, şifrenizi sıfırlamanız için size bir link göndereceğiz.';

  @override
  String get sendLink => 'Link Gönder';

  @override
  String get passwordResetSent => 'Şifre sıfırlama e-postası gönderildi! Gelen kutunuzu kontrol edin.';

  @override
  String get guestDescription => 'Verileriniz yalnızca bu cihazda yerel olarak saklanır ve buluta senkronize olmaz. Daha sonra verilerinizi yedeklemek için bir hesap oluşturabilirsiniz.';

  @override
  String get continueAction => 'Devam Et';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get signupSubtitle => 'Akademik başarınızı takip etmek için katılın.';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get nameRequired => 'Lütfen adınızı girin';

  @override
  String get nameMinLength => 'Ad en az 2 karakter olmalıdır';

  @override
  String get confirmPasswordRequired => 'Lütfen şifrenizi onaylayın';

  @override
  String get haveAccount => 'Zaten hesabınız var mı?';

  @override
  String get verifyYourEmail => 'E-postanızı Doğrulayın';

  @override
  String get verificationEmailSent => 'Doğrulama e-postası gönderildi! Gelen kutunuzu kontrol edin.';

  @override
  String get checkInbox => 'Lütfen gelen kutunuzu kontrol edin ve hesabınızı etkinleştirmek için doğrulama linkine tıklayın.';

  @override
  String get resendVerification => 'Doğrulama E-postasını Yeniden Gönder';

  @override
  String get iVerifiedMyEmail => 'E-postamı doğruladım → Devam Et';

  @override
  String get skip => 'Atla';

  @override
  String get getStarted => 'Başlayalım';

  @override
  String get nextLabel => 'İleri';

  @override
  String get savedDataFound => 'Kayıtlı Veri Bulundu';

  @override
  String savedDataDescription(Object courseCount) {
    return 'Bu hesapta $courseCount kayıtlı ders bulunuyor.';
  }

  @override
  String get loadDataDescription => 'Verilerinizi yüklemek derslerinizi, notlarınızı ve teslim tarihlerinizi bu cihaza aktaracaktır.';

  @override
  String get cloudDataCleared => 'Eski bulut verileri temizlendi. Sıfırdan başlanıyor.';

  @override
  String get startFresh => 'Sıfırdan Başla';

  @override
  String get loadData => 'Verileri Yükle';

  @override
  String get youAreOffline => 'Çevrim dışısınız';

  @override
  String get processingOcr => 'OCR işleniyor...';

  @override
  String get ocrNoteSaved => 'OCR notu kaydedildi!';

  @override
  String get noCoursesAddFirst => 'Ders bulunamadı. Önce bir ders ekleyin!';

  @override
  String get selectCourseTitle => 'Ders Seç';

  @override
  String get chooseSaveLocation => 'Bu notun nereye kaydedileceğini seçin';

  @override
  String get weeklyTimetable => 'Haftalık Ders Programı';

  @override
  String get dayMon => 'Pzt';

  @override
  String get dayTue => 'Sal';

  @override
  String get dayWed => 'Çar';

  @override
  String get dayThu => 'Per';

  @override
  String get dayFri => 'Cum';

  @override
  String get daySat => 'Cmt';

  @override
  String get daySun => 'Paz';

  @override
  String get dayM => 'P';

  @override
  String get dayT => 'S';

  @override
  String get dayW => 'Ç';

  @override
  String get dayTh => 'P';

  @override
  String get dayF => 'C';

  @override
  String get daySa => 'Ct';

  @override
  String get daySu => 'Pz';

  @override
  String get dailyPlan => 'Günlük Plan';

  @override
  String get scheduleAtGlance => 'Programınıza bir bakış';

  @override
  String get addPlan => 'Plan Ekle';

  @override
  String scheduleFor(Object date) {
    return '$date için Program';
  }

  @override
  String get freeDay => 'Boş Gün!';

  @override
  String get freeDayDescription => 'Planlanmış dersiniz veya teslim tarihiniz yok. İzin gününüzün keyfini çıkarın veya plan yapın.';

  @override
  String get deleteEventTitle => 'Etkinlik Silinsin mi?';

  @override
  String deleteEventConfirm(Object title) {
    return '\"$title\" silinsin mi?';
  }

  @override
  String get addPlanEvent => 'Plan Etkinliği Ekle';

  @override
  String get eventTitleHint => 'Etkinlik Başlığı (örn. Ali ile buluşma)';

  @override
  String get eventTitleRequired => 'Lütfen bir başlık girin';

  @override
  String get eventType => 'Etkinlik Türü';

  @override
  String startLabel(Object time) {
    return 'Başlangıç: $time';
  }

  @override
  String endLabel(Object time) {
    return 'Bitiş: $time';
  }

  @override
  String get notesOptional => 'Notlar (İsteğe Bağlı)';

  @override
  String get saveEvent => 'Etkinliği Kaydet';

  @override
  String get colorLabel => 'Renk';

  @override
  String get eventStudy => 'Çalışma';

  @override
  String get eventMeeting => 'Toplantı';

  @override
  String get eventCoffee => 'Kahve Molası';

  @override
  String get eventPersonal => 'Kişisel';

  @override
  String get eventOther => 'Diğer';

  @override
  String get recording => 'Kaydediliyor...';

  @override
  String get stopAndSave => 'Durdur ve Kaydet';

  @override
  String get syncFromMoodle => 'Moodle\'dan Senkronize Et';

  @override
  String get moodleSyncFirst => 'Önce Moodle hesabınızı senkronize edin';

  @override
  String moodleCourseSelected(Object courseName) {
    return '$courseName seçildi — ders detaylarını düzenleyin';
  }

  @override
  String get selectFromMoodle => 'Moodle\'dan Seç';

  @override
  String get cancelMoodle => 'İptal';

  @override
  String addSelected(Object count) {
    return 'Seçileni Ekle ($count)';
  }

  @override
  String get searchCourse => 'Ders ara...';

  @override
  String get courseArchived => 'Ders arşivlendi';

  @override
  String get notificationsDisabled => 'Bildirimler devre dışı';

  @override
  String get notificationsEnabled => 'Bildirimler etkin';

  @override
  String get deadlineAdded => 'Teslim tarihi başarıyla eklendi!';

  @override
  String get fileAdded => 'Dosya başarıyla eklendi';

  @override
  String photoSaved(Object count) {
    return '$count fotoğraf kaydedildi!';
  }

  @override
  String get noteSaved => 'Not kaydedildi!';

  @override
  String get drawingSaved => 'Çizim kaydedildi!';

  @override
  String get gradeDeleted => 'Puan silindi';

  @override
  String get ocrLabel => 'OCR';

  @override
  String get drawingLabel => 'Çizim';

  @override
  String ofNotes(Object count, Object total) {
    return '$count / $total Not';
  }

  @override
  String notesCount(Object count) {
    return '$count Not';
  }

  @override
  String get clearCanvas => 'Tuvali Temizle';

  @override
  String get clearCanvasConfirm => 'Tüm çizimleri temizlemek istediğinize emin misiniz?';

  @override
  String get clearAction => 'Temizle';

  @override
  String get nothingToSave => 'Kaydedilecek bir şey yok. Lütfen önce bir şeyler çizin.';

  @override
  String get blankPaper => 'Boş Kağıt';

  @override
  String get photoAnnotation => 'Fotoğraf Notu';

  @override
  String get pdfAnnotation => 'PDF Notu';

  @override
  String get blankLabel => 'Boş';

  @override
  String get photoLabel => 'Fotoğraf';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get tapPhotoHint => 'Bir resim seçmek için \"Fotoğraf\"a dokunun';

  @override
  String get tapPdfHint => 'Bir belge seçmek için \"PDF\"e dokunun';

  @override
  String get moveToCourse => 'Derse Taşı';

  @override
  String get deleteNote => 'Notu Sil';

  @override
  String get imageUnavailable => 'Resim kullanılamıyor';

  @override
  String get noOtherCourses => 'Başka ders bulunamadı';

  @override
  String get selectDestination => 'Hedef dersi seçin';

  @override
  String movedTo(Object course) {
    return '$course dersine taşındı';
  }

  @override
  String get noDrawingData => 'Çizim verisi yok';

  @override
  String get pdfFileNotFound => 'PDF dosyası bulunamadı';

  @override
  String get studyHistory => 'Çalışma Geçmişi';

  @override
  String get range7D => '7G';

  @override
  String get range14D => '14G';

  @override
  String get range30D => '30G';

  @override
  String get totalStudy => 'Toplam Çalışma';

  @override
  String get sessionsLabel => 'Oturum';

  @override
  String get avgPerDay => 'Günlük Ort';

  @override
  String get dailyStudyTime => 'Günlük Çalışma Süresi';

  @override
  String get noDataYet => 'Henüz veri yok';

  @override
  String get byCourse => 'Derse Göre';

  @override
  String get general => 'Genel';

  @override
  String get recentSessions => 'Son Oturumlar';

  @override
  String get noStudySessions => 'Henüz çalışma oturumu yok.\nBir Pomodoro zamanlayıcısı başlatın!';

  @override
  String get deleteSession => 'Oturumu Sil';

  @override
  String deleteSessionConfirm(Object minutes) {
    return '$minutes dakikalık çalışma oturumu silinsin mi?';
  }

  @override
  String get enabled => 'Etkin';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Pasif';

  @override
  String get start => 'Başlat';

  @override
  String get close => 'Kapat';

  @override
  String get saveQuestions => 'Soruları Kaydet';

  @override
  String questionLabel(Object index) {
    return 'Soru $index';
  }

  @override
  String get yourAnswer => 'Cevabınız';

  @override
  String get allAnswersRequired => 'Tüm cevaplar zorunludur';

  @override
  String get questionsSaved => 'Güvenlik soruları kaydedildi';

  @override
  String get questionsSaveFailed => 'Sorular kaydedilemedi';

  @override
  String get resetQuestions => 'Soruları Sıfırla';

  @override
  String biometricEnabled(Object biometric) {
    return '$biometric başarıyla etkinleştirildi';
  }

  @override
  String biometricDisabled(Object biometric) {
    return '$biometric devre dışı bırakıldı';
  }

  @override
  String biometricAuthReason(Object biometric) {
    return '$biometric etkinleştirmek için doğrulayın';
  }

  @override
  String get e2eEncryption => 'Uçtan Uca Şifreleme';

  @override
  String get e2eDescription => 'Dosyalarınız buluta yüklenmeden önce cihazınızda şifrelenir.';

  @override
  String get encryptionKey => 'Şifreleme Anahtarı';

  @override
  String get keyStorage => 'Anahtar Deposu';

  @override
  String get cloudAccess => 'Bulut Erişimi';

  @override
  String get aes256 => 'AES-256-CBC';

  @override
  String get deviceKeychain => 'Cihaz Anahtarlığı';

  @override
  String get encryptedOnly => 'Yalnızca şifrelenmiş veri';

  @override
  String get evenDevCantAccess => 'Uygulama geliştiricileri bile dosyalarınıza erişemez';

  @override
  String get alreadyEncrypted => 'Tüm dosyalar zaten şifrelenmiş';

  @override
  String get startingMigration => 'Taşıma başlatılıyor...';

  @override
  String get migrationComplete => 'Taşıma tamamlandı!';

  @override
  String get allEncrypted => 'Tüm dosyalar başarıyla şifrelendi!';

  @override
  String get migrationFailed => 'Taşıma başarısız';

  @override
  String migrationFailedDetail(Object error) {
    return 'Taşıma başarısız: $error';
  }

  @override
  String get setUpSecurityQuestions => 'Şifrenizi unutmanız durumunda hesabınızı kurtarmak için 3 güvenlik sorusu belirleyin.';

  @override
  String get questionsAlreadyConfigured => 'Güvenlik soruları zaten yapılandırılmış';

  @override
  String get encryptExistingFiles => 'Mevcut Dosyaları Şifrele';

  @override
  String get backupFilesToCloud => 'Dosyalarınızı buluta yedekleyin';

  @override
  String get securityQuestions => 'Güvenlik Soruları';

  @override
  String get securityQ1 => 'Evcil hayvanınızın adı nedir?';

  @override
  String get securityQ2 => 'İlk öğretmeninizin adı nedir?';

  @override
  String get securityQ3 => 'Hangi şehirde doğdunuz?';

  @override
  String get securityQ4 => 'En sevdiğiniz film nedir?';

  @override
  String get securityQ5 => 'İlk telefon numaranız neydi?';

  @override
  String get securityQ6 => 'Annenizin kızlık soyadı nedir?';

  @override
  String get securityQ7 => 'İlk okulunuzun adı nedir?';

  @override
  String get securityQ8 => 'En sevdiğiniz kitap nedir?';

  @override
  String get recoveryStepEmail => 'E-postayı Doğrula';

  @override
  String get recoveryStepQuestions => 'Güvenlik Soruları';

  @override
  String get recoveryStepPassword => 'Yeni Şifre';

  @override
  String get recoveryEmailDesc => 'Kurtarma işlemini başlatmak için e-postanızı girin';

  @override
  String get recoveryCodeSent => 'E-postanıza bir doğrulama kodu gönderdik';

  @override
  String get recoveryQuestionsDesc => 'Devam etmek için güvenlik sorularınızı cevaplayın';

  @override
  String get recoveryNewPasswordDesc => 'Hesabınız için yeni bir şifre oluşturun';

  @override
  String get emailHint => 'E-posta Adresi';

  @override
  String get emailIsRequired => 'E-posta zorunludur';

  @override
  String get enterValidEmail => 'Geçerli bir e-posta girin';

  @override
  String get sendCode => 'Kod Gönder';

  @override
  String get verificationCode => 'Doğrulama Kodu';

  @override
  String get codeIsRequired => 'Kod zorunludur';

  @override
  String get verifyCode => 'Kodu Doğrula';

  @override
  String get resendCode => 'Kodu Yeniden Gönder';

  @override
  String get yourAnswerLabel => 'Cevabınız';

  @override
  String get required => 'Zorunlu';

  @override
  String get verifyAnswers => 'Cevapları Doğrula';

  @override
  String securityQuestionN(Object number) {
    return 'Güvenlik Sorusu $number';
  }

  @override
  String get passwordLengthError => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get confirmPasswordLabel => 'Şifreyi Onayla';

  @override
  String get passwordsDoNotMatchError => 'Şifreler eşleşmiyor';

  @override
  String get resetPasswordButton => 'Şifre Sıfırla';

  @override
  String get failedToSendReset => 'Sıfırlama e-postası gönderilemedi. Lütfen e-posta adresinizi kontrol edin.';

  @override
  String get checkEmailForLink => 'E-postanızı kontrol edin ve sıfırlama linkine tıklayın';

  @override
  String get passwordResetEmailSent => 'Şifre sıfırlama e-postası gönderildi! Not: E2E şifrelemeniz etkinse...';

  @override
  String get failedToResetPassword => 'Şifre sıfırlanamadı. Lütfen tekrar deneyin.';

  @override
  String get professorDetailsSection => 'Profesör Detayları';

  @override
  String get notificationGeneral => 'Genel';

  @override
  String get turnOffAllNotifications => 'Tüm uygulama bildirimlerini kapat';

  @override
  String get reminderTiming => 'Hatırlatma Zamanı';

  @override
  String get remindBeforeClass => 'Dersten önce hatırlat';

  @override
  String get reminder5min => '5 dakika';

  @override
  String get reminder10min => '10 dakika';

  @override
  String get reminder15min => '15 dakika';

  @override
  String get reminder30min => '30 dakika';

  @override
  String get reminder1hour => '1 saat';

  @override
  String get reminder2hours => '2 saat';

  @override
  String alertAt(Object time) {
    return '$time saatinde uyar';
  }

  @override
  String get courseCustomization => 'Ders Özelleştirme';

  @override
  String get transcriptTitle => 'Transkript';

  @override
  String get courseHeader => 'Ders';

  @override
  String get crHeader => 'KR';

  @override
  String get avgHeader => 'Ort';

  @override
  String get gradeHeader => 'Not';

  @override
  String get gpHeader => 'GP';

  @override
  String get overallGpa => 'Genel GPA';

  @override
  String get totalCreditsLabel => 'Toplam Kredi';

  @override
  String get storageOptimized => 'Derin bellek optimizasyonu tamamlandı! Cihazda yer açıldı.';

  @override
  String get smartStorageManagement => 'Akıllı Depolama Yönetimi';

  @override
  String get storageOptions => 'Cihazınızda yer açma seçenekleri';

  @override
  String get standardCleanup => 'Standart Temizlik';

  @override
  String standardCleanupDesc(Object size) {
    return 'Geçici dosyaları siler. ($size)';
  }

  @override
  String get deepOptimization => 'Derin Optimizasyon';

  @override
  String get deepOptimizationDesc => 'Görsel kalıntılarını ve bellek sızıntılarını temizler, cihazı hızlandırır.';

  @override
  String get optimizeStorage => 'Depolamayı Optimize Et';

  @override
  String get userName => 'Kullanıcı';

  @override
  String get guestUserLabel => 'Misafir Kullanıcı';

  @override
  String get signInToSync => 'Veri senkronizasyonu için giriş yapın';

  @override
  String get guestMode => 'Misafir Modu';

  @override
  String get faceId => 'Face ID / Touch ID';

  @override
  String get faceIdSubtitle => 'Face ID / Touch ID ile kilidi aç';

  @override
  String get notAvailableOnDevice => 'Bu cihazda kullanılamaz';

  @override
  String get cloudBackup => 'Bulut Yedekleme';

  @override
  String get encryptedBackupActive => 'Şifreli yedekleme aktif';

  @override
  String get backupOffDefault => 'Kapalı (varsayılan)';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountKvkk => 'KVKK Madde 7 - Silme Hakkı';

  @override
  String get deletingAccount => 'Hesap siliniyor...';

  @override
  String deleteAccountError(Object error) {
    return 'Hesap silme hatası: $error';
  }

  @override
  String get cookiePolicy => 'Çerez Politikası';

  @override
  String get consentManagement => 'Açık Rıza Yönetimi';

  @override
  String get consentManagementDesc => 'KVKK Açık Rıza Tercihleriniz';

  @override
  String get appVersion => 'Lesson Tracker v1.0.0';

  @override
  String get moodleTabCourses => 'Dersler';

  @override
  String get moodleTabAssignments => 'Ödevler';

  @override
  String get moodleTabGrades => 'Notlar';

  @override
  String get moodleTabAnnouncements => 'Duyurular';

  @override
  String get moodleTabCalendar => 'Takvim';

  @override
  String get moodleTabMessages => 'Mesajlar';

  @override
  String get moodleTitle => 'Moodle';

  @override
  String moodleSummary(Object accounts, Object courses, Object unread) {
    return '$accounts hesap · $courses ders · $unread okunmamış';
  }

  @override
  String get moodleRefreshAll => 'Tümünü Yenile';

  @override
  String get moodleManageAccounts => 'Hesapları Yönet';

  @override
  String get moodleAddAccount => 'Hesap Ekle';

  @override
  String get moodleConnect => 'Moodle\'a Bağlan';

  @override
  String get moodleConnectDesc => 'Üniversitenizin Moodle sistemine bağlanarak derslerinizi, ödevlerinizi ve notlarınızı senkronize edin.';

  @override
  String get moodleFeatureAssignments => 'Ödevler ve Tarihler';

  @override
  String get moodleFeatureGrades => 'Notlar';

  @override
  String get moodleFeatureAnnouncements => 'Duyurular';

  @override
  String get moodleFeatureMultiAccount => 'Çoklu Hesap';

  @override
  String get moodlePasswordNotStored => 'Şifreniz cihazınızda asla saklanmaz';

  @override
  String get moodleConnected => 'Moodle hesabı başarıyla bağlandı!';

  @override
  String get moodleNoCourses => 'Ders bulunamadı';

  @override
  String get moodleSyncing => 'Moodle hesabınız senkronize ediliyor...';

  @override
  String get moodleNoAssignments => 'Bekleyen ödev bulunamadı';

  @override
  String get moodleAllDone => 'Harika! Görünüşe göre her şey tamamlanmış.';

  @override
  String get moodleOverdue => 'Gecikmiş';

  @override
  String get moodleThisWeek => 'Bu Hafta';

  @override
  String get moodleUpcoming => 'Yaklaşan';

  @override
  String get moodleSubmitted => 'Teslim Edildi';

  @override
  String get moodleLate => 'Geç';

  @override
  String get moodleDueToday => 'Bugün teslim!';

  @override
  String moodleDaysLeft(Object days) {
    return '$days gün kaldı';
  }

  @override
  String get moodleNoGrades => 'Not bulunamadı';

  @override
  String get moodleNoAnnouncements => 'Duyuru bulunamadı';

  @override
  String get moodleNoEvents => 'Bu günde etkinlik yok';

  @override
  String get moodleAllDay => 'Tüm gün';

  @override
  String get moodleNoMessages => 'Mesaj bulunamadı';

  @override
  String get moodleMessagesHere => 'Moodle mesajlarınız burada görünecek';

  @override
  String moodleAccountCourses(Object count) {
    return '$count ödev';
  }

  @override
  String get moodleAcademicSummary => 'Akademik Özet';

  @override
  String get moodleAvg => 'Ort.';

  @override
  String get moodleThisWeekTasks => 'Bu haftanın görevleri';

  @override
  String get moodleOverdueTasks => 'Gecikmiş';

  @override
  String get moodleCourseCount => 'Ders sayısı';

  @override
  String get moodleBest => 'En İyi';

  @override
  String get moodleWorst => 'En Kötü';

  @override
  String get moodleSelectUniversity => 'Üniversitenizi Seçin';

  @override
  String get moodleSelectUniversityDesc => 'Moodle hesabınızı bağlamak için üniversitenizi seçin';

  @override
  String get moodleSearchUniversity => 'Üniversite ara...';

  @override
  String get moodleManualUrl => 'Manuel URL Girişi';

  @override
  String get moodleManualUrlDesc => 'Listede olmayan üniversiteler için';

  @override
  String get moodleBack => 'Geri';

  @override
  String get moodleUrl => 'Moodle URL';

  @override
  String get moodleUrlHint => 'örn. moodle.universite.edu.tr';

  @override
  String get moodleUrlRequired => 'URL zorunludur';

  @override
  String get moodleLogin => 'Giriş Yap';

  @override
  String get moodleUsername => 'Kullanıcı Adı';

  @override
  String get moodleUsernameRequired => 'Kullanıcı adı zorunludur';

  @override
  String get moodlePassword => 'Şifre';

  @override
  String get moodlePasswordRequired => 'Şifre zorunludur';

  @override
  String get moodlePasswordHint => 'Şifreniz cihazınızda asla saklanmaz.';

  @override
  String get moodleConnectButton => 'Bağlan';

  @override
  String get moodleConnecting => 'Moodle\'a bağlanıyor...';

  @override
  String get moodleConnectionFailed => 'Bağlantı Başarısız';

  @override
  String get moodleTryAgain => 'Tekrar Dene';

  @override
  String get moodleConnectionSuccess => 'Bağlantı Başarılı!';

  @override
  String get moodleGreat => 'Harika!';

  @override
  String get moodleAccountsManage => 'Hesapları Yönet';

  @override
  String get moodleAccountAdd => 'Moodle Hesabı Ekle';

  @override
  String get moodleNoAccounts => 'Bağlı hesap yok';

  @override
  String get moodleNoAccountsDesc => 'Aşağıdaki butonu kullanarak Moodle hesabınızı ekleyin.';

  @override
  String get moodleLogout => 'Çıkış Yap';

  @override
  String moodleLogoutConfirm(Object account) {
    return '$account hesabından çıkış yapmak istediğinize emin misiniz?';
  }

  @override
  String moodleLogoutDone(Object account) {
    return '$account hesabından çıkış yapıldı';
  }

  @override
  String get moodleContentLoading => 'Ders içeriği yükleniyor...';

  @override
  String moodleContentError(Object error) {
    return 'İçerik yüklenemedi: $error';
  }

  @override
  String get moodleContentNotFound => 'İçerik bulunamadı';

  @override
  String get moodleDownloadFailed => 'İndirme başarısız veya dosya çok büyük.';

  @override
  String get moodleTransferToCourse => 'Derslerime Aktar';

  @override
  String get moodleTransferDesc => 'Bu dosyayı uygulamadaki derslerinizden birine kaydedin.';

  @override
  String get moodleSelectCourse => 'Ders Seç';

  @override
  String get moodleNoLocalCourses => 'Henüz ders eklemediniz.';

  @override
  String moodleSavedToCourse(Object course) {
    return 'Dosya \"$course\" dersine başarıyla kaydedildi!';
  }

  @override
  String get moodleSaveError => 'Dosya kaydedilirken bir hata oluştu.';

  @override
  String get moodleTokenNotFound => 'Token bulunamadı — hesabınızı yeniden bağlayın';

  @override
  String get moodleAccountNotFound => 'Hesap bulunamadı';

  @override
  String get veliConsentTitle => 'Veli Rızası';

  @override
  String get veliConsentDesc => '18 yaş altı kullanıcıların uygulamayı kullanması için veli rızası gereklidir.';

  @override
  String get veliEmailLabel => 'Veli E-posta Adresi';

  @override
  String get veliEmailHint => 'Velinin e-posta adresini girin';

  @override
  String get veliConfirmCheck => 'Veli olduğumu ve çocuğumun bu uygulamayı kullanmasına izin verdiğimi onaylıyorum.';

  @override
  String get veliKvkkCheck => '6698 sayılı KVKK kapsamında veli rızası veriyorum.';

  @override
  String veliCodeSent(Object email) {
    return '$email adresine doğrulama kodu gönderildi.';
  }

  @override
  String get veliEnterCode => '6 haneli doğrulama kodunu girin';

  @override
  String get veliVerifyAndApprove => 'Doğrula ve Onayla';

  @override
  String get veliResendCode => 'Kodu Yeniden Gönder';

  @override
  String get veliChangeEmail => 'E-posta Değiştir';

  @override
  String get veliSendCode => 'Doğrulama Kodu Gönder';

  @override
  String get veliCancel => 'İptal';

  @override
  String get veliRequired => 'Veli rızası zorunludur';

  @override
  String get veliValidEmail => 'Geçerli bir e-posta adresi girin';

  @override
  String get veliCheckConsent => 'Lütfen veli rızası kutusunu işaretleyin';

  @override
  String get veliCodeRequired => 'Doğrulama kodunu girin';

  @override
  String get veliSessionNotFound => 'Doğrulama oturumu bulunamadı. Lütfen tekrar deneyin.';

  @override
  String get veliCodeExpired => 'Doğrulama kodunun süresi doldu. Lütfen yeni bir kod isteyin.';

  @override
  String get veliWrongCode => 'Yanlış doğrulama kodu.';

  @override
  String get veliInfoText => 'Veli e-posta adresi yalnızca rıza bildirimi göndermek için kullanılacaktır.';

  @override
  String get veliRequestConsent => 'Rıza İste';

  @override
  String get veliEmailVerification => 'E-posta Doğrulama';

  @override
  String get veliStepVerification => 'Doğrulama';

  @override
  String get veliStepConsent => 'Rıza';

  @override
  String get kvkkFlowReset => 'KVKK rızası sıfırlandı — uygulamayı yeniden başlatın';

  @override
  String get kvkkReset => 'Sıfırla';

  @override
  String get kvkkSkip => 'Atla';

  @override
  String get consentManagementTitle => 'Açık Rıza Yönetimi';

  @override
  String get consentManagementSubtitle => 'Açık Rıza Tercihleriniz';

  @override
  String get consentWithdrawInfo => 'Rızanızı istediğiniz zaman geri çekebilirsiniz. Geri çekme, rızanın geri çekilmesinden önceki rızaya dayalı işlemenin hukuka uygunluğunu etkilemez.';

  @override
  String get consentCamera => 'Kamera Fotoğraf Çekimi';

  @override
  String get consentAudio => 'Ses Kaydı';

  @override
  String get consentOcr => 'OCR Metin Tanıma';

  @override
  String get consentPush => 'Push Bildirimleri';

  @override
  String get consentCloud => 'Bulut Yedekleme (İsteğe Bağlı)';

  @override
  String get consentLegalInfo => 'Yasal Bilgi';

  @override
  String get consentLegalDesc => '6698 sayılı KVKK kapsamında açık rıza tercihlerinizi buradan yönetebilirsiniz.';

  @override
  String get consentCameraDesc => 'Fotoğraf çekin ve belgeleri tarayın';

  @override
  String get consentAudioDesc => 'Derslerde sesli not alın';

  @override
  String get consentOcrDesc => 'Görsellerden ve PDF\'lerden metin çıkarın';

  @override
  String get consentPushDesc => 'Teslim tarihi ve ders bildirimleri alın';

  @override
  String get consentCloudDesc => 'Verilerinizi güvenli bir şekilde buluta yedekleyin';

  @override
  String get moodleSyncEnabled => 'Moodle arka plan senkronizasyonu etkinleştirildi!';

  @override
  String get moodleSyncDisabled => 'Moodle arka plan senkronizasyonu devre dışı!';

  @override
  String get moodleBackgroundSync => 'Moodle Arka Plan Senkronizasyonu';

  @override
  String get moodleSyncNotifications => 'Yeni ödevler, notlar ve duyurular bildirilecektir';

  @override
  String get moodleSyncOff => 'Kapalı — manuel yenileme gerekli';

  @override
  String get smartAttendanceSetLocationFirst => 'Akıllı devamsızlığı etkinleştirmek için önce okul konumunuzu ayarlayın.';

  @override
  String get smartAttendanceEnabled => 'Akıllı devamsızlık etkinleştirildi! Arka planda çalışacak.';

  @override
  String get smartAttendanceDisabled => 'Akıllı devamsızlık devre dışı.';

  @override
  String get smartAttendanceSchoolLocation => 'Okul Konumu';

  @override
  String get smartAttendanceLocationSet => 'Konum Ayarlanmış';

  @override
  String get smartAttendanceLocationNotSet => 'Henüz ayarlanmadı';

  @override
  String get smartAttendanceCurrentLocation => 'Mevcut okul konumunuz kaydedildi.';

  @override
  String get smartAttendanceSetLocationPrompt => 'Mevcut konumunuzu \"Üniversite Konumu\" olarak kaydetmek istiyor musunuz?';

  @override
  String get smartAttendanceCancel => 'İptal';

  @override
  String get smartAttendanceGettingLocation => 'Konum alınıyor...';

  @override
  String get smartAttendanceSaved => 'Okul konumu kaydedildi!';

  @override
  String get smartAttendanceLocationError => 'Konum alınamadı. Konum izinlerini kontrol edin.';

  @override
  String get smartAttendanceUpdate => 'Güncelle';

  @override
  String get smartAttendanceYesImAtSchool => 'Evet, Okuldayım';

  @override
  String get smartAttendanceTitle => 'Akıllı Devamsızlık';

  @override
  String get smartAttendanceActive => 'Aktif — Ders sırasında okuldaysanız devamsızlık sayılmaz';

  @override
  String get smartAttendanceOff => 'Devre Dışı';

  @override
  String get deleteAccountTitle => 'Hesabınız Silinmek Üzere';

  @override
  String get deleteAccountIrreversible => 'Bu işlem geri alınamaz';

  @override
  String get deleteAccountDataToDelete => 'Silinecek veriler:';

  @override
  String get deleteAccountNotes => 'Tüm ders notları';

  @override
  String get deleteAccountAudio => 'Ses kayıtları';

  @override
  String get deleteAccountPhotos => 'Fotoğraflar ve OCR verileri';

  @override
  String get deleteAccountAttendance => 'Devamsızlık ve not kayıtları';

  @override
  String get deleteAccountSessions => 'Çalışma oturumları';

  @override
  String get deleteAccountMoodle => 'Moodle hesap bağlantıları';

  @override
  String get deleteAccountFirebase => 'Firebase hesabı';

  @override
  String get deleteAccountRetention => 'Verileriniz 30 gün içinde kalıcı olarak silinecektir.';

  @override
  String get deleteAccountConfirm => 'Hesabımı silmek istediğimi onaylıyorum.';

  @override
  String get deleteAccountCancel => 'İptal';

  @override
  String get deleteAccountAction => 'Hesabımı Sil';

  @override
  String get aydinlatmaTitle => 'Aydınlatma Metni';

  @override
  String get aydinlatmaSubtitle => '6698 sayılı KVKK Madde 10 kapsamında bilgilendirme';

  @override
  String get aydinlatmaSection1 => '1. Veri Sorumlusu';

  @override
  String get aydinlatmaControllerInfo => 'LessonTracker\nE-posta: lessontracker@example.com';

  @override
  String get aydinlatmaSection2 => '2. İşlenen Kişisel Veriler';

  @override
  String get aydinlatmaSection3 => '3. Veri İşleme Amaçları';

  @override
  String get aydinlatmaSection4 => '4. Kişisel Verilerin Aktarılması';

  @override
  String get aydinlatmaSection5 => '5. Saklama Süresi';

  @override
  String get aydinlatmaSection6 => '6. Veri Güvenliği';

  @override
  String get aydinlatmaSection7 => '7. Haklarınız (KVKK Madde 11)';

  @override
  String get aydinlatmaSection8 => '8. Daha Fazla Bilgi';

  @override
  String get aydinlatmaConfirm => 'Aydınlatma metnini okudum ve bilgilendirildim.';

  @override
  String get aydinlatmaContinue => 'Anladım, Devam Et';

  @override
  String get acikRizaTitle => 'Açık Rıza';

  @override
  String get acikRizaSubtitle => 'Aşağıdaki işlemler için açık rızanız yasal olarak zorunludur (KVKK Madde 5/1 ve 6/2)';

  @override
  String get acikRizaImportant => 'Önemli Bilgi';

  @override
  String get acikRizaVoluntary => 'Açık rıza vermek tamamen gönüllüdür. Rıza vermeyi atlayabilir ve uygulamayı sınırlı modda kullanabilirsiniz. Tercihlerinizi daha sonra Ayarlar\'dan değiştirebilirsiniz.';

  @override
  String get acikRizaGiveAndContinue => 'Rıza Ver ve Devam Et';

  @override
  String get acikRizaSkip => 'Rızasız Devam Et';

  @override
  String get acikRizaWarning => 'Önemli Uyarı';

  @override
  String get acikRizaFeaturesDisabled => 'Rızasız devam ederseniz aşağıdaki özellikler kullanılamayacaktır:';

  @override
  String get acikRizaFeatureCamera => 'Kamera fotoğraf çekimi';

  @override
  String get acikRizaFeatureAudio => 'Ses kaydı';

  @override
  String get acikRizaFeatureOcr => 'OCR metin tanıma';

  @override
  String get acikRizaSettingsNote => 'Bu tercihleri daha sonra Ayarlar\'dan değiştirebilirsiniz.';

  @override
  String get acikRizaCancel => 'İptal';

  @override
  String get acikRizaLimitedMode => 'Sınırlı Modda Devam Et';
}
