import 'package:equatable/equatable.dart';

/// Base class for all Home screen events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the home screen is initialized
class HomeInitialized extends HomeEvent {
  const HomeInitialized();
}

/// Event triggered when an activity button is tapped
class ActivityTapped extends HomeEvent {
  final String activityType;

  const ActivityTapped(this.activityType);

  @override
  List<Object?> get props => [activityType];
}

/// Event triggered when Elli character is tapped (for interaction)
class ElliTapped extends HomeEvent {
  const ElliTapped();
}

/// Event triggered when language is changed
class LanguageChanged extends HomeEvent {
  final String languageCode;

  const LanguageChanged(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}
