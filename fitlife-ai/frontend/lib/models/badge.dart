// lib/models/badge.dart

class UserBadge {
  final String id;
  final String title;
  final String description;
  final String category;
  final String tier; // 'bronze' | 'silver' | 'gold'
  final String icon;
  final int xp;
  final bool isUnlocked;
  final int progressPct;
  final String currentProgress;

  const UserBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tier,
    required this.icon,
    required this.xp,
    required this.isUnlocked,
    required this.progressPct,
    required this.currentProgress,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Conquista',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      tier: json['tier'] as String? ?? 'bronze',
      icon: json['icon'] as String? ?? 'emoji_events',
      xp: (json['xp'] as num?)?.toInt() ?? 50,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      progressPct: (json['progressPct'] as num?)?.toInt() ?? 0,
      currentProgress: json['currentProgress'] as String? ?? '0/1',
    );
  }
}

class BadgesSummary {
  final int userLevel;
  final int totalXp;
  final int nextLevelXp;
  final int unlockedCount;
  final int totalCount;
  final List<UserBadge> badges;

  const BadgesSummary({
    required this.userLevel,
    required this.totalXp,
    required this.nextLevelXp,
    required this.unlockedCount,
    required this.totalCount,
    required this.badges,
  });

  factory BadgesSummary.fromJson(Map<String, dynamic> json) {
    final list = (json['badges'] as List<dynamic>? ?? [])
        .map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
        .toList();

    return BadgesSummary(
      userLevel: (json['userLevel'] as num?)?.toInt() ?? 1,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      nextLevelXp: (json['nextLevelXp'] as num?)?.toInt() ?? 200,
      unlockedCount: (json['unlockedCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? list.length,
      badges: list,
    );
  }
}

