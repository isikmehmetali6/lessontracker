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
  String get noNotesDescription => 'Use the tools below to capture your first note!';

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
  String get totalCourses => 'Total Courses';

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
  String get average => 'Average';

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
  String get noGradesYet => 'No grades added yet.';

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
  String get editDeadline => 'Edit Deadline';

  @override
  String get updateDeadline => 'Update Deadline';

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
  String get gpaCourses => 'Courses';

  @override
  String get letterGrade => 'Grade';

  @override
  String get gpaScale => 'GPA Scale';

  @override
  String get courseBreakdown => 'Course Breakdown';

  @override
  String get credits => 'credits';

  @override
  String get gpaNoGrades => 'No grades yet';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get studyTimerDesc => 'Pomodoro Timer';

  @override
  String get gpaCalcDesc => 'GPA Calculator';

  @override
  String get absenceCalendar => 'Absence Calendar';

  @override
  String get viewAbsenceCalendar => 'View Absence Calendar';

  @override
  String get noAbsencesOnDay => 'No absences on this day';

  @override
  String get unexcused => 'Unexcused';

  @override
  String get medical => 'Medical';

  @override
  String get excused => 'Excused';

  @override
  String get personal => 'Personal';

  @override
  String absencePredictionWarning(String weeks) {
    return 'At this rate, you\'ll exceed the limit in $weeks weeks';
  }

  @override
  String get professorDetails => 'Professor Details';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get officeRoom => 'Office Room';

  @override
  String get officeHoursLabel => 'Office Hours';

  @override
  String get teachingAssistant => 'Teaching Assistant';

  @override
  String get emailCopied => 'Email copied';

  @override
  String get phoneCopied => 'Phone copied';

  @override
  String get addLink => 'Add Link';

  @override
  String get linkName => 'Link Name';

  @override
  String get linkAdded => 'Link added';

  @override
  String get webLink => 'Web Link';

  @override
  String get templateCornellNotes => 'Cornell Notes';

  @override
  String get templateLectureSummary => 'Lecture Summary';

  @override
  String get templateExamNotes => 'Exam Notes';

  @override
  String get startFromTemplate => 'Start from Template';

  @override
  String get transcript => 'Transcript';

  @override
  String get inProgress => 'In Progress';

  @override
  String get semesterReport => 'Semester Report';

  @override
  String get generatePdfReport => 'Generate PDF report';

  @override
  String get exportDataCsv => 'Export Data (CSV)';

  @override
  String get exportData => 'Export Data';

  @override
  String get gradesCsv => 'Grades (CSV)';

  @override
  String get absencesCsv => 'Absences (CSV)';

  @override
  String get studySessionsCsv => 'Study Sessions (CSV)';

  @override
  String get selectAbsenceReason => 'Select absence reason';

  @override
  String get editCourse => 'Edit Course';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get setLocationGeofence => 'Set Location (Geofence)';

  @override
  String get absenceUnexcused => 'Unexcused';

  @override
  String get absenceMedical => 'Medical';

  @override
  String get absenceExcused => 'Excused';

  @override
  String get absencePersonal => 'Personal';

  @override
  String get absenceOverview => 'Attendance Overview';

  @override
  String get absencesUsed => 'absences used';

  @override
  String get totalAbsences => 'total absences';

  @override
  String get editAbsence => 'Edit Absence';

  @override
  String get deleteAbsence => 'Delete Absence';

  @override
  String get selectReason => 'Select reason:';

  @override
  String get convertToPdf => 'Convert to PDF';

  @override
  String get allNotesToPdf => 'All Notes → PDF';

  @override
  String get photosToPdf => 'Photos → PDF';

  @override
  String get courseReportPdf => 'Course Report → PDF';

  @override
  String get appLock => 'App Lock';

  @override
  String get appLockDisabled => 'Disabled';

  @override
  String get appLockAuthReason => 'Authenticate to enable app lock';

  @override
  String get shareNotes => 'View Notes';

  @override
  String get archiveCourse => 'Archive Course';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get loginSubtitle => 'Log in to continue your learning journey.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailRequired => 'Please enter your email address';

  @override
  String get validEmailRequired => 'Please enter a valid email address';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logIn => 'Log In';

  @override
  String get orDivider => 'OR';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDescription => 'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendLink => 'Send Link';

  @override
  String get passwordResetSent => 'Password reset email sent! Check your inbox.';

  @override
  String get guestDescription => 'Your data will be stored locally on this device only and won\'t sync to the cloud. You can create an account later to backup your data.';

  @override
  String get continueAction => 'Continue';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signupSubtitle => 'Join us to track your academic success.';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get verificationEmailSent => 'Verification email sent! Check your inbox.';

  @override
  String get checkInbox => 'Please check your inbox and click the verification link to activate your account.';

  @override
  String get resendVerification => 'Resend Verification Email';

  @override
  String get iVerifiedMyEmail => 'I verified my email → Continue';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get nextLabel => 'Next';

  @override
  String get savedDataFound => 'Saved Data Found';

  @override
  String savedDataDescription(Object courseCount) {
    return 'This account has $courseCount saved courses.';
  }

  @override
  String get loadDataDescription => 'Loading your data will transfer your courses, notes, and deadlines to this device.';

  @override
  String get cloudDataCleared => 'Old cloud data cleared. Starting fresh.';

  @override
  String get startFresh => 'Start Fresh';

  @override
  String get loadData => 'Load Data';

  @override
  String get youAreOffline => 'You are offline';

  @override
  String get processingOcr => 'Processing OCR...';

  @override
  String get ocrNoteSaved => 'OCR note saved!';

  @override
  String get noCoursesAddFirst => 'No courses available. Add a course first!';

  @override
  String get selectCourseTitle => 'Select Course';

  @override
  String get chooseSaveLocation => 'Choose where to save this note';

  @override
  String get weeklyTimetable => 'Weekly Timetable';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get dayM => 'M';

  @override
  String get dayT => 'T';

  @override
  String get dayW => 'W';

  @override
  String get dayTh => 'Th';

  @override
  String get dayF => 'F';

  @override
  String get daySa => 'Sa';

  @override
  String get daySu => 'Su';

  @override
  String get dailyPlan => 'Daily Plan';

  @override
  String get scheduleAtGlance => 'Your schedule at a glance';

  @override
  String get addPlan => 'Add Plan';

  @override
  String scheduleFor(Object date) {
    return 'Schedule for $date';
  }

  @override
  String get freeDay => 'It\'s a Free Day!';

  @override
  String get freeDayDescription => 'You have no classes or deadlines scheduled. Enjoy your time off or plan ahead.';

  @override
  String get deleteEventTitle => 'Delete Event?';

  @override
  String deleteEventConfirm(Object title) {
    return 'Do you want to delete \"$title\"?';
  }

  @override
  String get addPlanEvent => 'Add Plan Event';

  @override
  String get eventTitleHint => 'Event Title (e.g., Meet up with Ali)';

  @override
  String get eventTitleRequired => 'Please enter a title';

  @override
  String get eventType => 'Event Type';

  @override
  String startLabel(Object time) {
    return 'Start: $time';
  }

  @override
  String endLabel(Object time) {
    return 'End: $time';
  }

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get saveEvent => 'Save Event';

  @override
  String get colorLabel => 'Color';

  @override
  String get eventStudy => 'Study';

  @override
  String get eventMeeting => 'Meeting';

  @override
  String get eventCoffee => 'Coffee Break';

  @override
  String get eventPersonal => 'Personal';

  @override
  String get eventOther => 'Other';

  @override
  String get recording => 'Recording...';

  @override
  String get stopAndSave => 'Stop & Save';

  @override
  String get syncFromMoodle => 'Sync from Moodle';

  @override
  String get moodleSyncFirst => 'Sync your Moodle account first';

  @override
  String moodleCourseSelected(Object courseName) {
    return '$courseName selected — edit course details';
  }

  @override
  String get selectFromMoodle => 'Select from Moodle';

  @override
  String get cancelMoodle => 'Cancel';

  @override
  String addSelected(Object count) {
    return 'Add ($count)';
  }

  @override
  String get searchCourse => 'Search course...';

  @override
  String get courseArchived => 'Course archived';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get deadlineAdded => 'Deadline added successfully!';

  @override
  String get fileAdded => 'File added successfully';

  @override
  String photoSaved(Object count) {
    return '$count photos saved!';
  }

  @override
  String get noteSaved => 'Note saved!';

  @override
  String get drawingSaved => 'Drawing saved!';

  @override
  String get gradeDeleted => 'Grade deleted';

  @override
  String get ocrLabel => 'OCR';

  @override
  String get drawingLabel => 'Drawing';

  @override
  String ofNotes(Object count, Object total) {
    return '$count of $total Notes';
  }

  @override
  String notesCount(Object count) {
    return '$count Notes';
  }

  @override
  String get clearCanvas => 'Clear Canvas';

  @override
  String get clearCanvasConfirm => 'Are you sure you want to clear all drawings?';

  @override
  String get clearAction => 'Clear';

  @override
  String get nothingToSave => 'Nothing to save. Please draw something first.';

  @override
  String get blankPaper => 'Blank Paper';

  @override
  String get photoAnnotation => 'Photo Annotation';

  @override
  String get pdfAnnotation => 'PDF Annotation';

  @override
  String get blankLabel => 'Blank';

  @override
  String get photoLabel => 'Photo';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get tapPhotoHint => 'Tap \"Photo\" to select an image';

  @override
  String get tapPdfHint => 'Tap \"PDF\" to select a document';

  @override
  String get moveToCourse => 'Move to Course';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get noOtherCourses => 'No other courses available';

  @override
  String get selectDestination => 'Select destination course';

  @override
  String movedTo(Object course) {
    return 'Moved to $course';
  }

  @override
  String get noDrawingData => 'No drawing data';

  @override
  String get pdfFileNotFound => 'PDF file not found';

  @override
  String get studyHistory => 'Study History';

  @override
  String get range7D => '7D';

  @override
  String get range14D => '14D';

  @override
  String get range30D => '30D';

  @override
  String get totalStudy => 'Total Study';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get avgPerDay => 'Avg/Day';

  @override
  String get dailyStudyTime => 'Daily Study Time';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get byCourse => 'By Course';

  @override
  String get general => 'General';

  @override
  String get recentSessions => 'Recent Sessions';

  @override
  String get noStudySessions => 'No study sessions yet.\nStart a Pomodoro timer!';

  @override
  String get deleteSession => 'Delete Session';

  @override
  String deleteSessionConfirm(Object minutes) {
    return 'Delete this ${minutes}m study session?';
  }

  @override
  String get enabled => 'Enabled';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get start => 'Start';

  @override
  String get close => 'Close';

  @override
  String get saveQuestions => 'Save Questions';

  @override
  String questionLabel(Object index) {
    return 'Question $index';
  }

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get allAnswersRequired => 'All answers are required';

  @override
  String get questionsSaved => 'Security questions saved';

  @override
  String get questionsSaveFailed => 'Failed to save questions';

  @override
  String get resetQuestions => 'Reset Questions';

  @override
  String biometricEnabled(Object biometric) {
    return '$biometric enabled successfully';
  }

  @override
  String biometricDisabled(Object biometric) {
    return '$biometric disabled';
  }

  @override
  String biometricAuthReason(Object biometric) {
    return 'Authenticate to enable $biometric';
  }

  @override
  String get e2eEncryption => 'End-to-End Encryption';

  @override
  String get e2eDescription => 'Your files are encrypted on your device before being uploaded to the cloud.';

  @override
  String get encryptionKey => 'Encryption Key';

  @override
  String get keyStorage => 'Key Storage';

  @override
  String get cloudAccess => 'Cloud Access';

  @override
  String get aes256 => 'AES-256-CBC';

  @override
  String get deviceKeychain => 'Device Keychain';

  @override
  String get encryptedOnly => 'Only encrypted data';

  @override
  String get evenDevCantAccess => 'Even app developers cannot access your files';

  @override
  String get alreadyEncrypted => 'All files are already encrypted';

  @override
  String get startingMigration => 'Starting migration...';

  @override
  String get migrationComplete => 'Migration completed!';

  @override
  String get allEncrypted => 'All files encrypted successfully!';

  @override
  String get migrationFailed => 'Migration failed';

  @override
  String migrationFailedDetail(Object error) {
    return 'Migration failed: $error';
  }

  @override
  String get setUpSecurityQuestions => 'Set up 3 security questions to recover your account if you forget your password.';

  @override
  String get questionsAlreadyConfigured => 'Security questions are already configured';

  @override
  String get encryptExistingFiles => 'Encrypt Existing Files';

  @override
  String get backupFilesToCloud => 'Backup your files to cloud';

  @override
  String get securityQuestions => 'Security Questions';

  @override
  String get securityQ1 => 'What is your pet\'s name?';

  @override
  String get securityQ2 => 'What was your first teacher\'s name?';

  @override
  String get securityQ3 => 'What city were you born in?';

  @override
  String get securityQ4 => 'What is your favorite movie?';

  @override
  String get securityQ5 => 'What was your first phone number?';

  @override
  String get securityQ6 => 'What is your mother\'s maiden name?';

  @override
  String get securityQ7 => 'What was the name of your first school?';

  @override
  String get securityQ8 => 'What is your favorite book?';

  @override
  String get recoveryStepEmail => 'Verify Email';

  @override
  String get recoveryStepQuestions => 'Security Questions';

  @override
  String get recoveryStepPassword => 'New Password';

  @override
  String get recoveryEmailDesc => 'Enter your email to start the recovery process';

  @override
  String get recoveryCodeSent => 'We sent a verification code to your email';

  @override
  String get recoveryQuestionsDesc => 'Answer your security questions to continue';

  @override
  String get recoveryNewPasswordDesc => 'Create a new password for your account';

  @override
  String get emailHint => 'Email Address';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get sendCode => 'Send Code';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get codeIsRequired => 'Code is required';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get yourAnswerLabel => 'Your Answer';

  @override
  String get required => 'Required';

  @override
  String get verifyAnswers => 'Verify Answers';

  @override
  String securityQuestionN(Object number) {
    return 'Security Question $number';
  }

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get failedToSendReset => 'Failed to send reset email. Please check your email address.';

  @override
  String get checkEmailForLink => 'Check your email and click the reset link';

  @override
  String get passwordResetEmailSent => 'Password reset email sent! Note: If you have E2E encryption enabled...';

  @override
  String get failedToResetPassword => 'Failed to reset password. Please try again.';

  @override
  String get professorDetailsSection => 'Professor Details';

  @override
  String get notificationGeneral => 'General';

  @override
  String get turnOffAllNotifications => 'Turn off all app notifications';

  @override
  String get reminderTiming => 'Reminder Timing';

  @override
  String get remindBeforeClass => 'Remind me before class';

  @override
  String get reminder5min => '5 minutes';

  @override
  String get reminder10min => '10 minutes';

  @override
  String get reminder15min => '15 minutes';

  @override
  String get reminder30min => '30 minutes';

  @override
  String get reminder1hour => '1 hour';

  @override
  String get reminder2hours => '2 hours';

  @override
  String alertAt(Object time) {
    return 'Alert at $time';
  }

  @override
  String get courseCustomization => 'Course Customization';

  @override
  String get transcriptTitle => 'Transcript';

  @override
  String get courseHeader => 'Course';

  @override
  String get crHeader => 'CR';

  @override
  String get avgHeader => 'Avg';

  @override
  String get gradeHeader => 'Grade';

  @override
  String get gpHeader => 'GP';

  @override
  String get overallGpa => 'Overall GPA';

  @override
  String get totalCreditsLabel => 'Total Credits';

  @override
  String get storageOptimized => 'Deep memory optimization complete! Device freed up.';

  @override
  String get smartStorageManagement => 'Smart Storage Management';

  @override
  String get storageOptions => 'Options to free up space on your device';

  @override
  String get standardCleanup => 'Standard Cleanup';

  @override
  String standardCleanupDesc(Object size) {
    return 'Deletes temporary files. ($size)';
  }

  @override
  String get deepOptimization => 'Deep Optimization';

  @override
  String get deepOptimizationDesc => 'Clears image residuals and memory leaks, speeds up device.';

  @override
  String get optimizeStorage => 'Optimize Storage';

  @override
  String get userName => 'User';

  @override
  String get guestUserLabel => 'Guest User';

  @override
  String get signInToSync => 'Sign in to sync data';

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get faceId => 'Face ID / Touch ID';

  @override
  String get faceIdSubtitle => 'Use Face ID / Touch ID to unlock';

  @override
  String get notAvailableOnDevice => 'Not available on this device';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get encryptedBackupActive => 'Encrypted backup active';

  @override
  String get backupOffDefault => 'Off (default)';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountKvkk => 'KVKK Article 7 - Right to Deletion';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String deleteAccountError(Object error) {
    return 'Account deletion error: $error';
  }

  @override
  String get cookiePolicy => 'Cookie Policy';

  @override
  String get consentManagement => 'Consent Management';

  @override
  String get consentManagementDesc => 'Manage your explicit consent preferences under KVKK Article 5/1.';

  @override
  String get appVersion => 'Lesson Tracker v1.0.0';

  @override
  String get moodleTabCourses => 'Courses';

  @override
  String get moodleTabAssignments => 'Assignments';

  @override
  String get moodleTabGrades => 'Grades';

  @override
  String get moodleTabAnnouncements => 'Announcements';

  @override
  String get moodleTabCalendar => 'Calendar';

  @override
  String get moodleTabMessages => 'Messages';

  @override
  String get moodleTitle => 'Moodle';

  @override
  String moodleSummary(Object accounts, Object courses, Object unread) {
    return '$accounts account · $courses courses · $unread unread';
  }

  @override
  String get moodleRefreshAll => 'Refresh All';

  @override
  String get moodleManageAccounts => 'Manage Accounts';

  @override
  String get moodleAddAccount => 'Add Account';

  @override
  String get moodleConnect => 'Connect Moodle';

  @override
  String get moodleConnectDesc => 'Connect to your university\'s Moodle system to sync courses, assignments, and grades.';

  @override
  String get moodleFeatureAssignments => 'Assignments & Dates';

  @override
  String get moodleFeatureGrades => 'Grades';

  @override
  String get moodleFeatureAnnouncements => 'Announcements';

  @override
  String get moodleFeatureMultiAccount => 'Multi-Account';

  @override
  String get moodlePasswordNotStored => 'Your password is never stored on your device';

  @override
  String get moodleConnected => 'Moodle account connected successfully!';

  @override
  String get moodleNoCourses => 'No courses found';

  @override
  String get moodleSyncing => 'Syncing your Moodle account...';

  @override
  String get moodleNoAssignments => 'No pending assignments found';

  @override
  String get moodleAllDone => 'Great! Looks like everything is completed.';

  @override
  String get moodleOverdue => 'Overdue';

  @override
  String get moodleThisWeek => 'This Week';

  @override
  String get moodleUpcoming => 'Upcoming';

  @override
  String get moodleSubmitted => 'Submitted';

  @override
  String get moodleLate => 'Late';

  @override
  String get moodleDueToday => 'Due today!';

  @override
  String moodleDaysLeft(Object days) {
    return '$days days left';
  }

  @override
  String get moodleNoGrades => 'No grades found';

  @override
  String get moodleNoAnnouncements => 'No announcements found';

  @override
  String get moodleNoEvents => 'No events on this day';

  @override
  String get moodleAllDay => 'All day';

  @override
  String get moodleNoMessages => 'No messages found';

  @override
  String get moodleMessagesHere => 'Your Moodle messages will appear here';

  @override
  String moodleAccountCourses(Object count) {
    return '$count assignments';
  }

  @override
  String get moodleAcademicSummary => 'Academic Summary';

  @override
  String get moodleAvg => 'Avg.';

  @override
  String get moodleThisWeekTasks => 'This week tasks';

  @override
  String get moodleOverdueTasks => 'Overdue';

  @override
  String get moodleCourseCount => 'Course count';

  @override
  String get moodleBest => 'Best';

  @override
  String get moodleWorst => 'Worst';

  @override
  String get moodleSelectUniversity => 'Select Your University';

  @override
  String get moodleSelectUniversityDesc => 'Select your university to connect your Moodle account';

  @override
  String get moodleSearchUniversity => 'Search university...';

  @override
  String get moodleManualUrl => 'Manual URL Entry';

  @override
  String get moodleManualUrlDesc => 'For universities not in the list';

  @override
  String get moodleBack => 'Back';

  @override
  String get moodleUrl => 'Moodle URL';

  @override
  String get moodleUrlHint => 'e.g. moodle.university.edu.tr';

  @override
  String get moodleUrlRequired => 'URL is required';

  @override
  String get moodleLogin => 'Sign In';

  @override
  String get moodleUsername => 'Username';

  @override
  String get moodleUsernameRequired => 'Username is required';

  @override
  String get moodlePassword => 'Password';

  @override
  String get moodlePasswordRequired => 'Password is required';

  @override
  String get moodlePasswordHint => 'Your password is never stored on your device.';

  @override
  String get moodleConnectButton => 'Connect';

  @override
  String get moodleConnecting => 'Connecting to Moodle...';

  @override
  String get moodleConnectionFailed => 'Connection Failed';

  @override
  String get moodleTryAgain => 'Try Again';

  @override
  String get moodleConnectionSuccess => 'Connection Successful!';

  @override
  String get moodleGreat => 'Great!';

  @override
  String get moodleAccountsManage => 'Manage Accounts';

  @override
  String get moodleAccountAdd => 'Add Moodle Account';

  @override
  String get moodleNoAccounts => 'No connected accounts';

  @override
  String get moodleNoAccountsDesc => 'Add your Moodle account using the button below.';

  @override
  String get moodleLogout => 'Log Out';

  @override
  String moodleLogoutConfirm(Object account) {
    return 'Are you sure you want to log out of $account?';
  }

  @override
  String moodleLogoutDone(Object account) {
    return 'Logged out from $account';
  }

  @override
  String get moodleContentLoading => 'Loading course content...';

  @override
  String moodleContentError(Object error) {
    return 'Could not load content: $error';
  }

  @override
  String get moodleContentNotFound => 'Content not found';

  @override
  String get moodleDownloadFailed => 'Download failed or file too large.';

  @override
  String get moodleTransferToCourse => 'Transfer to My Courses';

  @override
  String get moodleTransferDesc => 'Save this file to one of your courses in the app.';

  @override
  String get moodleSelectCourse => 'Select Course';

  @override
  String get moodleNoLocalCourses => 'You haven\'t added any courses yet.';

  @override
  String moodleSavedToCourse(Object course) {
    return 'File saved to \"$course\" successfully!';
  }

  @override
  String get moodleSaveError => 'An error occurred while saving the file.';

  @override
  String get moodleTokenNotFound => 'Token not found — reconnect your account';

  @override
  String get moodleAccountNotFound => 'Account not found';

  @override
  String get veliConsentTitle => 'Parental Consent';

  @override
  String get veliConsentDesc => 'Users under 18 need parental consent to use the app.';

  @override
  String get veliEmailLabel => 'Parent Email Address';

  @override
  String get veliEmailHint => 'Enter parent\'s email address';

  @override
  String get veliConfirmCheck => 'I confirm that I am a parent and I allow my child to use this app.';

  @override
  String get veliKvkkCheck => 'I provide parental consent under KVKK Law No. 6698.';

  @override
  String veliCodeSent(Object email) {
    return 'Verification code sent to $email.';
  }

  @override
  String get veliEnterCode => 'Enter the 6-digit verification code';

  @override
  String get veliVerifyAndApprove => 'Verify & Approve';

  @override
  String get veliResendCode => 'Resend Code';

  @override
  String get veliChangeEmail => 'Change Email';

  @override
  String get veliSendCode => 'Send Verification Code';

  @override
  String get veliCancel => 'Cancel';

  @override
  String get veliRequired => 'Parental consent is required';

  @override
  String get veliValidEmail => 'Enter a valid email address';

  @override
  String get veliCheckConsent => 'Please check the parental consent box';

  @override
  String get veliCodeRequired => 'Enter the verification code';

  @override
  String get veliSessionNotFound => 'Verification session not found. Please try again.';

  @override
  String get veliCodeExpired => 'Verification code expired. Please request a new one.';

  @override
  String get veliWrongCode => 'Wrong verification code.';

  @override
  String get veliInfoText => 'The parent email will only be used to send the consent notification.';

  @override
  String get veliRequestConsent => 'Request Consent';

  @override
  String get veliEmailVerification => 'Email Verification';

  @override
  String get veliStepVerification => 'Verification';

  @override
  String get veliStepConsent => 'Consent';

  @override
  String get kvkkFlowReset => 'KVKK consent reset — restart the app';

  @override
  String get kvkkReset => 'Reset';

  @override
  String get kvkkSkip => 'Skip';

  @override
  String get consentManagementTitle => 'Consent Management';

  @override
  String get consentManagementSubtitle => 'Your Explicit Consent Preferences';

  @override
  String get consentWithdrawInfo => 'You can withdraw your consent at any time. Withdrawal does not affect the lawfulness of processing based on consent before its withdrawal.';

  @override
  String get consentCamera => 'Camera Photo Capture';

  @override
  String get consentAudio => 'Audio Recording';

  @override
  String get consentOcr => 'OCR Text Recognition';

  @override
  String get consentPush => 'Push Notifications';

  @override
  String get consentCloud => 'Cloud Backup (Optional)';

  @override
  String get consentLegalInfo => 'Legal Information';

  @override
  String get consentLegalDesc => 'Under KVKK Law No. 6698, you can manage your explicit consent preferences here.';

  @override
  String get consentCameraDesc => 'Take photos and scan documents';

  @override
  String get consentAudioDesc => 'Record audio notes in lessons';

  @override
  String get consentOcrDesc => 'Extract text from images and PDFs';

  @override
  String get consentPushDesc => 'Receive deadline and course notifications';

  @override
  String get consentCloudDesc => 'Back up your data to the cloud securely';

  @override
  String get moodleSyncEnabled => 'Moodle background sync enabled!';

  @override
  String get moodleSyncDisabled => 'Moodle background sync disabled!';

  @override
  String get moodleBackgroundSync => 'Moodle Background Sync';

  @override
  String get moodleSyncNotifications => 'New assignments, grades and announcements will be notified';

  @override
  String get moodleSyncOff => 'Off — manual refresh required';

  @override
  String get smartAttendanceSetLocationFirst => 'Set your school location first to enable smart attendance.';

  @override
  String get smartAttendanceEnabled => 'Smart attendance enabled! Will work in background.';

  @override
  String get smartAttendanceDisabled => 'Smart attendance disabled.';

  @override
  String get smartAttendanceSchoolLocation => 'School Location';

  @override
  String get smartAttendanceLocationSet => 'Location Set';

  @override
  String get smartAttendanceLocationNotSet => 'Not set yet';

  @override
  String get smartAttendanceCurrentLocation => 'Your current school location is saved.';

  @override
  String get smartAttendanceSetLocationPrompt => 'Do you want to save your current location as \"University Location\"?';

  @override
  String get smartAttendanceCancel => 'Cancel';

  @override
  String get smartAttendanceGettingLocation => 'Getting location...';

  @override
  String get smartAttendanceSaved => 'School location saved!';

  @override
  String get smartAttendanceLocationError => 'Could not get location. Check location permissions.';

  @override
  String get smartAttendanceUpdate => 'Update';

  @override
  String get smartAttendanceYesImAtSchool => 'Yes, I\'m at School';

  @override
  String get smartAttendanceTitle => 'Smart Attendance';

  @override
  String get smartAttendanceActive => 'Active — Absence not counted if you are at school during class';

  @override
  String get smartAttendanceOff => 'Disabled';

  @override
  String get deleteAccountTitle => 'About to Delete\nYour Account';

  @override
  String get deleteAccountIrreversible => 'This action cannot be undone';

  @override
  String get deleteAccountDataToDelete => 'Data to be deleted:';

  @override
  String get deleteAccountNotes => 'All course notes';

  @override
  String get deleteAccountAudio => 'Audio recordings';

  @override
  String get deleteAccountPhotos => 'Photos and OCR data';

  @override
  String get deleteAccountAttendance => 'Attendance and grade records';

  @override
  String get deleteAccountSessions => 'Study sessions';

  @override
  String get deleteAccountMoodle => 'Moodle account connections';

  @override
  String get deleteAccountFirebase => 'Firebase account';

  @override
  String get deleteAccountRetention => 'Your data will be permanently deleted within 30 days.';

  @override
  String get deleteAccountConfirm => 'I confirm that I want to delete my account.';

  @override
  String get deleteAccountCancel => 'Cancel';

  @override
  String get deleteAccountAction => 'Delete My Account';

  @override
  String get aydinlatmaTitle => 'Disclosure Text';

  @override
  String get aydinlatmaSubtitle => 'Information under KVKK Law No. 6698 Article 10';

  @override
  String get aydinlatmaSection1 => '1. Data Controller';

  @override
  String get aydinlatmaControllerInfo => 'LessonTracker\nEmail: lessontracker@example.com';

  @override
  String get aydinlatmaSection2 => '2. Personal Data Processed';

  @override
  String get aydinlatmaSection3 => '3. Purposes of Data Processing';

  @override
  String get aydinlatmaSection4 => '4. Transfer of Personal Data';

  @override
  String get aydinlatmaSection5 => '5. Retention Period';

  @override
  String get aydinlatmaSection6 => '6. Data Security';

  @override
  String get aydinlatmaSection7 => '7. Your Rights (KVKK Article 11)';

  @override
  String get aydinlatmaSection8 => '8. Further Information';

  @override
  String get aydinlatmaConfirm => 'I have read the disclosure text and have been informed.';

  @override
  String get aydinlatmaContinue => 'I Understand, Continue';

  @override
  String get acikRizaTitle => 'Explicit Consent';

  @override
  String get acikRizaSubtitle => 'Your explicit consent is legally required for the following actions (KVKK Article 5/1 and 6/2)';

  @override
  String get acikRizaImportant => 'Important Information';

  @override
  String get acikRizaVoluntary => 'Giving explicit consent is completely voluntary. You can skip consent and use the app in limited mode. You can change your preferences later in Settings.';

  @override
  String get acikRizaGiveAndContinue => 'Give Consent & Continue';

  @override
  String get acikRizaSkip => 'Continue Without Consent';

  @override
  String get acikRizaWarning => 'Important Notice';

  @override
  String get acikRizaFeaturesDisabled => 'If you continue without consent, the following features will not be available:';

  @override
  String get acikRizaFeatureCamera => 'Camera photo capture';

  @override
  String get acikRizaFeatureAudio => 'Audio recording';

  @override
  String get acikRizaFeatureOcr => 'OCR text recognition';

  @override
  String get acikRizaSettingsNote => 'You can change these preferences later in Settings.';

  @override
  String get acikRizaCancel => 'Cancel';

  @override
  String get acikRizaLimitedMode => 'Continue in Limited Mode';
}
