import '../../theme/app_theme.dart';

class AppSettings {
  final int themeIndex;
  final SlideshowPace defaultPace;
  final bool defaultReadAloud;
  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool hasSeenOnboarding;

  const AppSettings({
    this.themeIndex = 0,
    this.defaultPace = SlideshowPace.normal,
    this.defaultReadAloud = false,
    this.remindersEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.hasSeenOnboarding = false,
  });

  AppColorTheme get colorTheme =>
      AppColorTheme.presets[themeIndex.clamp(0, AppColorTheme.presets.length - 1)];

  AppSettings copyWith({
    int? themeIndex,
    SlideshowPace? defaultPace,
    bool? defaultReadAloud,
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? hasSeenOnboarding,
  }) {
    return AppSettings(
      themeIndex: themeIndex ?? this.themeIndex,
      defaultPace: defaultPace ?? this.defaultPace,
      defaultReadAloud: defaultReadAloud ?? this.defaultReadAloud,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }
}
