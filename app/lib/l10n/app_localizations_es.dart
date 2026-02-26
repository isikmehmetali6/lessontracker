// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Rastreador de Lecciones';

  @override
  String get homeParams => 'Inicio';

  @override
  String get planParams => 'Plan';

  @override
  String get statsParams => 'Estadísticas';

  @override
  String get settingsParams => 'Ajustes';

  @override
  String get priorityFocus => 'Enfoque Prioritario';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get quickCapture => 'Captura Rápida';

  @override
  String get recentNotes => 'Notas Recientes';

  @override
  String get noNotesYet => 'No hay notas aún. ¡Empieza a capturar!';

  @override
  String get goodMorning => 'Buenos Días,';

  @override
  String get goodAfternoon => 'Buenas Tardes,';

  @override
  String get goodEvening => 'Buenas Noches,';

  @override
  String get weeklySchedule => 'Horario Semanal';

  @override
  String get todaysClasses => 'Clases de Hoy';

  @override
  String get noClassesScheduled => 'No hay clases programadas';

  @override
  String get addCourseToSeeSchedule => 'Añade un curso para ver tu horario';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get trackYourProgress => 'Sigue tu progreso de aprendizaje';

  @override
  String get addNewCourse => 'Añadir Nuevo Curso';

  @override
  String get courseName => 'Nombre del Curso';

  @override
  String get courseNameHint => 'ej. Matemáticas';

  @override
  String get classSchedule => 'Horario de Clases';

  @override
  String get addTimeSlot => 'Añadir Franja Horaria';

  @override
  String get classroomLocation => 'Aula / Ubicación';

  @override
  String get classroomHint => 'ej. Sala de Ciencias 304';

  @override
  String get professorOptional => 'Profesor (Opcional)';

  @override
  String get professorHint => 'ej. Dr. García';

  @override
  String get absenceLimit => 'Límite de Ausencias';

  @override
  String get maxAllowedPerSemester => 'Máx. permitido por semestre';

  @override
  String get cardColor => 'Color de la Tarjeta';

  @override
  String get createCourse => 'Crear Curso';

  @override
  String get pleaseEnterCourseName => 'Por favor, introduce un nombre para el curso';

  @override
  String get pleaseAddClassTime => 'Por favor, añade al menos una hora de clase';

  @override
  String get failedToCreateSchedule => 'Error al crear algunos elementos del horario';

  @override
  String get courseProgress => 'Progreso del Curso';

  @override
  String get lessonMaterials => 'Materiales de la Lección';

  @override
  String get newNote => 'Nueva Nota';

  @override
  String get title => 'Título';

  @override
  String get writeYourNote => 'Escribe tu nota...';

  @override
  String get saveNote => 'Guardar Nota';

  @override
  String get deleteCourse => 'Eliminar Curso';

  @override
  String get deleteCourseConfirmation => 'Esto eliminará todas las notas asociadas con este curso.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get microphone => 'Micrófono';

  @override
  String get keyboard => 'Teclado';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get noClassTimesAdded => 'No se han añadido horas de clase todavía.';

  @override
  String get voiceMemo => 'Nota de Voz';

  @override
  String get notesHeader => 'Notas';

  @override
  String get deleteNoteTitle => '¿Eliminar Nota?';

  @override
  String get thisActionCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get totalCourses => 'Cursos Totales';

  @override
  String get totalNotes => 'Notas Totales';

  @override
  String get avgProgress => 'Progreso Prom.';

  @override
  String get studyStreak => 'Racha de Estudio';

  @override
  String get activeCourses => 'Cursos activos';

  @override
  String get notesCaptured => 'Notas capturadas';

  @override
  String get overallProgress => 'Progreso general';

  @override
  String get daysInRow => 'Días seguidos';

  @override
  String get weeklyGoal => 'Meta Semanal';

  @override
  String get syncBackup => 'Sincronización y Copia';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get helpSupport => 'Ayuda y Soporte';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get settingsHeader => 'Ajustes';

  @override
  String get settingsSubHeader => 'Personaliza tu experiencia';

  @override
  String get profileName => 'Alex Estudiante';

  @override
  String get profileEmail => 'alex@universidad.edu.es';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get weeklyGoalSub => '5/7 días';

  @override
  String get courseAbsence => 'Ausencia';

  @override
  String get remainingAbsences => 'restantes';

  @override
  String get addAbsence => 'Añadir Ausencia';

  @override
  String get removeAbsence => 'Eliminar Ausencia';

  @override
  String absenceLimitExceeded(Object excess) {
    return '¡Límite excedido! ($excess más)';
  }

  @override
  String get noAbsenceRightsLeft => '¡No quedan derechos!';

  @override
  String absenceRightsLeft(Object count) {
    return '$count derechos quedan';
  }

  @override
  String get absenceLabel => 'Ausencia';

  @override
  String get remainingLabel => 'Restante';

  @override
  String get viewHistory => 'Ver historial';

  @override
  String get gpa => 'GPA';

  @override
  String get academicStanding => 'Nivel Académico';

  @override
  String get atRisk => 'Riesgo de Asistencia';

  @override
  String get coursePerformance => 'Rendimiento del Curso';

  @override
  String get recentGrades => 'Notas Recientes';

  @override
  String get noGradesData => 'No hay datos de notas.';

  @override
  String get excellent => 'Excelente';

  @override
  String get good => 'Bueno';

  @override
  String get average => 'Promedio';

  @override
  String get improvementNeeded => 'Necesita Mejora';

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
