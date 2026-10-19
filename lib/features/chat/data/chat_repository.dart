import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/core/constants/api_constants.dart';
import 'package:hamyar/core/network/api_client.dart';
import 'package:hamyar/core/network/api_exception.dart';
import 'package:hamyar/core/security/security_utils.dart';
import 'package:hamyar/shared/models/user_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(apiClientProvider));
});

class ConversationModel {
  final int id;
  final int listingId;
  final String? listingTitle;
  final UserModel? otherUser;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.listingId,
    this.listingTitle,
    this.otherUser,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    UserModel? other;
    if (json['other_user'] != null) {
      other = UserModel.fromJson(json['other_user']);
    } else if (currentUserId != null) {
      final u1 = json['user_one'];
      final u2 = json['user_two'];
      if (u1 != null && u1['id'] != currentUserId) {
        other = UserModel.fromJson(u1);
      } else if (u2 != null) {
        other = UserModel.fromJson(u2);
      }
    }

    return ConversationModel(
      id: json['id'] as int,
      listingId: json['listing_id'] as int? ?? json['listing']?['id'] as int? ?? 0,
      listingTitle: json['listing']?['title'] as String?,
      otherUser: other,
      lastMessage: json['latest_message']?['body'] as String? ?? json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final UserModel? sender;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderId: json['sender_id'] as int,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['sender'] != null ? UserModel.fromJson(json['sender']) : null,
    );
  }
}

class ChatRepository {
  final ApiClient _client;

  ChatRepository(this._client);

  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _client.get(ApiConstants.conversations);
      if (response.statusCode != 200) {
        throw ApiException(message: 'خطا در دریافت گفتگوها');
      }
      final data = response.data['data'] as List? ?? [];
      return data.map((e) => ConversationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getConversation(int id) async {
    try {
      final response = await _client.get('${ApiConstants.conversations}/$id');
      if (response.statusCode != 200) {
        throw ApiException(message: 'گفتگو یافت نشد', statusCode: response.statusCode);
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ConversationModel> startConversation({
    required int listingId,
    required String message,
  }) async {
    try {
      final response = await _client.post(ApiConstants.conversations, data: {
        'listing_id': listingId,
        'message': SecurityUtils.sanitizeText(message, maxLength: 2000),
      });

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ApiException(
          message: response.data['message'] ?? 'خطا در شروع گفتگو',
          statusCode: response.statusCode,
        );
      }

      return ConversationModel.fromJson(response.data['conversation']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MessageModel> sendMessage({
    required int conversationId,
    required String body,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.conversations}/$conversationId/messages',
        data: {'body': SecurityUtils.sanitizeText(body, maxLength: 2000)},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ApiException(message: response.data['message'] ?? 'خطا در ارسال پیام');
      }

      return MessageModel.fromJson(response.data['message'] ?? response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markAsRead(int conversationId) async {
    try {
      await _client.post('${ApiConstants.conversations}/$conversationId/read');
    } catch (_) {
      // غیر بحرانی
    }
  }
}
