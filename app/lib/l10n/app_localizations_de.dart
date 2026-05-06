// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lektions-Tracker';

  @override
  String get homeParams => 'Startseite';

  @override
  String get planParams => 'Plan';

  @override
  String get statsParams => 'Statistiken';

  @override
  String get settingsParams => 'Einstellungen';

  @override
  String get priorityFocus => 'Prioritätsfokus';

  @override
  String get viewAll => 'Alle Ansehen';

  @override
  String get quickCapture => 'Schnellerfassung';

  @override
  String get recentNotes => 'Aktuelle Notizen';

  @override
  String get noNotesYet => 'Noch keine Notizen. Fang an zu erfassen!';

  @override
  String get noNotesDescription => 'Nutze die Tools unten, um deine erste Notiz zu erfassen!';

  @override
  String get goodMorning => 'Guten Morgen,';

  @override
  String get goodAfternoon => 'Guten Tag,';

  @override
  String get goodEvening => 'Guten Abend,';

  @override
  String get weeklySchedule => 'Wochenplan';

  @override
  String get todaysClasses => 'Heutige Kurse';

  @override
  String get noClassesScheduled => 'Keine Kurse geplant';

  @override
  String get addCourseToSeeSchedule => 'Füge einen Kurs hinzu, um deinen Plan zu sehen';

  @override
  String get statistics => 'Statistiken';

  @override
  String get trackYourProgress => 'Verfolge deinen Lernfortschritt';

  @override
  String get addNewCourse => 'Neuen Kurs Hinzufügen';

  @override
  String get courseName => 'Kursname';

  @override
  String get courseNameHint => 'z.B. Mathematik';

  @override
  String get classSchedule => 'Stundenplan';

  @override
  String get addTimeSlot => 'Zeitfenster Hinzufügen';

  @override
  String get classroomLocation => 'Klassenzimmer / Ort';

  @override
  String get classroomHint => 'z.B. Wissenschaftssaal 304';

  @override
  String get professorOptional => 'Professor (Optional)';

  @override
  String get professorHint => 'z.B. Dr. Schmidt';

  @override
  String get absenceLimit => 'Abwesenheitslimit';

  @override
  String get maxAllowedPerSemester => 'Max. erlaubt pro Semester';

  @override
  String get cardColor => 'Kartenfarbe';

  @override
  String get createCourse => 'Kurs Erstellen';

  @override
  String get pleaseEnterCourseName => 'Bitte gib einen Kursnamen ein';

  @override
  String get pleaseAddClassTime => 'Bitte füge mindestens eine Unterrichtszeit hinzu';

  @override
  String get failedToCreateSchedule => 'Fehler beim Erstellen einiger Zeitplanelemente';

  @override
  String get courseProgress => 'Kursfortschritt';

  @override
  String get lessonMaterials => 'Unterrichtsmaterialien';

  @override
  String get newNote => 'Neue Notiz';

  @override
  String get title => 'Titel';

  @override
  String get writeYourNote => 'Schreibe deine Notiz...';

  @override
  String get saveNote => 'Notiz Speichern';

  @override
  String get deleteCourse => 'Kurs Löschen';

  @override
  String get deleteCourseConfirmation => 'Dadurch werden alle mit diesem Kurs verknüpften Notizen gelöscht.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerie';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get keyboard => 'Tastatur';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Thema';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get lightMode => 'Hellmodus';

  @override
  String get systemMode => 'System';

  @override
  String get noClassTimesAdded => 'Noch keine Unterrichtszeiten hinzugefügt.';

  @override
  String get voiceMemo => 'Sprachnotiz';

  @override
  String get notesHeader => 'Notizen';

  @override
  String get deleteNoteTitle => 'Notiz löschen?';

  @override
  String get thisActionCannotBeUndone => 'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get totalCourses => 'Gesamtkurse';

  @override
  String get totalNotes => 'Gesamtnotizen';

  @override
  String get avgProgress => 'Durchschn. Fortschritt';

  @override
  String get studyStreak => 'Lernsträhne';

  @override
  String get activeCourses => 'Aktive Kurse';

  @override
  String get notesCaptured => 'Erfasste Notizen';

  @override
  String get overallProgress => 'Gesamtfortschritt';

  @override
  String get daysInRow => 'Tage in Folge';

  @override
  String get weeklyGoal => 'Wochenziel';

  @override
  String get syncBackup => 'Sync & Backup';

  @override
  String get storage => 'Speicher';

  @override
  String get helpSupport => 'Hilfe & Support';

  @override
  String get signOut => 'Abmelden';

  @override
  String get settingsHeader => 'Einstellungen';

  @override
  String get settingsSubHeader => 'Passe dein Erlebnis an';

  @override
  String get profileName => 'Alex Student';

  @override
  String get profileEmail => 'alex@universitaet.de';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get weeklyGoalSub => '5/7 Tage';

  @override
  String get courseAbsence => 'Abwesenheit';

  @override
  String get remainingAbsences => 'verbleibend';

  @override
  String get addAbsence => 'Abwesenheit hinzufügen';

  @override
  String get removeAbsence => 'Abwesenheit entfernen';

  @override
  String absenceLimitExceeded(Object excess) {
    return 'Limit überschritten! ($excess mehr)';
  }

  @override
  String get noAbsenceRightsLeft => 'Keine Rechte übrig!';

  @override
  String absenceRightsLeft(Object count) {
    return '$count Rechte übrig';
  }

  @override
  String get absenceLabel => 'Abwesenheit';

  @override
  String get remainingLabel => 'Übrig';

  @override
  String get viewHistory => 'Verlauf anzeigen';

  @override
  String get gpa => 'Notendurchschnitt';

  @override
  String get academicStanding => 'Akademischer Stand';

  @override
  String get atRisk => 'Anwesenheitsrisiko';

  @override
  String get coursePerformance => 'Kursleistung';

  @override
  String get recentGrades => 'Aktuelle Noten';

  @override
  String get noGradesData => 'Noch keine Notendaten.';

  @override
  String get excellent => 'Ausgezeichnet';

  @override
  String get good => 'Gut';

  @override
  String get average => 'Durchschnitt';

  @override
  String get improvementNeeded => 'Verbesserungswürdig';

  @override
  String get gradesTab => 'Noten';

  @override
  String get filesTab => 'Dateien';

  @override
  String get notesTab => 'Notizen';

  @override
  String get addGrade => 'Note Hinzufügen';

  @override
  String get noGradesYet => 'Noch keine Noten hinzugefügt.';

  @override
  String get noFilesYet => 'Noch keine Dateien';

  @override
  String get uploadFile => 'Datei Hochladen';

  @override
  String get addFile => 'Datei Hinzufügen';

  @override
  String nextExamIn(int days) {
    return 'Nächste Prüfung in $days Tagen';
  }

  @override
  String get semesterDefault => 'Frühlingssemester';

  @override
  String get noProfessor => 'Kein Professor';

  @override
  String get weight => 'Gewichtung';

  @override
  String get averageShort => 'Durchschn.';

  @override
  String get searchHint => 'Notizen, Tags (#prüfung) durchsuchen...';

  @override
  String get noResults => 'Keine passenden Notizen gefunden';

  @override
  String get searchStartPrompt => 'Suche nach Titel, Inhalt oder Tags';

  @override
  String get deadlinesHeader => 'Fristen';

  @override
  String get deadlinesSubtitle => 'Behalte deine Aufgaben im Blick';

  @override
  String get noUpcomingDeadlines => 'Keine anstehenden Fristen';

  @override
  String get addFirstDeadline => 'Füge deine erste Frist hinzu';

  @override
  String get deadlineOverdue => 'Überfällig';

  @override
  String get deadlineToday => 'Heute';

  @override
  String daysLeft(int days) {
    return 'Noch $days Tage';
  }

  @override
  String get addDeadlineTitle => 'Frist Hinzufügen';

  @override
  String get editDeadline => 'Frist Bearbeiten';

  @override
  String get updateDeadline => 'Frist Aktualisieren';

  @override
  String get fillAllFields => 'Bitte fülle alle Pflichtfelder aus';

  @override
  String get titleHint => 'Titel (z.B. Klausur, Projekt)';

  @override
  String get selectCourse => 'Kurs Auswählen';

  @override
  String get noCoursesAvailable => 'Keine Kurse verfügbar. Füge zuerst einen Kurs hinzu.';

  @override
  String get addToCalendar => 'Zum Kalender Hinzufügen';

  @override
  String get saveToDeviceCalendar => 'Im Gerätekalender speichern';

  @override
  String get assignmentNameHint => 'Aufgabenname (z.B. Klausur)';

  @override
  String get score => 'Punktzahl';

  @override
  String get max => 'Max';

  @override
  String get weightPercent => 'Gewichtung (%)';

  @override
  String get saveGrade => 'Note Speichern';

  @override
  String get addNoteToImage => 'Notiz zum Bild Hinzufügen';

  @override
  String get titleOptional => 'Titel (Optional)';

  @override
  String get imageContentHint => 'Schreibe etwas zu diesem Bild...';

  @override
  String get tagsHint => 'Tags (z.B. #prüfung, #geschichte)';

  @override
  String get absenceHistory => 'Abwesenheitsverlauf';

  @override
  String get noAbsenceHistory => 'Noch kein Abwesenheitsverlauf.';

  @override
  String get welcomeToClass => 'Willkommen im Unterricht! 🎓';

  @override
  String get youAreInArea => 'Du bist am Unterrichtsort.';

  @override
  String get syncDescription => 'Sichere deine Daten in der Cloud oder stelle sie auf diesem Gerät wieder her.';

  @override
  String get processing => 'Verarbeitung...';

  @override
  String get backupData => 'Daten Sichern';

  @override
  String get backupDescription => 'Lokale Daten in die Cloud hochladen';

  @override
  String get restoreData => 'Daten Wiederherstellen';

  @override
  String get restoreDescription => 'Aus der Cloud herunterladen (Ersetzt lokale Daten)';

  @override
  String get confirmRestore => 'Wiederherstellung Bestätigen';

  @override
  String get restoreWarning => 'Dies überschreibt einige lokale Daten mit Cloud-Daten. Fortfahren?';

  @override
  String get restoreAction => 'Wiederherstellen';

  @override
  String get save => 'Speichern';

  @override
  String get attendanceStatus => 'Anwesenheitsstatus';

  @override
  String get perfectAttendance => 'Perfekte Anwesenheit! Weiter so!';

  @override
  String absences(int current, int limit) {
    return '$current / $limit Abwesenheiten';
  }

  @override
  String get riskLabel => 'RISIKO';

  @override
  String get todaySchedule => 'Heutiger Stundenplan';

  @override
  String get noClassesToday => 'Heute keine Kurse — genieße deine freie Zeit! 🎉';

  @override
  String get guestUser => 'Gast';

  @override
  String get searchPlaceholder => 'Fächer, Notizen oder Tags finden...';

  @override
  String get noCourses => 'Noch keine Kurse';

  @override
  String get addYourFirstCourse => 'Tippe auf +, um deinen ersten Kurs hinzuzufügen!';

  @override
  String get editProfile => 'Profil Bearbeiten';

  @override
  String get name => 'Name';

  @override
  String get email => 'E-Mail';

  @override
  String get changePassword => 'Passwort Ändern';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmPassword => 'Passwort Bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordTooShort => 'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get emailVerificationSent => 'Bestätigungsmail an die neue Adresse gesendet';

  @override
  String get passwordChanged => 'Passwort erfolgreich geändert';

  @override
  String get faqTitle => 'Häufig Gestellte Fragen';

  @override
  String get faqQ1 => 'Wie füge ich einen neuen Kurs hinzu?';

  @override
  String get faqA1 => 'Tippe auf die +-Taste auf der Startseite und gib die Kursdetails ein, einschließlich Name, Zeitplan und Professorinformationen.';

  @override
  String get faqQ2 => 'Wie verfolge ich meine Abwesenheiten?';

  @override
  String get faqA2 => 'Öffne einen Kurs und nutze den Abwesenheitszähler, um Abwesenheiten hinzuzufügen oder zu entfernen. Du wirst gewarnt, wenn du das Limit erreichst.';

  @override
  String get faqQ3 => 'Kann ich meine Daten sichern?';

  @override
  String get faqA3 => 'Ja! Gehe zu Einstellungen > Sync & Backup, um deine Daten in die Cloud hochzuladen. Du musst dafür angemeldet sein.';

  @override
  String get faqQ4 => 'Wie nehme ich eine Sprachnotiz auf?';

  @override
  String get faqA4 => 'Öffne einen Kurs, tippe auf die +-Taste und wähle das Mikrofon-Symbol, um eine Sprachnotiz aufzunehmen.';

  @override
  String get faqQ5 => 'Wie ändere ich die App-Sprache?';

  @override
  String get faqA5 => 'Gehe zu Einstellungen und tippe auf Sprache. Du kannst zwischen Englisch, Türkisch, Spanisch und Deutsch wählen.';

  @override
  String get contactUs => 'Kontakt';

  @override
  String get emailSupport => 'E-Mail-Support';

  @override
  String get reportBug => 'Fehler Melden';

  @override
  String get reportBugDescription => 'Etwas Fehlerhaftes gefunden? Lass es uns wissen';

  @override
  String get featureRequest => 'Funktionswunsch';

  @override
  String get featureRequestDescription => 'Schlage eine neue Funktion vor';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get aboutDescription => 'Lektions-Tracker hilft Studierenden, ihre Kurse zu organisieren, Anwesenheit zu verfolgen, Notizen zu erfassen und Fristen im Blick zu behalten. Mit Sorgfalt für Studierende überall entwickelt.';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get totalStorageUsed => 'Genutzter Gesamtspeicher';

  @override
  String get storageBreakdown => 'Speicheraufschlüsselung';

  @override
  String get database => 'Datenbank';

  @override
  String get mediaFiles => 'Mediendateien';

  @override
  String get cache => 'Cache';

  @override
  String get dataStats => 'Datenstatistiken';

  @override
  String get clearCache => 'Cache Leeren';

  @override
  String get clearCacheConfirmation => 'Dadurch werden temporäre Dateien entfernt. Deine Daten bleiben unberührt. Fortfahren?';

  @override
  String get cacheCleared => 'Cache erfolgreich geleert!';

  @override
  String get signOutConfirmation => 'Bist du sicher, dass du dich abmelden möchtest?';

  @override
  String get lastBackup => 'Letztes Backup';

  @override
  String get never => 'Nie';

  @override
  String get loginRequiredForSync => 'Melde dich an, um Sync- & Backup-Funktionen zu nutzen';

  @override
  String get autoSync => 'Automatische Synchronisierung';

  @override
  String get tapToEdit => 'Tippe, um das Profil zu bearbeiten';

  @override
  String get studyTimer => 'Lern-Timer';

  @override
  String get focusTime => 'Fokuszeit';

  @override
  String get breakTime => 'Pausenzeit';

  @override
  String get session => 'Sitzung';

  @override
  String get sessionComplete => 'Gut gemacht! Sitzung abgeschlossen 🎉';

  @override
  String get breakComplete => 'Pause vorbei! Bereit zum Lernen?';

  @override
  String get studyingFor => 'Lernen für';

  @override
  String get noCourseSelected => 'Kein Kurs ausgewählt';

  @override
  String get timerPresets => 'Zeitvorgaben';

  @override
  String get short => 'Kurz';

  @override
  String get classic => 'Klassisch';

  @override
  String get long => 'Lang';

  @override
  String get marathon => 'Marathon';

  @override
  String get completedSessions => 'Abgeschlossene Sitzungen';

  @override
  String get gpaCalculator => 'Notendurchschnittrechner';

  @override
  String get overallGPA => 'Gesamtnotendurchschnitt';

  @override
  String get totalCredits => 'Leistungspunkte';

  @override
  String get gpaCourses => 'Kurse';

  @override
  String get letterGrade => 'Note';

  @override
  String get gpaScale => 'Notenskala';

  @override
  String get courseBreakdown => 'Kursaufschlüsselung';

  @override
  String get credits => 'Leistungspunkte';

  @override
  String get gpaNoGrades => 'Noch keine Noten';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get studyTimerDesc => 'Pomodoro-Timer';

  @override
  String get gpaCalcDesc => 'Notendurchschnittrechner';

  @override
  String get absenceCalendar => 'Abwesenheitskalender';

  @override
  String get viewAbsenceCalendar => 'Abwesenheitskalender anzeigen';

  @override
  String get noAbsencesOnDay => 'Keine Abwesenheiten an diesem Tag';

  @override
  String get unexcused => 'Unentschuldigt';

  @override
  String get medical => 'Medizinisch';

  @override
  String get excused => 'Entschuldigt';

  @override
  String get personal => 'Persönlich';

  @override
  String absencePredictionWarning(String weeks) {
    return 'Bei diesem Tempo überschreitest du das Limit in $weeks Wochen';
  }

  @override
  String get professorDetails => 'Professordetails';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get officeRoom => 'Büroraum';

  @override
  String get officeHoursLabel => 'Sprechstunden';

  @override
  String get teachingAssistant => 'Lehrassistent';

  @override
  String get emailCopied => 'E-Mail kopiert';

  @override
  String get phoneCopied => 'Telefon kopiert';

  @override
  String get addLink => 'Link hinzufügen';

  @override
  String get linkName => 'Linkname';

  @override
  String get linkAdded => 'Link hinzugefügt';

  @override
  String get webLink => 'Weblink';

  @override
  String get templateCornellNotes => 'Cornell-Notizen';

  @override
  String get templateLectureSummary => 'Vorlesungszusammenfassung';

  @override
  String get templateExamNotes => 'Prüfungsnotizen';

  @override
  String get startFromTemplate => 'Von Vorlage starten';

  @override
  String get transcript => 'Transkript';

  @override
  String get inProgress => 'In Bearbeitung';

  @override
  String get semesterReport => 'Semesterbericht';

  @override
  String get generatePdfReport => 'PDF-Bericht erstellen';

  @override
  String get exportDataCsv => 'Daten exportieren (CSV)';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get gradesCsv => 'Noten (CSV)';

  @override
  String get absencesCsv => 'Abwesenheiten (CSV)';

  @override
  String get studySessionsCsv => 'Lernsitzungen (CSV)';

  @override
  String get selectAbsenceReason => 'Abwesenheitsgrund auswählen';

  @override
  String get editCourse => 'Kurs bearbeiten';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get setLocationGeofence => 'Standort festlegen (Geofence)';

  @override
  String get absenceUnexcused => 'Unentschuldigt';

  @override
  String get absenceMedical => 'Ärztliches Attest';

  @override
  String get absenceExcused => 'Entschuldigt';

  @override
  String get absencePersonal => 'Persönlich';

  @override
  String get absenceOverview => 'Anwesenheitsübersicht';

  @override
  String get absencesUsed => 'Abwesenheiten genutzt';

  @override
  String get totalAbsences => 'Abwesenheiten gesamt';

  @override
  String get editAbsence => 'Abwesenheit bearbeiten';

  @override
  String get deleteAbsence => 'Abwesenheit löschen';

  @override
  String get selectReason => 'Grund auswählen:';

  @override
  String get convertToPdf => 'In PDF umwandeln';

  @override
  String get allNotesToPdf => 'Alle Notizen → PDF';

  @override
  String get photosToPdf => 'Fotos → PDF';

  @override
  String get courseReportPdf => 'Kursbericht → PDF';

  @override
  String get appLock => 'App-Sperre';

  @override
  String get appLockDisabled => 'Deaktiviert';

  @override
  String get appLockAuthReason => 'Authentifizieren, um die App-Sperre zu aktivieren';

  @override
  String get shareNotes => 'Notizen anzeigen';

  @override
  String get archiveCourse => 'Kurs archivieren';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String get loginSubtitle => 'Melde dich an, um deine Lernreise fortzusetzen.';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String get emailRequired => 'Bitte gib deine E-Mail-Adresse ein';

  @override
  String get validEmailRequired => 'Bitte gib eine gültige E-Mail-Adresse ein';

  @override
  String get passwordRequired => 'Bitte gib dein Passwort ein';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get logIn => 'Anmelden';

  @override
  String get orDivider => 'ODER';

  @override
  String get dontHaveAccount => 'Noch kein Konto?';

  @override
  String get signUp => 'Registrieren';

  @override
  String get continueAsGuest => 'Als Gast fortfahren';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get resetPasswordDescription => 'Gib deine E-Mail-Adresse ein und wir senden dir einen Link zum Zurücksetzen deines Passworts.';

  @override
  String get sendLink => 'Link senden';

  @override
  String get passwordResetSent => 'E-Mail zum Zurücksetzen des Passworts gesendet! Prüfe dein Postfach.';

  @override
  String get guestDescription => 'Deine Daten werden nur lokal auf diesem Gerät gespeichert und nicht mit der Cloud synchronisiert. Du kannst später ein Konto erstellen, um deine Daten zu sichern.';

  @override
  String get continueAction => 'Fortfahren';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get signupSubtitle => 'Begleite uns, um deinen akademischen Erfolg zu verfolgen.';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get nameRequired => 'Bitte gib deinen Namen ein';

  @override
  String get nameMinLength => 'Der Name muss mindestens 2 Zeichen lang sein';

  @override
  String get confirmPasswordRequired => 'Bitte bestätige dein Passwort';

  @override
  String get haveAccount => 'Bereits ein Konto?';

  @override
  String get verifyYourEmail => 'E-Mail bestätigen';

  @override
  String get verificationEmailSent => 'Bestätigungs-E-Mail gesendet! Prüfe dein Postfach.';

  @override
  String get checkInbox => 'Bitte prüfe dein Postfach und klicke auf den Bestätigungslink, um dein Konto zu aktivieren.';

  @override
  String get resendVerification => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get iVerifiedMyEmail => 'Ich habe meine E-Mail bestätigt → Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get nextLabel => 'Weiter';

  @override
  String get savedDataFound => 'Gespeicherte Daten gefunden';

  @override
  String savedDataDescription(Object courseCount) {
    return 'Dieses Konto hat $courseCount gespeicherte Kurse.';
  }

  @override
  String get loadDataDescription => 'Beim Laden deiner Daten werden deine Kurse, Notizen und Fristen auf dieses Gerät übertragen.';

  @override
  String get cloudDataCleared => 'Alte Cloud-Daten gelöscht. Es wird neu begonnen.';

  @override
  String get startFresh => 'Neu beginnen';

  @override
  String get loadData => 'Daten laden';

  @override
  String get youAreOffline => 'Du bist offline';

  @override
  String get processingOcr => 'OCR wird verarbeitet...';

  @override
  String get ocrNoteSaved => 'OCR-Notiz gespeichert!';

  @override
  String get noCoursesAddFirst => 'Keine Kurse verfügbar. Füge zuerst einen Kurs hinzu!';

  @override
  String get selectCourseTitle => 'Kurs auswählen';

  @override
  String get chooseSaveLocation => 'Wähle, wo diese Notiz gespeichert werden soll';

  @override
  String get weeklyTimetable => 'Wochenstundenplan';

  @override
  String get dayMon => 'Mo';

  @override
  String get dayTue => 'Di';

  @override
  String get dayWed => 'Mi';

  @override
  String get dayThu => 'Do';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Sa';

  @override
  String get daySun => 'So';

  @override
  String get dayM => 'M';

  @override
  String get dayT => 'D';

  @override
  String get dayW => 'M';

  @override
  String get dayTh => 'Do';

  @override
  String get dayF => 'F';

  @override
  String get daySa => 'Sa';

  @override
  String get daySu => 'So';

  @override
  String get dailyPlan => 'Tagesplan';

  @override
  String get scheduleAtGlance => 'Dein Stundenplan auf einen Blick';

  @override
  String get addPlan => 'Plan hinzufügen';

  @override
  String scheduleFor(Object date) {
    return 'Stundenplan für $date';
  }

  @override
  String get freeDay => 'Ein freier Tag!';

  @override
  String get freeDayDescription => 'Du hast keine Kurse oder Fristen. Genieße deine freie Zeit oder plane voraus.';

  @override
  String get deleteEventTitle => 'Ereignis löschen?';

  @override
  String deleteEventConfirm(Object title) {
    return 'Möchtest du \"$title\" löschen?';
  }

  @override
  String get addPlanEvent => 'Plan-Ereignis hinzufügen';

  @override
  String get eventTitleHint => 'Ereignistitel (z.B. Treffen mit Ali)';

  @override
  String get eventTitleRequired => 'Bitte gib einen Titel ein';

  @override
  String get eventType => 'Ereignistyp';

  @override
  String startLabel(Object time) {
    return 'Start: $time';
  }

  @override
  String endLabel(Object time) {
    return 'Ende: $time';
  }

  @override
  String get notesOptional => 'Notizen (Optional)';

  @override
  String get saveEvent => 'Ereignis speichern';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get eventStudy => 'Lernen';

  @override
  String get eventMeeting => 'Besprechung';

  @override
  String get eventCoffee => 'Kaffeepause';

  @override
  String get eventPersonal => 'Persönlich';

  @override
  String get eventOther => 'Sonstiges';

  @override
  String get recording => 'Aufnahme...';

  @override
  String get stopAndSave => 'Stoppen & Speichern';

  @override
  String get syncFromMoodle => 'Von Moodle synchronisieren';

  @override
  String get moodleSyncFirst => 'Moodle-Konto zuerst synchronisieren';

  @override
  String moodleCourseSelected(Object courseName) {
    return '$courseName ausgewählt — Kursdetails bearbeiten';
  }

  @override
  String get selectFromMoodle => 'Von Moodle auswählen';

  @override
  String get cancelMoodle => 'Abbrechen';

  @override
  String addSelected(Object count) {
    return 'Hinzufügen ($count)';
  }

  @override
  String get searchCourse => 'Kurs suchen...';

  @override
  String get courseArchived => 'Kurs archiviert';

  @override
  String get notificationsDisabled => 'Benachrichtigungen deaktiviert';

  @override
  String get notificationsEnabled => 'Benachrichtigungen aktiviert';

  @override
  String get deadlineAdded => 'Frist erfolgreich hinzugefügt!';

  @override
  String get fileAdded => 'Datei erfolgreich hinzugefügt';

  @override
  String photoSaved(Object count) {
    return '$count Fotos gespeichert!';
  }

  @override
  String get noteSaved => 'Notiz gespeichert!';

  @override
  String get drawingSaved => 'Zeichnung gespeichert!';

  @override
  String get gradeDeleted => 'Note gelöscht';

  @override
  String get ocrLabel => 'OCR';

  @override
  String get drawingLabel => 'Zeichnung';

  @override
  String ofNotes(Object count, Object total) {
    return '$count von $total Notizen';
  }

  @override
  String notesCount(Object count) {
    return '$count Notizen';
  }

  @override
  String get clearCanvas => 'Leinwand leeren';

  @override
  String get clearCanvasConfirm => 'Bist du sicher, dass du alle Zeichnungen löschen möchtest?';

  @override
  String get clearAction => 'Leeren';

  @override
  String get nothingToSave => 'Nichts zu speichern. Bitte zeichne zuerst etwas.';

  @override
  String get blankPaper => 'Leeres Blatt';

  @override
  String get photoAnnotation => 'Foto-Anmerkung';

  @override
  String get pdfAnnotation => 'PDF-Anmerkung';

  @override
  String get blankLabel => 'Leer';

  @override
  String get photoLabel => 'Foto';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get tapPhotoHint => 'Tippe auf \"Foto\", um ein Bild auszuwählen';

  @override
  String get tapPdfHint => 'Tippe auf \"PDF\", um ein Dokument auszuwählen';

  @override
  String get moveToCourse => 'In Kurs verschieben';

  @override
  String get deleteNote => 'Notiz löschen';

  @override
  String get imageUnavailable => 'Bild nicht verfügbar';

  @override
  String get noOtherCourses => 'Keine anderen Kurse verfügbar';

  @override
  String get selectDestination => 'Zielkurs auswählen';

  @override
  String movedTo(Object course) {
    return 'Verschoben nach $course';
  }

  @override
  String get noDrawingData => 'Keine Zeichnungsdaten';

  @override
  String get pdfFileNotFound => 'PDF-Datei nicht gefunden';

  @override
  String get studyHistory => 'Lernverlauf';

  @override
  String get range7D => '7T';

  @override
  String get range14D => '14T';

  @override
  String get range30D => '30T';

  @override
  String get totalStudy => 'Gesamtlernzeit';

  @override
  String get sessionsLabel => 'Sitzungen';

  @override
  String get avgPerDay => 'Schnitt/Tag';

  @override
  String get dailyStudyTime => 'Tägliche Lernzeit';

  @override
  String get noDataYet => 'Noch keine Daten';

  @override
  String get byCourse => 'Nach Kurs';

  @override
  String get general => 'Allgemein';

  @override
  String get recentSessions => 'Letzte Sitzungen';

  @override
  String get noStudySessions => 'Noch keine Lernsitzungen.\nStarte einen Pomodoro-Timer!';

  @override
  String get deleteSession => 'Sitzung löschen';

  @override
  String deleteSessionConfirm(Object minutes) {
    return 'Diese ${minutes}m Lernsitzung löschen?';
  }

  @override
  String get enabled => 'Aktiviert';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get start => 'Starten';

  @override
  String get close => 'Schließen';

  @override
  String get saveQuestions => 'Fragen speichern';

  @override
  String questionLabel(Object index) {
    return 'Frage $index';
  }

  @override
  String get yourAnswer => 'Deine Antwort';

  @override
  String get allAnswersRequired => 'Alle Antworten sind erforderlich';

  @override
  String get questionsSaved => 'Sicherheitsfragen gespeichert';

  @override
  String get questionsSaveFailed => 'Speichern der Fragen fehlgeschlagen';

  @override
  String get resetQuestions => 'Fragen zurücksetzen';

  @override
  String biometricEnabled(Object biometric) {
    return '$biometric erfolgreich aktiviert';
  }

  @override
  String biometricDisabled(Object biometric) {
    return '$biometric deaktiviert';
  }

  @override
  String biometricAuthReason(Object biometric) {
    return 'Authentifiziere dich, um $biometric zu aktivieren';
  }

  @override
  String get e2eEncryption => 'Ende-zu-Ende-Verschlüsselung';

  @override
  String get e2eDescription => 'Deine Dateien werden auf deinem Gerät verschlüsselt, bevor sie in die Cloud hochgeladen werden.';

  @override
  String get encryptionKey => 'Verschlüsselungsschlüssel';

  @override
  String get keyStorage => 'Schlüsselspeicher';

  @override
  String get cloudAccess => 'Cloud-Zugriff';

  @override
  String get aes256 => 'AES-256-CBC';

  @override
  String get deviceKeychain => 'Geräte-Schlüsselbund';

  @override
  String get encryptedOnly => 'Nur verschlüsselte Daten';

  @override
  String get evenDevCantAccess => 'Selbst App-Entwickler können nicht auf deine Dateien zugreifen';

  @override
  String get alreadyEncrypted => 'Alle Dateien sind bereits verschlüsselt';

  @override
  String get startingMigration => 'Migration wird gestartet...';

  @override
  String get migrationComplete => 'Migration abgeschlossen!';

  @override
  String get allEncrypted => 'Alle Dateien erfolgreich verschlüsselt!';

  @override
  String get migrationFailed => 'Migration fehlgeschlagen';

  @override
  String migrationFailedDetail(Object error) {
    return 'Migration fehlgeschlagen: $error';
  }

  @override
  String get setUpSecurityQuestions => 'Richte 3 Sicherheitsfragen ein, um dein Konto wiederherzustellen, falls du dein Passwort vergisst.';

  @override
  String get questionsAlreadyConfigured => 'Sicherheitsfragen sind bereits konfiguriert';

  @override
  String get encryptExistingFiles => 'Vorhandene Dateien verschlüsseln';

  @override
  String get backupFilesToCloud => 'Deine Dateien in der Cloud sichern';

  @override
  String get securityQuestions => 'Sicherheitsfragen';

  @override
  String get securityQ1 => 'Wie heißt dein Haustier?';

  @override
  String get securityQ2 => 'Wie hieß dein erster Lehrer?';

  @override
  String get securityQ3 => 'In welcher Stadt wurdest du geboren?';

  @override
  String get securityQ4 => 'Was ist dein Lieblingsfilm?';

  @override
  String get securityQ5 => 'Was war deine erste Telefonnummer?';

  @override
  String get securityQ6 => 'Wie lautet der Mädchenname deiner Mutter?';

  @override
  String get securityQ7 => 'Wie hieß deine erste Schule?';

  @override
  String get securityQ8 => 'Was ist dein Lieblingsbuch?';

  @override
  String get recoveryStepEmail => 'E-Mail bestätigen';

  @override
  String get recoveryStepQuestions => 'Sicherheitsfragen';

  @override
  String get recoveryStepPassword => 'Neues Passwort';

  @override
  String get recoveryEmailDesc => 'Gib deine E-Mail ein, um den Wiederherstellungsprozess zu starten';

  @override
  String get recoveryCodeSent => 'Wir haben einen Bestätigungscode an deine E-Mail gesendet';

  @override
  String get recoveryQuestionsDesc => 'Beantworte deine Sicherheitsfragen, um fortzufahren';

  @override
  String get recoveryNewPasswordDesc => 'Erstelle ein neues Passwort für dein Konto';

  @override
  String get emailHint => 'E-Mail-Adresse';

  @override
  String get emailIsRequired => 'E-Mail ist erforderlich';

  @override
  String get enterValidEmail => 'Gib eine gültige E-Mail ein';

  @override
  String get sendCode => 'Code senden';

  @override
  String get verificationCode => 'Bestätigungscode';

  @override
  String get codeIsRequired => 'Code ist erforderlich';

  @override
  String get verifyCode => 'Code bestätigen';

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String get yourAnswerLabel => 'Deine Antwort';

  @override
  String get required => 'Erforderlich';

  @override
  String get verifyAnswers => 'Antworten bestätigen';

  @override
  String securityQuestionN(Object number) {
    return 'Sicherheitsfrage $number';
  }

  @override
  String get passwordLengthError => 'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get passwordsDoNotMatchError => 'Passwörter stimmen nicht überein';

  @override
  String get resetPasswordButton => 'Passwort zurücksetzen';

  @override
  String get failedToSendReset => 'Senden der E-Mail zum Zurücksetzen fehlgeschlagen. Bitte überprüfe deine E-Mail-Adresse.';

  @override
  String get checkEmailForLink => 'Prüfe dein Postfach und klicke auf den Link';

  @override
  String get passwordResetEmailSent => 'E-Mail zum Passwortzurücksetzen gesendet! Hinweis: Wenn E2E-Verschlüsselung aktiviert ist...';

  @override
  String get failedToResetPassword => 'Passwort zurücksetzen fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get professorDetailsSection => 'Professordetails';

  @override
  String get notificationGeneral => 'Allgemein';

  @override
  String get turnOffAllNotifications => 'Alle App-Benachrichtigungen deaktivieren';

  @override
  String get reminderTiming => 'Erinnerungszeitpunkt';

  @override
  String get remindBeforeClass => 'Vor dem Unterricht erinnern';

  @override
  String get reminder5min => '5 Minuten';

  @override
  String get reminder10min => '10 Minuten';

  @override
  String get reminder15min => '15 Minuten';

  @override
  String get reminder30min => '30 Minuten';

  @override
  String get reminder1hour => '1 Stunde';

  @override
  String get reminder2hours => '2 Stunden';

  @override
  String alertAt(Object time) {
    return 'Erinnern um $time';
  }

  @override
  String get courseCustomization => 'Kursanpassung';

  @override
  String get transcriptTitle => 'Transkript';

  @override
  String get courseHeader => 'Kurs';

  @override
  String get crHeader => 'LP';

  @override
  String get avgHeader => 'Schnitt';

  @override
  String get gradeHeader => 'Note';

  @override
  String get gpHeader => 'NP';

  @override
  String get overallGpa => 'Gesamtnotendurchschnitt';

  @override
  String get totalCreditsLabel => 'Leistungspunkte gesamt';

  @override
  String get storageOptimized => 'Tiefe Speicheroptimierung abgeschlossen! Gerät wurde freigegeben.';

  @override
  String get smartStorageManagement => 'Intelligente Speicherverwaltung';

  @override
  String get storageOptions => 'Optionen zum Freigeben von Speicherplatz auf deinem Gerät';

  @override
  String get standardCleanup => 'Standardbereinigung';

  @override
  String standardCleanupDesc(Object size) {
    return 'Löscht temporäre Dateien. ($size)';
  }

  @override
  String get deepOptimization => 'Tiefenoptimierung';

  @override
  String get deepOptimizationDesc => 'Entfernt Bildreste und Speicherlecks, beschleunigt das Gerät.';

  @override
  String get optimizeStorage => 'Speicher optimieren';

  @override
  String get userName => 'Benutzer';

  @override
  String get guestUserLabel => 'Gastbenutzer';

  @override
  String get signInToSync => 'Anmelden, um Daten zu synchronisieren';

  @override
  String get guestMode => 'Gastmodus';

  @override
  String get faceId => 'Face ID / Touch ID';

  @override
  String get faceIdSubtitle => 'Face ID / Touch ID zum Entsperren verwenden';

  @override
  String get notAvailableOnDevice => 'Auf diesem Gerät nicht verfügbar';

  @override
  String get cloudBackup => 'Cloud-Backup';

  @override
  String get encryptedBackupActive => 'Verschlüsseltes Backup aktiv';

  @override
  String get backupOffDefault => 'Aus (Standard)';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountKvkk => 'KVKK Artikel 7 – Recht auf Löschung';

  @override
  String get deletingAccount => 'Konto wird gelöscht...';

  @override
  String deleteAccountError(Object error) {
    return 'Fehler beim Löschen des Kontos: $error';
  }

  @override
  String get cookiePolicy => 'Cookie-Richtlinie';

  @override
  String get consentManagement => 'Einwilligungsverwaltung';

  @override
  String get consentManagementDesc => 'Deine KVKK-Einwilligungspräferenzen';

  @override
  String get appVersion => 'Lesson Tracker v1.0.0';

  @override
  String get moodleTabCourses => 'Kurse';

  @override
  String get moodleTabAssignments => 'Aufgaben';

  @override
  String get moodleTabGrades => 'Noten';

  @override
  String get moodleTabAnnouncements => 'Ankündigungen';

  @override
  String get moodleTabCalendar => 'Kalender';

  @override
  String get moodleTabMessages => 'Nachrichten';

  @override
  String get moodleTitle => 'Moodle';

  @override
  String moodleSummary(Object accounts, Object courses, Object unread) {
    return '$accounts Konto · $courses Kurse · $unread ungelesen';
  }

  @override
  String get moodleRefreshAll => 'Alle aktualisieren';

  @override
  String get moodleManageAccounts => 'Konten verwalten';

  @override
  String get moodleAddAccount => 'Konto hinzufügen';

  @override
  String get moodleConnect => 'Moodle verbinden';

  @override
  String get moodleConnectDesc => 'Verbinde dich mit dem Moodle-System deiner Universität, um Kurse, Aufgaben und Noten zu synchronisieren.';

  @override
  String get moodleFeatureAssignments => 'Aufgaben & Termine';

  @override
  String get moodleFeatureGrades => 'Noten';

  @override
  String get moodleFeatureAnnouncements => 'Ankündigungen';

  @override
  String get moodleFeatureMultiAccount => 'Mehrere Konten';

  @override
  String get moodlePasswordNotStored => 'Dein Passwort wird niemals auf deinem Gerät gespeichert';

  @override
  String get moodleConnected => 'Moodle-Konto erfolgreich verbunden!';

  @override
  String get moodleNoCourses => 'Keine Kurse gefunden';

  @override
  String get moodleSyncing => 'Moodle-Konto wird synchronisiert...';

  @override
  String get moodleNoAssignments => 'Keine ausstehenden Aufgaben gefunden';

  @override
  String get moodleAllDone => 'Super! Sieht aus, als wäre alles erledigt.';

  @override
  String get moodleOverdue => 'Überfällig';

  @override
  String get moodleThisWeek => 'Diese Woche';

  @override
  String get moodleUpcoming => 'Bevorstehend';

  @override
  String get moodleSubmitted => 'Eingereicht';

  @override
  String get moodleLate => 'Verspätet';

  @override
  String get moodleDueToday => 'Heute fällig!';

  @override
  String moodleDaysLeft(Object days) {
    return 'Noch $days Tage';
  }

  @override
  String get moodleNoGrades => 'Keine Noten gefunden';

  @override
  String get moodleNoAnnouncements => 'Keine Ankündigungen gefunden';

  @override
  String get moodleNoEvents => 'Keine Ereignisse an diesem Tag';

  @override
  String get moodleAllDay => 'Ganztägig';

  @override
  String get moodleNoMessages => 'Keine Nachrichten gefunden';

  @override
  String get moodleMessagesHere => 'Deine Moodle-Nachrichten werden hier angezeigt';

  @override
  String moodleAccountCourses(Object count) {
    return '$count Aufgaben';
  }

  @override
  String get moodleAcademicSummary => 'Akademische Zusammenfassung';

  @override
  String get moodleAvg => 'Schnitt';

  @override
  String get moodleThisWeekTasks => 'Aufgaben diese Woche';

  @override
  String get moodleOverdueTasks => 'Überfällig';

  @override
  String get moodleCourseCount => 'Kursanzahl';

  @override
  String get moodleBest => 'Beste';

  @override
  String get moodleWorst => 'Schlechteste';

  @override
  String get moodleSelectUniversity => 'Universität auswählen';

  @override
  String get moodleSelectUniversityDesc => 'Wähle deine Universität aus, um dein Moodle-Konto zu verbinden';

  @override
  String get moodleSearchUniversity => 'Universität suchen...';

  @override
  String get moodleManualUrl => 'Manuelle URL-Eingabe';

  @override
  String get moodleManualUrlDesc => 'Für Universitäten, die nicht in der Liste sind';

  @override
  String get moodleBack => 'Zurück';

  @override
  String get moodleUrl => 'Moodle-URL';

  @override
  String get moodleUrlHint => 'z.B. moodle.universitaet.de';

  @override
  String get moodleUrlRequired => 'URL ist erforderlich';

  @override
  String get moodleLogin => 'Anmelden';

  @override
  String get moodleUsername => 'Benutzername';

  @override
  String get moodleUsernameRequired => 'Benutzername ist erforderlich';

  @override
  String get moodlePassword => 'Passwort';

  @override
  String get moodlePasswordRequired => 'Passwort ist erforderlich';

  @override
  String get moodlePasswordHint => 'Dein Passwort wird niemals auf deinem Gerät gespeichert.';

  @override
  String get moodleConnectButton => 'Verbinden';

  @override
  String get moodleConnecting => 'Verbindung zu Moodle wird hergestellt...';

  @override
  String get moodleConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get moodleTryAgain => 'Erneut versuchen';

  @override
  String get moodleConnectionSuccess => 'Verbindung erfolgreich!';

  @override
  String get moodleGreat => 'Super!';

  @override
  String get moodleAccountsManage => 'Konten verwalten';

  @override
  String get moodleAccountAdd => 'Moodle-Konto hinzufügen';

  @override
  String get moodleNoAccounts => 'Keine verbundenen Konten';

  @override
  String get moodleNoAccountsDesc => 'Füge dein Moodle-Konto mit dem untenstehenden Button hinzu.';

  @override
  String get moodleLogout => 'Abmelden';

  @override
  String moodleLogoutConfirm(Object account) {
    return 'Bist du sicher, dass du dich von $account abmelden möchtest?';
  }

  @override
  String moodleLogoutDone(Object account) {
    return 'Von $account abgemeldet';
  }

  @override
  String get moodleContentLoading => 'Kursinhalt wird geladen...';

  @override
  String moodleContentError(Object error) {
    return 'Inhalt konnte nicht geladen werden: $error';
  }

  @override
  String get moodleContentNotFound => 'Inhalt nicht gefunden';

  @override
  String get moodleDownloadFailed => 'Download fehlgeschlagen oder Datei zu groß.';

  @override
  String get moodleTransferToCourse => 'In meine Kurse übertragen';

  @override
  String get moodleTransferDesc => 'Speichere diese Datei in einem deiner Kurse in der App.';

  @override
  String get moodleSelectCourse => 'Kurs auswählen';

  @override
  String get moodleNoLocalCourses => 'Du hast noch keine Kurse hinzugefügt.';

  @override
  String moodleSavedToCourse(Object course) {
    return 'Datei erfolgreich in \"$course\" gespeichert!';
  }

  @override
  String get moodleSaveError => 'Beim Speichern der Datei ist ein Fehler aufgetreten.';

  @override
  String get moodleTokenNotFound => 'Token nicht gefunden — Konto neu verbinden';

  @override
  String get moodleAccountNotFound => 'Konto nicht gefunden';

  @override
  String get veliConsentTitle => 'Eltern';

  @override
  String get veliConsentDesc => 'Benutzer unter 18 Jahren benötigen die elterliche Einwilligung zur Nutzung der App.';

  @override
  String get veliEmailLabel => 'E-Mail der Eltern';

  @override
  String get veliEmailHint => 'E-Mail-Adresse der Eltern eingeben';

  @override
  String get veliConfirmCheck => 'Ich bestätige, dass ich Elternteil bin und meinem Kind die Nutzung dieser App erlaube.';

  @override
  String get veliKvkkCheck => 'Ich gebe die elterliche Einwilligung gemäß KVKK Gesetz Nr. 6698.';

  @override
  String veliCodeSent(Object email) {
    return 'Bestätigungscode an $email gesendet.';
  }

  @override
  String get veliEnterCode => 'Gib den 6-stelligen Bestätigungscode ein';

  @override
  String get veliVerifyAndApprove => 'Bestätigen & Genehmigen';

  @override
  String get veliResendCode => 'Code erneut senden';

  @override
  String get veliChangeEmail => 'E-Mail ändern';

  @override
  String get veliSendCode => 'Bestätigungscode senden';

  @override
  String get veliCancel => 'Abbrechen';

  @override
  String get veliRequired => 'Elterliche Einwilligung ist erforderlich';

  @override
  String get veliValidEmail => 'Gib eine gültige E-Mail-Adresse ein';

  @override
  String get veliCheckConsent => 'Bitte aktiviere das Kästchen für die elterliche Einwilligung';

  @override
  String get veliCodeRequired => 'Gib den Bestätigungscode ein';

  @override
  String get veliSessionNotFound => 'Bestätigungssitzung nicht gefunden. Bitte versuche es erneut.';

  @override
  String get veliCodeExpired => 'Bestätigungscode abgelaufen. Bitte fordere einen neuen an.';

  @override
  String get veliWrongCode => 'Falscher Bestätigungscode.';

  @override
  String get veliInfoText => 'Die E-Mail der Eltern wird nur zum Senden der Einwilligungsbenachrichtigung verwendet.';

  @override
  String get veliRequestConsent => 'Einwilligung anfordern';

  @override
  String get veliEmailVerification => 'E-Mail-Bestätigung';

  @override
  String get veliStepVerification => 'Bestätigung';

  @override
  String get veliStepConsent => 'Einwilligung';

  @override
  String get kvkkFlowReset => 'KVKK-Einwilligung zurückgesetzt – App neu starten';

  @override
  String get kvkkReset => 'Zurücksetzen';

  @override
  String get kvkkSkip => 'Überspringen';

  @override
  String get consentManagementTitle => 'Einwilligungsverwaltung';

  @override
  String get consentManagementSubtitle => 'Deine expliziten Einwilligungspräferenzen';

  @override
  String get consentWithdrawInfo => 'Du kannst deine Einwilligung jederzeit widerrufen. Der Widerruf berührt nicht die Rechtmäßigkeit der aufgrund der Einwilligung bis zum Widerruf erfolgten Verarbeitung.';

  @override
  String get consentCamera => 'Kamera-Fotoaufnahme';

  @override
  String get consentAudio => 'Audioaufnahme';

  @override
  String get consentOcr => 'OCR-Texterkennung';

  @override
  String get consentPush => 'Push-Benachrichtigungen';

  @override
  String get consentCloud => 'Cloud-Backup (Optional)';

  @override
  String get consentLegalInfo => 'Rechtliche Informationen';

  @override
  String get consentLegalDesc => 'Gemäß KVKK Gesetz Nr. 6698 kannst du hier deine expliziten Einwilligungspräferenzen verwalten.';

  @override
  String get consentCameraDesc => 'Fotos aufnehmen und Dokumente scannen';

  @override
  String get consentAudioDesc => 'Sprachnotizen im Unterricht aufnehmen';

  @override
  String get consentOcrDesc => 'Text aus Bildern und PDFs extrahieren';

  @override
  String get consentPushDesc => 'Benachrichtigungen zu Fristen und Kursen erhalten';

  @override
  String get consentCloudDesc => 'Deine Daten sicher in der Cloud sichern';

  @override
  String get moodleSyncEnabled => 'Moodle-Hintergrundsync aktiviert!';

  @override
  String get moodleSyncDisabled => 'Moodle-Hintergrundsync deaktiviert!';

  @override
  String get moodleBackgroundSync => 'Moodle-Hintergrundsync';

  @override
  String get moodleSyncNotifications => 'Neue Aufgaben, Noten und Ankündigungen werden benachrichtigt';

  @override
  String get moodleSyncOff => 'Aus — manuelle Aktualisierung erforderlich';

  @override
  String get smartAttendanceSetLocationFirst => 'Lege zuerst deinen Schulstandort fest, um die intelligente Anwesenheit zu aktivieren.';

  @override
  String get smartAttendanceEnabled => 'Intelligente Anwesenheit aktiviert! Funktioniert im Hintergrund.';

  @override
  String get smartAttendanceDisabled => 'Intelligente Anwesenheit deaktiviert.';

  @override
  String get smartAttendanceSchoolLocation => 'Schulstandort';

  @override
  String get smartAttendanceLocationSet => 'Standort festgelegt';

  @override
  String get smartAttendanceLocationNotSet => 'Noch nicht festgelegt';

  @override
  String get smartAttendanceCurrentLocation => 'Dein aktueller Schulstandort wurde gespeichert.';

  @override
  String get smartAttendanceSetLocationPrompt => 'Möchtest du deinen aktuellen Standort als \"Universitätsstandort\" speichern?';

  @override
  String get smartAttendanceCancel => 'Abbrechen';

  @override
  String get smartAttendanceGettingLocation => 'Standort wird ermittelt...';

  @override
  String get smartAttendanceSaved => 'Schulstandort gespeichert!';

  @override
  String get smartAttendanceLocationError => 'Standort konnte nicht ermittelt werden. Überprüfe die Standortberechtigungen.';

  @override
  String get smartAttendanceUpdate => 'Aktualisieren';

  @override
  String get smartAttendanceYesImAtSchool => 'Ja, ich bin an der Schule';

  @override
  String get smartAttendanceTitle => 'Intelligente Anwesenheit';

  @override
  String get smartAttendanceActive => 'Aktiv — Abwesenheit wird nicht gezählt, wenn du während des Unterrichts in der Schule bist';

  @override
  String get smartAttendanceOff => 'Deaktiviert';

  @override
  String get deleteAccountTitle => 'Dein Konto wird gelöscht';

  @override
  String get deleteAccountIrreversible => 'Diese Aktion kann nicht rückgängig gemacht werden';

  @override
  String get deleteAccountDataToDelete => 'Zu löschende Daten:';

  @override
  String get deleteAccountNotes => 'Alle Kursnotizen';

  @override
  String get deleteAccountAudio => 'Audioaufnahmen';

  @override
  String get deleteAccountPhotos => 'Fotos und OCR-Daten';

  @override
  String get deleteAccountAttendance => 'Anwesenheits- und Notenaufzeichnungen';

  @override
  String get deleteAccountSessions => 'Lernsitzungen';

  @override
  String get deleteAccountMoodle => 'Moodle-Kontoverbindungen';

  @override
  String get deleteAccountFirebase => 'Firebase-Konto';

  @override
  String get deleteAccountRetention => 'Deine Daten werden innerhalb von 30 Tagen endgültig gelöscht.';

  @override
  String get deleteAccountConfirm => 'Ich bestätige, dass ich mein Konto löschen möchte.';

  @override
  String get deleteAccountCancel => 'Abbrechen';

  @override
  String get deleteAccountAction => 'Mein Konto löschen';

  @override
  String get aydinlatmaTitle => 'Aufklärungstext';

  @override
  String get aydinlatmaSubtitle => 'Informationen gemäß KVKK Gesetz Nr. 6698 Artikel 10';

  @override
  String get aydinlatmaSection1 => '1. Datenverantwortlicher';

  @override
  String get aydinlatmaControllerInfo => 'LessonTracker\nE-Mail: lessontracker@example.com';

  @override
  String get aydinlatmaSection2 => '2. Verarbeitete personenbezogene Daten';

  @override
  String get aydinlatmaSection3 => '3. Zwecke der Datenverarbeitung';

  @override
  String get aydinlatmaSection4 => '4. Übermittlung personenbezogener Daten';

  @override
  String get aydinlatmaSection5 => '5. Aufbewahrungsfrist';

  @override
  String get aydinlatmaSection6 => '6. Datensicherheit';

  @override
  String get aydinlatmaSection7 => '7. Deine Rechte (KVKK Artikel 11)';

  @override
  String get aydinlatmaSection8 => '8. Weitere Informationen';

  @override
  String get aydinlatmaConfirm => 'Ich habe den Aufklärungstext gelesen und wurde informiert.';

  @override
  String get aydinlatmaContinue => 'Ich verstehe, fortfahren';

  @override
  String get acikRizaTitle => 'Ausdrückliche Einwilligung';

  @override
  String get acikRizaSubtitle => 'Deine ausdrückliche Einwilligung ist für die folgenden Aktionen gesetzlich erforderlich (KVKK Artikel 5/1 und 6/2)';

  @override
  String get acikRizaImportant => 'Wichtige Informationen';

  @override
  String get acikRizaVoluntary => 'Die ausdrückliche Einwilligung ist vollkommen freiwillig. Du kannst die Einwilligung überspringen und die App im eingeschränkten Modus nutzen. Du kannst deine Einstellungen später in den Einstellungen ändern.';

  @override
  String get acikRizaGiveAndContinue => 'Einwilligen & Fortfahren';

  @override
  String get acikRizaSkip => 'Ohne Einwilligung fortfahren';

  @override
  String get acikRizaWarning => 'Wichtiger Hinweis';

  @override
  String get acikRizaFeaturesDisabled => 'Wenn du ohne Einwilligung fortfährst, stehen die folgenden Funktionen nicht zur Verfügung:';

  @override
  String get acikRizaFeatureCamera => 'Kamera-Fotoaufnahme';

  @override
  String get acikRizaFeatureAudio => 'Audioaufnahme';

  @override
  String get acikRizaFeatureOcr => 'OCR-Texterkennung';

  @override
  String get acikRizaSettingsNote => 'Du kannst diese Einstellungen später in den Einstellungen ändern.';

  @override
  String get acikRizaCancel => 'Abbrechen';

  @override
  String get acikRizaLimitedMode => 'Im eingeschränkten Modus fortfahren';
}
