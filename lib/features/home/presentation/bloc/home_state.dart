import 'package:equatable/equatable.dart';
import '../../domain/entities/activity.dart';

/// Base class for all Home screen states
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the home screen is first created
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// State when the home screen is loading
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// State when the home screen is ready and displaying content
class HomeReady extends HomeState {
  final String greeting;
  final String characterMessage;
  final bool elliIsAnimating;
  final List<Activity> activities;

  const HomeReady({
    required this.greeting,
    required this.characterMessage,
    this.elliIsAnimating = false,
    required this.activities,
  });

  @override
  List<Object?> get props => [greeting, characterMessage, elliIsAnimating, activities];

  HomeReady copyWith({
    String? greeting,
    String? characterMessage,
    bool? elliIsAnimating,
    List<Activity>? activities,
  }) {
    return HomeReady(
      greeting: greeting ?? this.greeting,
      characterMessage: characterMessage ?? this.characterMessage,
      elliIsAnimating: elliIsAnimating ?? this.elliIsAnimating,
      activities: activities ?? this.activities,
    );
  }
}

/// State when navigating to an activity
class HomeNavigating extends HomeState {
  final String activityType;

  const HomeNavigating(this.activityType);

  @override
  List<Object?> get props => [activityType];
}

/// State when an error occurs
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
