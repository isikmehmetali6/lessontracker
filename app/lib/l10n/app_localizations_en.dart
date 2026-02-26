// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lesson Tracker';

  @override
  String get homeParams => 'Home';

  @override
  String get planParams => 'Plan';

  @override
  String get statsParams => 'Stats';

  @override
  String get settingsParams => 'Settings';

  @override
  String get priorityFocus => 'Priority Focus';

  @override
  String get viewAll => 'View All';

  @override
  String get quickCapture => 'Quick Capture';

  @override
  String get recentNotes => 'Recent Notes';

  @override
  String get noNotesYet => 'No notes yet. Start capturing!';

  @override
  String get goodMorning => 'Good Morning,';

  @override
  String get goodAfternoon => 'Good Afternoon,';

  @override
  String get goodEvening => 'Good Evening,';

  @override
  String get weeklySchedule => 'Weekly Schedule';

  @override
  String get todaysClasses => 'Today\'s Classes';

  @override
  String get noClassesScheduled => 'No classes scheduled';

  @override
  String get addCourseToSeeSchedule => 'Add a course to see your schedule';

  @override
  String get statistics => 'Statistics';

  @override
  String get trackYourProgress => 'Track your learning progress';

  @override
  String get addNewCourse => 'Add New Course';

  @override
  String get courseName => 'Course Name';

  @override
  String get courseNameHint => 'e.g. Mathematics';

  @override
  String get classSchedule => 'Class Schedule';

  @override
  String get addTimeSlot => 'Add Time Slot';

  @override
  String get classroomLocation => 'Classroom / Location';

  @override
  String get classroomHint => 'e.g. Science Hall 304';

  @override
  String get professorOptional => 'Professor (Optional)';

  @override
  String get professorHint => 'e.g. Dr. Smith';

  @override
  String get absenceLimit => 'Absence Limit';

  @override
  String get maxAllowedPerSemester => 'Max allowed per semester';

  @override
  String get cardColor => 'Card Color';

  @override
  String get createCourse => 'Create Course';

  @override
  String get pleaseEnterCourseName => 'Please enter a course name';

  @override
  String get pleaseAddClassTime => 'Please add at least one class time';

  @override
  String get failedToCreateSchedule => 'Failed to create some schedule items';

  @override
  String get courseProgress => 'Course Progress';

  @override
  String get lessonMaterials => 'Lesson Materials';

  @override
  String get newNote => 'New Note';

  @override
  String get title => 'Title';

  @override
  String get writeYourNote => 'Write your note...';

  @override
  String get saveNote => 'Save Note';

  @override
  String get deleteCourse => 'Delete Course';

  @override
  String get deleteCourseConfirmation => 'This will delete all notes associated with this course.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get microphone => 'Microphone';

  @override
  String get keyboard => 'Keyboard';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System';

  @override
  String get noClassTimesAdded => 'No class times added yet.';

  @override
  String get voiceMemo => 'Voice Memo';

  @override
  String get notesHeader => 'Notes';

  @override
  String get deleteNoteTitle => 'Delete Note?';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get totalCourses => 'Courses';

  @override
  String get totalNotes => 'Total Notes';

  @override
  String get avgProgress => 'Avg. Progress';

  @override
  String get studyStreak => 'Study Streak';

  @override
  String get activeCourses => 'Active courses';

  @override
  String get notesCaptured => 'Notes captured';

  @override
  String get overallProgress => 'Overall progress';

  @override
  String get daysInRow => 'Days in a row';

  @override
  String get weeklyGoal => 'Weekly Goal';

  @override
  String get syncBackup => 'Sync & Backup';

  @override
  String get storage => 'Storage';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get signOut => 'Sign Out';

  @override
  String get settingsHeader => 'Settings';

  @override
  String get settingsSubHeader => 'Customize your experience';

  @override
  String get profileName => 'Alex Student';

  @override
  String get profileEmail => 'alex@university.edu';

  @override
  String get notifications => 'Notifications';

  @override
  String get thisWeek => 'This Week';

  @override
  String get weeklyGoalSub => '5/7 days';

  @override
  String get courseAbsence => 'Absence';

  @override
  String get remainingAbsences => 'remaining';

  @override
  String get addAbsence => 'Add Absence';

  @override
  String get removeAbsence => 'Remove Absence';

  @override
  String absenceLimitExceeded(Object excess) {
    return 'Limit exceeded! ($excess over)';
  }

  @override
  String get noAbsenceRightsLeft => 'No rights left!';

  @override
  String absenceRightsLeft(Object count) {
    return '$count rights left';
  }

  @override
  String get absenceLabel => 'Absence';

  @override
  String get remainingLabel => 'Left';

  @override
  String get viewHistory => 'View History';

  @override
  String get gpa => 'GPA';

  @override
  String get academicStanding => 'Academic Standing';

  @override
  String get atRisk => 'Attendance Risk';

  @override
  String get coursePerformance => 'Course Performance';

  @override
  String get recentGrades => 'Recent Grades';

  @override
  String get noGradesData => 'No grades data yet.';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get average => 'Avg';

  @override
  String get improvementNeeded => 'Needs Improvement';

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
