import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/daily_engagement_state.dart';

final dailyEngagementProvider = Provider<DailyEngagementState>((ref) {
  return const DailyEngagementState();
});