import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

/// Implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl({
    ChatRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSourceImpl();

  @override
  Stream<String> sendMessage(List<ChatMessage> messages) {
    final models = messages.map((m) => ChatMessageModel.fromEntity(m)).toList();
    return _remoteDataSource.sendMessage(models);
  }

  @override
  String getSystemPrompt() {
    return '''You are a friendly primary-school assistant for children aged 3-7 years.
Keep answers short, simple, and safe.
Use simple words that children can understand.
Be encouraging and positive.
If the question is unsafe or personal, say "Let's discuss it with the teacher." and provide a gentle alternative.
Always be kind and patient.''';
  }
}
