import 'dart:math';
import 'package:flutter/material.dart';

/// Виджет с анимацией поющих птичек на ветках
class SingingBirds extends StatefulWidget {
  final int birdCount;
  final Duration duration;

  const SingingBirds({
    super.key,
    this.birdCount = 2,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<SingingBirds> createState() => _SingingBirdsState();
}

class _SingingBirdsState extends State<SingingBirds>
    with TickerProviderStateMixin {
  late List<BirdData> _birds;
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _initBirds();
  }

  void _initBirds() {
    final random = Random();
    _birds = [];
    _controllers = [];

    for (int i = 0; i < widget.birdCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 800 + random.nextInt(400), // 800-1200ms
        ),
      )..repeat(reverse: true);

      _controllers.add(controller);

      _birds.add(BirdData(
        controller: controller,
        position: (i + 1) / (widget.birdCount + 1), // Равномерно распределяем
        branchY: 0.15 + random.nextDouble() * 0.25, // 0.15-0.4 (выше, чем было)
        size: 50.0 + random.nextDouble() * 10, // 50-60
        delay: random.nextDouble() * 0.3, // 0-0.3 секунды
        swingAmount: 0.1 + random.nextDouble() * 0.1, // 0.1-0.2 радиан
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
            // Рисуем ветки для каждой птички
            ..._birds.map((bird) {
              return Positioned(
                left: 0,
                right: 0,
                top: bird.branchY * constraints.maxHeight,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 4),
                  painter: BranchPainter(),
                ),
              );
            }),
            // Рисуем птичек
            ..._birds.map((bird) {
              return AnimatedBird(
                bird: bird,
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

/// Данные одной птички
class BirdData {
  final AnimationController controller;
  final double position; // 0.0 to 1.0 (horizontal position)
  final double branchY; // 0.0 to 1.0 (vertical position of branch)
  final double size;
  final double delay;
  final double swingAmount; // Амплитуда покачивания в радианах

  BirdData({
    required this.controller,
    required this.position,
    required this.branchY,
    required this.size,
    required this.delay,
    required this.swingAmount,
  });
}

/// Одна анимированная птичка
class AnimatedBird extends StatelessWidget {
  final BirdData bird;
  final double containerWidth;
  final double containerHeight;

  const AnimatedBird({
    super.key,
    required this.bird,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bird.controller,
      builder: (context, child) {
        final progress = bird.controller.value;

        // Задержка перед началом
        if (progress < bird.delay) {
          return const SizedBox.shrink();
        }

        // Покачивание влево-вправо (как будто поет)
        final swingProgress = sin(progress * pi * 2);
        final rotation = swingProgress * bird.swingAmount;

        // Небольшое движение вверх-вниз (открывает клюв)
        final bobProgress = sin(progress * pi * 4);
        final bobOffset = bobProgress * 3;

        // Позиция птички
        final x = bird.position * containerWidth;
        final y = bird.branchY * containerHeight + bobOffset;

        return Positioned(
          left: x - bird.size / 2,
          top: y - bird.size / 2,
          child: Transform.rotate(
            angle: rotation,
            child: Text(
              '🐦',
              style: TextStyle(fontSize: bird.size),
            ),
          ),
        );
      },
    );
  }
}

/// Рисует ветку дерева
class BranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513) // Коричневый цвет
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Рисуем волнистую ветку
    final path = Path();
    path.moveTo(0, size.height / 2);

    final curvePoints = 8;
    for (int i = 0; i <= curvePoints; i++) {
      final x = (i / curvePoints) * size.width;
      final y = size.height / 2 + sin(i * 0.5) * 2;

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevX = ((i - 1) / curvePoints) * size.width;
        final prevY = size.height / 2 + sin((i - 1) * 0.5) * 2;
        final cpX = (prevX + x) / 2;
        final cpY = (prevY + y) / 2;
        path.quadraticBezierTo(cpX, cpY, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Рисуем листочки на ветке
    final leafPaint = Paint()
      ..color = const Color(0xFF228B22) // Зеленый цвет
      ..style = PaintingStyle.fill;

    for (int i = 1; i < curvePoints; i += 2) {
      final x = (i / curvePoints) * size.width;
      final y = size.height / 2;

      // Маленький листочек
      canvas.drawCircle(
        Offset(x, y - 5),
        3,
        leafPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BranchPainter oldDelegate) => false;
}
