import 'dart:math';
import 'package:flutter/material.dart';

/// Виджет с анимацией медленных черепашек, греющихся на солнце
class SlowTurtles extends StatefulWidget {
  final int turtleCount;
  final Duration duration;

  const SlowTurtles({
    super.key,
    this.turtleCount = 5,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<SlowTurtles> createState() => _SlowTurtlesState();
}

class _SlowTurtlesState extends State<SlowTurtles>
    with TickerProviderStateMixin {
  late List<TurtleData> _turtles;
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _initTurtles();
  }

  void _initTurtles() {
    final random = Random();
    _turtles = [];
    _controllers = [];

    for (int i = 0; i < widget.turtleCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 2000 + random.nextInt(1000), // 2000-3000ms (медленно)
        ),
      )..repeat(reverse: true);

      _controllers.add(controller);

      _turtles.add(TurtleData(
        controller: controller,
        position: (i + 1) / (widget.turtleCount + 1), // Равномерно распределяем
        baseY: 0.5 + random.nextDouble() * 0.3, // 0.5-0.8 (нижняя часть)
        size: 45.0 + random.nextDouble() * 15, // 45-60
        delay: random.nextDouble() * 0.3, // 0-0.3 секунды
        rockAmount: 0.05 + random.nextDouble() * 0.05, // 0.05-0.1 радиан (небольшое покачивание)
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
          children: [
            // Рисуем солнце в правом верхнем углу
            Positioned(
              right: 20,
              top: 20,
              child: CustomPaint(
                size: const Size(60, 60),
                painter: SunPainter(),
              ),
            ),
            // Рисуем черепашек
            ..._turtles.map((turtle) {
              return AnimatedTurtle(
                turtle: turtle,
                containerWidth: constraints.maxWidth,
                containerHeight: constraints.maxHeight,
              );
            }),
          ],
        );
      },
    );
  }
}

/// Данные одной черепашки
class TurtleData {
  final AnimationController controller;
  final double position; // 0.0 to 1.0 (horizontal position)
  final double baseY; // 0.0 to 1.0 (vertical position)
  final double size;
  final double delay;
  final double rockAmount; // Амплитуда покачивания в радианах

  TurtleData({
    required this.controller,
    required this.position,
    required this.baseY,
    required this.size,
    required this.delay,
    required this.rockAmount,
  });
}

/// Одна анимированная черепашка
class AnimatedTurtle extends StatelessWidget {
  final TurtleData turtle;
  final double containerWidth;
  final double containerHeight;

  const AnimatedTurtle({
    super.key,
    required this.turtle,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: turtle.controller,
      builder: (context, child) {
        final progress = turtle.controller.value;

        // Задержка перед началом
        if (progress < turtle.delay) {
          return const SizedBox.shrink();
        }

        // Медленное покачивание (как будто дышит или дремлет на солнце)
        final rockProgress = sin(progress * pi * 2);
        final rotation = rockProgress * turtle.rockAmount;

        // Очень небольшое движение вверх-вниз (расслабленное дыхание)
        final breathProgress = sin(progress * pi * 1.5);
        final breathOffset = breathProgress * 2;

        // Позиция черепашки
        final x = turtle.position * containerWidth;
        final y = turtle.baseY * containerHeight + breathOffset;

        return Positioned(
          left: x - turtle.size / 2,
          top: y - turtle.size / 2,
          child: Transform.rotate(
            angle: rotation,
            child: Text(
              '🐢',
              style: TextStyle(fontSize: turtle.size),
            ),
          ),
        );
      },
    );
  }
}

/// Рисует солнце
class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700) // Золотой цвет
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Рисуем лучи
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final startX = center.dx + cos(angle) * (radius + 2);
      final startY = center.dy + sin(angle) * (radius + 2);
      final endX = center.dx + cos(angle) * (radius + 8);
      final endY = center.dy + sin(angle) * (radius + 8);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        rayPaint,
      );
    }

    // Рисуем круг солнца
    canvas.drawCircle(center, radius, paint);

    // Добавляем свечение
    paint.color = const Color(0xFFFFD700).withValues(alpha: 0.3);
    canvas.drawCircle(center, radius + 4, paint);
  }

  @override
  bool shouldRepaint(SunPainter oldDelegate) => false;
}
