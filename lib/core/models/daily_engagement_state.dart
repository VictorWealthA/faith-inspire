class DailyEngagementState {
  final int streakCount;
  final DateTime? lastVisitDate;
  final int lastCelebratedMilestone;
  final int? recentMilestone;

  const DailyEngagementState({
    this.streakCount = 0,
    this.lastVisitDate,
    this.lastCelebratedMilestone = 0,
    this.recentMilestone,
  });
}