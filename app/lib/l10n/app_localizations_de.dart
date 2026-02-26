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
  String get gradesTab => 'Grades';

  @override
  String get filesTab => 'Files';

  @override
  String get notesTab => 'Notes';

  @override
  String get addGrade => 'Add Grade';

  @override
  String get noGradesYet => 'No grades yet';

  @override
  String get noFilesYet => 'No files yet';

  @override
  String get uploadFile => 'Upload File';

  @override
  String get addFile => 'Add File';

  @override
  String nextExamIn(int days) {
    return 'Next exam in $days days';
  }

  @override
  String get semesterDefault => 'Spring Semester';

  @override
  String get noProfessor => 'No Professor';

  @override
  String get weight => 'Weight';

  @override
  String get averageShort => 'Avg';

  @override
  String get searchHint => 'Search notes, tags (#exam)...';

  @override
  String get noResults => 'No matching notes found';

  @override
  String get searchStartPrompt => 'Search by title, content or tags';

  @override
  String get deadlinesHeader => 'Deadlines';

  @override
  String get deadlinesSubtitle => 'Stay on top of your tasks';

  @override
  String get noUpcomingDeadlines => 'No upcoming deadlines';

  @override
  String get addFirstDeadline => 'Add your first deadline';

  @override
  String get deadlineOverdue => 'Overdue';

  @override
  String get deadlineToday => 'Today';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get addDeadlineTitle => 'Add Deadline';

  @override
  String get fillAllFields => 'Please fill all required fields';

  @override
  String get titleHint => 'Title (e.g. Midterm, Project)';

  @override
  String get selectCourse => 'Select Course';

  @override
  String get noCoursesAvailable => 'No courses available. Add a course first.';

  @override
  String get addToCalendar => 'Add to Calendar';

  @override
  String get saveToDeviceCalendar => 'Save to device calendar';

  @override
  String get assignmentNameHint => 'Assignment Name (e.g. Midterm)';

  @override
  String get score => 'Score';

  @override
  String get max => 'Max';

  @override
  String get weightPercent => 'Weight (%)';

  @override
  String get saveGrade => 'Save Grade';

  @override
  String get addNoteToImage => 'Add Note to Image';

  @override
  String get titleOptional => 'Title (Optional)';

  @override
  String get imageContentHint => 'Write something about this image...';

  @override
  String get tagsHint => 'Tags (e.g. #exam, #history)';

  @override
  String get absenceHistory => 'Absence History';

  @override
  String get noAbsenceHistory => 'No absence history yet.';

  @override
  String get welcomeToClass => 'Welcome to class! 🎓';

  @override
  String get youAreInArea => 'You are at the class location.';

  @override
  String get syncDescription => 'Backup your data to the cloud or restore it to this device.';

  @override
  String get processing => 'Processing...';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupDescription => 'Upload local data to cloud';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreDescription => 'Download from cloud (Replaces Local)';

  @override
  String get confirmRestore => 'Confirm Restore';

  @override
  String get restoreWarning => 'This will overwrite some local data with cloud data. Continue?';

  @override
  String get restoreAction => 'Restore';

  @override
  String get save => 'Save';

  @override
  String get attendanceStatus => 'Attendance Status';

  @override
  String get perfectAttendance => 'Perfect attendance! Keep it up!';

  @override
  String absences(int current, int limit) {
    return '$current / $limit Absences';
  }

  @override
  String get riskLabel => 'RISK';

  @override
  String get todaySchedule => 'Today\'s Schedule';

  @override
  String get noClassesToday => 'No classes today — enjoy your free time! 🎉';

  @override
  String get guestUser => 'Guest';

  @override
  String get searchPlaceholder => 'Find subjects, notes, or tags...';

  @override
  String get noCourses => 'No courses yet';

  @override
  String get addYourFirstCourse => 'Tap + to add your first course and start tracking!';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get emailVerificationSent => 'Verification email sent to new address';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faqQ1 => 'How do I add a new course?';

  @override
  String get faqA1 => 'Tap the + button on the home screen and fill in the course details including name, schedule, and professor info.';

  @override
  String get faqQ2 => 'How do I track my absences?';

  @override
  String get faqA2 => 'Open any course and use the absence counter to add or remove absences. You\'ll get warned when you approach work limit.';

  @override
  String get faqQ3 => 'Can I backup my data?';

  @override
  String get faqA3 => 'Yes! Go to Settings > Sync & Backup to upload your data to the cloud. You need to be signed in to use this feature.';

  @override
  String get faqQ4 => 'How do I record a voice note?';

  @override
  String get faqA4 => 'Open a course, tap the + button, and select the microphone icon to start recording a voice memo.';

  @override
  String get faqQ5 => 'How do I change the app language?';

  @override
  String get faqA5 => 'Go to Settings and tap on Language. You can choose between English, Turkish, Spanish, and German.';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get reportBugDescription => 'Found something broken? Let us know';

  @override
  String get featureRequest => 'Feature Request';

  @override
  String get featureRequestDescription => 'Suggest a new feature';

  @override
  String get aboutApp => 'About';

  @override
  String get aboutDescription => 'Lesson Tracker helps students organize their courses, track attendance, capture notes, and stay on top of deadlines. Built with care for students everywhere.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get totalStorageUsed => 'Total Storage Used';

  @override
  String get storageBreakdown => 'Storage Breakdown';

  @override
  String get database => 'Database';

  @override
  String get mediaFiles => 'Media Files';

  @override
  String get cache => 'Cache';

  @override
  String get dataStats => 'Data Statistics';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheConfirmation => 'This will remove temporary files. Your data will not be affected. Continue?';

  @override
  String get cacheCleared => 'Cache cleared successfully!';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get lastBackup => 'Last backup';

  @override
  String get never => 'Never';

  @override
  String get loginRequiredForSync => 'Sign in to use sync & backup features';

  @override
  String get autoSync => 'Auto Sync';

  @override
  String get tapToEdit => 'Tap to edit profile';

  @override
  String get studyTimer => 'Study Timer';

  @override
  String get focusTime => 'Focus Time';

  @override
  String get breakTime => 'Break Time';

  @override
  String get session => 'Session';

  @override
  String get sessionComplete => 'Great job! Session complete 🎉';

  @override
  String get breakComplete => 'Break over! Ready to focus?';

  @override
  String get studyingFor => 'Studying for';

  @override
  String get noCourseSelected => 'No course selected';

  @override
  String get timerPresets => 'Duration Presets';

  @override
  String get short => 'Short';

  @override
  String get classic => 'Classic';

  @override
  String get long => 'Long';

  @override
  String get marathon => 'Marathon';

  @override
  String get completedSessions => 'Completed sessions';

  @override
  String get gpaCalculator => 'GPA Calculator';

  @override
  String get overallGPA => 'Overall GPA';

  @override
  String get totalCredits => 'Credits';

  @override
  String get letterGrade => 'Grade';

  @override
  String get gpaScale => 'GPA Scale';

  @override
  String get courseBreakdown => 'Course Breakdown';

  @override
  String get credits => 'credits';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get studyTimerDesc => 'Pomodoro Timer';

  @override
  String get gpaCalcDesc => 'GPA Calculator';
}
