import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/app_settings.dart';
import '../theme/app_theme.dart';

class SettingsService {
  static const _themeKey = 'settings_theme_index';
  static const _paceKey = 'settings_default_pace';
  static const _readAloudKey = 'settings_default_read_aloud';
  static const _remindersEnabledKey = 'settings_reminders_enabled';
  static const _reminderHourKey = 'settings_reminder_hour';
  static const _reminderMinuteKey = 'settings_reminder_minute';
  static const _hasSeenOnboardingKey = 'settings_has_seen_onboarding';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    final paceIndex = prefs.getInt(_paceKey) ?? 1; // normal
    final readAloud = prefs.getBool(_readAloudKey) ?? false;
    final remindersEnabled = prefs.getBool(_remindersEnabledKey) ?? false;
    final reminderHour = prefs.getInt(_reminderHourKey) ?? 9;
    final reminderMinute = prefs.getInt(_reminderMinuteKey) ?? 0;
    final hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;

    return AppSettings(
      themeIndex: themeIndex.clamp(0, AppColorTheme.presets.length - 1),
      defaultPace:
          SlideshowPace.values[paceIndex.clamp(0, SlideshowPace.values.length - 1)],
      defaultReadAloud: readAloud,
      remindersEnabled: remindersEnabled,
      reminderHour: reminderHour.clamp(0, 23),
      reminderMinute: reminderMinute.clamp(0, 59),
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, settings.themeIndex);
    await prefs.setInt(_paceKey, settings.defaultPace.index);
    await prefs.setBool(_readAloudKey, settings.defaultReadAloud);
    await prefs.setBool(_remindersEnabledKey, settings.remindersEnabled);
    await prefs.setInt(_reminderHourKey, settings.reminderHour);
    await prefs.setInt(_reminderMinuteKey, settings.reminderMinute);
    await prefs.setBool(_hasSeenOnboardingKey, settings.hasSeenOnboarding);
  }
}
