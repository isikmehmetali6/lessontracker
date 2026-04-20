import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    if (value && !_hasLocation) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Akıllı yoklamayı açmak için önce okul konumunuzu belirlemelisiniz.'),
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
            ? 'Akıllı yoklama etkinleştirildi! Arka planda çalışacak.' 
            : 'Akıllı yoklama kapatıldı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showLocationDialog() async {
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
            Text('Okul Konumu', style: TextStyle(color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          ],
        ),
        content: Text(
          _hasLocation
              ? 'Mevcut okul konumunuz kayıtlı. Şu anki konumunuzla güncellemek ister misiniz?'
              : 'Şu anki konumunuzu "Üniversite Konumu" olarak kaydetmek ister misiniz?\n\nNot: Bu işlemi okulunuzun kampüsünden yapmalısınız.',
          style: TextStyle(color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Konum alınıyor...'), behavior: SnackBarBehavior.floating),
                );
              }
              
              final pos = await locationService.getCurrentLocation();
              if (pos != null) {
                await locationService.saveUniversityLocation(pos.latitude, pos.longitude);
                await _loadSettings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Okul konumu kaydedildi! (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Konum alınamadı. Konum izinlerini kontrol edin.'), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
                  );
                }
              }
            },
            child: Text(_hasLocation ? 'Güncelle' : 'Evet, Şu An Okuldayım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: Icons.school,
          iconColor: AppColors.sky,
          title: 'Okul Konumu',
          subtitle: _hasLocation ? '✓ Konum Ayarlandı' : 'Henüz ayarlanmadı',
          isDark: widget.isDark,
          onTap: _showLocationDialog,
        ),
        SettingsDivider(isDark: widget.isDark),
        SettingsTile(
          icon: Icons.fact_check,
          iconColor: AppColors.emerald,
          title: 'Akıllı Yoklama',
          subtitle: _isEnabled 
              ? 'Aktif — Ders saatinde okulda iseniz devamsızlık girilmez' 
              : 'Kapalı',
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
