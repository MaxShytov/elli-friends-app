import 'dart:math';
import 'package:flutter/material.dart';

/// Виджет с летающими бабочками
class FlyingButterflies extends StatefulWidget {
  final int butterflyCount;
  final Duration duration;

  const FlyingButterflies({
    Key? key,
    this.butterflyCount = 12,
    this.duration = const Duration(seconds: 8),
  }) : super(key: key);

  @override
  State<FlyingButterflies> createState() => _FlyingButterfliesState();
}

class _FlyingButterfliesState extends State<FlyingButterflies>
    with TickerProviderStateMixin {
  late List<ButterflyData> _butterflies;
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _initButterflies();
  }

  void _initButterflies() {
    final random = Random();
    _butterflies = [];
    _controllers = [];

    for (int i = 0; i < widget.butterflyCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 6000 + random.nextInt(4000), // 6-10 секунд
        ),
      )..repeat();

      _controllers.add(controller);

      _butterflies.add(ButterflyData(
        controller: controller,
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        endX: random.nextDouble(),
        endY: random.nextDouble(),
        color: ButterflyColor.values[random.nextInt(ButterflyColor.values.length)],
        size: 30.0 + random.nextDouble() * 20, // 30-50
        delay: random.nextDouble() * 2, // Задержка 0-2 секунды
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
    // Используем LayoutBuilder для получения размеров, затем возвращаем Stack
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _butterflies.map((butterfly) {
            return AnimatedButterfly(
              butterfly: butterfly,
              containerWidth: constraints.maxWidth,
              containerHeight: constraints.maxHeight,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Данные одной бабочки
class ButterflyData {
  final AnimationController controller;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final ButterflyColor color;
  final double size;
  final double delay;

  ButterflyData({
    required this.controller,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
    required this.size,
    required this.delay,
  });
}

enum ButterflyColor {
  orange,
  yellow,
  blue,
  pink,
  purple,
  red,
}

/// Одна анимированная бабочка
class AnimatedButterfly extends StatelessWidget {
  final ButterflyData butterfly;
  final double containerWidth;
  final double containerHeight;

  const AnimatedButterfly({
    Key? key,
    required this.butterfly,
    required this.containerWidth,
    required this.containerHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: butterfly.controller,
      builder: (context, child) {
        final progress = butterfly.controller.value;

        // Задержка перед началом
        if (progress < butterfly.delay / 10) {
          return const SizedBox.shrink();
        }

        final adjustedProgress = (progress - butterfly.delay / 10) / (1 - butterfly.delay / 10);

        // Позиция по X с небольшими волнами
        final x = butterfly.startX +
            (butterfly.endX - butterfly.startX) * adjustedProgress;
        final waveX = sin(adjustedProgress * pi * 4) * 0.05; // Волна влево-вправо
        final finalX = (x + waveX).clamp(0.0, 1.0) * containerWidth;

        // Позиция по Y
        final y = butterfly.startY +
            (butterfly.endY - butterfly.startY) * adjustedProgress;
        final waveY = sin(adjustedProgress * pi * 3) * 0.03; // Волна вверх-вниз
        final finalY = (y + waveY).clamp(0.0, 1.0) * containerHeight;

        // Эффект "порхания" - изменение размера
        final flutter = sin(adjustedProgress * pi * 8) * 0.15 + 1.0;
        final scale = butterfly.size * flutter;

        // Небольшой наклон при полёте
        final tilt = sin(adjustedProgress * pi * 4) * 0.2;

        return Positioned(
          left: finalX - scale / 2,
          top: finalY - scale / 2,
          child: Transform.rotate(
            angle: tilt,
            child: _buildButterfly(scale),
          ),
        );
      },
    );
  }

  Widget _buildButterfly(double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: ButterflyPainter(color: butterfly.color),
    );
  }
}

/// Рисует бабочку
class ButterflyPainter extends CustomPainter {
  final ButterflyColor color;

  ButterflyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = _getColors();
    
    // Тело бабочки
    final bodyPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.12,
        height: size.height * 0.6,
      ));
    canvas.drawPath(bodyPath, bodyPaint);

    // Левое крыло (верхнее)
    paint.color = colors[0];
    _drawWing(canvas, size, paint, isLeft: true, isTop: true);

    // Левое крыло (нижнее)
    paint.color = colors[1];
    _drawWing(canvas, size, paint, isLeft: true, isTop: false);

    // Правое крыло (верхнее)
    paint.color = colors[0];
    _drawWing(canvas, size, paint, isLeft: false, isTop: true);

    // Правое крыло (нижнее)
    paint.color = colors[1];
    _drawWing(canvas, size, paint, isLeft: false, isTop: false);

    // Усики
    final antennaePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;

    final leftAntenna = Path()
      ..moveTo(size.width * 0.48, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.15,
        size.width * 0.3,
        size.height * 0.1,
      );
    canvas.drawPath(leftAntenna, antennaePaint);

    final rightAntenna = Path()
      ..moveTo(size.width * 0.52, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.15,
        size.width * 0.7,
        size.height * 0.1,
      );
    canvas.drawPath(rightAntenna, antennaePaint);
  }

  void _drawWing(Canvas canvas, Size size, Paint paint, 
      {required bool isLeft, required bool isTop}) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final path = Path();
    
    if (isTop) {
      // Верхние крылья
      if (isLeft) {
        path.moveTo(centerX, centerY - size.height * 0.1);
        path.quadraticBezierTo(
          centerX - size.width * 0.35,
          centerY - size.height * 0.25,
          centerX - size.width * 0.4,
          centerY - size.height * 0.05,
        );
        path.quadraticBezierTo(
          centerX - size.width * 0.25,
          centerY + size.height * 0.05,
          centerX,
          centerY,
        );
      } else {
        path.moveTo(centerX, centerY - size.height * 0.1);
        path.quadraticBezierTo(
          centerX + size.width * 0.35,
          centerY - size.height * 0.25,
          centerX + size.width * 0.4,
          centerY - size.height * 0.05,
        );
        path.quadraticBezierTo(
          centerX + size.width * 0.25,
          centerY + size.height * 0.05,
          centerX,
          centerY,
        );
      }
    } else {
      // Нижние крылья
      if (isLeft) {
        path.moveTo(centerX, centerY);
        path.quadraticBezierTo(
          centerX - size.width * 0.3,
          centerY + size.height * 0.1,
          centerX - size.width * 0.35,
          centerY + size.height * 0.25,
        );
        path.quadraticBezierTo(
          centerX - size.width * 0.2,
          centerY + size.height * 0.2,
          centerX,
          centerY + size.height * 0.1,
        );
      } else {
        path.moveTo(centerX, centerY);
        path.quadraticBezierTo(
          centerX + size.width * 0.3,
          centerY + size.height * 0.1,
          centerX + size.width * 0.35,
          centerY + size.height * 0.25,
        );
        path.quadraticBezierTo(
          centerX + size.width * 0.2,
          centerY + size.height * 0.2,
          centerX,
          centerY + size.height * 0.1,
        );
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);

    // Добавляем узоры на крыльях
    final patternPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    if (isTop) {
      final spotX = isLeft ? centerX - size.width * 0.25 : centerX + size.width * 0.25;
      canvas.drawCircle(
        Offset(spotX, centerY - size.height * 0.1),
        size.width * 0.05,
        patternPaint,
      );
    }
  }

  List<Color> _getColors() {
    switch (color) {
      case ButterflyColor.orange:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case ButterflyColor.yellow:
        return [Colors.yellow.shade400, Colors.yellow.shade600];
      case ButterflyColor.blue:
        return [Colors.blue.shade300, Colors.blue.shade500];
      case ButterflyColor.pink:
        return [Colors.pink.shade300, Colors.pink.shade400];
      case ButterflyColor.purple:
        return [Colors.purple.shade300, Colors.purple.shade500];
      case ButterflyColor.red:
        return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  @override
  bool shouldRepaint(ButterflyPainter oldDelegate) => false;
}

/// Пример использования на экране урока
class ButterflyLessonScreen extends StatelessWidget {
  const ButterflyLessonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Светло-зелёный фон
      body: Stack(
        children: [
          // Летающие бабочки на фоне
          const Positioned.fill(
            child: FlyingButterflies(
              butterflyCount: 12, // Количество бабочек
            ),
          ),

          // Основной контент
          SafeArea(
            child: Column(
              children: [
                // Счётчик вопросов
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '1 / 8',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

                const Spacer(),

                // Персонаж (слон)
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🐘',
                      style: TextStyle(fontSize: 80),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Одна большая бабочка (центральная)
                const Text(
                  '🦋',
                  style: TextStyle(fontSize: 60),
                ),

                const SizedBox(height: 40),

                // Текст
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Look, very beautiful butterflies have flown to us.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // Кнопка Next
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Переход на следующий экран
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
