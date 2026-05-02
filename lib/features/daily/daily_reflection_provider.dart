import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/inspiration_item.dart';
import '../content/inspiration_catalog_provider.dart';

final dailyReflectionProvider = Provider<InspirationItem?>((ref) {
  final catalog = ref.watch(inspirationCatalogProvider);
  return selectDailyReflection(catalog.allItems);
});

InspirationItem? selectDailyReflection(
  List<InspirationItem> items, {
  DateTime? date,
}) {
  if (items.isEmpty) {
    return null;
  }

  final target = DateUtils.dateOnly(date ?? DateTime.now());
  final seed = target.difference(DateTime(2024, 1, 1)).inDays.abs();
  return items[seed % items.length];
}

String inspirationTypeLabel(InspirationType type) {
  switch (type) {
    case InspirationType.quote:
      return 'Quote';
    case InspirationType.affirmation:
      return 'Affirmation';
    case InspirationType.scripture:
      return 'Scripture';
  }
}

String shortenReflectionText(String text, {int maxLength = 92}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= maxLength) {
    return normalized;
  }

  return '${normalized.substring(0, maxLength - 1).trimRight()}...';
}

class ReminderCopy {
  final String title;
  final String body;

  const ReminderCopy({
    required this.title,
    required this.body,
  });
}

ReminderCopy buildReminderCopy({
  required DateTime date,
  required List<InspirationItem> items,
}) {
  final reflection = selectDailyReflection(items, date: date);
  final seed = DateUtils.dateOnly(date).difference(DateTime(2024, 1, 1)).inDays.abs();

  const titles = [
    'Faith Inspire',
    'A calm moment is waiting',
    'Reset for a minute',
    'Today\'s reflection is ready',
    'Take your daily pause',
    'A gentle reminder for today',
    'Step back and breathe',
  ];

  final title = titles[seed % titles.length];

  if (reflection == null) {
    return ReminderCopy(
      title: title,
      body: 'Open Faith Inspire for a quote, affirmation, or scripture.',
    );
  }

  final preview = shortenReflectionText(reflection.text, maxLength: 72);
  final typeLabel = inspirationTypeLabel(reflection.type);
  final bodies = [
    '$typeLabel for today: "$preview"',
    'Pause for a $typeLabel and recenter with "$preview"',
    'A fresh $typeLabel is waiting: "$preview"',
    'Take one minute with today\'s $typeLabel: "$preview"',
    'Return to today\'s reflection: "$preview"',
    'Open the app and sit with this $typeLabel: "$preview"',
    'A grounded moment starts here: "$preview"',
  ];

  return ReminderCopy(
    title: title,
    body: bodies[seed % bodies.length],
  );
}