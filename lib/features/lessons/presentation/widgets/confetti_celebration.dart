import 'dart:math';
import 'package:flutter/material.dart';

/// Виджет празднования с конфетти для правильных ответов
class ConfettiCelebration extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const ConfettiCelebration({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.onComplete,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Фиксированная длительность одного цикла
    );

    // Создаём частицы конфетти
    _particles = List.generate(50, (index) => ConfettiParticle());

    // Если duration очень большая (больше 10 секунд), повторяем анимацию
    if (widget.duration.inSeconds > 10) {
      _controller.repeat();
    } else {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Одна частица конфетти
class ConfettiParticle {
  late double x;
  late double startY;
  late double speedY;
  late double speedX;
  late double rotation;
  late double rotationSpeed;
  late Color color;
  late ConfettiShape shape;
  late double size;

  ConfettiParticle() {
    final random = Random();
    x = random.nextDouble();
    startY = -0.1 - random.nextDouble() * 0.1;
    speedY = 0.3 + random.nextDouble() * 0.4;
    speedX = (random.nextDouble() - 0.5) * 0.2;
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 10;
    size = 8 + random.nextDouble() * 8;

    // Яркие цвета для детей
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    color = colors[random.nextInt(colors.length)];

    shape = ConfettiShape.values[random.nextInt(ConfettiShape.values.length)];
  }
}

enum ConfettiShape {
  circle,
  square,
  star,
  heart,
}

/// Рисует частицы конфетти
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final x = particle.x * size.width + particle.speedX * progress * size.width;
      final y = particle.startY * size.height + particle.speedY * progress * size.height;

      // Пропускаем частицы, которые вышли за пределы экрана
      if (y > size.height) continue;

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * progress);

      switch (particle.shape) {
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case ConfettiShape.star:
          _drawStar(canvas, particle.size, paint);
          break;
        case ConfettiShape.heart:
          _drawHeart(canvas, particle.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;

    for (var i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final x = radius * cos(angle);
      final y = radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final width = size;
    final height = size;

    path.moveTo(width / 2, height / 4);

    // Левая часть сердца
    path.cubicTo(
      width / 2,
      height / 8,
      width / 4,
      0,
      0,
      height / 4,
    );
    path.cubicTo(
      0,
      height / 2,
      width / 4,
      3 * height / 4,
      width / 2,
      height,
    );

    // Правая часть сердца
    path.cubicTo(
      3 * width / 4,
      3 * height / 4,
      width,
      height / 2,
      width,
      height / 4,
    );
    path.cubicTo(
      width,
      0,
      3 * width / 4,
      height / 8,
      width / 2,
      height / 4,
    );

    canvas.save();
    canvas.translate(-width / 2, -height / 2);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Пример использования в экране урока
class CelebrationExample extends StatefulWidget {
  const CelebrationExample({super.key});

  @override
  State<CelebrationExample> createState() => _CelebrationExampleState();
}

class _CelebrationExampleState extends State<CelebrationExample> {
  bool _showConfetti = false;

  void _celebrate() {
    setState(() {
      _showConfetti = true;
    });

    // Скрываем конфетти через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Твой основной контент
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '2 + 2 = ?',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _celebrate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 32),
                  ),
                  child: const Text('4'),
                ),
              ],
            ),
          ),

          // Слой конфетти поверх всего
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiCelebration(
                  onComplete: () {
                    setState(() {
                      _showConfetti = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
