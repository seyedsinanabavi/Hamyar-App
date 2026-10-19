import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/features/chat/data/chat_repository.dart';

final conversationsProvider = FutureProvider.autoDispose<List<ConversationModel>>((ref) async {
  return ref.read(chatRepositoryProvider).getConversations();
});

final conversationDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, id) async {
  return ref.read(chatRepositoryProvider).getConversation(id);
});
