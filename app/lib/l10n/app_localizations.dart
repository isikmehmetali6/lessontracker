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

  /// No description provided for @noNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the tools below to capture your first note!'**
  String get noNotesDescription;

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
  /// **'Total Courses'**
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

  /// No description provided for @addAbsenceAction.
  ///
  /// In en, this message translates to:
  /// **'Add absence'**
  String get addAbsenceAction;

  /// No description provided for @removeAbsenceAction.
  ///
  /// In en, this message translates to:
  /// **'Remove last absence'**
  String get removeAbsenceAction;

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
  /// **'Average'**
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
  /// **'No grades added yet.'**
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

  /// No description provided for @editDeadline.
  ///
  /// In en, this message translates to:
  /// **'Edit Deadline'**
  String get editDeadline;

  /// No description provided for @updateDeadline.
  ///
  /// In en, this message translates to:
  /// **'Update Deadline'**
  String get updateDeadline;

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

  /// No description provided for @gpaCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get gpaCourses;

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

  /// No description provided for @gpaNoGrades.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get gpaNoGrades;

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

  /// No description provided for @absenceCalendar.
  ///
  /// In en, this message translates to:
  /// **'Absence Calendar'**
  String get absenceCalendar;

  /// No description provided for @viewAbsenceCalendar.
  ///
  /// In en, this message translates to:
  /// **'View Absence Calendar'**
  String get viewAbsenceCalendar;

  /// No description provided for @noAbsencesOnDay.
  ///
  /// In en, this message translates to:
  /// **'No absences on this day'**
  String get noAbsencesOnDay;

  /// No description provided for @unexcused.
  ///
  /// In en, this message translates to:
  /// **'Unexcused'**
  String get unexcused;

  /// No description provided for @medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// No description provided for @excused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get excused;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @absencePredictionWarning.
  ///
  /// In en, this message translates to:
  /// **'At this rate, you\'ll exceed the limit in {weeks} weeks'**
  String absencePredictionWarning(String weeks);

  /// No description provided for @professorDetails.
  ///
  /// In en, this message translates to:
  /// **'Professor Details'**
  String get professorDetails;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @officeRoom.
  ///
  /// In en, this message translates to:
  /// **'Office Room'**
  String get officeRoom;

  /// No description provided for @officeHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Office Hours'**
  String get officeHoursLabel;

  /// No description provided for @teachingAssistant.
  ///
  /// In en, this message translates to:
  /// **'Teaching Assistant'**
  String get teachingAssistant;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get emailCopied;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone copied'**
  String get phoneCopied;

  /// No description provided for @addLink.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get addLink;

  /// No description provided for @linkName.
  ///
  /// In en, this message translates to:
  /// **'Link Name'**
  String get linkName;

  /// No description provided for @linkAdded.
  ///
  /// In en, this message translates to:
  /// **'Link added'**
  String get linkAdded;

  /// No description provided for @webLink.
  ///
  /// In en, this message translates to:
  /// **'Web Link'**
  String get webLink;

  /// No description provided for @templateCornellNotes.
  ///
  /// In en, this message translates to:
  /// **'Cornell Notes'**
  String get templateCornellNotes;

  /// No description provided for @templateLectureSummary.
  ///
  /// In en, this message translates to:
  /// **'Lecture Summary'**
  String get templateLectureSummary;

  /// No description provided for @templateExamNotes.
  ///
  /// In en, this message translates to:
  /// **'Exam Notes'**
  String get templateExamNotes;

  /// No description provided for @startFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start from Template'**
  String get startFromTemplate;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @semesterReport.
  ///
  /// In en, this message translates to:
  /// **'Semester Report'**
  String get semesterReport;

  /// No description provided for @generatePdfReport.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF report'**
  String get generatePdfReport;

  /// No description provided for @exportDataCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Data (CSV)'**
  String get exportDataCsv;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @gradesCsv.
  ///
  /// In en, this message translates to:
  /// **'Grades (CSV)'**
  String get gradesCsv;

  /// No description provided for @absencesCsv.
  ///
  /// In en, this message translates to:
  /// **'Absences (CSV)'**
  String get absencesCsv;

  /// No description provided for @studySessionsCsv.
  ///
  /// In en, this message translates to:
  /// **'Study Sessions (CSV)'**
  String get studySessionsCsv;

  /// No description provided for @selectAbsenceReason.
  ///
  /// In en, this message translates to:
  /// **'Select absence reason'**
  String get selectAbsenceReason;

  /// No description provided for @editCourse.
  ///
  /// In en, this message translates to:
  /// **'Edit Course'**
  String get editCourse;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @setLocationGeofence.
  ///
  /// In en, this message translates to:
  /// **'Set Location (Geofence)'**
  String get setLocationGeofence;

  /// No description provided for @absenceUnexcused.
  ///
  /// In en, this message translates to:
  /// **'Unexcused'**
  String get absenceUnexcused;

  /// No description provided for @absenceMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get absenceMedical;

  /// No description provided for @absenceExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get absenceExcused;

  /// No description provided for @absencePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get absencePersonal;

  /// No description provided for @absenceOverview.
  ///
  /// In en, this message translates to:
  /// **'Attendance Overview'**
  String get absenceOverview;

  /// No description provided for @absencesUsed.
  ///
  /// In en, this message translates to:
  /// **'absences used'**
  String get absencesUsed;

  /// No description provided for @totalAbsences.
  ///
  /// In en, this message translates to:
  /// **'total absences'**
  String get totalAbsences;

  /// No description provided for @editAbsence.
  ///
  /// In en, this message translates to:
  /// **'Edit Absence'**
  String get editAbsence;

  /// No description provided for @deleteAbsence.
  ///
  /// In en, this message translates to:
  /// **'Delete Absence'**
  String get deleteAbsence;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select reason:'**
  String get selectReason;

  /// No description provided for @convertToPdf.
  ///
  /// In en, this message translates to:
  /// **'Convert to PDF'**
  String get convertToPdf;

  /// No description provided for @allNotesToPdf.
  ///
  /// In en, this message translates to:
  /// **'All Notes → PDF'**
  String get allNotesToPdf;

  /// No description provided for @photosToPdf.
  ///
  /// In en, this message translates to:
  /// **'Photos → PDF'**
  String get photosToPdf;

  /// No description provided for @courseReportPdf.
  ///
  /// In en, this message translates to:
  /// **'Course Report → PDF'**
  String get courseReportPdf;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get appLockDisabled;

  /// No description provided for @appLockAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to enable app lock'**
  String get appLockAuthReason;

  /// No description provided for @shareNotes.
  ///
  /// In en, this message translates to:
  /// **'View Notes'**
  String get shareNotes;

  /// No description provided for @archiveCourse.
  ///
  /// In en, this message translates to:
  /// **'Archive Course'**
  String get archiveCourse;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your learning journey.'**
  String get loginSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validEmailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox.'**
  String get passwordResetSent;

  /// No description provided for @guestDescription.
  ///
  /// In en, this message translates to:
  /// **'Your data will be stored locally on this device only and won\'t sync to the cloud. You can create an account later to backup your data.'**
  String get guestDescription;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us to track your academic success.'**
  String get signupSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox.'**
  String get verificationEmailSent;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link to activate your account.'**
  String get checkInbox;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerification;

  /// No description provided for @iVerifiedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I verified my email → Continue'**
  String get iVerifiedMyEmail;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLabel;

  /// No description provided for @savedDataFound.
  ///
  /// In en, this message translates to:
  /// **'Saved Data Found'**
  String get savedDataFound;

  /// No description provided for @savedDataDescription.
  ///
  /// In en, this message translates to:
  /// **'This account has {courseCount} saved courses.'**
  String savedDataDescription(Object courseCount);

  /// No description provided for @loadDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Loading your data will transfer your courses, notes, and deadlines to this device.'**
  String get loadDataDescription;

  /// No description provided for @cloudDataCleared.
  ///
  /// In en, this message translates to:
  /// **'Old cloud data cleared. Starting fresh.'**
  String get cloudDataCleared;

  /// No description provided for @startFresh.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh'**
  String get startFresh;

  /// No description provided for @loadData.
  ///
  /// In en, this message translates to:
  /// **'Load Data'**
  String get loadData;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get youAreOffline;

  /// No description provided for @processingOcr.
  ///
  /// In en, this message translates to:
  /// **'Processing OCR...'**
  String get processingOcr;

  /// No description provided for @ocrNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'OCR note saved!'**
  String get ocrNoteSaved;

  /// No description provided for @noCoursesAddFirst.
  ///
  /// In en, this message translates to:
  /// **'No courses available. Add a course first!'**
  String get noCoursesAddFirst;

  /// No description provided for @selectCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get selectCourseTitle;

  /// No description provided for @chooseSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose where to save this note'**
  String get chooseSaveLocation;

  /// No description provided for @weeklyTimetable.
  ///
  /// In en, this message translates to:
  /// **'Weekly Timetable'**
  String get weeklyTimetable;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dayM.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dayM;

  /// No description provided for @dayT.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayT;

  /// No description provided for @dayW.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dayW;

  /// No description provided for @dayTh.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get dayTh;

  /// No description provided for @dayF.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get dayF;

  /// No description provided for @daySa.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get daySa;

  /// No description provided for @daySu.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get daySu;

  /// No description provided for @dailyPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily Plan'**
  String get dailyPlan;

  /// No description provided for @scheduleAtGlance.
  ///
  /// In en, this message translates to:
  /// **'Your schedule at a glance'**
  String get scheduleAtGlance;

  /// No description provided for @addPlan.
  ///
  /// In en, this message translates to:
  /// **'Add Plan'**
  String get addPlan;

  /// No description provided for @scheduleFor.
  ///
  /// In en, this message translates to:
  /// **'Schedule for {date}'**
  String scheduleFor(Object date);

  /// No description provided for @freeDay.
  ///
  /// In en, this message translates to:
  /// **'It\'s a Free Day!'**
  String get freeDay;

  /// No description provided for @freeDayDescription.
  ///
  /// In en, this message translates to:
  /// **'You have no classes or deadlines scheduled. Enjoy your time off or plan ahead.'**
  String get freeDayDescription;

  /// No description provided for @deleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Event?'**
  String get deleteEventTitle;

  /// No description provided for @deleteEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{title}\"?'**
  String deleteEventConfirm(Object title);

  /// No description provided for @addPlanEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Plan Event'**
  String get addPlanEvent;

  /// No description provided for @eventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Event Title (e.g., Meet up with Ali)'**
  String get eventTitleHint;

  /// No description provided for @eventTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get eventTitleRequired;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start: {time}'**
  String startLabel(Object time);

  /// No description provided for @endLabel.
  ///
  /// In en, this message translates to:
  /// **'End: {time}'**
  String endLabel(Object time);

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @saveEvent.
  ///
  /// In en, this message translates to:
  /// **'Save Event'**
  String get saveEvent;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @eventStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get eventStudy;

  /// No description provided for @eventMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get eventMeeting;

  /// No description provided for @eventCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee Break'**
  String get eventCoffee;

  /// No description provided for @eventPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get eventPersonal;

  /// No description provided for @eventOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get eventOther;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @stopAndSave.
  ///
  /// In en, this message translates to:
  /// **'Stop & Save'**
  String get stopAndSave;

  /// No description provided for @syncFromMoodle.
  ///
  /// In en, this message translates to:
  /// **'Sync from Moodle'**
  String get syncFromMoodle;

  /// No description provided for @moodleSyncFirst.
  ///
  /// In en, this message translates to:
  /// **'Sync your Moodle account first'**
  String get moodleSyncFirst;

  /// No description provided for @moodleCourseSelected.
  ///
  /// In en, this message translates to:
  /// **'{courseName} selected — edit course details'**
  String moodleCourseSelected(Object courseName);

  /// No description provided for @selectFromMoodle.
  ///
  /// In en, this message translates to:
  /// **'Select from Moodle'**
  String get selectFromMoodle;

  /// No description provided for @cancelMoodle.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelMoodle;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addSelected(Object count);

  /// No description provided for @searchCourse.
  ///
  /// In en, this message translates to:
  /// **'Search course...'**
  String get searchCourse;

  /// No description provided for @courseArchived.
  ///
  /// In en, this message translates to:
  /// **'Course archived'**
  String get courseArchived;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @deadlineAdded.
  ///
  /// In en, this message translates to:
  /// **'Deadline added successfully!'**
  String get deadlineAdded;

  /// No description provided for @fileAdded.
  ///
  /// In en, this message translates to:
  /// **'File added successfully'**
  String get fileAdded;

  /// No description provided for @photoSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} photos saved!'**
  String photoSaved(Object count);

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved!'**
  String get noteSaved;

  /// No description provided for @drawingSaved.
  ///
  /// In en, this message translates to:
  /// **'Drawing saved!'**
  String get drawingSaved;

  /// No description provided for @gradeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Grade deleted'**
  String get gradeDeleted;

  /// No description provided for @ocrLabel.
  ///
  /// In en, this message translates to:
  /// **'OCR'**
  String get ocrLabel;

  /// No description provided for @drawingLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get drawingLabel;

  /// No description provided for @ofNotes.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} Notes'**
  String ofNotes(Object count, Object total);

  /// No description provided for @notesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Notes'**
  String notesCount(Object count);

  /// No description provided for @clearCanvas.
  ///
  /// In en, this message translates to:
  /// **'Clear Canvas'**
  String get clearCanvas;

  /// No description provided for @clearCanvasConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all drawings?'**
  String get clearCanvasConfirm;

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @nothingToSave.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save. Please draw something first.'**
  String get nothingToSave;

  /// No description provided for @blankPaper.
  ///
  /// In en, this message translates to:
  /// **'Blank Paper'**
  String get blankPaper;

  /// No description provided for @photoAnnotation.
  ///
  /// In en, this message translates to:
  /// **'Photo Annotation'**
  String get photoAnnotation;

  /// No description provided for @pdfAnnotation.
  ///
  /// In en, this message translates to:
  /// **'PDF Annotation'**
  String get pdfAnnotation;

  /// No description provided for @blankLabel.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get blankLabel;

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoLabel;

  /// No description provided for @pdfLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfLabel;

  /// No description provided for @tapPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Photo\" to select an image'**
  String get tapPhotoHint;

  /// No description provided for @tapPdfHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"PDF\" to select a document'**
  String get tapPdfHint;

  /// No description provided for @moveToCourse.
  ///
  /// In en, this message translates to:
  /// **'Move to Course'**
  String get moveToCourse;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @noOtherCourses.
  ///
  /// In en, this message translates to:
  /// **'No other courses available'**
  String get noOtherCourses;

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select destination course'**
  String get selectDestination;

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'Moved to {course}'**
  String movedTo(Object course);

  /// No description provided for @noDrawingData.
  ///
  /// In en, this message translates to:
  /// **'No drawing data'**
  String get noDrawingData;

  /// No description provided for @pdfFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'PDF file not found'**
  String get pdfFileNotFound;

  /// No description provided for @studyHistory.
  ///
  /// In en, this message translates to:
  /// **'Study History'**
  String get studyHistory;

  /// No description provided for @range7D.
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get range7D;

  /// No description provided for @range14D.
  ///
  /// In en, this message translates to:
  /// **'14D'**
  String get range14D;

  /// No description provided for @range30D.
  ///
  /// In en, this message translates to:
  /// **'30D'**
  String get range30D;

  /// No description provided for @totalStudy.
  ///
  /// In en, this message translates to:
  /// **'Total Study'**
  String get totalStudy;

  /// No description provided for @sessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionsLabel;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg/Day'**
  String get avgPerDay;

  /// No description provided for @dailyStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Time'**
  String get dailyStudyTime;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @byCourse.
  ///
  /// In en, this message translates to:
  /// **'By Course'**
  String get byCourse;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent Sessions'**
  String get recentSessions;

  /// No description provided for @noStudySessions.
  ///
  /// In en, this message translates to:
  /// **'No study sessions yet.\nStart a Pomodoro timer!'**
  String get noStudySessions;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get deleteSession;

  /// No description provided for @deleteSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this {minutes}m study session?'**
  String deleteSessionConfirm(Object minutes);

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @saveQuestions.
  ///
  /// In en, this message translates to:
  /// **'Save Questions'**
  String get saveQuestions;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question {index}'**
  String questionLabel(Object index);

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// No description provided for @allAnswersRequired.
  ///
  /// In en, this message translates to:
  /// **'All answers are required'**
  String get allAnswersRequired;

  /// No description provided for @questionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Security questions saved'**
  String get questionsSaved;

  /// No description provided for @questionsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save questions'**
  String get questionsSaveFailed;

  /// No description provided for @resetQuestions.
  ///
  /// In en, this message translates to:
  /// **'Reset Questions'**
  String get resetQuestions;

  /// No description provided for @biometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'{biometric} enabled successfully'**
  String biometricEnabled(Object biometric);

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'{biometric} disabled'**
  String biometricDisabled(Object biometric);

  /// No description provided for @biometricAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to enable {biometric}'**
  String biometricAuthReason(Object biometric);

  /// No description provided for @e2eEncryption.
  ///
  /// In en, this message translates to:
  /// **'End-to-End Encryption'**
  String get e2eEncryption;

  /// No description provided for @e2eDescription.
  ///
  /// In en, this message translates to:
  /// **'Your files are encrypted on your device before being uploaded to the cloud.'**
  String get e2eDescription;

  /// No description provided for @encryptionKey.
  ///
  /// In en, this message translates to:
  /// **'Encryption Key'**
  String get encryptionKey;

  /// No description provided for @keyStorage.
  ///
  /// In en, this message translates to:
  /// **'Key Storage'**
  String get keyStorage;

  /// No description provided for @cloudAccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud Access'**
  String get cloudAccess;

  /// No description provided for @aes256.
  ///
  /// In en, this message translates to:
  /// **'AES-256-CBC'**
  String get aes256;

  /// No description provided for @deviceKeychain.
  ///
  /// In en, this message translates to:
  /// **'Device Keychain'**
  String get deviceKeychain;

  /// No description provided for @encryptedOnly.
  ///
  /// In en, this message translates to:
  /// **'Only encrypted data'**
  String get encryptedOnly;

  /// No description provided for @evenDevCantAccess.
  ///
  /// In en, this message translates to:
  /// **'Even app developers cannot access your files'**
  String get evenDevCantAccess;

  /// No description provided for @alreadyEncrypted.
  ///
  /// In en, this message translates to:
  /// **'All files are already encrypted'**
  String get alreadyEncrypted;

  /// No description provided for @startingMigration.
  ///
  /// In en, this message translates to:
  /// **'Starting migration...'**
  String get startingMigration;

  /// No description provided for @migrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Migration completed!'**
  String get migrationComplete;

  /// No description provided for @allEncrypted.
  ///
  /// In en, this message translates to:
  /// **'All files encrypted successfully!'**
  String get allEncrypted;

  /// No description provided for @migrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Migration failed'**
  String get migrationFailed;

  /// No description provided for @migrationFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'Migration failed: {error}'**
  String migrationFailedDetail(Object error);

  /// No description provided for @setUpSecurityQuestions.
  ///
  /// In en, this message translates to:
  /// **'Set up 3 security questions to recover your account if you forget your password.'**
  String get setUpSecurityQuestions;

  /// No description provided for @questionsAlreadyConfigured.
  ///
  /// In en, this message translates to:
  /// **'Security questions are already configured'**
  String get questionsAlreadyConfigured;

  /// No description provided for @encryptExistingFiles.
  ///
  /// In en, this message translates to:
  /// **'Encrypt Existing Files'**
  String get encryptExistingFiles;

  /// No description provided for @backupFilesToCloud.
  ///
  /// In en, this message translates to:
  /// **'Backup your files to cloud'**
  String get backupFilesToCloud;

  /// No description provided for @securityQuestions.
  ///
  /// In en, this message translates to:
  /// **'Security Questions'**
  String get securityQuestions;

  /// No description provided for @securityQ1.
  ///
  /// In en, this message translates to:
  /// **'What is your pet\'s name?'**
  String get securityQ1;

  /// No description provided for @securityQ2.
  ///
  /// In en, this message translates to:
  /// **'What was your first teacher\'s name?'**
  String get securityQ2;

  /// No description provided for @securityQ3.
  ///
  /// In en, this message translates to:
  /// **'What city were you born in?'**
  String get securityQ3;

  /// No description provided for @securityQ4.
  ///
  /// In en, this message translates to:
  /// **'What is your favorite movie?'**
  String get securityQ4;

  /// No description provided for @securityQ5.
  ///
  /// In en, this message translates to:
  /// **'What was your first phone number?'**
  String get securityQ5;

  /// No description provided for @securityQ6.
  ///
  /// In en, this message translates to:
  /// **'What is your mother\'s maiden name?'**
  String get securityQ6;

  /// No description provided for @securityQ7.
  ///
  /// In en, this message translates to:
  /// **'What was the name of your first school?'**
  String get securityQ7;

  /// No description provided for @securityQ8.
  ///
  /// In en, this message translates to:
  /// **'What is your favorite book?'**
  String get securityQ8;

  /// No description provided for @recoveryStepEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get recoveryStepEmail;

  /// No description provided for @recoveryStepQuestions.
  ///
  /// In en, this message translates to:
  /// **'Security Questions'**
  String get recoveryStepQuestions;

  /// No description provided for @recoveryStepPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get recoveryStepPassword;

  /// No description provided for @recoveryEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to start the recovery process'**
  String get recoveryEmailDesc;

  /// No description provided for @recoveryCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your email'**
  String get recoveryCodeSent;

  /// No description provided for @recoveryQuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer your security questions to continue'**
  String get recoveryQuestionsDesc;

  /// No description provided for @recoveryNewPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a new password for your account'**
  String get recoveryNewPasswordDesc;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailHint;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @codeIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Code is required'**
  String get codeIsRequired;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @yourAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswerLabel;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @verifyAnswers.
  ///
  /// In en, this message translates to:
  /// **'Verify Answers'**
  String get verifyAnswers;

  /// No description provided for @securityQuestionN.
  ///
  /// In en, this message translates to:
  /// **'Security Question {number}'**
  String securityQuestionN(Object number);

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchError;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @failedToSendReset.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email. Please check your email address.'**
  String get failedToSendReset;

  /// No description provided for @checkEmailForLink.
  ///
  /// In en, this message translates to:
  /// **'Check your email and click the reset link'**
  String get checkEmailForLink;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Note: If you have E2E encryption enabled...'**
  String get passwordResetEmailSent;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password. Please try again.'**
  String get failedToResetPassword;

  /// No description provided for @professorDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Professor Details'**
  String get professorDetailsSection;

  /// No description provided for @notificationGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get notificationGeneral;

  /// No description provided for @turnOffAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn off all app notifications'**
  String get turnOffAllNotifications;

  /// No description provided for @reminderTiming.
  ///
  /// In en, this message translates to:
  /// **'Reminder Timing'**
  String get reminderTiming;

  /// No description provided for @remindBeforeClass.
  ///
  /// In en, this message translates to:
  /// **'Remind me before class'**
  String get remindBeforeClass;

  /// No description provided for @reminder5min.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get reminder5min;

  /// No description provided for @reminder10min.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get reminder10min;

  /// No description provided for @reminder15min.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get reminder15min;

  /// No description provided for @reminder30min.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get reminder30min;

  /// No description provided for @reminder1hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get reminder1hour;

  /// No description provided for @reminder2hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get reminder2hours;

  /// No description provided for @alertAt.
  ///
  /// In en, this message translates to:
  /// **'Alert at {time}'**
  String alertAt(Object time);

  /// No description provided for @courseCustomization.
  ///
  /// In en, this message translates to:
  /// **'Course Customization'**
  String get courseCustomization;

  /// No description provided for @transcriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcriptTitle;

  /// No description provided for @courseHeader.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get courseHeader;

  /// No description provided for @crHeader.
  ///
  /// In en, this message translates to:
  /// **'CR'**
  String get crHeader;

  /// No description provided for @avgHeader.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get avgHeader;

  /// No description provided for @gradeHeader.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get gradeHeader;

  /// No description provided for @gpHeader.
  ///
  /// In en, this message translates to:
  /// **'GP'**
  String get gpHeader;

  /// No description provided for @overallGpa.
  ///
  /// In en, this message translates to:
  /// **'Overall GPA'**
  String get overallGpa;

  /// No description provided for @totalCreditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCreditsLabel;

  /// No description provided for @storageOptimized.
  ///
  /// In en, this message translates to:
  /// **'Deep memory optimization complete! Device freed up.'**
  String get storageOptimized;

  /// No description provided for @smartStorageManagement.
  ///
  /// In en, this message translates to:
  /// **'Smart Storage Management'**
  String get smartStorageManagement;

  /// No description provided for @storageOptions.
  ///
  /// In en, this message translates to:
  /// **'Options to free up space on your device'**
  String get storageOptions;

  /// No description provided for @standardCleanup.
  ///
  /// In en, this message translates to:
  /// **'Standard Cleanup'**
  String get standardCleanup;

  /// No description provided for @standardCleanupDesc.
  ///
  /// In en, this message translates to:
  /// **'Deletes temporary files. ({size})'**
  String standardCleanupDesc(Object size);

  /// No description provided for @deepOptimization.
  ///
  /// In en, this message translates to:
  /// **'Deep Optimization'**
  String get deepOptimization;

  /// No description provided for @deepOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Clears image residuals and memory leaks, speeds up device.'**
  String get deepOptimizationDesc;

  /// No description provided for @optimizeStorage.
  ///
  /// In en, this message translates to:
  /// **'Optimize Storage'**
  String get optimizeStorage;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userName;

  /// No description provided for @guestUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUserLabel;

  /// No description provided for @signInToSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync data'**
  String get signInToSync;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID / Touch ID'**
  String get faceId;

  /// No description provided for @faceIdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID / Touch ID to unlock'**
  String get faceIdSubtitle;

  /// No description provided for @notAvailableOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get notAvailableOnDevice;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// No description provided for @encryptedBackupActive.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup active'**
  String get encryptedBackupActive;

  /// No description provided for @backupOffDefault.
  ///
  /// In en, this message translates to:
  /// **'Off (default)'**
  String get backupOffDefault;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountKvkk.
  ///
  /// In en, this message translates to:
  /// **'KVKK Article 7 - Right to Deletion'**
  String get deleteAccountKvkk;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Account deletion error: {error}'**
  String deleteAccountError(Object error);

  /// No description provided for @cookiePolicy.
  ///
  /// In en, this message translates to:
  /// **'Cookie Policy'**
  String get cookiePolicy;

  /// No description provided for @consentManagement.
  ///
  /// In en, this message translates to:
  /// **'Consent Management'**
  String get consentManagement;

  /// No description provided for @consentManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your explicit consent preferences under KVKK Article 5/1.'**
  String get consentManagementDesc;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Lesson Tracker v1.0.0'**
  String get appVersion;

  /// No description provided for @moodleTabCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get moodleTabCourses;

  /// No description provided for @moodleTabAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get moodleTabAssignments;

  /// No description provided for @moodleTabGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get moodleTabGrades;

  /// No description provided for @moodleTabAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get moodleTabAnnouncements;

  /// No description provided for @moodleTabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get moodleTabCalendar;

  /// No description provided for @moodleTabMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get moodleTabMessages;

  /// No description provided for @moodleTitle.
  ///
  /// In en, this message translates to:
  /// **'Moodle'**
  String get moodleTitle;

  /// No description provided for @moodleSummary.
  ///
  /// In en, this message translates to:
  /// **'{accounts} account · {courses} courses · {unread} unread'**
  String moodleSummary(Object accounts, Object courses, Object unread);

  /// No description provided for @moodleRefreshAll.
  ///
  /// In en, this message translates to:
  /// **'Refresh All'**
  String get moodleRefreshAll;

  /// No description provided for @moodleManageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get moodleManageAccounts;

  /// No description provided for @moodleAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get moodleAddAccount;

  /// No description provided for @moodleConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect Moodle'**
  String get moodleConnect;

  /// No description provided for @moodleConnectDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect to your university\'s Moodle system to sync courses, assignments, and grades.'**
  String get moodleConnectDesc;

  /// No description provided for @moodleFeatureAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments & Dates'**
  String get moodleFeatureAssignments;

  /// No description provided for @moodleFeatureGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get moodleFeatureGrades;

  /// No description provided for @moodleFeatureAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get moodleFeatureAnnouncements;

  /// No description provided for @moodleFeatureMultiAccount.
  ///
  /// In en, this message translates to:
  /// **'Multi-Account'**
  String get moodleFeatureMultiAccount;

  /// No description provided for @moodlePasswordNotStored.
  ///
  /// In en, this message translates to:
  /// **'Your password is never stored on your device'**
  String get moodlePasswordNotStored;

  /// No description provided for @moodleConnected.
  ///
  /// In en, this message translates to:
  /// **'Moodle account connected successfully!'**
  String get moodleConnected;

  /// No description provided for @moodleNoCourses.
  ///
  /// In en, this message translates to:
  /// **'No courses found'**
  String get moodleNoCourses;

  /// No description provided for @moodleSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing your Moodle account...'**
  String get moodleSyncing;

  /// No description provided for @moodleNoAssignments.
  ///
  /// In en, this message translates to:
  /// **'No pending assignments found'**
  String get moodleNoAssignments;

  /// No description provided for @moodleAllDone.
  ///
  /// In en, this message translates to:
  /// **'Great! Looks like everything is completed.'**
  String get moodleAllDone;

  /// No description provided for @moodleOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get moodleOverdue;

  /// No description provided for @moodleThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get moodleThisWeek;

  /// No description provided for @moodleUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get moodleUpcoming;

  /// No description provided for @moodleSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get moodleSubmitted;

  /// No description provided for @moodleLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get moodleLate;

  /// No description provided for @moodleDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today!'**
  String get moodleDueToday;

  /// No description provided for @moodleDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String moodleDaysLeft(Object days);

  /// No description provided for @moodleNoGrades.
  ///
  /// In en, this message translates to:
  /// **'No grades found'**
  String get moodleNoGrades;

  /// No description provided for @moodleNoAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements found'**
  String get moodleNoAnnouncements;

  /// No description provided for @moodleNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events on this day'**
  String get moodleNoEvents;

  /// No description provided for @moodleAllDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get moodleAllDay;

  /// No description provided for @moodleNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages found'**
  String get moodleNoMessages;

  /// No description provided for @moodleMessagesHere.
  ///
  /// In en, this message translates to:
  /// **'Your Moodle messages will appear here'**
  String get moodleMessagesHere;

  /// No description provided for @moodleAccountCourses.
  ///
  /// In en, this message translates to:
  /// **'{count} assignments'**
  String moodleAccountCourses(Object count);

  /// No description provided for @moodleAcademicSummary.
  ///
  /// In en, this message translates to:
  /// **'Academic Summary'**
  String get moodleAcademicSummary;

  /// No description provided for @moodleAvg.
  ///
  /// In en, this message translates to:
  /// **'Avg.'**
  String get moodleAvg;

  /// No description provided for @moodleThisWeekTasks.
  ///
  /// In en, this message translates to:
  /// **'This week tasks'**
  String get moodleThisWeekTasks;

  /// No description provided for @moodleOverdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get moodleOverdueTasks;

  /// No description provided for @moodleCourseCount.
  ///
  /// In en, this message translates to:
  /// **'Course count'**
  String get moodleCourseCount;

  /// No description provided for @moodleBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get moodleBest;

  /// No description provided for @moodleWorst.
  ///
  /// In en, this message translates to:
  /// **'Worst'**
  String get moodleWorst;

  /// No description provided for @moodleSelectUniversity.
  ///
  /// In en, this message translates to:
  /// **'Select Your University'**
  String get moodleSelectUniversity;

  /// No description provided for @moodleSelectUniversityDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your university to connect your Moodle account'**
  String get moodleSelectUniversityDesc;

  /// No description provided for @moodleSearchUniversity.
  ///
  /// In en, this message translates to:
  /// **'Search university...'**
  String get moodleSearchUniversity;

  /// No description provided for @moodleManualUrl.
  ///
  /// In en, this message translates to:
  /// **'Manual URL Entry'**
  String get moodleManualUrl;

  /// No description provided for @moodleManualUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'For universities not in the list'**
  String get moodleManualUrlDesc;

  /// No description provided for @moodleBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get moodleBack;

  /// No description provided for @moodleUrl.
  ///
  /// In en, this message translates to:
  /// **'Moodle URL'**
  String get moodleUrl;

  /// No description provided for @moodleUrlHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. moodle.university.edu.tr'**
  String get moodleUrlHint;

  /// No description provided for @moodleUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get moodleUrlRequired;

  /// No description provided for @moodleLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get moodleLogin;

  /// No description provided for @moodleUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get moodleUsername;

  /// No description provided for @moodleUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get moodleUsernameRequired;

  /// No description provided for @moodlePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get moodlePassword;

  /// No description provided for @moodlePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get moodlePasswordRequired;

  /// No description provided for @moodlePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password is never stored on your device.'**
  String get moodlePasswordHint;

  /// No description provided for @moodleConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get moodleConnectButton;

  /// No description provided for @moodleConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Moodle...'**
  String get moodleConnecting;

  /// No description provided for @moodleConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get moodleConnectionFailed;

  /// No description provided for @moodleTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get moodleTryAgain;

  /// No description provided for @moodleConnectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection Successful!'**
  String get moodleConnectionSuccess;

  /// No description provided for @moodleGreat.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get moodleGreat;

  /// No description provided for @moodleAccountsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get moodleAccountsManage;

  /// No description provided for @moodleAccountAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Moodle Account'**
  String get moodleAccountAdd;

  /// No description provided for @moodleNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No connected accounts'**
  String get moodleNoAccounts;

  /// No description provided for @moodleNoAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your Moodle account using the button below.'**
  String get moodleNoAccountsDesc;

  /// No description provided for @moodleLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get moodleLogout;

  /// No description provided for @moodleLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of {account}?'**
  String moodleLogoutConfirm(Object account);

  /// No description provided for @moodleLogoutDone.
  ///
  /// In en, this message translates to:
  /// **'Logged out from {account}'**
  String moodleLogoutDone(Object account);

  /// No description provided for @moodleContentLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading course content...'**
  String get moodleContentLoading;

  /// No description provided for @moodleContentError.
  ///
  /// In en, this message translates to:
  /// **'Could not load content: {error}'**
  String moodleContentError(Object error);

  /// No description provided for @moodleContentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Content not found'**
  String get moodleContentNotFound;

  /// No description provided for @moodleDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed or file too large.'**
  String get moodleDownloadFailed;

  /// No description provided for @moodleTransferToCourse.
  ///
  /// In en, this message translates to:
  /// **'Transfer to My Courses'**
  String get moodleTransferToCourse;

  /// No description provided for @moodleTransferDesc.
  ///
  /// In en, this message translates to:
  /// **'Save this file to one of your courses in the app.'**
  String get moodleTransferDesc;

  /// No description provided for @moodleSelectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get moodleSelectCourse;

  /// No description provided for @moodleNoLocalCourses.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any courses yet.'**
  String get moodleNoLocalCourses;

  /// No description provided for @moodleSavedToCourse.
  ///
  /// In en, this message translates to:
  /// **'File saved to \"{course}\" successfully!'**
  String moodleSavedToCourse(Object course);

  /// No description provided for @moodleSaveError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the file.'**
  String get moodleSaveError;

  /// No description provided for @moodleTokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Token not found — reconnect your account'**
  String get moodleTokenNotFound;

  /// No description provided for @moodleAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get moodleAccountNotFound;

  /// No description provided for @veliConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Parental Consent'**
  String get veliConsentTitle;

  /// No description provided for @veliConsentDesc.
  ///
  /// In en, this message translates to:
  /// **'Users under 18 need parental consent to use the app.'**
  String get veliConsentDesc;

  /// No description provided for @veliEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent Email Address'**
  String get veliEmailLabel;

  /// No description provided for @veliEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter parent\'s email address'**
  String get veliEmailHint;

  /// No description provided for @veliConfirmCheck.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am a parent and I allow my child to use this app.'**
  String get veliConfirmCheck;

  /// No description provided for @veliKvkkCheck.
  ///
  /// In en, this message translates to:
  /// **'I provide parental consent under KVKK Law No. 6698.'**
  String get veliKvkkCheck;

  /// No description provided for @veliCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to {email}.'**
  String veliCodeSent(Object email);

  /// No description provided for @veliEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code'**
  String get veliEnterCode;

  /// No description provided for @veliVerifyAndApprove.
  ///
  /// In en, this message translates to:
  /// **'Verify & Approve'**
  String get veliVerifyAndApprove;

  /// No description provided for @veliResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get veliResendCode;

  /// No description provided for @veliChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get veliChangeEmail;

  /// No description provided for @veliSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get veliSendCode;

  /// No description provided for @veliCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get veliCancel;

  /// No description provided for @veliRequired.
  ///
  /// In en, this message translates to:
  /// **'Parental consent is required'**
  String get veliRequired;

  /// No description provided for @veliValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get veliValidEmail;

  /// No description provided for @veliCheckConsent.
  ///
  /// In en, this message translates to:
  /// **'Please check the parental consent box'**
  String get veliCheckConsent;

  /// No description provided for @veliCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get veliCodeRequired;

  /// No description provided for @veliSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Verification session not found. Please try again.'**
  String get veliSessionNotFound;

  /// No description provided for @veliCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code expired. Please request a new one.'**
  String get veliCodeExpired;

  /// No description provided for @veliWrongCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong verification code.'**
  String get veliWrongCode;

  /// No description provided for @veliInfoText.
  ///
  /// In en, this message translates to:
  /// **'The parent email will only be used to send the consent notification.'**
  String get veliInfoText;

  /// No description provided for @veliRequestConsent.
  ///
  /// In en, this message translates to:
  /// **'Request Consent'**
  String get veliRequestConsent;

  /// No description provided for @veliEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get veliEmailVerification;

  /// No description provided for @veliStepVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get veliStepVerification;

  /// No description provided for @veliStepConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get veliStepConsent;

  /// No description provided for @kvkkFlowReset.
  ///
  /// In en, this message translates to:
  /// **'KVKK consent reset — restart the app'**
  String get kvkkFlowReset;

  /// No description provided for @kvkkReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get kvkkReset;

  /// No description provided for @kvkkSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get kvkkSkip;

  /// No description provided for @consentManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent Management'**
  String get consentManagementTitle;

  /// No description provided for @consentManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Explicit Consent Preferences'**
  String get consentManagementSubtitle;

  /// No description provided for @consentWithdrawInfo.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your consent at any time. Withdrawal does not affect the lawfulness of processing based on consent before its withdrawal.'**
  String get consentWithdrawInfo;

  /// No description provided for @consentCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera Photo Capture'**
  String get consentCamera;

  /// No description provided for @consentAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio Recording'**
  String get consentAudio;

  /// No description provided for @consentOcr.
  ///
  /// In en, this message translates to:
  /// **'OCR Text Recognition'**
  String get consentOcr;

  /// No description provided for @consentPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get consentPush;

  /// No description provided for @consentCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup (Optional)'**
  String get consentCloud;

  /// No description provided for @consentLegalInfo.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get consentLegalInfo;

  /// No description provided for @consentLegalDesc.
  ///
  /// In en, this message translates to:
  /// **'Under KVKK Law No. 6698, you can manage your explicit consent preferences here.'**
  String get consentLegalDesc;

  /// No description provided for @consentCameraDesc.
  ///
  /// In en, this message translates to:
  /// **'Take photos and scan documents'**
  String get consentCameraDesc;

  /// No description provided for @consentAudioDesc.
  ///
  /// In en, this message translates to:
  /// **'Record audio notes in lessons'**
  String get consentAudioDesc;

  /// No description provided for @consentOcrDesc.
  ///
  /// In en, this message translates to:
  /// **'Extract text from images and PDFs'**
  String get consentOcrDesc;

  /// No description provided for @consentPushDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive deadline and course notifications'**
  String get consentPushDesc;

  /// No description provided for @consentCloudDesc.
  ///
  /// In en, this message translates to:
  /// **'Back up your data to the cloud securely'**
  String get consentCloudDesc;

  /// No description provided for @moodleSyncEnabled.
  ///
  /// In en, this message translates to:
  /// **'Moodle background sync enabled!'**
  String get moodleSyncEnabled;

  /// No description provided for @moodleSyncDisabled.
  ///
  /// In en, this message translates to:
  /// **'Moodle background sync disabled!'**
  String get moodleSyncDisabled;

  /// No description provided for @moodleBackgroundSync.
  ///
  /// In en, this message translates to:
  /// **'Moodle Background Sync'**
  String get moodleBackgroundSync;

  /// No description provided for @moodleSyncNotifications.
  ///
  /// In en, this message translates to:
  /// **'New assignments, grades and announcements will be notified'**
  String get moodleSyncNotifications;

  /// No description provided for @moodleSyncOff.
  ///
  /// In en, this message translates to:
  /// **'Off — manual refresh required'**
  String get moodleSyncOff;

  /// No description provided for @smartAttendanceSetLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Set your school location first to enable smart attendance.'**
  String get smartAttendanceSetLocationFirst;

  /// No description provided for @smartAttendanceEnabled.
  ///
  /// In en, this message translates to:
  /// **'Smart attendance enabled! Will work in background.'**
  String get smartAttendanceEnabled;

  /// No description provided for @smartAttendanceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Smart attendance disabled.'**
  String get smartAttendanceDisabled;

  /// No description provided for @smartAttendanceSchoolLocation.
  ///
  /// In en, this message translates to:
  /// **'School Location'**
  String get smartAttendanceSchoolLocation;

  /// No description provided for @smartAttendanceLocationSet.
  ///
  /// In en, this message translates to:
  /// **'Location Set'**
  String get smartAttendanceLocationSet;

  /// No description provided for @smartAttendanceLocationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get smartAttendanceLocationNotSet;

  /// No description provided for @smartAttendanceCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Your current school location is saved.'**
  String get smartAttendanceCurrentLocation;

  /// No description provided for @smartAttendanceSetLocationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save your current location as \"University Location\"?'**
  String get smartAttendanceSetLocationPrompt;

  /// No description provided for @smartAttendanceCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get smartAttendanceCancel;

  /// No description provided for @smartAttendanceGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get smartAttendanceGettingLocation;

  /// No description provided for @smartAttendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'School location saved!'**
  String get smartAttendanceSaved;

  /// No description provided for @smartAttendanceLocationError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location. Check location permissions.'**
  String get smartAttendanceLocationError;

  /// No description provided for @smartAttendanceUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get smartAttendanceUpdate;

  /// No description provided for @smartAttendanceYesImAtSchool.
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m at School'**
  String get smartAttendanceYesImAtSchool;

  /// No description provided for @smartAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Attendance'**
  String get smartAttendanceTitle;

  /// No description provided for @smartAttendanceActive.
  ///
  /// In en, this message translates to:
  /// **'Active — Absence not counted if you are at school during class'**
  String get smartAttendanceActive;

  /// No description provided for @smartAttendanceOff.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get smartAttendanceOff;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'About to Delete\nYour Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteAccountIrreversible;

  /// No description provided for @deleteAccountDataToDelete.
  ///
  /// In en, this message translates to:
  /// **'Data to be deleted:'**
  String get deleteAccountDataToDelete;

  /// No description provided for @deleteAccountNotes.
  ///
  /// In en, this message translates to:
  /// **'All course notes'**
  String get deleteAccountNotes;

  /// No description provided for @deleteAccountAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio recordings'**
  String get deleteAccountAudio;

  /// No description provided for @deleteAccountPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos and OCR data'**
  String get deleteAccountPhotos;

  /// No description provided for @deleteAccountAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance and grade records'**
  String get deleteAccountAttendance;

  /// No description provided for @deleteAccountSessions.
  ///
  /// In en, this message translates to:
  /// **'Study sessions'**
  String get deleteAccountSessions;

  /// No description provided for @deleteAccountMoodle.
  ///
  /// In en, this message translates to:
  /// **'Moodle account connections'**
  String get deleteAccountMoodle;

  /// No description provided for @deleteAccountFirebase.
  ///
  /// In en, this message translates to:
  /// **'Firebase account'**
  String get deleteAccountFirebase;

  /// No description provided for @deleteAccountRetention.
  ///
  /// In en, this message translates to:
  /// **'Your data will be permanently deleted within 30 days.'**
  String get deleteAccountRetention;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I want to delete my account.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteAccountCancel;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccountAction;

  /// No description provided for @aydinlatmaTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclosure Text'**
  String get aydinlatmaTitle;

  /// No description provided for @aydinlatmaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Information under KVKK Law No. 6698 Article 10'**
  String get aydinlatmaSubtitle;

  /// No description provided for @aydinlatmaSection1.
  ///
  /// In en, this message translates to:
  /// **'1. Data Controller'**
  String get aydinlatmaSection1;

  /// No description provided for @aydinlatmaControllerInfo.
  ///
  /// In en, this message translates to:
  /// **'LessonTracker\nEmail: lessontracker@example.com'**
  String get aydinlatmaControllerInfo;

  /// No description provided for @aydinlatmaSection2.
  ///
  /// In en, this message translates to:
  /// **'2. Personal Data Processed'**
  String get aydinlatmaSection2;

  /// No description provided for @aydinlatmaSection3.
  ///
  /// In en, this message translates to:
  /// **'3. Purposes of Data Processing'**
  String get aydinlatmaSection3;

  /// No description provided for @aydinlatmaSection4.
  ///
  /// In en, this message translates to:
  /// **'4. Transfer of Personal Data'**
  String get aydinlatmaSection4;

  /// No description provided for @aydinlatmaSection5.
  ///
  /// In en, this message translates to:
  /// **'5. Retention Period'**
  String get aydinlatmaSection5;

  /// No description provided for @aydinlatmaSection6.
  ///
  /// In en, this message translates to:
  /// **'6. Data Security'**
  String get aydinlatmaSection6;

  /// No description provided for @aydinlatmaSection7.
  ///
  /// In en, this message translates to:
  /// **'7. Your Rights (KVKK Article 11)'**
  String get aydinlatmaSection7;

  /// No description provided for @aydinlatmaSection8.
  ///
  /// In en, this message translates to:
  /// **'8. Further Information'**
  String get aydinlatmaSection8;

  /// No description provided for @aydinlatmaConfirm.
  ///
  /// In en, this message translates to:
  /// **'I have read the disclosure text and have been informed.'**
  String get aydinlatmaConfirm;

  /// No description provided for @aydinlatmaContinue.
  ///
  /// In en, this message translates to:
  /// **'I Understand, Continue'**
  String get aydinlatmaContinue;

  /// No description provided for @acikRizaTitle.
  ///
  /// In en, this message translates to:
  /// **'Explicit Consent'**
  String get acikRizaTitle;

  /// No description provided for @acikRizaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your explicit consent is legally required for the following actions (KVKK Article 5/1 and 6/2)'**
  String get acikRizaSubtitle;

  /// No description provided for @acikRizaImportant.
  ///
  /// In en, this message translates to:
  /// **'Important Information'**
  String get acikRizaImportant;

  /// No description provided for @acikRizaVoluntary.
  ///
  /// In en, this message translates to:
  /// **'Giving explicit consent is completely voluntary. You can skip consent and use the app in limited mode. You can change your preferences later in Settings.'**
  String get acikRizaVoluntary;

  /// No description provided for @acikRizaGiveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Give Consent & Continue'**
  String get acikRizaGiveAndContinue;

  /// No description provided for @acikRizaSkip.
  ///
  /// In en, this message translates to:
  /// **'Continue Without Consent'**
  String get acikRizaSkip;

  /// No description provided for @acikRizaWarning.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get acikRizaWarning;

  /// No description provided for @acikRizaFeaturesDisabled.
  ///
  /// In en, this message translates to:
  /// **'If you continue without consent, the following features will not be available:'**
  String get acikRizaFeaturesDisabled;

  /// No description provided for @acikRizaFeatureCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera photo capture'**
  String get acikRizaFeatureCamera;

  /// No description provided for @acikRizaFeatureAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio recording'**
  String get acikRizaFeatureAudio;

  /// No description provided for @acikRizaFeatureOcr.
  ///
  /// In en, this message translates to:
  /// **'OCR text recognition'**
  String get acikRizaFeatureOcr;

  /// No description provided for @acikRizaSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'You can change these preferences later in Settings.'**
  String get acikRizaSettingsNote;

  /// No description provided for @acikRizaCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get acikRizaCancel;

  /// No description provided for @acikRizaLimitedMode.
  ///
  /// In en, this message translates to:
  /// **'Continue in Limited Mode'**
  String get acikRizaLimitedMode;
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
