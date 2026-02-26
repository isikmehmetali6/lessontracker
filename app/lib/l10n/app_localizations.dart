import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Tracker'**
  String get appTitle;

  /// No description provided for @homeParams.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeParams;

  /// No description provided for @planParams.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planParams;

  /// No description provided for @statsParams.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsParams;

  /// No description provided for @settingsParams.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsParams;

  /// No description provided for @priorityFocus.
  ///
  /// In en, this message translates to:
  /// **'Priority Focus'**
  String get priorityFocus;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @quickCapture.
  ///
  /// In en, this message translates to:
  /// **'Quick Capture'**
  String get quickCapture;

  /// No description provided for @recentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Notes'**
  String get recentNotes;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Start capturing!'**
  String get noNotesYet;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening,'**
  String get goodEvening;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @todaysClasses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Classes'**
  String get todaysClasses;

  /// No description provided for @noClassesScheduled.
  ///
  /// In en, this message translates to:
  /// **'No classes scheduled'**
  String get noClassesScheduled;

  /// No description provided for @addCourseToSeeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add a course to see your schedule'**
  String get addCourseToSeeSchedule;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your learning progress'**
  String get trackYourProgress;

  /// No description provided for @addNewCourse.
  ///
  /// In en, this message translates to:
  /// **'Add New Course'**
  String get addNewCourse;

  /// No description provided for @courseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseName;

  /// No description provided for @courseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mathematics'**
  String get courseNameHint;

  /// No description provided for @classSchedule.
  ///
  /// In en, this message translates to:
  /// **'Class Schedule'**
  String get classSchedule;

  /// No description provided for @addTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Time Slot'**
  String get addTimeSlot;

  /// No description provided for @classroomLocation.
  ///
  /// In en, this message translates to:
  /// **'Classroom / Location'**
  String get classroomLocation;

  /// No description provided for @classroomHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Science Hall 304'**
  String get classroomHint;

  /// No description provided for @professorOptional.
  ///
  /// In en, this message translates to:
  /// **'Professor (Optional)'**
  String get professorOptional;

  /// No description provided for @professorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Smith'**
  String get professorHint;

  /// No description provided for @absenceLimit.
  ///
  /// In en, this message translates to:
  /// **'Absence Limit'**
  String get absenceLimit;

  /// No description provided for @maxAllowedPerSemester.
  ///
  /// In en, this message translates to:
  /// **'Max allowed per semester'**
  String get maxAllowedPerSemester;

  /// No description provided for @cardColor.
  ///
  /// In en, this message translates to:
  /// **'Card Color'**
  String get cardColor;

  /// No description provided for @createCourse.
  ///
  /// In en, this message translates to:
  /// **'Create Course'**
  String get createCourse;

  /// No description provided for @pleaseEnterCourseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a course name'**
  String get pleaseEnterCourseName;

  /// No description provided for @pleaseAddClassTime.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one class time'**
  String get pleaseAddClassTime;

  /// No description provided for @failedToCreateSchedule.
  ///
  /// In en, this message translates to:
  /// **'Failed to create some schedule items'**
  String get failedToCreateSchedule;

  /// No description provided for @courseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course Progress'**
  String get courseProgress;

  /// No description provided for @lessonMaterials.
  ///
  /// In en, this message translates to:
  /// **'Lesson Materials'**
  String get lessonMaterials;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @writeYourNote.
  ///
  /// In en, this message translates to:
  /// **'Write your note...'**
  String get writeYourNote;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @deleteCourse.
  ///
  /// In en, this message translates to:
  /// **'Delete Course'**
  String get deleteCourse;

  /// No description provided for @deleteCourseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete all notes associated with this course.'**
  String get deleteCourseConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @keyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get keyboard;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @noClassTimesAdded.
  ///
  /// In en, this message translates to:
  /// **'No class times added yet.'**
  String get noClassTimesAdded;

  /// No description provided for @voiceMemo.
  ///
  /// In en, this message translates to:
  /// **'Voice Memo'**
  String get voiceMemo;

  /// No description provided for @notesHeader.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesHeader;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Note?'**
  String get deleteNoteTitle;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @totalCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get totalCourses;

  /// No description provided for @totalNotes.
  ///
  /// In en, this message translates to:
  /// **'Total Notes'**
  String get totalNotes;

  /// No description provided for @avgProgress.
  ///
  /// In en, this message translates to:
  /// **'Avg. Progress'**
  String get avgProgress;

  /// No description provided for @studyStreak.
  ///
  /// In en, this message translates to:
  /// **'Study Streak'**
  String get studyStreak;

  /// No description provided for @activeCourses.
  ///
  /// In en, this message translates to:
  /// **'Active courses'**
  String get activeCourses;

  /// No description provided for @notesCaptured.
  ///
  /// In en, this message translates to:
  /// **'Notes captured'**
  String get notesCaptured;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get overallProgress;

  /// No description provided for @daysInRow.
  ///
  /// In en, this message translates to:
  /// **'Days in a row'**
  String get daysInRow;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// No description provided for @syncBackup.
  ///
  /// In en, this message translates to:
  /// **'Sync & Backup'**
  String get syncBackup;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @settingsHeader.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsHeader;

  /// No description provided for @settingsSubHeader.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get settingsSubHeader;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Alex Student'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'alex@university.edu'**
  String get profileEmail;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @weeklyGoalSub.
  ///
  /// In en, this message translates to:
  /// **'5/7 days'**
  String get weeklyGoalSub;

  /// No description provided for @courseAbsence.
  ///
  /// In en, this message translates to:
  /// **'Absence'**
  String get courseAbsence;

  /// No description provided for @remainingAbsences.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remainingAbsences;

  /// No description provided for @addAbsence.
  ///
  /// In en, this message translates to:
  /// **'Add Absence'**
  String get addAbsence;

  /// No description provided for @removeAbsence.
  ///
  /// In en, this message translates to:
  /// **'Remove Absence'**
  String get removeAbsence;

  /// No description provided for @absenceLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Limit exceeded! ({excess} over)'**
  String absenceLimitExceeded(Object excess);

  /// No description provided for @noAbsenceRightsLeft.
  ///
  /// In en, this message translates to:
  /// **'No rights left!'**
  String get noAbsenceRightsLeft;

  /// No description provided for @absenceRightsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} rights left'**
  String absenceRightsLeft(Object count);

  /// No description provided for @absenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Absence'**
  String get absenceLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get remainingLabel;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @gpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gpa;

  /// No description provided for @academicStanding.
  ///
  /// In en, this message translates to:
  /// **'Academic Standing'**
  String get academicStanding;

  /// No description provided for @atRisk.
  ///
  /// In en, this message translates to:
  /// **'Attendance Risk'**
  String get atRisk;

  /// No description provided for @coursePerformance.
  ///
  /// In en, this message translates to:
  /// **'Course Performance'**
  String get coursePerformance;

  /// No description provided for @recentGrades.
  ///
  /// In en, this message translates to:
  /// **'Recent Grades'**
  String get recentGrades;

  /// No description provided for @noGradesData.
  ///
  /// In en, this message translates to:
  /// **'No grades data yet.'**
  String get noGradesData;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get average;

  /// No description provided for @improvementNeeded.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get improvementNeeded;

  /// No description provided for @gradesTab.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get gradesTab;

  /// No description provided for @filesTab.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesTab;

  /// No description provided for @notesTab.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTab;

  /// No description provided for @addGrade.
  ///
  /// In en, this message translates to:
  /// **'Add Grade'**
  String get addGrade;

  /// No description provided for @noGradesYet.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get noGradesYet;

  /// No description provided for @noFilesYet.
  ///
  /// In en, this message translates to:
  /// **'No files yet'**
  String get noFilesYet;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @addFile.
  ///
  /// In en, this message translates to:
  /// **'Add File'**
  String get addFile;

  /// No description provided for @nextExamIn.
  ///
  /// In en, this message translates to:
  /// **'Next exam in {days} days'**
  String nextExamIn(int days);

  /// No description provided for @semesterDefault.
  ///
  /// In en, this message translates to:
  /// **'Spring Semester'**
  String get semesterDefault;

  /// No description provided for @noProfessor.
  ///
  /// In en, this message translates to:
  /// **'No Professor'**
  String get noProfessor;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @averageShort.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get averageShort;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes, tags (#exam)...'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching notes found'**
  String get noResults;

  /// No description provided for @searchStartPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search by title, content or tags'**
  String get searchStartPrompt;

  /// No description provided for @deadlinesHeader.
  ///
  /// In en, this message translates to:
  /// **'Deadlines'**
  String get deadlinesHeader;

  /// No description provided for @deadlinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of your tasks'**
  String get deadlinesSubtitle;

  /// No description provided for @noUpcomingDeadlines.
  ///
  /// In en, this message translates to:
  /// **'No upcoming deadlines'**
  String get noUpcomingDeadlines;

  /// No description provided for @addFirstDeadline.
  ///
  /// In en, this message translates to:
  /// **'Add your first deadline'**
  String get addFirstDeadline;

  /// No description provided for @deadlineOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get deadlineOverdue;

  /// No description provided for @deadlineToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get deadlineToday;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @addDeadlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Deadline'**
  String get addDeadlineTitle;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillAllFields;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title (e.g. Midterm, Project)'**
  String get titleHint;

  /// No description provided for @selectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get selectCourse;

  /// No description provided for @noCoursesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No courses available. Add a course first.'**
  String get noCoursesAvailable;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// No description provided for @saveToDeviceCalendar.
  ///
  /// In en, this message translates to:
  /// **'Save to device calendar'**
  String get saveToDeviceCalendar;

  /// No description provided for @assignmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'Assignment Name (e.g. Midterm)'**
  String get assignmentNameHint;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @weightPercent.
  ///
  /// In en, this message translates to:
  /// **'Weight (%)'**
  String get weightPercent;

  /// No description provided for @saveGrade.
  ///
  /// In en, this message translates to:
  /// **'Save Grade'**
  String get saveGrade;

  /// No description provided for @addNoteToImage.
  ///
  /// In en, this message translates to:
  /// **'Add Note to Image'**
  String get addNoteToImage;

  /// No description provided for @titleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (Optional)'**
  String get titleOptional;

  /// No description provided for @imageContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write something about this image...'**
  String get imageContentHint;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Tags (e.g. #exam, #history)'**
  String get tagsHint;

  /// No description provided for @absenceHistory.
  ///
  /// In en, this message translates to:
  /// **'Absence History'**
  String get absenceHistory;

  /// No description provided for @noAbsenceHistory.
  ///
  /// In en, this message translates to:
  /// **'No absence history yet.'**
  String get noAbsenceHistory;

  /// No description provided for @welcomeToClass.
  ///
  /// In en, this message translates to:
  /// **'Welcome to class! 🎓'**
  String get welcomeToClass;

  /// No description provided for @youAreInArea.
  ///
  /// In en, this message translates to:
  /// **'You are at the class location.'**
  String get youAreInArea;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup your data to the cloud or restore it to this device.'**
  String get syncDescription;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload local data to cloud'**
  String get backupDescription;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Download from cloud (Replaces Local)'**
  String get restoreDescription;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get confirmRestore;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite some local data with cloud data. Continue?'**
  String get restoreWarning;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @attendanceStatus.
  ///
  /// In en, this message translates to:
  /// **'Attendance Status'**
  String get attendanceStatus;

  /// No description provided for @perfectAttendance.
  ///
  /// In en, this message translates to:
  /// **'Perfect attendance! Keep it up!'**
  String get perfectAttendance;

  /// No description provided for @absences.
  ///
  /// In en, this message translates to:
  /// **'{current} / {limit} Absences'**
  String absences(int current, int limit);

  /// No description provided for @riskLabel.
  ///
  /// In en, this message translates to:
  /// **'RISK'**
  String get riskLabel;

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaySchedule;

  /// No description provided for @noClassesToday.
  ///
  /// In en, this message translates to:
  /// **'No classes today — enjoy your free time! 🎉'**
  String get noClassesToday;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Find subjects, notes, or tags...'**
  String get searchPlaceholder;

  /// No description provided for @noCourses.
  ///
  /// In en, this message translates to:
  /// **'No courses yet'**
  String get noCourses;

  /// No description provided for @addYourFirstCourse.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first course and start tracking!'**
  String get addYourFirstCourse;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to new address'**
  String get emailVerificationSent;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new course?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button on the home screen and fill in the course details including name, schedule, and professor info.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I track my absences?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Open any course and use the absence counter to add or remove absences. You\'ll get warned when you approach work limit.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'Can I backup my data?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Yes! Go to Settings > Sync & Backup to upload your data to the cloud. You need to be signed in to use this feature.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'How do I record a voice note?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Open a course, tap the + button, and select the microphone icon to start recording a voice memo.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I change the app language?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings and tap on Language. You can choose between English, Turkish, Spanish, and German.'**
  String get faqA5;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @reportBugDescription.
  ///
  /// In en, this message translates to:
  /// **'Found something broken? Let us know'**
  String get reportBugDescription;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequest;

  /// No description provided for @featureRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'Suggest a new feature'**
  String get featureRequestDescription;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Lesson Tracker helps students organize their courses, track attendance, capture notes, and stay on top of deadlines. Built with care for students everywhere.'**
  String get aboutDescription;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @totalStorageUsed.
  ///
  /// In en, this message translates to:
  /// **'Total Storage Used'**
  String get totalStorageUsed;

  /// No description provided for @storageBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Storage Breakdown'**
  String get storageBreakdown;

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @mediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Media Files'**
  String get mediaFiles;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @dataStats.
  ///
  /// In en, this message translates to:
  /// **'Data Statistics'**
  String get dataStats;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will remove temporary files. Your data will not be affected. Continue?'**
  String get clearCacheConfirmation;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully!'**
  String get cacheCleared;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get lastBackup;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @loginRequiredForSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use sync & backup features'**
  String get loginRequiredForSync;

  /// No description provided for @autoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto Sync'**
  String get autoSync;

  /// No description provided for @tapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit profile'**
  String get tapToEdit;

  /// No description provided for @studyTimer.
  ///
  /// In en, this message translates to:
  /// **'Study Timer'**
  String get studyTimer;

  /// No description provided for @focusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get focusTime;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break Time'**
  String get breakTime;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Great job! Session complete 🎉'**
  String get sessionComplete;

  /// No description provided for @breakComplete.
  ///
  /// In en, this message translates to:
  /// **'Break over! Ready to focus?'**
  String get breakComplete;

  /// No description provided for @studyingFor.
  ///
  /// In en, this message translates to:
  /// **'Studying for'**
  String get studyingFor;

  /// No description provided for @noCourseSelected.
  ///
  /// In en, this message translates to:
  /// **'No course selected'**
  String get noCourseSelected;

  /// No description provided for @timerPresets.
  ///
  /// In en, this message translates to:
  /// **'Duration Presets'**
  String get timerPresets;

  /// No description provided for @short.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get short;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @long.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get long;

  /// No description provided for @marathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get marathon;

  /// No description provided for @completedSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions'**
  String get completedSessions;

  /// No description provided for @gpaCalculator.
  ///
  /// In en, this message translates to:
  /// **'GPA Calculator'**
  String get gpaCalculator;

  /// No description provided for @overallGPA.
  ///
  /// In en, this message translates to:
  /// **'Overall GPA'**
  String get overallGPA;

  /// No description provided for @totalCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get totalCredits;

  /// No description provided for @letterGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get letterGrade;

  /// No description provided for @gpaScale.
  ///
  /// In en, this message translates to:
  /// **'GPA Scale'**
  String get gpaScale;

  /// No description provided for @courseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Course Breakdown'**
  String get courseBreakdown;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'credits'**
  String get credits;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @studyTimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Timer'**
  String get studyTimerDesc;

  /// No description provided for @gpaCalcDesc.
  ///
  /// In en, this message translates to:
  /// **'GPA Calculator'**
  String get gpaCalcDesc;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
