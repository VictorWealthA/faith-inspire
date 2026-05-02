import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/content/inspiration_catalog_provider.dart';
import '../features/settings/settings_provider.dart';
import '../services/home_widget_service.dart';
import '../services/notifications_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final catalog = ref.watch(inspirationCatalogProvider);
    final homeWidgetService = ref.read(homeWidgetServiceProvider);
    final notifications = ref.read(notificationsServiceProvider);
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Settings',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Theme ──────────────────────────────────────────────
                    _SectionLabel('Theme'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(AppColorTheme.presets.length, (i) {
                        final preset = AppColorTheme.presets[i];
                        final selected = settings.themeIndex == i;
                        return _ThemeSwatch(
                          preset: preset,
                          selected: selected,
                          onTap: () => notifier.updateTheme(i),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // ── Default Pace ───────────────────────────────────────
                    _SectionLabel('Default Pace'),
                    const SizedBox(height: 10),
                    Row(
                      children: SlideshowPace.values.map((pace) {
                        final selected = settings.defaultPace == pace;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _PaceChip(
                              pace: pace,
                              selected: selected,
                              onTap: () {
                                notifier.updateDefaultPace(pace);
                                ref.read(activePaceProvider.notifier).state = pace;
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // ── Read Aloud default ─────────────────────────────────
                    _SectionLabel('Read Aloud'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SwitchListTile(
                        title: const Text('Start read aloud by default'),
                        subtitle: const Text('Reads cards aloud when opening a tab'),
                        value: settings.defaultReadAloud,
                        onChanged: notifier.updateDefaultReadAloud,
                        activeColor: AppTheme.primary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel('Daily Reminder'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Daily reminder'),
                            subtitle: Text(
                              'A gentle nudge at ${_formatReminderTime(settings.reminderHour, settings.reminderMinute)}',
                            ),
                            value: settings.remindersEnabled,
                            onChanged: (enabled) async {
                              if (enabled) {
                                final granted = await notifications.requestPermissions();
                                if (!granted && context.mounted) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text('Notification permission is required to enable reminders.'),
                                      ),
                                    );
                                  return;
                                }

                                notifier.updateReminderSchedule(
                                  enabled: true,
                                  hour: settings.reminderHour,
                                  minute: settings.reminderMinute,
                                );
                                await notifications.scheduleDailyReminder(
                                  hour: settings.reminderHour,
                                  minute: settings.reminderMinute,
                                  items: catalog.allItems,
                                );
                                return;
                              }

                              notifier.updateReminderSchedule(
                                enabled: false,
                                hour: settings.reminderHour,
                                minute: settings.reminderMinute,
                              );
                              await notifications.cancelDailyReminder();
                            },
                            activeColor: AppTheme.primary,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            enabled: settings.remindersEnabled,
                            leading: const Icon(Icons.schedule_rounded),
                            title: const Text('Reminder time'),
                            subtitle: Text(
                              _formatReminderTime(settings.reminderHour, settings.reminderMinute),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: !settings.remindersEnabled
                                ? null
                                : () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                        hour: settings.reminderHour,
                                        minute: settings.reminderMinute,
                                      ),
                                    );

                                    if (picked == null) {
                                      return;
                                    }

                                    notifier.updateReminderSchedule(
                                      enabled: true,
                                      hour: picked.hour,
                                      minute: picked.minute,
                                    );
                                    await notifications.scheduleDailyReminder(
                                      hour: picked.hour,
                                      minute: picked.minute,
                                      items: catalog.allItems,
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                    if (defaultTargetPlatform == TargetPlatform.android) ...[
                      const SizedBox(height: 28),
                      _SectionLabel('Home Screen Widget'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.widgets_outlined),
                          title: const Text('Add Android widget'),
                          subtitle: const Text('Pin today\'s reflection and your streak to the home screen'),
                          trailing: const Icon(Icons.add_circle_outline_rounded),
                          onTap: () async {
                            final canPin = await homeWidgetService.isPinWidgetSupported();
                            if (!canPin && context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text('Your launcher does not support widget pinning from the app. Add it manually from the home screen instead.'),
                                  ),
                                );
                              return;
                            }

                            await homeWidgetService.requestPinWidget();
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatReminderTime(int hour, int minute) {
  final time = TimeOfDay(hour: hour, minute: minute);
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minuteLabel = time.minute.toString().padLeft(2, '0');
  return '$hourOfPeriod:$minuteLabel $suffix';
}

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 13,
            letterSpacing: 1.1,
            color: AppTheme.textSecondary,
          ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final AppColorTheme preset;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.emphasized,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [preset.gradientStart, preset.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: selected ? preset.primary : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: preset.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            preset.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? preset.primary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaceChip extends StatelessWidget {
  final SlideshowPace pace;
  final bool selected;
  final VoidCallback onTap;

  const _PaceChip({
    required this.pace,
    required this.selected,
    required this.onTap,
  });

  String get _label {
    switch (pace) {
      case SlideshowPace.fast:
        return 'Fast';
      case SlideshowPace.normal:
        return 'Normal';
      case SlideshowPace.slow:
        return 'Slow';
    }
  }

  IconData get _icon {
    switch (pace) {
      case SlideshowPace.fast:
        return Icons.bolt_rounded;
      case SlideshowPace.normal:
        return Icons.speed_rounded;
      case SlideshowPace.slow:
        return Icons.hourglass_bottom_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.emphasized,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withValues(alpha: 0.10) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primary.withValues(alpha: 0.55) : Colors.grey.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _icon,
                size: 22,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                _label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
