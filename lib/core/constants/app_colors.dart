import 'package:flutter/material.dart';

/// App color palette based on jungle/nature theme design system
class AppColors {
  AppColors._();

  // Основные цвета (Primary colors)
  static const Color primary = Color(0xFF4CAF50);      // Зелёный джунглей (Jungle green)
  static const Color secondary = Color(0xFF8BC34A);    // Светло-зелёный (Light green)
  static const Color accent = Color(0xFFFFEB3B);       // Жёлтый солнечный (Sunny yellow)

  // UI элементы (UI elements)
  static const Color background = Color(0xFFF5F9F5);   // Светлый фон (Light background)
  static const Color surface = Color(0xFFFFFFFF);      // Белая поверхность (White surface)
  static const Color cardBg = Color(0xFFE8F5E9);       // Фон карточек (Card background)

  // Текст (Text)
  static const Color textPrimary = Color(0xFF2E7D32);  // Тёмно-зелёный текст (Dark green text)
  static const Color textSecondary = Color(0xFF66BB6A); // Средне-зелёный текст (Medium green text)

  // Обратная связь (Feedback)
  static const Color success = Color(0xFF4CAF50);      // Успех (Success)
  static const Color error = Color(0xFFFF6B6B);        // Ошибка (Error)
  static const Color warning = Color(0xFFFFA726);      // Предупреждение (Warning)

  // Персонажи (Characters)
  static const Color elli = Color(0xFF9E9E9E);         // Серый слон (Grey elephant - Elli)
  static const Color bono = Color(0xFFBCAAA4);         // Коричневый слон (Brown elephant - Bono)
  static const Color hippo = Color(0xFFB39DDB);        // Фиолетовый бегемот (Purple hippo)

  // Дополнительные UI цвета для совместимости с существующим кодом
  // Additional UI colors for compatibility with existing code

  // Character backgrounds
  static const Color elliBg = Color(0xFFE0E0E0);       // Светло-серый фон для Elli
  static const Color bonoBg = Color(0xFFD7CCC8);       // Светло-коричневый фон для Bono
  static const Color hippoBg = Color(0xFFE1BEE7);      // Светло-фиолетовый фон для Hippo

  // Activity button colors
  static const Color watchAgain = Color(0xFFB39DDB);   // Purple
  static const Color tryAgain = Color(0xFFFFCC80);     // Orange
  static const Color askForHint = Color(0xFF81D4FA);   // Light Blue
  static const Color seeMyScore = Color(0xFF81C784);   // Green

  // Round button colors
  static const Color speak = Color(0xFFEF9A9A);        // Coral/Red
  static const Color draw = Color(0xFFFFE082);         // Yellow
  static const Color think = Color(0xFF90CAF9);        // Blue

  // Border colors
  static const Color borderPrimary = Color(0xFF2E7D32); // Dark green
  static const Color borderSecondary = Color(0xFF8BC34A); // Light green

  // Feedback colors (extended)
  static const Color correct = success;                 // Правильно (Correct)
  static const Color incorrect = error;                 // Неправильно (Incorrect)
  static const Color hint = Color(0xFF2196F3);         // Подсказка (Hint - Blue)

  // Text colors (extended)
  static const Color textLight = Color(0xFFFFFFFF);    // Белый текст (White text)

  // Character-specific colors for CharacterWidget
  static const Color elliBlue = Color(0xFF90CAF9);      // Elli's blue color
  static const Color elliDarkBlue = Color(0xFF42A5F5);  // Elli's dark blue border
}
