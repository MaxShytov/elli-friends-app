import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String id;
  final String title;
  final String type;
  final int difficulty;
  final GameConfig config;

  const Game({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    required this.config,
  });

  @override
  List<Object?> get props => [id, title, type, difficulty, config];
}

class GameConfig extends Equatable {
  final int minNumber;
  final int maxNumber;
  final int questionsCount;
  final int timeLimit;

  const GameConfig({
    required this.minNumber,
    required this.maxNumber,
    required this.questionsCount,
    this.timeLimit = 0,
  });

  @override
  List<Object?> get props => [minNumber, maxNumber, questionsCount, timeLimit];
}

class GameQuestion extends Equatable {
  final int number;
  final String emoji;

  const GameQuestion({
    required this.number,
    required this.emoji,
  });

  @override
  List<Object?> get props => [number, emoji];
}
