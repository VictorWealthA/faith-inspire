import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/daily_engagement_state.dart';

class DailyEngagementService {
  static const _streakCountKey = 'daily_engagement_streak_count';
  static const _lastVisitDateKey = 'daily_engagement_last_visit_date';
  static const _lastCelebratedMilestoneKey =
      'daily_engagement_last_celebrated_milestone';
  static const _milestones = <int>{7, 30, 100};

  Future<DailyEngagementState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final streakCount = prefs.getInt(_streakCountKey) ?? 0;
    final lastVisitRaw = prefs.getString(_lastVisitDateKey);
    final lastCelebratedMilestone =
        prefs.getInt(_lastCelebratedMilestoneKey) ?? 0;

    return DailyEngagementState(
      streakCount: streakCount,
      lastVisitDate: lastVisitRaw == null ? null : DateTime.tryParse(lastVisitRaw),
      lastCelebratedMilestone: lastCelebratedMilestone,
    );
  }

  Future<DailyEngagementState> recordVisit({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load();
    final today = DateUtils.dateOnly(now ?? DateTime.now());

    if (current.lastVisitDate != null && DateUtils.isSameDay(current.lastVisitDate, today)) {
      return current;
    }

    final isConsecutiveVisit =
        current.lastVisitDate != null && today.difference(DateUtils.dateOnly(current.lastVisitDate!)).inDays == 1;
    final nextStreak = isConsecutiveVisit ? current.streakCount + 1 : 1;
    final recentMilestone =
        _milestones.contains(nextStreak) && nextStreak > current.lastCelebratedMilestone
            ? nextStreak
            : null;
    final nextState = DailyEngagementState(
      streakCount: nextStreak,
      lastVisitDate: today,
      lastCelebratedMilestone:
          recentMilestone ?? current.lastCelebratedMilestone,
      recentMilestone: recentMilestone,
    );

    await prefs.setInt(_streakCountKey, nextState.streakCount);
    await prefs.setString(_lastVisitDateKey, today.toIso8601String());
    await prefs.setInt(
      _lastCelebratedMilestoneKey,
      nextState.lastCelebratedMilestone,
    );

    return nextState;
  }
}