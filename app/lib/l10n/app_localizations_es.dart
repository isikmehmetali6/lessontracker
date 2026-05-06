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
  String get noNotesDescription => '¡Usa las herramientas de abajo para capturar tu primera nota!';

  @override
  String get goodMorning => 'Buenos Días,';

  @override
  String get goodAfternoon => 'Buenas Tardes,';

  @override
  String get goodEvening => 'Buenas Noches,';

  @override
  String get weeklySchedule => 'Horario';

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
  String get totalCourses => 'Cursos';

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
  String get average => 'Prom.';

  @override
  String get improvementNeeded => 'Necesita Mejora';

  @override
  String get gradesTab => 'Calificaciones';

  @override
  String get filesTab => 'Archivos';

  @override
  String get notesTab => 'Notas';

  @override
  String get addGrade => 'Añadir Calificación';

  @override
  String get noGradesYet => 'Aún no hay calificaciones';

  @override
  String get noFilesYet => 'Aún no hay archivos';

  @override
  String get uploadFile => 'Subir Archivo';

  @override
  String get addFile => 'Añadir Archivo';

  @override
  String nextExamIn(int days) {
    return 'Próximo examen en $days días';
  }

  @override
  String get semesterDefault => 'Semestre de Primavera';

  @override
  String get noProfessor => 'Sin Profesor';

  @override
  String get weight => 'Peso';

  @override
  String get averageShort => 'Prom.';

  @override
  String get searchHint => 'Buscar notas, etiquetas (#examen)...';

  @override
  String get noResults => 'No se encontraron notas coincidentes';

  @override
  String get searchStartPrompt => 'Buscar por título, contenido o etiquetas';

  @override
  String get deadlinesHeader => 'Plazos';

  @override
  String get deadlinesSubtitle => 'Mantente al día con tus tareas';

  @override
  String get noUpcomingDeadlines => 'No hay plazos próximos';

  @override
  String get addFirstDeadline => 'Añade tu primer plazo';

  @override
  String get deadlineOverdue => 'Vencido';

  @override
  String get deadlineToday => 'Hoy';

  @override
  String daysLeft(int days) {
    return '$days días restantes';
  }

  @override
  String get addDeadlineTitle => 'Añadir Plazo';

  @override
  String get editDeadline => 'Editar Plazo';

  @override
  String get updateDeadline => 'Actualizar Plazo';

  @override
  String get fillAllFields => 'Por favor, completa todos los campos obligatorios';

  @override
  String get titleHint => 'Título (ej. Parcial, Proyecto)';

  @override
  String get selectCourse => 'Seleccionar Curso';

  @override
  String get noCoursesAvailable => 'No hay cursos disponibles. Añade un curso primero.';

  @override
  String get addToCalendar => 'Añadir al Calendario';

  @override
  String get saveToDeviceCalendar => 'Guardar en el calendario del dispositivo';

  @override
  String get assignmentNameHint => 'Nombre de la tarea (ej. Parcial)';

  @override
  String get score => 'Puntuación';

  @override
  String get max => 'Máx.';

  @override
  String get weightPercent => 'Peso (%)';

  @override
  String get saveGrade => 'Guardar Calificación';

  @override
  String get addNoteToImage => 'Añadir Nota a la Imagen';

  @override
  String get titleOptional => 'Título (Opcional)';

  @override
  String get imageContentHint => 'Escribe algo sobre esta imagen...';

  @override
  String get tagsHint => 'Etiquetas (ej. #examen, #historia)';

  @override
  String get absenceHistory => 'Historial de Ausencias';

  @override
  String get noAbsenceHistory => 'Aún no hay historial de ausencias.';

  @override
  String get welcomeToClass => '¡Bienvenido a clase! 🎓';

  @override
  String get youAreInArea => 'Estás en la ubicación de la clase.';

  @override
  String get syncDescription => 'Haz una copia de seguridad de tus datos en la nube o restáuralos en este dispositivo.';

  @override
  String get processing => 'Procesando...';

  @override
  String get backupData => 'Copia de Seguridad';

  @override
  String get backupDescription => 'Subir datos locales a la nube';

  @override
  String get restoreData => 'Restaurar Datos';

  @override
  String get restoreDescription => 'Descargar de la nube (Reemplaza los datos locales)';

  @override
  String get confirmRestore => 'Confirmar Restauración';

  @override
  String get restoreWarning => 'Esto sobrescribirá algunos datos locales con datos de la nube. ¿Continuar?';

  @override
  String get restoreAction => 'Restaurar';

  @override
  String get save => 'Guardar';

  @override
  String get attendanceStatus => 'Estado de Asistencia';

  @override
  String get perfectAttendance => '¡Asistencia perfecta! ¡Sigue así!';

  @override
  String absences(int current, int limit) {
    return '$current / $limit Ausencias';
  }

  @override
  String get riskLabel => 'RIESGO';

  @override
  String get todaySchedule => 'Horario de Hoy';

  @override
  String get noClassesToday => 'No hay clases hoy — ¡disfruta tu tiempo libre! 🎉';

  @override
  String get guestUser => 'Invitado';

  @override
  String get searchPlaceholder => 'Buscar materias, notas o etiquetas...';

  @override
  String get noCourses => 'Aún no hay cursos';

  @override
  String get addYourFirstCourse => '¡Toca + para añadir tu primer curso y empezar a organizarte!';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get name => 'Nombre';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get currentPassword => 'Contraseña Actual';

  @override
  String get newPassword => 'Nueva Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordTooShort => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get profileUpdated => 'Perfil actualizado correctamente';

  @override
  String get emailVerificationSent => 'Correo de verificación enviado a la nueva dirección';

  @override
  String get passwordChanged => 'Contraseña cambiada correctamente';

  @override
  String get faqTitle => 'Preguntas Frecuentes';

  @override
  String get faqQ1 => '¿Cómo añado un nuevo curso?';

  @override
  String get faqA1 => 'Toca el botón + en la pantalla de inicio y completa los detalles del curso, incluyendo nombre, horario e información del profesor.';

  @override
  String get faqQ2 => '¿Cómo registro mis ausencias?';

  @override
  String get faqA2 => 'Abre cualquier curso y usa el contador de ausencias para añadir o eliminar ausencias. Recibirás una alerta cuando te acerques al límite.';

  @override
  String get faqQ3 => '¿Puedo hacer una copia de seguridad de mis datos?';

  @override
  String get faqA3 => '¡Sí! Ve a Ajustes > Sincronización y Copia para subir tus datos a la nube. Necesitas iniciar sesión para usar esta función.';

  @override
  String get faqQ4 => '¿Cómo grabo una nota de voz?';

  @override
  String get faqA4 => 'Abre un curso, toca el botón + y selecciona el icono del micrófono para empezar a grabar una nota de voz.';

  @override
  String get faqQ5 => '¿Cómo cambio el idioma de la aplicación?';

  @override
  String get faqA5 => 'Ve a Ajustes y toca en Idioma. Puedes elegir entre inglés, turco, español y alemán.';

  @override
  String get contactUs => 'Contáctanos';

  @override
  String get emailSupport => 'Soporte por Correo';

  @override
  String get reportBug => 'Reportar un Error';

  @override
  String get reportBugDescription => '¿Encontraste algo roto? Avísanos';

  @override
  String get featureRequest => 'Solicitar Función';

  @override
  String get featureRequestDescription => 'Sugiere una nueva función';

  @override
  String get aboutApp => 'Acerca de';

  @override
  String get aboutDescription => 'Rastreador de Lecciones ayuda a los estudiantes a organizar sus cursos, controlar la asistencia, tomar notas y cumplir con los plazos. Desarrollado con dedicación para estudiantes de todo el mundo.';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get totalStorageUsed => 'Almacenamiento Total Usado';

  @override
  String get storageBreakdown => 'Desglose del Almacenamiento';

  @override
  String get database => 'Base de Datos';

  @override
  String get mediaFiles => 'Archivos Multimedia';

  @override
  String get cache => 'Caché';

  @override
  String get dataStats => 'Estadísticas de Datos';

  @override
  String get clearCache => 'Limpiar Caché';

  @override
  String get clearCacheConfirmation => 'Esto eliminará los archivos temporales. Tus datos no se verán afectados. ¿Continuar?';

  @override
  String get cacheCleared => '¡Caché limpiada correctamente!';

  @override
  String get signOutConfirmation => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get lastBackup => 'Última copia de seguridad';

  @override
  String get never => 'Nunca';

  @override
  String get loginRequiredForSync => 'Inicia sesión para usar las funciones de sincronización y copia de seguridad';

  @override
  String get autoSync => 'Sincronización Automática';

  @override
  String get tapToEdit => 'Toca para editar el perfil';

  @override
  String get studyTimer => 'Temporizador de Estudio';

  @override
  String get focusTime => 'Tiempo de Enfoque';

  @override
  String get breakTime => 'Tiempo de Descanso';

  @override
  String get session => 'Sesión';

  @override
  String get sessionComplete => '¡Buen trabajo! Sesión completada 🎉';

  @override
  String get breakComplete => '¡Descanso terminado! ¿Listo para concentrarte?';

  @override
  String get studyingFor => 'Estudiando para';

  @override
  String get noCourseSelected => 'Ningún curso seleccionado';

  @override
  String get timerPresets => 'Duraciones Predefinidas';

  @override
  String get short => 'Corta';

  @override
  String get classic => 'Clásica';

  @override
  String get long => 'Larga';

  @override
  String get marathon => 'Maratón';

  @override
  String get completedSessions => 'Sesiones completadas';

  @override
  String get gpaCalculator => 'Calculadora de GPA';

  @override
  String get overallGPA => 'GPA General';

  @override
  String get totalCredits => 'Créditos';

  @override
  String get letterGrade => 'Calificación';

  @override
  String get gpaScale => 'Escala de GPA';

  @override
  String get courseBreakdown => 'Desglose por Curso';

  @override
  String get credits => 'créditos';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get studyTimerDesc => 'Temporizador Pomodoro';

  @override
  String get gpaCalcDesc => 'Calculadora de GPA';

  @override
  String get absenceCalendar => 'Calendario de Ausencias';

  @override
  String get viewAbsenceCalendar => 'Ver Calendario de Ausencias';

  @override
  String get noAbsencesOnDay => 'Sin ausencias en este día';

  @override
  String get unexcused => 'Sin justificación';

  @override
  String get medical => 'Médica';

  @override
  String get excused => 'Justificada';

  @override
  String get personal => 'Personal';

  @override
  String absencePredictionWarning(String weeks) {
    return 'A este ritmo, superarás el límite en $weeks semanas';
  }

  @override
  String get professorDetails => 'Detalles del Profesor';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get officeRoom => 'Oficina';

  @override
  String get officeHoursLabel => 'Horario de Oficina';

  @override
  String get teachingAssistant => 'Asistente de Enseñanza';

  @override
  String get emailCopied => 'Correo copiado';

  @override
  String get phoneCopied => 'Teléfono copiado';

  @override
  String get addLink => 'Agregar Enlace';

  @override
  String get linkName => 'Nombre del Enlace';

  @override
  String get linkAdded => 'Enlace agregado';

  @override
  String get webLink => 'Enlace Web';

  @override
  String get templateCornellNotes => 'Notas Cornell';

  @override
  String get templateLectureSummary => 'Resumen de Clase';

  @override
  String get templateExamNotes => 'Notas de Examen';

  @override
  String get startFromTemplate => 'Iniciar desde Plantilla';

  @override
  String get transcript => 'Expediente Académico';

  @override
  String get inProgress => 'En Curso';

  @override
  String get semesterReport => 'Informe del Semestre';

  @override
  String get generatePdfReport => 'Generar informe PDF';

  @override
  String get exportDataCsv => 'Exportar Datos (CSV)';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get gradesCsv => 'Calificaciones (CSV)';

  @override
  String get absencesCsv => 'Ausencias (CSV)';

  @override
  String get studySessionsCsv => 'Sesiones de Estudio (CSV)';

  @override
  String get selectAbsenceReason => 'Seleccionar razón de ausencia';

  @override
  String get editCourse => 'Editar Curso';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get setLocationGeofence => 'Establecer Ubicación (Geofence)';

  @override
  String get absenceUnexcused => 'Sin justificación';

  @override
  String get absenceMedical => 'Médica';

  @override
  String get absenceExcused => 'Justificada';

  @override
  String get absencePersonal => 'Personal';

  @override
  String get absenceOverview => 'Resumen de Asistencia';

  @override
  String get absencesUsed => 'ausencias utilizadas';

  @override
  String get totalAbsences => 'ausencias totales';

  @override
  String get editAbsence => 'Editar Ausencia';

  @override
  String get deleteAbsence => 'Eliminar Ausencia';

  @override
  String get selectReason => 'Seleccionar motivo:';

  @override
  String get convertToPdf => 'Convertir a PDF';

  @override
  String get allNotesToPdf => 'Todas las Notas → PDF';

  @override
  String get photosToPdf => 'Fotos → PDF';

  @override
  String get courseReportPdf => 'Informe del Curso → PDF';

  @override
  String get appLock => 'Bloqueo de App';

  @override
  String get appLockDisabled => 'Desactivado';

  @override
  String get appLockAuthReason => 'Autentícate para activar el bloqueo de la app';

  @override
  String get shareNotes => 'Ver Notas';

  @override
  String get archiveCourse => 'Archivar Curso';
}
