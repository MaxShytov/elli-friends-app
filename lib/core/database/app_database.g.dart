// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LessonsTable extends Lessons with TableInfo<$LessonsTable, Lesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleJsonMeta = const VerificationMeta(
    'titleJson',
  );
  @override
  late final GeneratedColumn<String> titleJson = GeneratedColumn<String>(
    'title_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionJsonMeta = const VerificationMeta(
    'descriptionJson',
  );
  @override
  late final GeneratedColumn<String> descriptionJson = GeneratedColumn<String>(
    'description_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    topic,
    difficulty,
    tags,
    titleJson,
    descriptionJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('title_json')) {
      context.handle(
        _titleJsonMeta,
        titleJson.isAcceptableOrUnknown(data['title_json']!, _titleJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_titleJsonMeta);
    }
    if (data.containsKey('description_json')) {
      context.handle(
        _descriptionJsonMeta,
        descriptionJson.isAcceptableOrUnknown(
          data['description_json']!,
          _descriptionJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lesson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      titleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_json'],
      )!,
      descriptionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }
}

class Lesson extends DataClass implements Insertable<Lesson> {
  final int id;
  final String lessonId;
  final String topic;
  final int difficulty;
  final String tags;
  final String titleJson;
  final String descriptionJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Lesson({
    required this.id,
    required this.lessonId,
    required this.topic,
    required this.difficulty,
    required this.tags,
    required this.titleJson,
    required this.descriptionJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['topic'] = Variable<String>(topic);
    map['difficulty'] = Variable<int>(difficulty);
    map['tags'] = Variable<String>(tags);
    map['title_json'] = Variable<String>(titleJson);
    map['description_json'] = Variable<String>(descriptionJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      topic: Value(topic),
      difficulty: Value(difficulty),
      tags: Value(tags),
      titleJson: Value(titleJson),
      descriptionJson: Value(descriptionJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Lesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lesson(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      topic: serializer.fromJson<String>(json['topic']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      tags: serializer.fromJson<String>(json['tags']),
      titleJson: serializer.fromJson<String>(json['titleJson']),
      descriptionJson: serializer.fromJson<String>(json['descriptionJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'topic': serializer.toJson<String>(topic),
      'difficulty': serializer.toJson<int>(difficulty),
      'tags': serializer.toJson<String>(tags),
      'titleJson': serializer.toJson<String>(titleJson),
      'descriptionJson': serializer.toJson<String>(descriptionJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Lesson copyWith({
    int? id,
    String? lessonId,
    String? topic,
    int? difficulty,
    String? tags,
    String? titleJson,
    String? descriptionJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Lesson(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    topic: topic ?? this.topic,
    difficulty: difficulty ?? this.difficulty,
    tags: tags ?? this.tags,
    titleJson: titleJson ?? this.titleJson,
    descriptionJson: descriptionJson ?? this.descriptionJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Lesson copyWithCompanion(LessonsCompanion data) {
    return Lesson(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      topic: data.topic.present ? data.topic.value : this.topic,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      tags: data.tags.present ? data.tags.value : this.tags,
      titleJson: data.titleJson.present ? data.titleJson.value : this.titleJson,
      descriptionJson: data.descriptionJson.present
          ? data.descriptionJson.value
          : this.descriptionJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lesson(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('topic: $topic, ')
          ..write('difficulty: $difficulty, ')
          ..write('tags: $tags, ')
          ..write('titleJson: $titleJson, ')
          ..write('descriptionJson: $descriptionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    topic,
    difficulty,
    tags,
    titleJson,
    descriptionJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lesson &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.topic == this.topic &&
          other.difficulty == this.difficulty &&
          other.tags == this.tags &&
          other.titleJson == this.titleJson &&
          other.descriptionJson == this.descriptionJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LessonsCompanion extends UpdateCompanion<Lesson> {
  final Value<int> id;
  final Value<String> lessonId;
  final Value<String> topic;
  final Value<int> difficulty;
  final Value<String> tags;
  final Value<String> titleJson;
  final Value<String> descriptionJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LessonsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.topic = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.tags = const Value.absent(),
    this.titleJson = const Value.absent(),
    this.descriptionJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LessonsCompanion.insert({
    this.id = const Value.absent(),
    required String lessonId,
    required String topic,
    this.difficulty = const Value.absent(),
    required String tags,
    required String titleJson,
    required String descriptionJson,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : lessonId = Value(lessonId),
       topic = Value(topic),
       tags = Value(tags),
       titleJson = Value(titleJson),
       descriptionJson = Value(descriptionJson);
  static Insertable<Lesson> custom({
    Expression<int>? id,
    Expression<String>? lessonId,
    Expression<String>? topic,
    Expression<int>? difficulty,
    Expression<String>? tags,
    Expression<String>? titleJson,
    Expression<String>? descriptionJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (topic != null) 'topic': topic,
      if (difficulty != null) 'difficulty': difficulty,
      if (tags != null) 'tags': tags,
      if (titleJson != null) 'title_json': titleJson,
      if (descriptionJson != null) 'description_json': descriptionJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LessonsCompanion copyWith({
    Value<int>? id,
    Value<String>? lessonId,
    Value<String>? topic,
    Value<int>? difficulty,
    Value<String>? tags,
    Value<String>? titleJson,
    Value<String>? descriptionJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LessonsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      titleJson: titleJson ?? this.titleJson,
      descriptionJson: descriptionJson ?? this.descriptionJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (titleJson.present) {
      map['title_json'] = Variable<String>(titleJson.value);
    }
    if (descriptionJson.present) {
      map['description_json'] = Variable<String>(descriptionJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('topic: $topic, ')
          ..write('difficulty: $difficulty, ')
          ..write('tags: $tags, ')
          ..write('titleJson: $titleJson, ')
          ..write('descriptionJson: $descriptionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScenesTable extends Scenes with TableInfo<$ScenesTable, Scene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lessons (id)',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _animationMeta = const VerificationMeta(
    'animation',
  );
  @override
  late final GeneratedColumn<String> animation = GeneratedColumn<String>(
    'animation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondCharacterMeta = const VerificationMeta(
    'secondCharacter',
  );
  @override
  late final GeneratedColumn<String> secondCharacter = GeneratedColumn<String>(
    'second_character',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondAnimationMeta = const VerificationMeta(
    'secondAnimation',
  );
  @override
  late final GeneratedColumn<String> secondAnimation = GeneratedColumn<String>(
    'second_animation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondEmotionMeta = const VerificationMeta(
    'secondEmotion',
  );
  @override
  late final GeneratedColumn<String> secondEmotion = GeneratedColumn<String>(
    'second_emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dialogueJsonMeta = const VerificationMeta(
    'dialogueJson',
  );
  @override
  late final GeneratedColumn<String> dialogueJson = GeneratedColumn<String>(
    'dialogue_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buttonTitleJsonMeta = const VerificationMeta(
    'buttonTitleJson',
  );
  @override
  late final GeneratedColumn<String> buttonTitleJson = GeneratedColumn<String>(
    'button_title_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toneMeta = const VerificationMeta('tone');
  @override
  late final GeneratedColumn<String> tone = GeneratedColumn<String>(
    'tone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transitionTypeMeta = const VerificationMeta(
    'transitionType',
  );
  @override
  late final GeneratedColumn<String> transitionType = GeneratedColumn<String>(
    'transition_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isQuestionMeta = const VerificationMeta(
    'isQuestion',
  );
  @override
  late final GeneratedColumn<bool> isQuestion = GeneratedColumn<bool>(
    'is_question',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_question" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPauseMeta = const VerificationMeta(
    'isPause',
  );
  @override
  late final GeneratedColumn<bool> isPause = GeneratedColumn<bool>(
    'is_pause',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pause" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<int> correctAnswer = GeneratedColumn<int>(
    'correct_answer',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waitForAnswerMeta = const VerificationMeta(
    'waitForAnswer',
  );
  @override
  late final GeneratedColumn<bool> waitForAnswer = GeneratedColumn<bool>(
    'wait_for_answer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wait_for_answer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showPreviousAnimalsMeta =
      const VerificationMeta('showPreviousAnimals');
  @override
  late final GeneratedColumn<bool> showPreviousAnimals = GeneratedColumn<bool>(
    'show_previous_animals',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_previous_animals" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _animalsJsonMeta = const VerificationMeta(
    'animalsJson',
  );
  @override
  late final GeneratedColumn<String> animalsJson = GeneratedColumn<String>(
    'animals_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioFilesJsonMeta = const VerificationMeta(
    'audioFilesJson',
  );
  @override
  late final GeneratedColumn<String> audioFilesJson = GeneratedColumn<String>(
    'audio_files_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioStaleJsonMeta = const VerificationMeta(
    'audioStaleJson',
  );
  @override
  late final GeneratedColumn<String> audioStaleJson = GeneratedColumn<String>(
    'audio_stale_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    orderIndex,
    character,
    animation,
    emotion,
    secondCharacter,
    secondAnimation,
    secondEmotion,
    dialogueJson,
    buttonTitleJson,
    duration,
    tone,
    transitionType,
    isQuestion,
    isPause,
    correctAnswer,
    waitForAnswer,
    showPreviousAnimals,
    animalsJson,
    audioFilesJson,
    audioStaleJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scene> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    }
    if (data.containsKey('animation')) {
      context.handle(
        _animationMeta,
        animation.isAcceptableOrUnknown(data['animation']!, _animationMeta),
      );
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    }
    if (data.containsKey('second_character')) {
      context.handle(
        _secondCharacterMeta,
        secondCharacter.isAcceptableOrUnknown(
          data['second_character']!,
          _secondCharacterMeta,
        ),
      );
    }
    if (data.containsKey('second_animation')) {
      context.handle(
        _secondAnimationMeta,
        secondAnimation.isAcceptableOrUnknown(
          data['second_animation']!,
          _secondAnimationMeta,
        ),
      );
    }
    if (data.containsKey('second_emotion')) {
      context.handle(
        _secondEmotionMeta,
        secondEmotion.isAcceptableOrUnknown(
          data['second_emotion']!,
          _secondEmotionMeta,
        ),
      );
    }
    if (data.containsKey('dialogue_json')) {
      context.handle(
        _dialogueJsonMeta,
        dialogueJson.isAcceptableOrUnknown(
          data['dialogue_json']!,
          _dialogueJsonMeta,
        ),
      );
    }
    if (data.containsKey('button_title_json')) {
      context.handle(
        _buttonTitleJsonMeta,
        buttonTitleJson.isAcceptableOrUnknown(
          data['button_title_json']!,
          _buttonTitleJsonMeta,
        ),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('tone')) {
      context.handle(
        _toneMeta,
        tone.isAcceptableOrUnknown(data['tone']!, _toneMeta),
      );
    }
    if (data.containsKey('transition_type')) {
      context.handle(
        _transitionTypeMeta,
        transitionType.isAcceptableOrUnknown(
          data['transition_type']!,
          _transitionTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_question')) {
      context.handle(
        _isQuestionMeta,
        isQuestion.isAcceptableOrUnknown(data['is_question']!, _isQuestionMeta),
      );
    }
    if (data.containsKey('is_pause')) {
      context.handle(
        _isPauseMeta,
        isPause.isAcceptableOrUnknown(data['is_pause']!, _isPauseMeta),
      );
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    }
    if (data.containsKey('wait_for_answer')) {
      context.handle(
        _waitForAnswerMeta,
        waitForAnswer.isAcceptableOrUnknown(
          data['wait_for_answer']!,
          _waitForAnswerMeta,
        ),
      );
    }
    if (data.containsKey('show_previous_animals')) {
      context.handle(
        _showPreviousAnimalsMeta,
        showPreviousAnimals.isAcceptableOrUnknown(
          data['show_previous_animals']!,
          _showPreviousAnimalsMeta,
        ),
      );
    }
    if (data.containsKey('animals_json')) {
      context.handle(
        _animalsJsonMeta,
        animalsJson.isAcceptableOrUnknown(
          data['animals_json']!,
          _animalsJsonMeta,
        ),
      );
    }
    if (data.containsKey('audio_files_json')) {
      context.handle(
        _audioFilesJsonMeta,
        audioFilesJson.isAcceptableOrUnknown(
          data['audio_files_json']!,
          _audioFilesJsonMeta,
        ),
      );
    }
    if (data.containsKey('audio_stale_json')) {
      context.handle(
        _audioStaleJsonMeta,
        audioStaleJson.isAcceptableOrUnknown(
          data['audio_stale_json']!,
          _audioStaleJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scene(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      ),
      animation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animation'],
      ),
      emotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion'],
      ),
      secondCharacter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}second_character'],
      ),
      secondAnimation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}second_animation'],
      ),
      secondEmotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}second_emotion'],
      ),
      dialogueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dialogue_json'],
      ),
      buttonTitleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}button_title_json'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      tone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone'],
      ),
      transitionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transition_type'],
      ),
      isQuestion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_question'],
      )!,
      isPause: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pause'],
      )!,
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answer'],
      ),
      waitForAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wait_for_answer'],
      )!,
      showPreviousAnimals: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_previous_animals'],
      )!,
      animalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animals_json'],
      ),
      audioFilesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_files_json'],
      ),
      audioStaleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_stale_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScenesTable createAlias(String alias) {
    return $ScenesTable(attachedDatabase, alias);
  }
}

class Scene extends DataClass implements Insertable<Scene> {
  final int id;
  final int lessonId;
  final int orderIndex;
  final String? character;
  final String? animation;
  final String? emotion;
  final String? secondCharacter;
  final String? secondAnimation;
  final String? secondEmotion;
  final String? dialogueJson;
  final String? buttonTitleJson;
  final int? duration;
  final String? tone;
  final String? transitionType;
  final bool isQuestion;
  final bool isPause;
  final int? correctAnswer;
  final bool waitForAnswer;
  final bool showPreviousAnimals;
  final String? animalsJson;
  final String? audioFilesJson;
  final String? audioStaleJson;
  final DateTime updatedAt;
  const Scene({
    required this.id,
    required this.lessonId,
    required this.orderIndex,
    this.character,
    this.animation,
    this.emotion,
    this.secondCharacter,
    this.secondAnimation,
    this.secondEmotion,
    this.dialogueJson,
    this.buttonTitleJson,
    this.duration,
    this.tone,
    this.transitionType,
    required this.isQuestion,
    required this.isPause,
    this.correctAnswer,
    required this.waitForAnswer,
    required this.showPreviousAnimals,
    this.animalsJson,
    this.audioFilesJson,
    this.audioStaleJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<int>(lessonId);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || character != null) {
      map['character'] = Variable<String>(character);
    }
    if (!nullToAbsent || animation != null) {
      map['animation'] = Variable<String>(animation);
    }
    if (!nullToAbsent || emotion != null) {
      map['emotion'] = Variable<String>(emotion);
    }
    if (!nullToAbsent || secondCharacter != null) {
      map['second_character'] = Variable<String>(secondCharacter);
    }
    if (!nullToAbsent || secondAnimation != null) {
      map['second_animation'] = Variable<String>(secondAnimation);
    }
    if (!nullToAbsent || secondEmotion != null) {
      map['second_emotion'] = Variable<String>(secondEmotion);
    }
    if (!nullToAbsent || dialogueJson != null) {
      map['dialogue_json'] = Variable<String>(dialogueJson);
    }
    if (!nullToAbsent || buttonTitleJson != null) {
      map['button_title_json'] = Variable<String>(buttonTitleJson);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    if (!nullToAbsent || tone != null) {
      map['tone'] = Variable<String>(tone);
    }
    if (!nullToAbsent || transitionType != null) {
      map['transition_type'] = Variable<String>(transitionType);
    }
    map['is_question'] = Variable<bool>(isQuestion);
    map['is_pause'] = Variable<bool>(isPause);
    if (!nullToAbsent || correctAnswer != null) {
      map['correct_answer'] = Variable<int>(correctAnswer);
    }
    map['wait_for_answer'] = Variable<bool>(waitForAnswer);
    map['show_previous_animals'] = Variable<bool>(showPreviousAnimals);
    if (!nullToAbsent || animalsJson != null) {
      map['animals_json'] = Variable<String>(animalsJson);
    }
    if (!nullToAbsent || audioFilesJson != null) {
      map['audio_files_json'] = Variable<String>(audioFilesJson);
    }
    if (!nullToAbsent || audioStaleJson != null) {
      map['audio_stale_json'] = Variable<String>(audioStaleJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScenesCompanion toCompanion(bool nullToAbsent) {
    return ScenesCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      orderIndex: Value(orderIndex),
      character: character == null && nullToAbsent
          ? const Value.absent()
          : Value(character),
      animation: animation == null && nullToAbsent
          ? const Value.absent()
          : Value(animation),
      emotion: emotion == null && nullToAbsent
          ? const Value.absent()
          : Value(emotion),
      secondCharacter: secondCharacter == null && nullToAbsent
          ? const Value.absent()
          : Value(secondCharacter),
      secondAnimation: secondAnimation == null && nullToAbsent
          ? const Value.absent()
          : Value(secondAnimation),
      secondEmotion: secondEmotion == null && nullToAbsent
          ? const Value.absent()
          : Value(secondEmotion),
      dialogueJson: dialogueJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dialogueJson),
      buttonTitleJson: buttonTitleJson == null && nullToAbsent
          ? const Value.absent()
          : Value(buttonTitleJson),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      tone: tone == null && nullToAbsent ? const Value.absent() : Value(tone),
      transitionType: transitionType == null && nullToAbsent
          ? const Value.absent()
          : Value(transitionType),
      isQuestion: Value(isQuestion),
      isPause: Value(isPause),
      correctAnswer: correctAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(correctAnswer),
      waitForAnswer: Value(waitForAnswer),
      showPreviousAnimals: Value(showPreviousAnimals),
      animalsJson: animalsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(animalsJson),
      audioFilesJson: audioFilesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilesJson),
      audioStaleJson: audioStaleJson == null && nullToAbsent
          ? const Value.absent()
          : Value(audioStaleJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory Scene.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scene(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<int>(json['lessonId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      character: serializer.fromJson<String?>(json['character']),
      animation: serializer.fromJson<String?>(json['animation']),
      emotion: serializer.fromJson<String?>(json['emotion']),
      secondCharacter: serializer.fromJson<String?>(json['secondCharacter']),
      secondAnimation: serializer.fromJson<String?>(json['secondAnimation']),
      secondEmotion: serializer.fromJson<String?>(json['secondEmotion']),
      dialogueJson: serializer.fromJson<String?>(json['dialogueJson']),
      buttonTitleJson: serializer.fromJson<String?>(json['buttonTitleJson']),
      duration: serializer.fromJson<int?>(json['duration']),
      tone: serializer.fromJson<String?>(json['tone']),
      transitionType: serializer.fromJson<String?>(json['transitionType']),
      isQuestion: serializer.fromJson<bool>(json['isQuestion']),
      isPause: serializer.fromJson<bool>(json['isPause']),
      correctAnswer: serializer.fromJson<int?>(json['correctAnswer']),
      waitForAnswer: serializer.fromJson<bool>(json['waitForAnswer']),
      showPreviousAnimals: serializer.fromJson<bool>(
        json['showPreviousAnimals'],
      ),
      animalsJson: serializer.fromJson<String?>(json['animalsJson']),
      audioFilesJson: serializer.fromJson<String?>(json['audioFilesJson']),
      audioStaleJson: serializer.fromJson<String?>(json['audioStaleJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<int>(lessonId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'character': serializer.toJson<String?>(character),
      'animation': serializer.toJson<String?>(animation),
      'emotion': serializer.toJson<String?>(emotion),
      'secondCharacter': serializer.toJson<String?>(secondCharacter),
      'secondAnimation': serializer.toJson<String?>(secondAnimation),
      'secondEmotion': serializer.toJson<String?>(secondEmotion),
      'dialogueJson': serializer.toJson<String?>(dialogueJson),
      'buttonTitleJson': serializer.toJson<String?>(buttonTitleJson),
      'duration': serializer.toJson<int?>(duration),
      'tone': serializer.toJson<String?>(tone),
      'transitionType': serializer.toJson<String?>(transitionType),
      'isQuestion': serializer.toJson<bool>(isQuestion),
      'isPause': serializer.toJson<bool>(isPause),
      'correctAnswer': serializer.toJson<int?>(correctAnswer),
      'waitForAnswer': serializer.toJson<bool>(waitForAnswer),
      'showPreviousAnimals': serializer.toJson<bool>(showPreviousAnimals),
      'animalsJson': serializer.toJson<String?>(animalsJson),
      'audioFilesJson': serializer.toJson<String?>(audioFilesJson),
      'audioStaleJson': serializer.toJson<String?>(audioStaleJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Scene copyWith({
    int? id,
    int? lessonId,
    int? orderIndex,
    Value<String?> character = const Value.absent(),
    Value<String?> animation = const Value.absent(),
    Value<String?> emotion = const Value.absent(),
    Value<String?> secondCharacter = const Value.absent(),
    Value<String?> secondAnimation = const Value.absent(),
    Value<String?> secondEmotion = const Value.absent(),
    Value<String?> dialogueJson = const Value.absent(),
    Value<String?> buttonTitleJson = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    Value<String?> tone = const Value.absent(),
    Value<String?> transitionType = const Value.absent(),
    bool? isQuestion,
    bool? isPause,
    Value<int?> correctAnswer = const Value.absent(),
    bool? waitForAnswer,
    bool? showPreviousAnimals,
    Value<String?> animalsJson = const Value.absent(),
    Value<String?> audioFilesJson = const Value.absent(),
    Value<String?> audioStaleJson = const Value.absent(),
    DateTime? updatedAt,
  }) => Scene(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    orderIndex: orderIndex ?? this.orderIndex,
    character: character.present ? character.value : this.character,
    animation: animation.present ? animation.value : this.animation,
    emotion: emotion.present ? emotion.value : this.emotion,
    secondCharacter: secondCharacter.present
        ? secondCharacter.value
        : this.secondCharacter,
    secondAnimation: secondAnimation.present
        ? secondAnimation.value
        : this.secondAnimation,
    secondEmotion: secondEmotion.present
        ? secondEmotion.value
        : this.secondEmotion,
    dialogueJson: dialogueJson.present ? dialogueJson.value : this.dialogueJson,
    buttonTitleJson: buttonTitleJson.present
        ? buttonTitleJson.value
        : this.buttonTitleJson,
    duration: duration.present ? duration.value : this.duration,
    tone: tone.present ? tone.value : this.tone,
    transitionType: transitionType.present
        ? transitionType.value
        : this.transitionType,
    isQuestion: isQuestion ?? this.isQuestion,
    isPause: isPause ?? this.isPause,
    correctAnswer: correctAnswer.present
        ? correctAnswer.value
        : this.correctAnswer,
    waitForAnswer: waitForAnswer ?? this.waitForAnswer,
    showPreviousAnimals: showPreviousAnimals ?? this.showPreviousAnimals,
    animalsJson: animalsJson.present ? animalsJson.value : this.animalsJson,
    audioFilesJson: audioFilesJson.present
        ? audioFilesJson.value
        : this.audioFilesJson,
    audioStaleJson: audioStaleJson.present
        ? audioStaleJson.value
        : this.audioStaleJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Scene copyWithCompanion(ScenesCompanion data) {
    return Scene(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      character: data.character.present ? data.character.value : this.character,
      animation: data.animation.present ? data.animation.value : this.animation,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      secondCharacter: data.secondCharacter.present
          ? data.secondCharacter.value
          : this.secondCharacter,
      secondAnimation: data.secondAnimation.present
          ? data.secondAnimation.value
          : this.secondAnimation,
      secondEmotion: data.secondEmotion.present
          ? data.secondEmotion.value
          : this.secondEmotion,
      dialogueJson: data.dialogueJson.present
          ? data.dialogueJson.value
          : this.dialogueJson,
      buttonTitleJson: data.buttonTitleJson.present
          ? data.buttonTitleJson.value
          : this.buttonTitleJson,
      duration: data.duration.present ? data.duration.value : this.duration,
      tone: data.tone.present ? data.tone.value : this.tone,
      transitionType: data.transitionType.present
          ? data.transitionType.value
          : this.transitionType,
      isQuestion: data.isQuestion.present
          ? data.isQuestion.value
          : this.isQuestion,
      isPause: data.isPause.present ? data.isPause.value : this.isPause,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      waitForAnswer: data.waitForAnswer.present
          ? data.waitForAnswer.value
          : this.waitForAnswer,
      showPreviousAnimals: data.showPreviousAnimals.present
          ? data.showPreviousAnimals.value
          : this.showPreviousAnimals,
      animalsJson: data.animalsJson.present
          ? data.animalsJson.value
          : this.animalsJson,
      audioFilesJson: data.audioFilesJson.present
          ? data.audioFilesJson.value
          : this.audioFilesJson,
      audioStaleJson: data.audioStaleJson.present
          ? data.audioStaleJson.value
          : this.audioStaleJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scene(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('character: $character, ')
          ..write('animation: $animation, ')
          ..write('emotion: $emotion, ')
          ..write('secondCharacter: $secondCharacter, ')
          ..write('secondAnimation: $secondAnimation, ')
          ..write('secondEmotion: $secondEmotion, ')
          ..write('dialogueJson: $dialogueJson, ')
          ..write('buttonTitleJson: $buttonTitleJson, ')
          ..write('duration: $duration, ')
          ..write('tone: $tone, ')
          ..write('transitionType: $transitionType, ')
          ..write('isQuestion: $isQuestion, ')
          ..write('isPause: $isPause, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('waitForAnswer: $waitForAnswer, ')
          ..write('showPreviousAnimals: $showPreviousAnimals, ')
          ..write('animalsJson: $animalsJson, ')
          ..write('audioFilesJson: $audioFilesJson, ')
          ..write('audioStaleJson: $audioStaleJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    lessonId,
    orderIndex,
    character,
    animation,
    emotion,
    secondCharacter,
    secondAnimation,
    secondEmotion,
    dialogueJson,
    buttonTitleJson,
    duration,
    tone,
    transitionType,
    isQuestion,
    isPause,
    correctAnswer,
    waitForAnswer,
    showPreviousAnimals,
    animalsJson,
    audioFilesJson,
    audioStaleJson,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scene &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.orderIndex == this.orderIndex &&
          other.character == this.character &&
          other.animation == this.animation &&
          other.emotion == this.emotion &&
          other.secondCharacter == this.secondCharacter &&
          other.secondAnimation == this.secondAnimation &&
          other.secondEmotion == this.secondEmotion &&
          other.dialogueJson == this.dialogueJson &&
          other.buttonTitleJson == this.buttonTitleJson &&
          other.duration == this.duration &&
          other.tone == this.tone &&
          other.transitionType == this.transitionType &&
          other.isQuestion == this.isQuestion &&
          other.isPause == this.isPause &&
          other.correctAnswer == this.correctAnswer &&
          other.waitForAnswer == this.waitForAnswer &&
          other.showPreviousAnimals == this.showPreviousAnimals &&
          other.animalsJson == this.animalsJson &&
          other.audioFilesJson == this.audioFilesJson &&
          other.audioStaleJson == this.audioStaleJson &&
          other.updatedAt == this.updatedAt);
}

class ScenesCompanion extends UpdateCompanion<Scene> {
  final Value<int> id;
  final Value<int> lessonId;
  final Value<int> orderIndex;
  final Value<String?> character;
  final Value<String?> animation;
  final Value<String?> emotion;
  final Value<String?> secondCharacter;
  final Value<String?> secondAnimation;
  final Value<String?> secondEmotion;
  final Value<String?> dialogueJson;
  final Value<String?> buttonTitleJson;
  final Value<int?> duration;
  final Value<String?> tone;
  final Value<String?> transitionType;
  final Value<bool> isQuestion;
  final Value<bool> isPause;
  final Value<int?> correctAnswer;
  final Value<bool> waitForAnswer;
  final Value<bool> showPreviousAnimals;
  final Value<String?> animalsJson;
  final Value<String?> audioFilesJson;
  final Value<String?> audioStaleJson;
  final Value<DateTime> updatedAt;
  const ScenesCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.character = const Value.absent(),
    this.animation = const Value.absent(),
    this.emotion = const Value.absent(),
    this.secondCharacter = const Value.absent(),
    this.secondAnimation = const Value.absent(),
    this.secondEmotion = const Value.absent(),
    this.dialogueJson = const Value.absent(),
    this.buttonTitleJson = const Value.absent(),
    this.duration = const Value.absent(),
    this.tone = const Value.absent(),
    this.transitionType = const Value.absent(),
    this.isQuestion = const Value.absent(),
    this.isPause = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.waitForAnswer = const Value.absent(),
    this.showPreviousAnimals = const Value.absent(),
    this.animalsJson = const Value.absent(),
    this.audioFilesJson = const Value.absent(),
    this.audioStaleJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScenesCompanion.insert({
    this.id = const Value.absent(),
    required int lessonId,
    required int orderIndex,
    this.character = const Value.absent(),
    this.animation = const Value.absent(),
    this.emotion = const Value.absent(),
    this.secondCharacter = const Value.absent(),
    this.secondAnimation = const Value.absent(),
    this.secondEmotion = const Value.absent(),
    this.dialogueJson = const Value.absent(),
    this.buttonTitleJson = const Value.absent(),
    this.duration = const Value.absent(),
    this.tone = const Value.absent(),
    this.transitionType = const Value.absent(),
    this.isQuestion = const Value.absent(),
    this.isPause = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.waitForAnswer = const Value.absent(),
    this.showPreviousAnimals = const Value.absent(),
    this.animalsJson = const Value.absent(),
    this.audioFilesJson = const Value.absent(),
    this.audioStaleJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : lessonId = Value(lessonId),
       orderIndex = Value(orderIndex);
  static Insertable<Scene> custom({
    Expression<int>? id,
    Expression<int>? lessonId,
    Expression<int>? orderIndex,
    Expression<String>? character,
    Expression<String>? animation,
    Expression<String>? emotion,
    Expression<String>? secondCharacter,
    Expression<String>? secondAnimation,
    Expression<String>? secondEmotion,
    Expression<String>? dialogueJson,
    Expression<String>? buttonTitleJson,
    Expression<int>? duration,
    Expression<String>? tone,
    Expression<String>? transitionType,
    Expression<bool>? isQuestion,
    Expression<bool>? isPause,
    Expression<int>? correctAnswer,
    Expression<bool>? waitForAnswer,
    Expression<bool>? showPreviousAnimals,
    Expression<String>? animalsJson,
    Expression<String>? audioFilesJson,
    Expression<String>? audioStaleJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (character != null) 'character': character,
      if (animation != null) 'animation': animation,
      if (emotion != null) 'emotion': emotion,
      if (secondCharacter != null) 'second_character': secondCharacter,
      if (secondAnimation != null) 'second_animation': secondAnimation,
      if (secondEmotion != null) 'second_emotion': secondEmotion,
      if (dialogueJson != null) 'dialogue_json': dialogueJson,
      if (buttonTitleJson != null) 'button_title_json': buttonTitleJson,
      if (duration != null) 'duration': duration,
      if (tone != null) 'tone': tone,
      if (transitionType != null) 'transition_type': transitionType,
      if (isQuestion != null) 'is_question': isQuestion,
      if (isPause != null) 'is_pause': isPause,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (waitForAnswer != null) 'wait_for_answer': waitForAnswer,
      if (showPreviousAnimals != null)
        'show_previous_animals': showPreviousAnimals,
      if (animalsJson != null) 'animals_json': animalsJson,
      if (audioFilesJson != null) 'audio_files_json': audioFilesJson,
      if (audioStaleJson != null) 'audio_stale_json': audioStaleJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScenesCompanion copyWith({
    Value<int>? id,
    Value<int>? lessonId,
    Value<int>? orderIndex,
    Value<String?>? character,
    Value<String?>? animation,
    Value<String?>? emotion,
    Value<String?>? secondCharacter,
    Value<String?>? secondAnimation,
    Value<String?>? secondEmotion,
    Value<String?>? dialogueJson,
    Value<String?>? buttonTitleJson,
    Value<int?>? duration,
    Value<String?>? tone,
    Value<String?>? transitionType,
    Value<bool>? isQuestion,
    Value<bool>? isPause,
    Value<int?>? correctAnswer,
    Value<bool>? waitForAnswer,
    Value<bool>? showPreviousAnimals,
    Value<String?>? animalsJson,
    Value<String?>? audioFilesJson,
    Value<String?>? audioStaleJson,
    Value<DateTime>? updatedAt,
  }) {
    return ScenesCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      orderIndex: orderIndex ?? this.orderIndex,
      character: character ?? this.character,
      animation: animation ?? this.animation,
      emotion: emotion ?? this.emotion,
      secondCharacter: secondCharacter ?? this.secondCharacter,
      secondAnimation: secondAnimation ?? this.secondAnimation,
      secondEmotion: secondEmotion ?? this.secondEmotion,
      dialogueJson: dialogueJson ?? this.dialogueJson,
      buttonTitleJson: buttonTitleJson ?? this.buttonTitleJson,
      duration: duration ?? this.duration,
      tone: tone ?? this.tone,
      transitionType: transitionType ?? this.transitionType,
      isQuestion: isQuestion ?? this.isQuestion,
      isPause: isPause ?? this.isPause,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      waitForAnswer: waitForAnswer ?? this.waitForAnswer,
      showPreviousAnimals: showPreviousAnimals ?? this.showPreviousAnimals,
      animalsJson: animalsJson ?? this.animalsJson,
      audioFilesJson: audioFilesJson ?? this.audioFilesJson,
      audioStaleJson: audioStaleJson ?? this.audioStaleJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (animation.present) {
      map['animation'] = Variable<String>(animation.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (secondCharacter.present) {
      map['second_character'] = Variable<String>(secondCharacter.value);
    }
    if (secondAnimation.present) {
      map['second_animation'] = Variable<String>(secondAnimation.value);
    }
    if (secondEmotion.present) {
      map['second_emotion'] = Variable<String>(secondEmotion.value);
    }
    if (dialogueJson.present) {
      map['dialogue_json'] = Variable<String>(dialogueJson.value);
    }
    if (buttonTitleJson.present) {
      map['button_title_json'] = Variable<String>(buttonTitleJson.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(tone.value);
    }
    if (transitionType.present) {
      map['transition_type'] = Variable<String>(transitionType.value);
    }
    if (isQuestion.present) {
      map['is_question'] = Variable<bool>(isQuestion.value);
    }
    if (isPause.present) {
      map['is_pause'] = Variable<bool>(isPause.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<int>(correctAnswer.value);
    }
    if (waitForAnswer.present) {
      map['wait_for_answer'] = Variable<bool>(waitForAnswer.value);
    }
    if (showPreviousAnimals.present) {
      map['show_previous_animals'] = Variable<bool>(showPreviousAnimals.value);
    }
    if (animalsJson.present) {
      map['animals_json'] = Variable<String>(animalsJson.value);
    }
    if (audioFilesJson.present) {
      map['audio_files_json'] = Variable<String>(audioFilesJson.value);
    }
    if (audioStaleJson.present) {
      map['audio_stale_json'] = Variable<String>(audioStaleJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenesCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('character: $character, ')
          ..write('animation: $animation, ')
          ..write('emotion: $emotion, ')
          ..write('secondCharacter: $secondCharacter, ')
          ..write('secondAnimation: $secondAnimation, ')
          ..write('secondEmotion: $secondEmotion, ')
          ..write('dialogueJson: $dialogueJson, ')
          ..write('buttonTitleJson: $buttonTitleJson, ')
          ..write('duration: $duration, ')
          ..write('tone: $tone, ')
          ..write('transitionType: $transitionType, ')
          ..write('isQuestion: $isQuestion, ')
          ..write('isPause: $isPause, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('waitForAnswer: $waitForAnswer, ')
          ..write('showPreviousAnimals: $showPreviousAnimals, ')
          ..write('animalsJson: $animalsJson, ')
          ..write('audioFilesJson: $audioFilesJson, ')
          ..write('audioStaleJson: $audioStaleJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AudioCachesTable extends AudioCaches
    with TableInfo<$AudioCachesTable, AudioCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sceneIdMeta = const VerificationMeta(
    'sceneId',
  );
  @override
  late final GeneratedColumn<int> sceneId = GeneratedColumn<int>(
    'scene_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scenes (id)',
    ),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttsProviderMeta = const VerificationMeta(
    'ttsProvider',
  );
  @override
  late final GeneratedColumn<String> ttsProvider = GeneratedColumn<String>(
    'tts_provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textHashMeta = const VerificationMeta(
    'textHash',
  );
  @override
  late final GeneratedColumn<String> textHash = GeneratedColumn<String>(
    'text_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sceneId,
    languageCode,
    character,
    filePath,
    ttsProvider,
    generatedAt,
    textHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scene_id')) {
      context.handle(
        _sceneIdMeta,
        sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('tts_provider')) {
      context.handle(
        _ttsProviderMeta,
        ttsProvider.isAcceptableOrUnknown(
          data['tts_provider']!,
          _ttsProviderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ttsProviderMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('text_hash')) {
      context.handle(
        _textHashMeta,
        textHash.isAcceptableOrUnknown(data['text_hash']!, _textHashMeta),
      );
    } else if (isInserting) {
      context.missing(_textHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sceneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scene_id'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      ttsProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tts_provider'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      textHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_hash'],
      )!,
    );
  }

  @override
  $AudioCachesTable createAlias(String alias) {
    return $AudioCachesTable(attachedDatabase, alias);
  }
}

class AudioCache extends DataClass implements Insertable<AudioCache> {
  final int id;
  final int sceneId;
  final String languageCode;
  final String character;
  final String filePath;
  final String ttsProvider;
  final DateTime generatedAt;
  final String textHash;
  const AudioCache({
    required this.id,
    required this.sceneId,
    required this.languageCode,
    required this.character,
    required this.filePath,
    required this.ttsProvider,
    required this.generatedAt,
    required this.textHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scene_id'] = Variable<int>(sceneId);
    map['language_code'] = Variable<String>(languageCode);
    map['character'] = Variable<String>(character);
    map['file_path'] = Variable<String>(filePath);
    map['tts_provider'] = Variable<String>(ttsProvider);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['text_hash'] = Variable<String>(textHash);
    return map;
  }

  AudioCachesCompanion toCompanion(bool nullToAbsent) {
    return AudioCachesCompanion(
      id: Value(id),
      sceneId: Value(sceneId),
      languageCode: Value(languageCode),
      character: Value(character),
      filePath: Value(filePath),
      ttsProvider: Value(ttsProvider),
      generatedAt: Value(generatedAt),
      textHash: Value(textHash),
    );
  }

  factory AudioCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioCache(
      id: serializer.fromJson<int>(json['id']),
      sceneId: serializer.fromJson<int>(json['sceneId']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      character: serializer.fromJson<String>(json['character']),
      filePath: serializer.fromJson<String>(json['filePath']),
      ttsProvider: serializer.fromJson<String>(json['ttsProvider']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      textHash: serializer.fromJson<String>(json['textHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sceneId': serializer.toJson<int>(sceneId),
      'languageCode': serializer.toJson<String>(languageCode),
      'character': serializer.toJson<String>(character),
      'filePath': serializer.toJson<String>(filePath),
      'ttsProvider': serializer.toJson<String>(ttsProvider),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'textHash': serializer.toJson<String>(textHash),
    };
  }

  AudioCache copyWith({
    int? id,
    int? sceneId,
    String? languageCode,
    String? character,
    String? filePath,
    String? ttsProvider,
    DateTime? generatedAt,
    String? textHash,
  }) => AudioCache(
    id: id ?? this.id,
    sceneId: sceneId ?? this.sceneId,
    languageCode: languageCode ?? this.languageCode,
    character: character ?? this.character,
    filePath: filePath ?? this.filePath,
    ttsProvider: ttsProvider ?? this.ttsProvider,
    generatedAt: generatedAt ?? this.generatedAt,
    textHash: textHash ?? this.textHash,
  );
  AudioCache copyWithCompanion(AudioCachesCompanion data) {
    return AudioCache(
      id: data.id.present ? data.id.value : this.id,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      character: data.character.present ? data.character.value : this.character,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      ttsProvider: data.ttsProvider.present
          ? data.ttsProvider.value
          : this.ttsProvider,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      textHash: data.textHash.present ? data.textHash.value : this.textHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioCache(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('languageCode: $languageCode, ')
          ..write('character: $character, ')
          ..write('filePath: $filePath, ')
          ..write('ttsProvider: $ttsProvider, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('textHash: $textHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sceneId,
    languageCode,
    character,
    filePath,
    ttsProvider,
    generatedAt,
    textHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioCache &&
          other.id == this.id &&
          other.sceneId == this.sceneId &&
          other.languageCode == this.languageCode &&
          other.character == this.character &&
          other.filePath == this.filePath &&
          other.ttsProvider == this.ttsProvider &&
          other.generatedAt == this.generatedAt &&
          other.textHash == this.textHash);
}

class AudioCachesCompanion extends UpdateCompanion<AudioCache> {
  final Value<int> id;
  final Value<int> sceneId;
  final Value<String> languageCode;
  final Value<String> character;
  final Value<String> filePath;
  final Value<String> ttsProvider;
  final Value<DateTime> generatedAt;
  final Value<String> textHash;
  const AudioCachesCompanion({
    this.id = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.character = const Value.absent(),
    this.filePath = const Value.absent(),
    this.ttsProvider = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.textHash = const Value.absent(),
  });
  AudioCachesCompanion.insert({
    this.id = const Value.absent(),
    required int sceneId,
    required String languageCode,
    required String character,
    required String filePath,
    required String ttsProvider,
    required DateTime generatedAt,
    required String textHash,
  }) : sceneId = Value(sceneId),
       languageCode = Value(languageCode),
       character = Value(character),
       filePath = Value(filePath),
       ttsProvider = Value(ttsProvider),
       generatedAt = Value(generatedAt),
       textHash = Value(textHash);
  static Insertable<AudioCache> custom({
    Expression<int>? id,
    Expression<int>? sceneId,
    Expression<String>? languageCode,
    Expression<String>? character,
    Expression<String>? filePath,
    Expression<String>? ttsProvider,
    Expression<DateTime>? generatedAt,
    Expression<String>? textHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sceneId != null) 'scene_id': sceneId,
      if (languageCode != null) 'language_code': languageCode,
      if (character != null) 'character': character,
      if (filePath != null) 'file_path': filePath,
      if (ttsProvider != null) 'tts_provider': ttsProvider,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (textHash != null) 'text_hash': textHash,
    });
  }

  AudioCachesCompanion copyWith({
    Value<int>? id,
    Value<int>? sceneId,
    Value<String>? languageCode,
    Value<String>? character,
    Value<String>? filePath,
    Value<String>? ttsProvider,
    Value<DateTime>? generatedAt,
    Value<String>? textHash,
  }) {
    return AudioCachesCompanion(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      languageCode: languageCode ?? this.languageCode,
      character: character ?? this.character,
      filePath: filePath ?? this.filePath,
      ttsProvider: ttsProvider ?? this.ttsProvider,
      generatedAt: generatedAt ?? this.generatedAt,
      textHash: textHash ?? this.textHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<int>(sceneId.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (ttsProvider.present) {
      map['tts_provider'] = Variable<String>(ttsProvider.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (textHash.present) {
      map['text_hash'] = Variable<String>(textHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioCachesCompanion(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('languageCode: $languageCode, ')
          ..write('character: $character, ')
          ..write('filePath: $filePath, ')
          ..write('ttsProvider: $ttsProvider, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('textHash: $textHash')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  late final $ScenesTable scenes = $ScenesTable(this);
  late final $AudioCachesTable audioCaches = $AudioCachesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lessons,
    scenes,
    audioCaches,
  ];
}

typedef $$LessonsTableCreateCompanionBuilder =
    LessonsCompanion Function({
      Value<int> id,
      required String lessonId,
      required String topic,
      Value<int> difficulty,
      required String tags,
      required String titleJson,
      required String descriptionJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LessonsTableUpdateCompanionBuilder =
    LessonsCompanion Function({
      Value<int> id,
      Value<String> lessonId,
      Value<String> topic,
      Value<int> difficulty,
      Value<String> tags,
      Value<String> titleJson,
      Value<String> descriptionJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$LessonsTableReferences
    extends BaseReferences<_$AppDatabase, $LessonsTable, Lesson> {
  $$LessonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScenesTable, List<Scene>> _scenesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.scenes,
    aliasName: $_aliasNameGenerator(db.lessons.id, db.scenes.lessonId),
  );

  $$ScenesTableProcessedTableManager get scenesRefs {
    final manager = $$ScenesTableTableManager(
      $_db,
      $_db.scenes,
    ).filter((f) => f.lessonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scenesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleJson => $composableBuilder(
    column: $table.titleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionJson => $composableBuilder(
    column: $table.descriptionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scenesRefs(
    Expression<bool> Function($$ScenesTableFilterComposer f) f,
  ) {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableFilterComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleJson => $composableBuilder(
    column: $table.titleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionJson => $composableBuilder(
    column: $table.descriptionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get titleJson =>
      $composableBuilder(column: $table.titleJson, builder: (column) => column);

  GeneratedColumn<String> get descriptionJson => $composableBuilder(
    column: $table.descriptionJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> scenesRefs<T extends Object>(
    Expression<T> Function($$ScenesTableAnnotationComposer a) f,
  ) {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableAnnotationComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonsTable,
          Lesson,
          $$LessonsTableFilterComposer,
          $$LessonsTableOrderingComposer,
          $$LessonsTableAnnotationComposer,
          $$LessonsTableCreateCompanionBuilder,
          $$LessonsTableUpdateCompanionBuilder,
          (Lesson, $$LessonsTableReferences),
          Lesson,
          PrefetchHooks Function({bool scenesRefs})
        > {
  $$LessonsTableTableManager(_$AppDatabase db, $LessonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> titleJson = const Value.absent(),
                Value<String> descriptionJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LessonsCompanion(
                id: id,
                lessonId: lessonId,
                topic: topic,
                difficulty: difficulty,
                tags: tags,
                titleJson: titleJson,
                descriptionJson: descriptionJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String lessonId,
                required String topic,
                Value<int> difficulty = const Value.absent(),
                required String tags,
                required String titleJson,
                required String descriptionJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LessonsCompanion.insert(
                id: id,
                lessonId: lessonId,
                topic: topic,
                difficulty: difficulty,
                tags: tags,
                titleJson: titleJson,
                descriptionJson: descriptionJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LessonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scenesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scenesRefs) db.scenes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scenesRefs)
                    await $_getPrefetchedData<Lesson, $LessonsTable, Scene>(
                      currentTable: table,
                      referencedTable: $$LessonsTableReferences
                          ._scenesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LessonsTableReferences(db, table, p0).scenesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.lessonId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonsTable,
      Lesson,
      $$LessonsTableFilterComposer,
      $$LessonsTableOrderingComposer,
      $$LessonsTableAnnotationComposer,
      $$LessonsTableCreateCompanionBuilder,
      $$LessonsTableUpdateCompanionBuilder,
      (Lesson, $$LessonsTableReferences),
      Lesson,
      PrefetchHooks Function({bool scenesRefs})
    >;
typedef $$ScenesTableCreateCompanionBuilder =
    ScenesCompanion Function({
      Value<int> id,
      required int lessonId,
      required int orderIndex,
      Value<String?> character,
      Value<String?> animation,
      Value<String?> emotion,
      Value<String?> secondCharacter,
      Value<String?> secondAnimation,
      Value<String?> secondEmotion,
      Value<String?> dialogueJson,
      Value<String?> buttonTitleJson,
      Value<int?> duration,
      Value<String?> tone,
      Value<String?> transitionType,
      Value<bool> isQuestion,
      Value<bool> isPause,
      Value<int?> correctAnswer,
      Value<bool> waitForAnswer,
      Value<bool> showPreviousAnimals,
      Value<String?> animalsJson,
      Value<String?> audioFilesJson,
      Value<String?> audioStaleJson,
      Value<DateTime> updatedAt,
    });
typedef $$ScenesTableUpdateCompanionBuilder =
    ScenesCompanion Function({
      Value<int> id,
      Value<int> lessonId,
      Value<int> orderIndex,
      Value<String?> character,
      Value<String?> animation,
      Value<String?> emotion,
      Value<String?> secondCharacter,
      Value<String?> secondAnimation,
      Value<String?> secondEmotion,
      Value<String?> dialogueJson,
      Value<String?> buttonTitleJson,
      Value<int?> duration,
      Value<String?> tone,
      Value<String?> transitionType,
      Value<bool> isQuestion,
      Value<bool> isPause,
      Value<int?> correctAnswer,
      Value<bool> waitForAnswer,
      Value<bool> showPreviousAnimals,
      Value<String?> animalsJson,
      Value<String?> audioFilesJson,
      Value<String?> audioStaleJson,
      Value<DateTime> updatedAt,
    });

final class $$ScenesTableReferences
    extends BaseReferences<_$AppDatabase, $ScenesTable, Scene> {
  $$ScenesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LessonsTable _lessonIdTable(_$AppDatabase db) => db.lessons
      .createAlias($_aliasNameGenerator(db.scenes.lessonId, db.lessons.id));

  $$LessonsTableProcessedTableManager get lessonId {
    final $_column = $_itemColumn<int>('lesson_id')!;

    final manager = $$LessonsTableTableManager(
      $_db,
      $_db.lessons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AudioCachesTable, List<AudioCache>>
  _audioCachesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audioCaches,
    aliasName: $_aliasNameGenerator(db.scenes.id, db.audioCaches.sceneId),
  );

  $$AudioCachesTableProcessedTableManager get audioCachesRefs {
    final manager = $$AudioCachesTableTableManager(
      $_db,
      $_db.audioCaches,
    ).filter((f) => f.sceneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_audioCachesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScenesTableFilterComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animation => $composableBuilder(
    column: $table.animation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondCharacter => $composableBuilder(
    column: $table.secondCharacter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondAnimation => $composableBuilder(
    column: $table.secondAnimation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondEmotion => $composableBuilder(
    column: $table.secondEmotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dialogueJson => $composableBuilder(
    column: $table.dialogueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buttonTitleJson => $composableBuilder(
    column: $table.buttonTitleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transitionType => $composableBuilder(
    column: $table.transitionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isQuestion => $composableBuilder(
    column: $table.isQuestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPause => $composableBuilder(
    column: $table.isPause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get waitForAnswer => $composableBuilder(
    column: $table.waitForAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showPreviousAnimals => $composableBuilder(
    column: $table.showPreviousAnimals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animalsJson => $composableBuilder(
    column: $table.animalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFilesJson => $composableBuilder(
    column: $table.audioFilesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioStaleJson => $composableBuilder(
    column: $table.audioStaleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LessonsTableFilterComposer get lessonId {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableFilterComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> audioCachesRefs(
    Expression<bool> Function($$AudioCachesTableFilterComposer f) f,
  ) {
    final $$AudioCachesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioCaches,
      getReferencedColumn: (t) => t.sceneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioCachesTableFilterComposer(
            $db: $db,
            $table: $db.audioCaches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animation => $composableBuilder(
    column: $table.animation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondCharacter => $composableBuilder(
    column: $table.secondCharacter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondAnimation => $composableBuilder(
    column: $table.secondAnimation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondEmotion => $composableBuilder(
    column: $table.secondEmotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dialogueJson => $composableBuilder(
    column: $table.dialogueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buttonTitleJson => $composableBuilder(
    column: $table.buttonTitleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transitionType => $composableBuilder(
    column: $table.transitionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isQuestion => $composableBuilder(
    column: $table.isQuestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPause => $composableBuilder(
    column: $table.isPause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get waitForAnswer => $composableBuilder(
    column: $table.waitForAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showPreviousAnimals => $composableBuilder(
    column: $table.showPreviousAnimals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animalsJson => $composableBuilder(
    column: $table.animalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFilesJson => $composableBuilder(
    column: $table.audioFilesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioStaleJson => $composableBuilder(
    column: $table.audioStaleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LessonsTableOrderingComposer get lessonId {
    final $$LessonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableOrderingComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get animation =>
      $composableBuilder(column: $table.animation, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get secondCharacter => $composableBuilder(
    column: $table.secondCharacter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondAnimation => $composableBuilder(
    column: $table.secondAnimation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondEmotion => $composableBuilder(
    column: $table.secondEmotion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dialogueJson => $composableBuilder(
    column: $table.dialogueJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buttonTitleJson => $composableBuilder(
    column: $table.buttonTitleJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<String> get transitionType => $composableBuilder(
    column: $table.transitionType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isQuestion => $composableBuilder(
    column: $table.isQuestion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPause =>
      $composableBuilder(column: $table.isPause, builder: (column) => column);

  GeneratedColumn<int> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get waitForAnswer => $composableBuilder(
    column: $table.waitForAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showPreviousAnimals => $composableBuilder(
    column: $table.showPreviousAnimals,
    builder: (column) => column,
  );

  GeneratedColumn<String> get animalsJson => $composableBuilder(
    column: $table.animalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioFilesJson => $composableBuilder(
    column: $table.audioFilesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioStaleJson => $composableBuilder(
    column: $table.audioStaleJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LessonsTableAnnotationComposer get lessonId {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableAnnotationComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> audioCachesRefs<T extends Object>(
    Expression<T> Function($$AudioCachesTableAnnotationComposer a) f,
  ) {
    final $$AudioCachesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioCaches,
      getReferencedColumn: (t) => t.sceneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioCachesTableAnnotationComposer(
            $db: $db,
            $table: $db.audioCaches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScenesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenesTable,
          Scene,
          $$ScenesTableFilterComposer,
          $$ScenesTableOrderingComposer,
          $$ScenesTableAnnotationComposer,
          $$ScenesTableCreateCompanionBuilder,
          $$ScenesTableUpdateCompanionBuilder,
          (Scene, $$ScenesTableReferences),
          Scene,
          PrefetchHooks Function({bool lessonId, bool audioCachesRefs})
        > {
  $$ScenesTableTableManager(_$AppDatabase db, $ScenesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lessonId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String?> character = const Value.absent(),
                Value<String?> animation = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<String?> secondCharacter = const Value.absent(),
                Value<String?> secondAnimation = const Value.absent(),
                Value<String?> secondEmotion = const Value.absent(),
                Value<String?> dialogueJson = const Value.absent(),
                Value<String?> buttonTitleJson = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> tone = const Value.absent(),
                Value<String?> transitionType = const Value.absent(),
                Value<bool> isQuestion = const Value.absent(),
                Value<bool> isPause = const Value.absent(),
                Value<int?> correctAnswer = const Value.absent(),
                Value<bool> waitForAnswer = const Value.absent(),
                Value<bool> showPreviousAnimals = const Value.absent(),
                Value<String?> animalsJson = const Value.absent(),
                Value<String?> audioFilesJson = const Value.absent(),
                Value<String?> audioStaleJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScenesCompanion(
                id: id,
                lessonId: lessonId,
                orderIndex: orderIndex,
                character: character,
                animation: animation,
                emotion: emotion,
                secondCharacter: secondCharacter,
                secondAnimation: secondAnimation,
                secondEmotion: secondEmotion,
                dialogueJson: dialogueJson,
                buttonTitleJson: buttonTitleJson,
                duration: duration,
                tone: tone,
                transitionType: transitionType,
                isQuestion: isQuestion,
                isPause: isPause,
                correctAnswer: correctAnswer,
                waitForAnswer: waitForAnswer,
                showPreviousAnimals: showPreviousAnimals,
                animalsJson: animalsJson,
                audioFilesJson: audioFilesJson,
                audioStaleJson: audioStaleJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lessonId,
                required int orderIndex,
                Value<String?> character = const Value.absent(),
                Value<String?> animation = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<String?> secondCharacter = const Value.absent(),
                Value<String?> secondAnimation = const Value.absent(),
                Value<String?> secondEmotion = const Value.absent(),
                Value<String?> dialogueJson = const Value.absent(),
                Value<String?> buttonTitleJson = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> tone = const Value.absent(),
                Value<String?> transitionType = const Value.absent(),
                Value<bool> isQuestion = const Value.absent(),
                Value<bool> isPause = const Value.absent(),
                Value<int?> correctAnswer = const Value.absent(),
                Value<bool> waitForAnswer = const Value.absent(),
                Value<bool> showPreviousAnimals = const Value.absent(),
                Value<String?> animalsJson = const Value.absent(),
                Value<String?> audioFilesJson = const Value.absent(),
                Value<String?> audioStaleJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScenesCompanion.insert(
                id: id,
                lessonId: lessonId,
                orderIndex: orderIndex,
                character: character,
                animation: animation,
                emotion: emotion,
                secondCharacter: secondCharacter,
                secondAnimation: secondAnimation,
                secondEmotion: secondEmotion,
                dialogueJson: dialogueJson,
                buttonTitleJson: buttonTitleJson,
                duration: duration,
                tone: tone,
                transitionType: transitionType,
                isQuestion: isQuestion,
                isPause: isPause,
                correctAnswer: correctAnswer,
                waitForAnswer: waitForAnswer,
                showPreviousAnimals: showPreviousAnimals,
                animalsJson: animalsJson,
                audioFilesJson: audioFilesJson,
                audioStaleJson: audioStaleJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ScenesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({lessonId = false, audioCachesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (audioCachesRefs) db.audioCaches],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lessonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lessonId,
                                referencedTable: $$ScenesTableReferences
                                    ._lessonIdTable(db),
                                referencedColumn: $$ScenesTableReferences
                                    ._lessonIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (audioCachesRefs)
                    await $_getPrefetchedData<Scene, $ScenesTable, AudioCache>(
                      currentTable: table,
                      referencedTable: $$ScenesTableReferences
                          ._audioCachesRefsTable(db),
                      managerFromTypedResult: (p0) => $$ScenesTableReferences(
                        db,
                        table,
                        p0,
                      ).audioCachesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sceneId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScenesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenesTable,
      Scene,
      $$ScenesTableFilterComposer,
      $$ScenesTableOrderingComposer,
      $$ScenesTableAnnotationComposer,
      $$ScenesTableCreateCompanionBuilder,
      $$ScenesTableUpdateCompanionBuilder,
      (Scene, $$ScenesTableReferences),
      Scene,
      PrefetchHooks Function({bool lessonId, bool audioCachesRefs})
    >;
typedef $$AudioCachesTableCreateCompanionBuilder =
    AudioCachesCompanion Function({
      Value<int> id,
      required int sceneId,
      required String languageCode,
      required String character,
      required String filePath,
      required String ttsProvider,
      required DateTime generatedAt,
      required String textHash,
    });
typedef $$AudioCachesTableUpdateCompanionBuilder =
    AudioCachesCompanion Function({
      Value<int> id,
      Value<int> sceneId,
      Value<String> languageCode,
      Value<String> character,
      Value<String> filePath,
      Value<String> ttsProvider,
      Value<DateTime> generatedAt,
      Value<String> textHash,
    });

final class $$AudioCachesTableReferences
    extends BaseReferences<_$AppDatabase, $AudioCachesTable, AudioCache> {
  $$AudioCachesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScenesTable _sceneIdTable(_$AppDatabase db) => db.scenes.createAlias(
    $_aliasNameGenerator(db.audioCaches.sceneId, db.scenes.id),
  );

  $$ScenesTableProcessedTableManager get sceneId {
    final $_column = $_itemColumn<int>('scene_id')!;

    final manager = $$ScenesTableTableManager(
      $_db,
      $_db.scenes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sceneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudioCachesTableFilterComposer
    extends Composer<_$AppDatabase, $AudioCachesTable> {
  $$AudioCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttsProvider => $composableBuilder(
    column: $table.ttsProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textHash => $composableBuilder(
    column: $table.textHash,
    builder: (column) => ColumnFilters(column),
  );

  $$ScenesTableFilterComposer get sceneId {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableFilterComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioCachesTable> {
  $$AudioCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttsProvider => $composableBuilder(
    column: $table.ttsProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textHash => $composableBuilder(
    column: $table.textHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScenesTableOrderingComposer get sceneId {
    final $$ScenesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableOrderingComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioCachesTable> {
  $$AudioCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get ttsProvider => $composableBuilder(
    column: $table.ttsProvider,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textHash =>
      $composableBuilder(column: $table.textHash, builder: (column) => column);

  $$ScenesTableAnnotationComposer get sceneId {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sceneId,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableAnnotationComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioCachesTable,
          AudioCache,
          $$AudioCachesTableFilterComposer,
          $$AudioCachesTableOrderingComposer,
          $$AudioCachesTableAnnotationComposer,
          $$AudioCachesTableCreateCompanionBuilder,
          $$AudioCachesTableUpdateCompanionBuilder,
          (AudioCache, $$AudioCachesTableReferences),
          AudioCache,
          PrefetchHooks Function({bool sceneId})
        > {
  $$AudioCachesTableTableManager(_$AppDatabase db, $AudioCachesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sceneId = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> ttsProvider = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String> textHash = const Value.absent(),
              }) => AudioCachesCompanion(
                id: id,
                sceneId: sceneId,
                languageCode: languageCode,
                character: character,
                filePath: filePath,
                ttsProvider: ttsProvider,
                generatedAt: generatedAt,
                textHash: textHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sceneId,
                required String languageCode,
                required String character,
                required String filePath,
                required String ttsProvider,
                required DateTime generatedAt,
                required String textHash,
              }) => AudioCachesCompanion.insert(
                id: id,
                sceneId: sceneId,
                languageCode: languageCode,
                character: character,
                filePath: filePath,
                ttsProvider: ttsProvider,
                generatedAt: generatedAt,
                textHash: textHash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudioCachesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sceneId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sceneId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sceneId,
                                referencedTable: $$AudioCachesTableReferences
                                    ._sceneIdTable(db),
                                referencedColumn: $$AudioCachesTableReferences
                                    ._sceneIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AudioCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioCachesTable,
      AudioCache,
      $$AudioCachesTableFilterComposer,
      $$AudioCachesTableOrderingComposer,
      $$AudioCachesTableAnnotationComposer,
      $$AudioCachesTableCreateCompanionBuilder,
      $$AudioCachesTableUpdateCompanionBuilder,
      (AudioCache, $$AudioCachesTableReferences),
      AudioCache,
      PrefetchHooks Function({bool sceneId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db, _db.scenes);
  $$AudioCachesTableTableManager get audioCaches =>
      $$AudioCachesTableTableManager(_db, _db.audioCaches);
}
