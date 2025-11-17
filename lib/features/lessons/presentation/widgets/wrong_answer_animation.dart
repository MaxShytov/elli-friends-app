import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';

/// Виджет анимации для неправильного ответа
/// Мягко показывает ребёнку, что ответ не верный
class WrongAnswerAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final bool playSound;
  final bool showRetryMessage;
  final WrongAnswerStyle style;

  const WrongAnswerAnimation({
    Key? key,
    required this.child,
    this.onComplete,
    this.playSound = true,
    this.showRetryMessage = true,
    this.style = WrongAnswerStyle.shake,
  }) : super(key: key);

  @override
  State<WrongAnswerAnimation> createState() => _WrongAnswerAnimationState();
}

class _WrongAnswerAnimationState extends State<WrongAnswerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Анимация тряски
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Анимация затухания (для крестика)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Анимация масштаба
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.playSound) {
      _playSound();
    }

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  Future<void> _playSound() async {
    try {
      // Лёгкая вибрация для тактильной обратной связи
      await HapticFeedback.lightImpact();

      // TODO: Замени на свой звук "упс" или "попробуй снова"
      // AudioManager.instance.playSound('wrong_answer');
    } catch (e) {
      debugPrint('Error playing wrong answer sound: $e');
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
        switch (widget.style) {
          case WrongAnswerStyle.shake:
            return _buildShakeStyle();
          case WrongAnswerStyle.pulse:
            return _buildPulseStyle();
          case WrongAnswerStyle.cross:
            return _buildCrossStyle();
          case WrongAnswerStyle.gentle:
            return _buildGentleStyle();
        }
      },
    );
  }

  // Стиль 1: Тряска (самый популярный)
  Widget _buildShakeStyle() {
    return Transform.translate(
      offset: Offset(_shakeAnimation.value, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red.withOpacity(_fadeAnimation.value * 0.5),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: widget.child,
      ),
    );
  }

  // Стиль 2: Пульсация с красным оттенком
  Widget _buildPulseStyle() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(_fadeAnimation.value * 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: widget.child,
      ),
    );
  }

  // Стиль 3: Крестик поверх
  Widget _buildCrossStyle() {
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(_shakeAnimation.value * 0.5, 0),
          child: widget.child,
        ),
        Positioned.fill(
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Стиль 4: Мягкий (только лёгкая тряска)
  Widget _buildGentleStyle() {
    return Transform.translate(
      offset: Offset(_shakeAnimation.value * 0.3, 0),
      child: widget.child,
    );
  }
}

enum WrongAnswerStyle {
  shake,    // Тряска с красной рамкой
  pulse,    // Пульсация с красным оттенком
  cross,    // Большой красный крестик
  gentle,   // Мягкая тряска без визуалов
}

/// Виджет с сообщением "Попробуй ещё раз!" (с кнопками "Попробовать снова" и "Пропустить")
class TryAgainMessage extends StatefulWidget {
  final VoidCallback? onTryAgain;
  final VoidCallback? onSkip;

  const TryAgainMessage({
    Key? key,
    this.onTryAgain,
    this.onSkip,
  }) : super(key: key);

  @override
  State<TryAgainMessage> createState() => _TryAgainMessageState();
}

class _TryAgainMessageState extends State<TryAgainMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Появление с эластичным эффектом
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Кнопка "Попробуй ещё раз"
              GestureDetector(
                onTap: widget.onTryAgain,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.orange,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.tryAgain,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Кнопка "Пропустить"
              GestureDetector(
                onTap: widget.onSkip,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.skip_next,
                        color: Colors.grey.shade700,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.skip,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Виджет грустного персонажа (Бонно качает головой)
class SadCharacterAnimation extends StatefulWidget {
  final String? characterAsset;
  final Duration duration;
  final VoidCallback? onComplete;

  const SadCharacterAnimation({
    Key? key,
    this.characterAsset,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  }) : super(key: key);

  @override
  State<SadCharacterAnimation> createState() => _SadCharacterAnimationState();
}

class _SadCharacterAnimationState extends State<SadCharacterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headShakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Персонаж качает головой "нет-нет-нет"
    _headShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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
        return Transform.rotate(
          angle: _headShakeAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: Замени на своего персонажа (Бонно)
              // Image.asset(widget.characterAsset ?? 'assets/characters/bono_sad.png')
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '😔',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Упс! Не совсем...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Пример использования в экране урока
class WrongAnswerExample extends StatefulWidget {
  const WrongAnswerExample({Key? key}) : super(key: key);

  @override
  State<WrongAnswerExample> createState() => _WrongAnswerExampleState();
}

class _WrongAnswerExampleState extends State<WrongAnswerExample> {
  bool _showWrongAnimation = false;
  bool _showTryAgain = false;
  bool _showSadCharacter = false;
  WrongAnswerStyle _selectedStyle = WrongAnswerStyle.shake;

  void _onWrongAnswer() {
    setState(() {
      _showWrongAnimation = true;
    });

    // Через 0.6 секунды показываем сообщение
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showWrongAnimation = false;
          _showTryAgain = true;
        });
      }
    });

    // Через 2 секунды убираем всё
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        setState(() {
          _showTryAgain = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Сколько будет 2 + 2?',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                
                // Кнопки с ответами
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnswerButton('3', isCorrect: false),
                    const SizedBox(width: 20),
                    _buildAnswerButton('4', isCorrect: true),
                    const SizedBox(width: 20),
                    _buildAnswerButton('5', isCorrect: false),
                  ],
                ),

                const SizedBox(height: 60),

                // Выбор стиля анимации
                const Text(
                  'Выбери стиль анимации:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildStyleChip('Тряска', WrongAnswerStyle.shake),
                    _buildStyleChip('Пульсация', WrongAnswerStyle.pulse),
                    _buildStyleChip('Крестик', WrongAnswerStyle.cross),
                    _buildStyleChip('Мягкая', WrongAnswerStyle.gentle),
                  ],
                ),
              ],
            ),
          ),

          // Сообщение "Попробуй ещё раз"
          if (_showTryAgain)
            const Positioned.fill(
              child: Center(
                child: TryAgainMessage(),
              ),
            ),

          // Грустный персонаж
          if (_showSadCharacter)
            Positioned.fill(
              child: Center(
                child: SadCharacterAnimation(
                  onComplete: () {
                    setState(() => _showSadCharacter = false);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String answer, {required bool isCorrect}) {
    Widget button = ElevatedButton(
      onPressed: () {
        if (isCorrect) {
          // Показываем конфетти
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Правильно! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _onWrongAnswer();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        textStyle: const TextStyle(fontSize: 32),
        backgroundColor: Colors.white,
      ),
      child: Text(answer),
    );

    // Оборачиваем в анимацию только если показываем её
    if (_showWrongAnimation && !isCorrect) {
      return WrongAnswerAnimation(
        style: _selectedStyle,
        onComplete: () {
          setState(() => _showWrongAnimation = false);
        },
        child: button,
      );
    }

    return button;
  }

  Widget _buildStyleChip(String label, WrongAnswerStyle style) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedStyle == style,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStyle = style);
        }
      },
    );
  }
}
