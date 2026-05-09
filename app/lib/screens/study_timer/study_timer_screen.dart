import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/course_provider.dart';
import '../../repositories/study_session_repository.dart';
import '../../models/study_session.dart';
import '../study_timer/study_history_screen.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> with TickerProviderStateMixin {
  // Timer State
  int _workMinutes = 25;
  int _breakMinutes = 5;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedSessions = 0;
  Timer? _timer;
  String? _selectedCourseId;
  DateTime? _sessionStartTime;
  final _uuid = const Uuid();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() => _isRunning = true);
    _sessionStartTime ??= DateTime.now();
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _pulseController.stop();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remainingSeconds = _workMinutes * 60;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    HapticFeedback.heavyImpact();

    if (!_isBreak) {
      // Work session complete
      setState(() {
        _completedSessions++;
        _isBreak = true;
        _remainingSeconds = _breakMinutes * 60;
        _isRunning = false;
      });
      // Oturumu DB'ye kaydet
      _saveSession();
      _showCompletionSnackBar(false);
    } else {
      // Break complete
      setState(() {
        _isBreak = false;
        _remainingSeconds = _workMinutes * 60;
        _isRunning = false;
      });
      _showCompletionSnackBar(true);
    }
  }

  void _showCompletionSnackBar(bool wasBreak) {
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(wasBreak ? Icons.play_arrow : Icons.celebration, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                wasBreak ? loc.breakComplete : loc.sessionComplete,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: wasBreak ? AppColors.primary : AppColors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveSession() async {
    final endTime = DateTime.now();
    final session = StudySession(
      id: _uuid.v4(),
      courseId: _selectedCourseId,
      durationMinutes: _workMinutes,
      startedAt: _sessionStartTime ?? endTime.subtract(Duration(minutes: _workMinutes)),
      endedAt: endTime,
      sessionType: 'work',
    );
    await StudySessionRepository().insertStudySession(session);
    _sessionStartTime = null;
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final totalSeconds = _isBreak ? _breakMinutes * 60 : _workMinutes * 60;
    return 1.0 - (_remainingSeconds / totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final courses = context.select((CourseProvider p) => p.uniqueCourses);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.studyTimer,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // Session indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isBreak
                          ? AppColors.green.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isBreak ? Icons.coffee : Icons.auto_stories,
                          color: _isBreak ? AppColors.green : AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isBreak ? loc.breakTime : loc.focusTime,
                          style: TextStyle(
                            color: _isBreak ? AppColors.green : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Timer Circle
              ScaleTransition(
                scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          ),
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _progress),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 10,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isBreak ? AppColors.green : AppColors.primary,
                              ),
                              strokeCap: StrokeCap.round,
                            );
                          },
                        ),
                      ),
                      // Time text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w200,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${loc.session} ${_completedSessions + (_isBreak ? 0 : 1)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset
                  _buildControlButton(
                    icon: Icons.refresh,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    iconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    size: 52,
                    onTap: _resetTimer,
                  ),
                  const SizedBox(width: 24),
                  // Play / Pause
                  _buildControlButton(
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    color: _isBreak ? AppColors.green : AppColors.primary,
                    iconColor: Colors.white,
                    size: 72,
                    iconSize: 36,
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                  ),
                  const SizedBox(width: 24),
                  // Skip
                  _buildControlButton(
                    icon: Icons.skip_next,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    iconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    size: 52,
                    onTap: _onTimerComplete,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Course selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.studyingFor,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: _selectedCourseId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            loc.noCourseSelected,
                            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                        ...courses.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Text(c.name, style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (val) => setState(() => _selectedCourseId = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Duration presets
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.timerPresets,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPresetChip(loc.short, 15, 3, isDark),
                        const SizedBox(width: 8),
                        _buildPresetChip(loc.classic, 25, 5, isDark),
                        const SizedBox(width: 8),
                        _buildPresetChip(loc.long, 45, 10, isDark),
                        const SizedBox(width: 8),
                        _buildPresetChip(loc.marathon, 60, 15, isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Completed sessions
              if (_completedSessions > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: AppColors.orange, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '${loc.completedSessions}: $_completedSessions',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    double iconSize = 24,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }

  Widget _buildPresetChip(String label, int work, int breakMin, bool isDark) {
    final isSelected = _workMinutes == work && _breakMinutes == breakMin;
    return Expanded(
      child: GestureDetector(
        onTap: _isRunning ? null : () {
          HapticFeedback.lightImpact();
          setState(() {
            _workMinutes = work;
            _breakMinutes = breakMin;
            _remainingSeconds = work * 60;
            _isBreak = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '${work}m',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white.withValues(alpha: 0.8) : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
