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
  String get addAbsenceAction => 'Agregar ausencia';

  @override
  String get removeAbsenceAction => 'Eliminar última ausencia';

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
  String get gradesTab => 'Calificaciones';

  @override
  String get filesTab => 'Archivos';

  @override
  String get notesTab => 'Notas';

  @override
  String get addGrade => 'Añadir Calificación';

  @override
  String get noGradesYet => 'Aún no hay calificaciones.';

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
  String get gpaCourses => 'Cursos';

  @override
  String get letterGrade => 'Calificación';

  @override
  String get gpaScale => 'Escala de GPA';

  @override
  String get courseBreakdown => 'Desglose por Curso';

  @override
  String get credits => 'créditos';

  @override
  String get gpaNoGrades => 'Aún no hay calificaciones';

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

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar tu aprendizaje.';

  @override
  String get emailAddress => 'Correo Electrónico';

  @override
  String get emailRequired => 'Por favor, introduce tu correo electrónico';

  @override
  String get validEmailRequired => 'Por favor, introduce un correo electrónico válido';

  @override
  String get passwordRequired => 'Por favor, introduce tu contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get logIn => 'Iniciar Sesión';

  @override
  String get orDivider => 'O';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get signUp => 'Registrarse';

  @override
  String get continueAsGuest => 'Continuar como Invitado';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get resetPasswordDescription => 'Introduce tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get sendLink => 'Enviar Enlace';

  @override
  String get passwordResetSent => '¡Correo de restablecimiento enviado! Revisa tu bandeja de entrada.';

  @override
  String get guestDescription => 'Tus datos se almacenarán localmente en este dispositivo y no se sincronizarán con la nube. Puedes crear una cuenta más tarde para hacer una copia de seguridad.';

  @override
  String get continueAction => 'Continuar';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get signupSubtitle => 'Únete para seguir tu éxito académico.';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get nameRequired => 'Por favor, introduce tu nombre';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get confirmPasswordRequired => 'Por favor, confirma tu contraseña';

  @override
  String get haveAccount => '¿Ya tienes una cuenta?';

  @override
  String get verifyYourEmail => 'Verifica tu Correo Electrónico';

  @override
  String get verificationEmailSent => '¡Correo de verificación enviado! Revisa tu bandeja de entrada.';

  @override
  String get checkInbox => 'Revisa tu bandeja de entrada y haz clic en el enlace de verificación para activar tu cuenta.';

  @override
  String get resendVerification => 'Reenviar Correo de Verificación';

  @override
  String get iVerifiedMyEmail => 'Verifiqué mi correo → Continuar';

  @override
  String get skip => 'Omitir';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get nextLabel => 'Siguiente';

  @override
  String get savedDataFound => 'Datos Guardados Encontrados';

  @override
  String savedDataDescription(Object courseCount) {
    return 'Esta cuenta tiene $courseCount cursos guardados.';
  }

  @override
  String get loadDataDescription => 'Cargar tus datos transferirá tus cursos, notas y plazos a este dispositivo.';

  @override
  String get cloudDataCleared => 'Datos antiguos de la nube eliminados. Empezando de cero.';

  @override
  String get startFresh => 'Empezar de Cero';

  @override
  String get loadData => 'Cargar Datos';

  @override
  String get youAreOffline => 'Estás desconectado';

  @override
  String get processingOcr => 'Procesando OCR...';

  @override
  String get ocrNoteSaved => '¡Nota OCR guardada!';

  @override
  String get noCoursesAddFirst => 'No hay cursos disponibles. ¡Añade un curso primero!';

  @override
  String get selectCourseTitle => 'Seleccionar Curso';

  @override
  String get chooseSaveLocation => 'Elige dónde guardar esta nota';

  @override
  String get weeklyTimetable => 'Horario Semanal';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mié';

  @override
  String get dayThu => 'Jue';

  @override
  String get dayFri => 'Vie';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get dayM => 'L';

  @override
  String get dayT => 'M';

  @override
  String get dayW => 'X';

  @override
  String get dayTh => 'J';

  @override
  String get dayF => 'V';

  @override
  String get daySa => 'S';

  @override
  String get daySu => 'D';

  @override
  String get dailyPlan => 'Plan Diario';

  @override
  String get scheduleAtGlance => 'Tu horario de un vistazo';

  @override
  String get addPlan => 'Añadir Plan';

  @override
  String scheduleFor(Object date) {
    return 'Horario para $date';
  }

  @override
  String get freeDay => '¡Día Libre!';

  @override
  String get freeDayDescription => 'No tienes clases ni plazos programados. Disfruta tu tiempo libre o planifica con anticipación.';

  @override
  String get deleteEventTitle => '¿Eliminar Evento?';

  @override
  String deleteEventConfirm(Object title) {
    return '¿Quieres eliminar \"$title\"?';
  }

  @override
  String get addPlanEvent => 'Añadir Evento al Plan';

  @override
  String get eventTitleHint => 'Título del Evento (ej., Quedar con María)';

  @override
  String get eventTitleRequired => 'Por favor, introduce un título';

  @override
  String get eventType => 'Tipo de Evento';

  @override
  String startLabel(Object time) {
    return 'Inicio: $time';
  }

  @override
  String endLabel(Object time) {
    return 'Fin: $time';
  }

  @override
  String get notesOptional => 'Notas (Opcional)';

  @override
  String get saveEvent => 'Guardar Evento';

  @override
  String get colorLabel => 'Color';

  @override
  String get eventStudy => 'Estudio';

  @override
  String get eventMeeting => 'Reunión';

  @override
  String get eventCoffee => 'Pausa para Café';

  @override
  String get eventPersonal => 'Personal';

  @override
  String get eventOther => 'Otro';

  @override
  String get recording => 'Grabando...';

  @override
  String get stopAndSave => 'Detener y Guardar';

  @override
  String get syncFromMoodle => 'Sincronizar desde Moodle';

  @override
  String get moodleSyncFirst => 'Sincroniza tu cuenta de Moodle primero';

  @override
  String moodleCourseSelected(Object courseName) {
    return '$courseName seleccionado — editar detalles del curso';
  }

  @override
  String get selectFromMoodle => 'Seleccionar desde Moodle';

  @override
  String get cancelMoodle => 'Cancelar';

  @override
  String addSelected(Object count) {
    return 'Añadir ($count)';
  }

  @override
  String get searchCourse => 'Buscar curso...';

  @override
  String get courseArchived => 'Curso archivado';

  @override
  String get notificationsDisabled => 'Notificaciones desactivadas';

  @override
  String get notificationsEnabled => 'Notificaciones activadas';

  @override
  String get deadlineAdded => '¡Plazo añadido correctamente!';

  @override
  String get fileAdded => 'Archivo añadido correctamente';

  @override
  String photoSaved(Object count) {
    return '¡$count fotos guardadas!';
  }

  @override
  String get noteSaved => '¡Nota guardada!';

  @override
  String get drawingSaved => '¡Dibujo guardado!';

  @override
  String get gradeDeleted => 'Calificación eliminada';

  @override
  String get ocrLabel => 'OCR';

  @override
  String get drawingLabel => 'Dibujo';

  @override
  String ofNotes(Object count, Object total) {
    return '$count de $total Notas';
  }

  @override
  String notesCount(Object count) {
    return '$count Notas';
  }

  @override
  String get clearCanvas => 'Limpiar Lienzo';

  @override
  String get clearCanvasConfirm => '¿Estás seguro de que quieres borrar todos los dibujos?';

  @override
  String get clearAction => 'Limpiar';

  @override
  String get nothingToSave => 'Nada que guardar. Dibuja algo primero.';

  @override
  String get blankPaper => 'Papel en Blanco';

  @override
  String get photoAnnotation => 'Anotación de Foto';

  @override
  String get pdfAnnotation => 'Anotación de PDF';

  @override
  String get blankLabel => 'Blanco';

  @override
  String get photoLabel => 'Foto';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get tapPhotoHint => 'Toca \"Foto\" para seleccionar una imagen';

  @override
  String get tapPdfHint => 'Toca \"PDF\" para seleccionar un documento';

  @override
  String get moveToCourse => 'Mover a Curso';

  @override
  String get deleteNote => 'Eliminar Nota';

  @override
  String get imageUnavailable => 'Imagen no disponible';

  @override
  String get noOtherCourses => 'No hay otros cursos disponibles';

  @override
  String get selectDestination => 'Seleccionar curso de destino';

  @override
  String movedTo(Object course) {
    return 'Movido a $course';
  }

  @override
  String get noDrawingData => 'Sin datos de dibujo';

  @override
  String get pdfFileNotFound => 'Archivo PDF no encontrado';

  @override
  String get studyHistory => 'Historial de Estudio';

  @override
  String get range7D => '7D';

  @override
  String get range14D => '14D';

  @override
  String get range30D => '30D';

  @override
  String get totalStudy => 'Estudio Total';

  @override
  String get sessionsLabel => 'Sesiones';

  @override
  String get avgPerDay => 'Prom./Día';

  @override
  String get dailyStudyTime => 'Tiempo de Estudio Diario';

  @override
  String get noDataYet => 'Aún no hay datos';

  @override
  String get byCourse => 'Por Curso';

  @override
  String get general => 'General';

  @override
  String get recentSessions => 'Sesiones Recientes';

  @override
  String get noStudySessions => 'Aún no hay sesiones de estudio.\n¡Inicia un temporizador Pomodoro!';

  @override
  String get deleteSession => 'Eliminar Sesión';

  @override
  String deleteSessionConfirm(Object minutes) {
    return '¿Eliminar esta sesión de estudio de ${minutes}m?';
  }

  @override
  String get enabled => 'Activado';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get start => 'Iniciar';

  @override
  String get close => 'Cerrar';

  @override
  String get saveQuestions => 'Guardar Preguntas';

  @override
  String questionLabel(Object index) {
    return 'Pregunta $index';
  }

  @override
  String get yourAnswer => 'Tu Respuesta';

  @override
  String get allAnswersRequired => 'Todas las respuestas son obligatorias';

  @override
  String get questionsSaved => 'Preguntas de seguridad guardadas';

  @override
  String get questionsSaveFailed => 'Error al guardar las preguntas';

  @override
  String get resetQuestions => 'Restablecer Preguntas';

  @override
  String biometricEnabled(Object biometric) {
    return '$biometric activado correctamente';
  }

  @override
  String biometricDisabled(Object biometric) {
    return '$biometric desactivado';
  }

  @override
  String biometricAuthReason(Object biometric) {
    return 'Autentícate para activar $biometric';
  }

  @override
  String get e2eEncryption => 'Cifrado de Extremo a Extremo';

  @override
  String get e2eDescription => 'Tus archivos se cifran en tu dispositivo antes de subirse a la nube.';

  @override
  String get encryptionKey => 'Clave de Cifrado';

  @override
  String get keyStorage => 'Almacén de Claves';

  @override
  String get cloudAccess => 'Acceso a la Nube';

  @override
  String get aes256 => 'AES-256-CBC';

  @override
  String get deviceKeychain => 'Llavero del Dispositivo';

  @override
  String get encryptedOnly => 'Solo datos cifrados';

  @override
  String get evenDevCantAccess => 'Ni los desarrolladores pueden acceder a tus archivos';

  @override
  String get alreadyEncrypted => 'Todos los archivos ya están cifrados';

  @override
  String get startingMigration => 'Iniciando migración...';

  @override
  String get migrationComplete => '¡Migración completada!';

  @override
  String get allEncrypted => '¡Todos los archivos cifrados correctamente!';

  @override
  String get migrationFailed => 'Migración fallida';

  @override
  String migrationFailedDetail(Object error) {
    return 'Migración fallida: $error';
  }

  @override
  String get setUpSecurityQuestions => 'Configura 3 preguntas de seguridad para recuperar tu cuenta si olvidas tu contraseña.';

  @override
  String get questionsAlreadyConfigured => 'Las preguntas de seguridad ya están configuradas';

  @override
  String get encryptExistingFiles => 'Cifrar Archivos Existentes';

  @override
  String get backupFilesToCloud => 'Haz una copia de seguridad de tus archivos en la nube';

  @override
  String get securityQuestions => 'Preguntas de Seguridad';

  @override
  String get securityQ1 => '¿Cuál es el nombre de tu mascota?';

  @override
  String get securityQ2 => '¿Cuál era el nombre de tu primer profesor?';

  @override
  String get securityQ3 => '¿En qué ciudad naciste?';

  @override
  String get securityQ4 => '¿Cuál es tu película favorita?';

  @override
  String get securityQ5 => '¿Cuál fue tu primer número de teléfono?';

  @override
  String get securityQ6 => '¿Cuál es el apellido de soltera de tu madre?';

  @override
  String get securityQ7 => '¿Cuál era el nombre de tu primera escuela?';

  @override
  String get securityQ8 => '¿Cuál es tu libro favorito?';

  @override
  String get recoveryStepEmail => 'Verificar Correo';

  @override
  String get recoveryStepQuestions => 'Preguntas de Seguridad';

  @override
  String get recoveryStepPassword => 'Nueva Contraseña';

  @override
  String get recoveryEmailDesc => 'Introduce tu correo para iniciar el proceso de recuperación';

  @override
  String get recoveryCodeSent => 'Enviamos un código de verificación a tu correo';

  @override
  String get recoveryQuestionsDesc => 'Responde tus preguntas de seguridad para continuar';

  @override
  String get recoveryNewPasswordDesc => 'Crea una nueva contraseña para tu cuenta';

  @override
  String get emailHint => 'Correo Electrónico';

  @override
  String get emailIsRequired => 'El correo es obligatorio';

  @override
  String get enterValidEmail => 'Introduce un correo válido';

  @override
  String get sendCode => 'Enviar Código';

  @override
  String get verificationCode => 'Código de Verificación';

  @override
  String get codeIsRequired => 'El código es obligatorio';

  @override
  String get verifyCode => 'Verificar Código';

  @override
  String get resendCode => 'Reenviar Código';

  @override
  String get yourAnswerLabel => 'Tu Respuesta';

  @override
  String get required => 'Obligatorio';

  @override
  String get verifyAnswers => 'Verificar Respuestas';

  @override
  String securityQuestionN(Object number) {
    return 'Pregunta de Seguridad $number';
  }

  @override
  String get passwordLengthError => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get passwordsDoNotMatchError => 'Las contraseñas no coinciden';

  @override
  String get resetPasswordButton => 'Restablecer Contraseña';

  @override
  String get failedToSendReset => 'Error al enviar el correo de restablecimiento. Verifica tu dirección de correo.';

  @override
  String get checkEmailForLink => 'Revisa tu correo y haz clic en el enlace de restablecimiento';

  @override
  String get passwordResetEmailSent => '¡Correo de restablecimiento enviado! Nota: Si tienes el cifrado E2E activado...';

  @override
  String get failedToResetPassword => 'Error al restablecer la contraseña. Inténtalo de nuevo.';

  @override
  String get professorDetailsSection => 'Detalles del Profesor';

  @override
  String get notificationGeneral => 'General';

  @override
  String get turnOffAllNotifications => 'Desactivar todas las notificaciones de la app';

  @override
  String get reminderTiming => 'Temporización de Recordatorios';

  @override
  String get remindBeforeClass => 'Recordarme antes de clase';

  @override
  String get reminder5min => '5 minutos';

  @override
  String get reminder10min => '10 minutos';

  @override
  String get reminder15min => '15 minutos';

  @override
  String get reminder30min => '30 minutos';

  @override
  String get reminder1hour => '1 hora';

  @override
  String get reminder2hours => '2 horas';

  @override
  String alertAt(Object time) {
    return 'Alerta a las $time';
  }

  @override
  String get courseCustomization => 'Personalización del Curso';

  @override
  String get transcriptTitle => 'Expediente Académico';

  @override
  String get courseHeader => 'Curso';

  @override
  String get crHeader => 'CR';

  @override
  String get avgHeader => 'Prom';

  @override
  String get gradeHeader => 'Nota';

  @override
  String get gpHeader => 'GP';

  @override
  String get overallGpa => 'GPA General';

  @override
  String get totalCreditsLabel => 'Créditos Totales';

  @override
  String get storageOptimized => '¡Optimización de memoria completa! Dispositivo liberado.';

  @override
  String get smartStorageManagement => 'Gestión Inteligente de Almacenamiento';

  @override
  String get storageOptions => 'Opciones para liberar espacio en tu dispositivo';

  @override
  String get standardCleanup => 'Limpieza Estándar';

  @override
  String standardCleanupDesc(Object size) {
    return 'Elimina archivos temporales. ($size)';
  }

  @override
  String get deepOptimization => 'Optimización Profunda';

  @override
  String get deepOptimizationDesc => 'Limpia residuos de imágenes y fugas de memoria, acelera el dispositivo.';

  @override
  String get optimizeStorage => 'Optimizar Almacenamiento';

  @override
  String get userName => 'Usuario';

  @override
  String get guestUserLabel => 'Usuario Invitado';

  @override
  String get signInToSync => 'Inicia sesión para sincronizar datos';

  @override
  String get guestMode => 'Modo Invitado';

  @override
  String get faceId => 'Face ID / Touch ID';

  @override
  String get faceIdSubtitle => 'Usa Face ID / Touch ID para desbloquear';

  @override
  String get notAvailableOnDevice => 'No disponible en este dispositivo';

  @override
  String get cloudBackup => 'Copia de Seguridad en la Nube';

  @override
  String get encryptedBackupActive => 'Copia de seguridad cifrada activa';

  @override
  String get backupOffDefault => 'Desactivada (predeterminado)';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountKvkk => 'KVKK Artículo 7 - Derecho de Supresión';

  @override
  String get deletingAccount => 'Eliminando cuenta...';

  @override
  String deleteAccountError(Object error) {
    return 'Error al eliminar la cuenta: $error';
  }

  @override
  String get cookiePolicy => 'Política de Cookies';

  @override
  String get consentManagement => 'Gestión de Consentimiento';

  @override
  String get consentManagementDesc => 'Gestiona tus preferencias de consentimiento explícito según el Artículo 5/1 de la KVKK.';

  @override
  String get appVersion => 'Lesson Tracker v1.0.0';

  @override
  String get moodleTabCourses => 'Cursos';

  @override
  String get moodleTabAssignments => 'Tareas';

  @override
  String get moodleTabGrades => 'Calificaciones';

  @override
  String get moodleTabAnnouncements => 'Anuncios';

  @override
  String get moodleTabCalendar => 'Calendario';

  @override
  String get moodleTabMessages => 'Mensajes';

  @override
  String get moodleTitle => 'Moodle';

  @override
  String moodleSummary(Object accounts, Object courses, Object unread) {
    return '$accounts cuenta · $courses cursos · $unread sin leer';
  }

  @override
  String get moodleRefreshAll => 'Actualizar Todo';

  @override
  String get moodleManageAccounts => 'Gestionar Cuentas';

  @override
  String get moodleAddAccount => 'Añadir Cuenta';

  @override
  String get moodleConnect => 'Conectar Moodle';

  @override
  String get moodleConnectDesc => 'Conéctate al sistema Moodle de tu universidad para sincronizar cursos, tareas y calificaciones.';

  @override
  String get moodleFeatureAssignments => 'Tareas y Fechas';

  @override
  String get moodleFeatureGrades => 'Calificaciones';

  @override
  String get moodleFeatureAnnouncements => 'Anuncios';

  @override
  String get moodleFeatureMultiAccount => 'Multi-Cuenta';

  @override
  String get moodlePasswordNotStored => 'Tu contraseña nunca se almacena en el dispositivo';

  @override
  String get moodleConnected => '¡Cuenta de Moodle conectada correctamente!';

  @override
  String get moodleNoCourses => 'No se encontraron cursos';

  @override
  String get moodleSyncing => 'Sincronizando tu cuenta de Moodle...';

  @override
  String get moodleNoAssignments => 'No se encontraron tareas pendientes';

  @override
  String get moodleAllDone => '¡Genial! Parece que todo está completado.';

  @override
  String get moodleOverdue => 'Vencido';

  @override
  String get moodleThisWeek => 'Esta Semana';

  @override
  String get moodleUpcoming => 'Próximos';

  @override
  String get moodleSubmitted => 'Entregado';

  @override
  String get moodleLate => 'Tarde';

  @override
  String get moodleDueToday => '¡Vence hoy!';

  @override
  String moodleDaysLeft(Object days) {
    return '$days días restantes';
  }

  @override
  String get moodleNoGrades => 'No se encontraron calificaciones';

  @override
  String get moodleNoAnnouncements => 'No se encontraron anuncios';

  @override
  String get moodleNoEvents => 'No hay eventos en este día';

  @override
  String get moodleAllDay => 'Todo el día';

  @override
  String get moodleNoMessages => 'No se encontraron mensajes';

  @override
  String get moodleMessagesHere => 'Tus mensajes de Moodle aparecerán aquí';

  @override
  String moodleAccountCourses(Object count) {
    return '$count tareas';
  }

  @override
  String get moodleAcademicSummary => 'Resumen Académico';

  @override
  String get moodleAvg => 'Prom.';

  @override
  String get moodleThisWeekTasks => 'Tareas de esta semana';

  @override
  String get moodleOverdueTasks => 'Vencidas';

  @override
  String get moodleCourseCount => 'Número de cursos';

  @override
  String get moodleBest => 'Mejor';

  @override
  String get moodleWorst => 'Peor';

  @override
  String get moodleSelectUniversity => 'Selecciona tu Universidad';

  @override
  String get moodleSelectUniversityDesc => 'Selecciona tu universidad para conectar tu cuenta de Moodle';

  @override
  String get moodleSearchUniversity => 'Buscar universidad...';

  @override
  String get moodleManualUrl => 'Entrada Manual de URL';

  @override
  String get moodleManualUrlDesc => 'Para universidades que no están en la lista';

  @override
  String get moodleBack => 'Atrás';

  @override
  String get moodleUrl => 'URL de Moodle';

  @override
  String get moodleUrlHint => 'ej. moodle.universidad.edu.es';

  @override
  String get moodleUrlRequired => 'La URL es obligatoria';

  @override
  String get moodleLogin => 'Iniciar Sesión';

  @override
  String get moodleUsername => 'Nombre de Usuario';

  @override
  String get moodleUsernameRequired => 'El nombre de usuario es obligatorio';

  @override
  String get moodlePassword => 'Contraseña';

  @override
  String get moodlePasswordRequired => 'La contraseña es obligatoria';

  @override
  String get moodlePasswordHint => 'Tu contraseña nunca se almacena en tu dispositivo.';

  @override
  String get moodleConnectButton => 'Conectar';

  @override
  String get moodleConnecting => 'Conectando a Moodle...';

  @override
  String get moodleConnectionFailed => 'Conexión Fallida';

  @override
  String get moodleTryAgain => 'Intentar de Nuevo';

  @override
  String get moodleConnectionSuccess => '¡Conexión Exitosa!';

  @override
  String get moodleGreat => '¡Genial!';

  @override
  String get moodleAccountsManage => 'Gestionar Cuentas';

  @override
  String get moodleAccountAdd => 'Añadir Cuenta de Moodle';

  @override
  String get moodleNoAccounts => 'No hay cuentas conectadas';

  @override
  String get moodleNoAccountsDesc => 'Añade tu cuenta de Moodle usando el botón de abajo.';

  @override
  String get moodleLogout => 'Cerrar Sesión';

  @override
  String moodleLogoutConfirm(Object account) {
    return '¿Estás seguro de que quieres cerrar sesión de $account?';
  }

  @override
  String moodleLogoutDone(Object account) {
    return 'Sesión cerrada de $account';
  }

  @override
  String get moodleContentLoading => 'Cargando contenido del curso...';

  @override
  String moodleContentError(Object error) {
    return 'No se pudo cargar el contenido: $error';
  }

  @override
  String get moodleContentNotFound => 'Contenido no encontrado';

  @override
  String get moodleDownloadFailed => 'Descarga fallida o archivo demasiado grande.';

  @override
  String get moodleTransferToCourse => 'Transferir a Mis Cursos';

  @override
  String get moodleTransferDesc => 'Guarda este archivo en uno de tus cursos en la app.';

  @override
  String get moodleSelectCourse => 'Seleccionar Curso';

  @override
  String get moodleNoLocalCourses => 'Aún no has añadido ningún curso.';

  @override
  String moodleSavedToCourse(Object course) {
    return '¡Archivo guardado en \"$course\" correctamente!';
  }

  @override
  String get moodleSaveError => 'Ocurrió un error al guardar el archivo.';

  @override
  String get moodleTokenNotFound => 'Token no encontrado — reconecta tu cuenta';

  @override
  String get moodleAccountNotFound => 'Cuenta no encontrada';

  @override
  String get veliConsentTitle => 'Consentimiento Parental';

  @override
  String get veliConsentDesc => 'Los usuarios menores de 18 años necesitan consentimiento parental para usar la app.';

  @override
  String get veliEmailLabel => 'Correo Electrónico del Padre/Madre';

  @override
  String get veliEmailHint => 'Introduce el correo del padre o madre';

  @override
  String get veliConfirmCheck => 'Confirmo que soy padre/madre y permito que mi hijo/a use esta app.';

  @override
  String get veliKvkkCheck => 'Doy consentimiento parental según la Ley KVKK No. 6698.';

  @override
  String veliCodeSent(Object email) {
    return 'Código de verificación enviado a $email.';
  }

  @override
  String get veliEnterCode => 'Introduce el código de verificación de 6 dígitos';

  @override
  String get veliVerifyAndApprove => 'Verificar y Aprobar';

  @override
  String get veliResendCode => 'Reenviar Código';

  @override
  String get veliChangeEmail => 'Cambiar Correo';

  @override
  String get veliSendCode => 'Enviar Código de Verificación';

  @override
  String get veliCancel => 'Cancelar';

  @override
  String get veliRequired => 'Se requiere consentimiento parental';

  @override
  String get veliValidEmail => 'Introduce una dirección de correo válida';

  @override
  String get veliCheckConsent => 'Marca la casilla de consentimiento parental';

  @override
  String get veliCodeRequired => 'Introduce el código de verificación';

  @override
  String get veliSessionNotFound => 'Sesión de verificación no encontrada. Inténtalo de nuevo.';

  @override
  String get veliCodeExpired => 'Código de verificación caducado. Solicita uno nuevo.';

  @override
  String get veliWrongCode => 'Código de verificación incorrecto.';

  @override
  String get veliInfoText => 'El correo del padre/madre solo se usará para enviar la notificación de consentimiento.';

  @override
  String get veliRequestConsent => 'Solicitar Consentimiento';

  @override
  String get veliEmailVerification => 'Verificación de Correo';

  @override
  String get veliStepVerification => 'Verificación';

  @override
  String get veliStepConsent => 'Consentimiento';

  @override
  String get kvkkFlowReset => 'Consentimiento KVKK restablecido — reinicia la app';

  @override
  String get kvkkReset => 'Restablecer';

  @override
  String get kvkkSkip => 'Omitir';

  @override
  String get consentManagementTitle => 'Gestión de Consentimiento';

  @override
  String get consentManagementSubtitle => 'Tus Preferencias de Consentimiento Explícito';

  @override
  String get consentWithdrawInfo => 'Puedes retirar tu consentimiento en cualquier momento. La retirada no afecta la legalidad del tratamiento basado en el consentimiento antes de su retirada.';

  @override
  String get consentCamera => 'Captura de Fotos con Cámara';

  @override
  String get consentAudio => 'Grabación de Audio';

  @override
  String get consentOcr => 'Reconocimiento de Texto OCR';

  @override
  String get consentPush => 'Notificaciones Push';

  @override
  String get consentCloud => 'Copia de Seguridad en la Nube (Opcional)';

  @override
  String get consentLegalInfo => 'Información Legal';

  @override
  String get consentLegalDesc => 'Según la Ley KVKK No. 6698, puedes gestionar tus preferencias de consentimiento explícito aquí.';

  @override
  String get consentCameraDesc => 'Tomar fotos y escanear documentos';

  @override
  String get consentAudioDesc => 'Grabar notas de audio en las lecciones';

  @override
  String get consentOcrDesc => 'Extraer texto de imágenes y PDFs';

  @override
  String get consentPushDesc => 'Recibir notificaciones de plazos y cursos';

  @override
  String get consentCloudDesc => 'Hacer una copia de seguridad de tus datos en la nube de forma segura';

  @override
  String get moodleSyncEnabled => '¡Sincronización en segundo plano de Moodle activada!';

  @override
  String get moodleSyncDisabled => '¡Sincronización en segundo plano de Moodle desactivada!';

  @override
  String get moodleBackgroundSync => 'Sincronización en Segundo Plano de Moodle';

  @override
  String get moodleSyncNotifications => 'Se notificarán nuevas tareas, calificaciones y anuncios';

  @override
  String get moodleSyncOff => 'Desactivada — requiere actualización manual';

  @override
  String get smartAttendanceSetLocationFirst => 'Primero configura la ubicación de tu escuela para activar la asistencia inteligente.';

  @override
  String get smartAttendanceEnabled => '¡Asistencia inteligente activada! Funcionará en segundo plano.';

  @override
  String get smartAttendanceDisabled => 'Asistencia inteligente desactivada.';

  @override
  String get smartAttendanceSchoolLocation => 'Ubicación de la Escuela';

  @override
  String get smartAttendanceLocationSet => 'Ubicación Configurada';

  @override
  String get smartAttendanceLocationNotSet => 'Aún no configurada';

  @override
  String get smartAttendanceCurrentLocation => 'Tu ubicación escolar actual está guardada.';

  @override
  String get smartAttendanceSetLocationPrompt => '¿Quieres guardar tu ubicación actual como \"Ubicación de la Universidad\"?';

  @override
  String get smartAttendanceCancel => 'Cancelar';

  @override
  String get smartAttendanceGettingLocation => 'Obteniendo ubicación...';

  @override
  String get smartAttendanceSaved => '¡Ubicación escolar guardada!';

  @override
  String get smartAttendanceLocationError => 'No se pudo obtener la ubicación. Verifica los permisos de ubicación.';

  @override
  String get smartAttendanceUpdate => 'Actualizar';

  @override
  String get smartAttendanceYesImAtSchool => 'Sí, estoy en la Escuela';

  @override
  String get smartAttendanceTitle => 'Asistencia Inteligente';

  @override
  String get smartAttendanceActive => 'Activa — La ausencia no se cuenta si estás en la escuela durante la clase';

  @override
  String get smartAttendanceOff => 'Desactivada';

  @override
  String get deleteAccountTitle => 'A punto de Eliminar\nTu Cuenta';

  @override
  String get deleteAccountIrreversible => 'Esta acción no se puede deshacer';

  @override
  String get deleteAccountDataToDelete => 'Datos que se eliminarán:';

  @override
  String get deleteAccountNotes => 'Todas las notas del curso';

  @override
  String get deleteAccountAudio => 'Grabaciones de audio';

  @override
  String get deleteAccountPhotos => 'Fotos y datos OCR';

  @override
  String get deleteAccountAttendance => 'Registros de asistencia y calificaciones';

  @override
  String get deleteAccountSessions => 'Sesiones de estudio';

  @override
  String get deleteAccountMoodle => 'Conexiones de cuentas de Moodle';

  @override
  String get deleteAccountFirebase => 'Cuenta de Firebase';

  @override
  String get deleteAccountRetention => 'Tus datos se eliminarán permanentemente en un plazo de 30 días.';

  @override
  String get deleteAccountConfirm => 'Confirmo que quiero eliminar mi cuenta.';

  @override
  String get deleteAccountCancel => 'Cancelar';

  @override
  String get deleteAccountAction => 'Eliminar Mi Cuenta';

  @override
  String get aydinlatmaTitle => 'Texto Informativo';

  @override
  String get aydinlatmaSubtitle => 'Información según la Ley KVKK No. 6698 Artículo 10';

  @override
  String get aydinlatmaSection1 => '1. Responsable del Tratamiento';

  @override
  String get aydinlatmaControllerInfo => 'LessonTracker\nCorreo: lessontracker@example.com';

  @override
  String get aydinlatmaSection2 => '2. Datos Personales Tratados';

  @override
  String get aydinlatmaSection3 => '3. Fines del Tratamiento de Datos';

  @override
  String get aydinlatmaSection4 => '4. Transferencia de Datos Personales';

  @override
  String get aydinlatmaSection5 => '5. Período de Conservación';

  @override
  String get aydinlatmaSection6 => '6. Seguridad de los Datos';

  @override
  String get aydinlatmaSection7 => '7. Tus Derechos (KVKK Artículo 11)';

  @override
  String get aydinlatmaSection8 => '8. Más Información';

  @override
  String get aydinlatmaConfirm => 'He leído el texto informativo y he sido informado.';

  @override
  String get aydinlatmaContinue => 'Entiendo, Continuar';

  @override
  String get acikRizaTitle => 'Consentimiento Explícito';

  @override
  String get acikRizaSubtitle => 'Tu consentimiento explícito es legalmente requerido para las siguientes acciones (KVKK Artículo 5/1 y 6/2)';

  @override
  String get acikRizaImportant => 'Información Importante';

  @override
  String get acikRizaVoluntary => 'Dar consentimiento explícito es completamente voluntario. Puedes omitir el consentimiento y usar la app en modo limitado. Puedes cambiar tus preferencias más tarde en Ajustes.';

  @override
  String get acikRizaGiveAndContinue => 'Dar Consentimiento y Continuar';

  @override
  String get acikRizaSkip => 'Continuar sin Consentimiento';

  @override
  String get acikRizaWarning => 'Aviso Importante';

  @override
  String get acikRizaFeaturesDisabled => 'Si continúas sin consentimiento, las siguientes funciones no estarán disponibles:';

  @override
  String get acikRizaFeatureCamera => 'Captura de fotos con cámara';

  @override
  String get acikRizaFeatureAudio => 'Grabación de audio';

  @override
  String get acikRizaFeatureOcr => 'Reconocimiento de texto OCR';

  @override
  String get acikRizaSettingsNote => 'Puedes cambiar estas preferencias más tarde en Ajustes.';

  @override
  String get acikRizaCancel => 'Cancelar';

  @override
  String get acikRizaLimitedMode => 'Continuar en Modo Limitado';
}
