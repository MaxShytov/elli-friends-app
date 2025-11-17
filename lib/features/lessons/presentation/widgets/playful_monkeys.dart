import 'dart:math';
import 'package:flutter/material.dart';

/// Виджет с анимацией игривых обезьянок, прыгающих вверх-вниз
class PlayfulMonkeys extends StatefulWidget {
  final int monkeyCount;
  final Duration duration;

  const PlayfulMonkeys({
    super.key,
    this.monkeyCount = 4,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<PlayfulMonkeys> createState() => _PlayfulMonkeysState();
}

class _PlayfulMonkeysState extends State<PlayfulMonkeys>
    with TickerProviderStateMixin {
  late List<MonkeyData> _monkeys;
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _initMonkeys();
  }

  void _initMonkeys() {
    final random = Random();
    _monkeys = [];
    _controllers = [];

    for (int i = 0; i < widget.monkeyCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 600 + random.nextInt(200), // 600-800ms
        ),
      )..repeat(reverse: true);

      _controllers.add(controller);

      _monkeys.add(MonkeyData(
        controller: controller,
        position: i / (widget.monkeyCount - 1), // 0.0 to 1.0
        jumpHeight: 30.0 + random.nextDouble() * 20, // 30-50
        delay: random.nextDouble() * 0.5, // 0-0.5 секунды
      ));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Используем LayoutBuilder для получения размеров
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _monkeys.map((monkey) {
            return AnimatedMonkey(
              monkey: monkey,
              containerWidth: constraints.maxWidth,
              containerHeight: constraints.maxHeight,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Данные одной обезьянки
class MonkeyData {
  final AnimationController controller;
  final double position; // 0.0 to 1.0 (horizontal position)
  final double jumpHeight;
  final double delay;

  MonkeyData({
    required this.controller,
    required this.position,
    required this.jumpHeight,
    required this.delay,
  });
}

/// Одна анимированная обезьянка
class AnimatedMonkey extends StatelessWidget {
  final MonkeyData monkey;
  final double containerWidth;
  final double containerHeight;

  const AnimatedMonkey({
    super.key,
    required this.monkey,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: monkey.controller,
      builder: (context, child) {
        final progress = monkey.controller.value;

        // Задержка перед началом
        if (progress < monkey.delay) {
          return const SizedBox.shrink();
        }

        // Прыжок вверх-вниз (параболическая траектория)
        final jumpProgress = sin(progress * pi);
        final jumpOffset = -jumpProgress * monkey.jumpHeight;

        // Горизонтальная позиция
        final x = monkey.position * containerWidth;

        // Вертикальная позиция (по центру + прыжок)
        final y = containerHeight / 2 + jumpOffset;

        // Небольшое вращение при прыжке
        final rotation = sin(progress * pi * 2) * 0.1;

        return Positioned(
          left: x - 30, // 30 - половина размера emoji
          top: y - 30,
          child: Transform.rotate(
            angle: rotation,
            child: const Text(
              '🐵',
              style: TextStyle(fontSize: 60),
            ),
          ),
        );
      },
    );
  }
}
