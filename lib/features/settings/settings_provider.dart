import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(service: ref.watch(settingsServiceProvider));
});

/// The pace currently active in the foreground InspirationScreen.
/// Updated whenever any screen cycles pace.
final activePaceProvider = StateProvider<SlideshowPace>((ref) {
  return ref.read(settingsProvider).defaultPace;
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier({
    required SettingsService service,
    AppSettings? initialSettings,
  })  : _service = service,
        super(initialSettings ?? const AppSettings());

  final SettingsService _service;

  void updateTheme(int index) {
    state = state.copyWith(themeIndex: index);
    _service.save(state);
  }

  void updateDefaultPace(SlideshowPace pace) {
    state = state.copyWith(defaultPace: pace);
    _service.save(state);
  }

  void updateDefaultReadAloud(bool value) {
    state = state.copyWith(defaultReadAloud: value);
    _service.save(state);
  }

  void updateReminderSchedule({
    required bool enabled,
    required int hour,
    required int minute,
  }) {
    state = state.copyWith(
      remindersEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    _service.save(state);
  }

  void markOnboardingSeen() {
    state = state.copyWith(hasSeenOnboarding: true);
    _service.save(state);
  }
}
