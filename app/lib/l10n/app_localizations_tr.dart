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
  String get totalCourses => 'Ders';

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
  String get average => 'Ort';

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
  String get noGradesYet => 'Henüz not yok';

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
  String get letterGrade => 'Harf Notu';

  @override
  String get gpaScale => 'GPA Skalası';

  @override
  String get courseBreakdown => 'Ders Bazlı Detay';

  @override
  String get credits => 'kredi';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get studyTimerDesc => 'Pomodoro Zamanlayıcı';

  @override
  String get gpaCalcDesc => 'GPA Hesaplayıcı';
}
