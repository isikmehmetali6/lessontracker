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
  String get totalCourses => 'Kurse';

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
  String get average => 'Durchschn.';

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
  String get noGradesYet => 'Noch keine Noten';

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
  String get letterGrade => 'Note';

  @override
  String get gpaScale => 'Notenskala';

  @override
  String get courseBreakdown => 'Kursaufschlüsselung';

  @override
  String get credits => 'Leistungspunkte';

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
}
