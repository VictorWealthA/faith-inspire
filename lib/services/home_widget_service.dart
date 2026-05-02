import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/models/inspiration_item.dart';
import '../features/daily/daily_reflection_provider.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService();
});

class HomeWidgetService {
  static const androidWidgetProvider = 'FaithInspireWidgetProvider';
  static const _widgetItemIdKey = 'faith_inspire_widget_item_id';
  static const _widgetItemTypeKey = 'faith_inspire_widget_item_type';

  Future<void> initialize() async {}

  Future<void> updateDailyReflectionWidget({
    required InspirationItem? item,
    required int streakCount,
  }) async {
    if (item == null) {
      return;
    }

    try {
      await HomeWidget.saveWidgetData<String>('faith_inspire_widget_title', 'Today\'s ${inspirationTypeLabel(item.type)}');
      await HomeWidget.saveWidgetData<String>('faith_inspire_widget_text', shortenReflectionText(item.text, maxLength: 118));
      await HomeWidget.saveWidgetData<String>('faith_inspire_widget_footer', _buildFooter(item: item, streakCount: streakCount));
      await HomeWidget.saveWidgetData<String>(_widgetItemIdKey, item.id);
      await HomeWidget.saveWidgetData<String>(_widgetItemTypeKey, item.type.name);
      await HomeWidget.updateWidget(androidName: androidWidgetProvider);
    } catch (_) {
      // Ignore when the platform/widget is unavailable.
    }
  }

  Future<bool> isPinWidgetSupported() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    return await HomeWidget.isRequestPinWidgetSupported() ?? false;
  }

  Future<void> requestPinWidget() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await HomeWidget.requestPinWidget(androidName: androidWidgetProvider);
    } catch (_) {
      // No-op on unsupported launchers.
    }
  }

  String _buildFooter({
    required InspirationItem item,
    required int streakCount,
  }) {
    final source = item.author ?? item.reference ?? inspirationTypeLabel(item.type);
    final streakLabel = streakCount == 1 ? '1 day streak' : '$streakCount day streak';
    return '$source • $streakLabel';
  }
}