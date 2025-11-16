// lib/features/home/domain/entities/activity.dart

import 'package:equatable/equatable.dart';

/// Represents an activity (lesson or game) on the home screen
class Activity extends Equatable {
  final String id;
  final String title;
  final String emoji;
  final bool isLocked;
  final int requiredStars;

  const Activity({
    required this.id,
    required this.title,
    required this.emoji,
    this.isLocked = false,
    this.requiredStars = 0,
  });

  @override
  List<Object?> get props => [id, title, emoji, isLocked, requiredStars];
}
