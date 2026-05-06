import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/attendance_automation_service.dart';
import 'settings_shared.dart';

class SmartAttendanceSettings extends StatefulWidget {
  final bool isDark;
  
  const SmartAttendanceSettings({super.key, required this.isDark});

  @override
  State<SmartAttendanceSettings> createState() => _SmartAttendanceSettingsState();
}

class _SmartAttendanceSettingsState extends State<SmartAttendanceSettings> {
  bool _isEnabled = false;
  bool _hasLocation = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('smart_attendance_enabled') ?? false;
    
    final uniLoc = await LocationService().getUniversityLocation();
    
    if (mounted) {
      setState(() {
        _isEnabled = isEnabled;
        _hasLocation = uniLoc != null;
      });
    }
  }

  Future<void> _toggleSmartAttendance(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    if (value && !_hasLocation) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.smartAttendanceSetLocationFirst),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smart_attendance_enabled', value);
    
    // Workmanager periodic task'ı aç/kapat
    if (value) {
      await AttendanceAutomationService.registerPeriodicTask();
    } else {
      await AttendanceAutomationService.cancelPeriodicTask();
    }

    if (mounted) {
      setState(() {
        _isEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value 
            ? l10n.smartAttendanceEnabled 
            : l10n.smartAttendanceDisabled),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showLocationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final locationService = LocationService();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.school, color: AppColors.sky, size: 24),
            const SizedBox(width: 8),
            Text(l10n.smartAttendanceSchoolLocation, style: TextStyle(color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          ],
        ),
        content: Text(
          _hasLocation
              ? l10n.smartAttendanceCurrentLocation
              : l10n.smartAttendanceSetLocationPrompt,
          style: TextStyle(color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.smartAttendanceCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.smartAttendanceGettingLocation), behavior: SnackBarBehavior.floating),
                );
              }
              
              final pos = await locationService.getCurrentLocation();
              if (pos != null) {
                await locationService.saveUniversityLocation(pos.latitude, pos.longitude);
                await _loadSettings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.smartAttendanceSaved),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.smartAttendanceLocationError), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
                  );
                }
              }
            },
            child: Text(_hasLocation ? l10n.smartAttendanceUpdate : l10n.smartAttendanceYesImAtSchool),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SettingsTile(
          icon: Icons.school,
          iconColor: AppColors.sky,
          title: l10n.smartAttendanceSchoolLocation,
          subtitle: _hasLocation ? l10n.smartAttendanceLocationSet : l10n.smartAttendanceLocationNotSet,
          isDark: widget.isDark,
          onTap: _showLocationDialog,
        ),
        SettingsDivider(isDark: widget.isDark),
        SettingsTile(
          icon: Icons.fact_check,
          iconColor: AppColors.emerald,
          title: l10n.smartAttendanceTitle,
          subtitle: _isEnabled 
              ? l10n.smartAttendanceActive 
              : l10n.smartAttendanceOff,
          isDark: widget.isDark,
          trailing: Switch(
            value: _isEnabled,
            onChanged: _toggleSmartAttendance,
            activeThumbColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
