/// Перечисление всех анимационных эффектов для объектов и персонажей
enum AnimationEffect {
  // === БАЗОВЫЕ ЭФФЕКТЫ ПОЯВЛЕНИЯ ===
  appear,           // Мгновенное появление
  fade,             // Плавное проявление
  flyInLeft,        // Влетает слева
  flyInRight,       // Влетает справа
  flyInTop,         // Влетает сверху
  flyInBottom,      // Влетает снизу
  floatIn,          // Всплывает снизу
  split,            // Разделяется/раскрывается
  wipe,             // Стирание/проявление
  zoom,             // Увеличение от точки

  // === ЭФФЕКТНЫЕ АНИМАЦИИ ПОЯВЛЕНИЯ ===
  bounce,           // Прыгает с отскоком
  swivel,           // Поворот вокруг оси
  pinwheel,         // Вертушка
  growAndTurn,      // Увеличивается и поворачивается
  wheel,            // Появление секторами
  randomBars,       // Случайные полосы

  // === ЭФФЕКТЫ ИСЧЕЗНОВЕНИЯ ===
  disappear,        // Мгновенное исчезновение
  fadeOut,          // Плавное растворение
  flyOutLeft,       // Улетает влево
  flyOutRight,      // Улетает вправо
  flyOutTop,        // Улетает вверх
  flyOutBottom,     // Улетает вниз
  floatOut,         // Улетает вверх как шарик
  scaleOut,         // Уменьшение до точки
  dropOut,          // Падение вниз
  poof,             // Исчезновение с облачком
  spinOut,          // Исчезает с вращением

  // === АКТИВНЫЕ/IDLE АНИМАЦИИ ===
  idleBobbing,      // Легкое покачивание
  float,            // Плавание вверх-вниз
  wiggle,           // Покачивание из стороны в сторону
  pulse,            // Пульсация размера
  spin,             // Медленное вращение
  jump,             // Периодические подпрыгивания
  sway,             // Раскачивание

  // === СПЕЦИФИЧНЫЕ АНИМАЦИИ ОБЪЕКТОВ ===
  flutter,          // Бабочки - порхание крыльями
  swingDown,        // Обезьянки - спускание с деревьев
  walkSlow,         // Черепахи - медленная ходьба
  hop,              // Лягушки - прыжки
  rollIn,           // Бананы - вкатывание
  fallFromTree,     // Яблоки - падение с дерева
  waveInBreeze,     // Листья - качание на ветру
}

/// Расширение для получения рекомендованных анимаций для объектов
extension AnimationEffectRecommendations on String {
  /// Получить рекомендованную entrance анимацию для типа объекта
  AnimationEffect? getRecommendedEntranceEffect() {
    switch (this) {
      case 'butterfly': return AnimationEffect.floatIn;
      case 'monkey': return AnimationEffect.swingDown;
      case 'turtle': return AnimationEffect.walkSlow;
      case 'frog': return AnimationEffect.hop;
      case 'banana': return AnimationEffect.rollIn;
      case 'apple': return AnimationEffect.fallFromTree;
      case 'leaf': return AnimationEffect.waveInBreeze;
      default: return null;
    }
  }

  /// Получить рекомендованную active анимацию для типа объекта
  AnimationEffect? getRecommendedActiveEffect() {
    switch (this) {
      case 'butterfly': return AnimationEffect.flutter;
      case 'monkey': return null; // Используется swingDown как entrance
      case 'turtle': return AnimationEffect.walkSlow;
      case 'frog': return AnimationEffect.hop;
      case 'leaf': return AnimationEffect.waveInBreeze;
      default: return AnimationEffect.idleBobbing;
    }
  }

  /// Получить рекомендованную exit анимацию для типа объекта
  AnimationEffect? getRecommendedExitEffect() {
    switch (this) {
      case 'butterfly': return AnimationEffect.flyOutTop;
      case 'monkey': return AnimationEffect.fadeOut;
      case 'turtle': return AnimationEffect.walkSlow;
      case 'frog': return AnimationEffect.hop;
      case 'banana': return AnimationEffect.fadeOut;
      case 'apple': return AnimationEffect.fadeOut;
      case 'leaf': return AnimationEffect.fadeOut;
      default: return AnimationEffect.fadeOut;
    }
  }
}
