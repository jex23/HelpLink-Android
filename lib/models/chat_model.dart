class ChatParticipant {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? badge;
  final DateTime joinedAt;

  ChatParticipant({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.badge,
    required this.joinedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['profile_image'],
      badge: json['badge'],
      joinedAt: _parseDateTime(json['joined_at']) ?? DateTime.now(),
    );
  }

  String get fullName => '$firstName $lastName';

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Parse the datetime - DateTime.parse handles both UTC and local formats
        final parsed = DateTime.parse(value);
        // If it's UTC, convert to local time for proper time difference calculation
        if (parsed.isUtc) {
          return parsed.toLocal();
        }
        return parsed;
      } catch (e) {
        print('Error parsing datetime: $value - $e');
        return null;
      }
    }
    return null;
  }
}

class MessageMedia {
  final int id;
  final int messageId;
  final String mediaType; // 'photo' or 'video'
  final String mediaUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;

  MessageMedia({
    required this.id,
    required this.messageId,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory MessageMedia.fromJson(Map<String, dynamic> json) {
    return MessageMedia(
      id: json['id'] ?? 0,
      messageId: json['message_id'] ?? 0,
      mediaType: json['media_type'] ?? 'photo',
      mediaUrl: json['media_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Parse the datetime - DateTime.parse handles both UTC and local formats
        final parsed = DateTime.parse(value);
        // If it's UTC, convert to local time for proper time difference calculation
        if (parsed.isUtc) {
          return parsed.toLocal();
        }
        return parsed;
      } catch (e) {
        print('Error parsing datetime: $value - $e');
        return null;
      }
    }
    return null;
  }
}

class Message {
  final int id;
  final int chatId;
  final int senderId;
  final String? content;
  final String messageType; // 'text', 'photo', 'video'
  final DateTime createdAt;
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderProfileImage;
  final String? status; // 'sent', 'delivered', 'seen'
  final DateTime? seenAt;
  final List<MessageMedia> media;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    required this.messageType,
    required this.createdAt,
    this.senderFirstName,
    this.senderLastName,
    this.senderProfileImage,
    this.status,
    this.seenAt,
    this.media = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    List<MessageMedia> mediaList = [];
    if (json['media'] != null) {
      mediaList = (json['media'] as List)
          .map((m) => MessageMedia.fromJson(m))
          .toList();
    }

    final createdAtRaw = json['created_at'];
    final createdAtParsed = _parseDateTime(createdAtRaw);

    print('=== Message Time Debug ===');
    print('Raw created_at: $createdAtRaw');
    print('Parsed created_at: $createdAtParsed');
    print('Current time: ${DateTime.now()}');
    if (createdAtParsed != null) {
      print('Difference: ${DateTime.now().difference(createdAtParsed)}');
    }

    return Message(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      createdAt: createdAtParsed ?? DateTime.now(),
      senderFirstName: json['first_name'],
      senderLastName: json['last_name'],
      senderProfileImage: json['profile_image'],
      status: json['status'],
      seenAt: _parseDateTime(json['seen_at']),
      media: mediaList,
    );
  }

  String get senderName {
    if (senderFirstName != null && senderLastName != null) {
      return '$senderFirstName $senderLastName';
    }
    return 'Unknown';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Parse the datetime - DateTime.parse handles both UTC and local formats
        final parsed = DateTime.parse(value);
        // If it's UTC, convert to local time for proper time difference calculation
        if (parsed.isUtc) {
          return parsed.toLocal();
        }
        return parsed;
      } catch (e) {
        print('Error parsing datetime: $value - $e');
        return null;
      }
    }
    return null;
  }
}

class Chat {
  final int id;
  final String type; // 'private' or 'group'
  final DateTime createdAt;
  final List<ChatParticipant> participants;
  final Message? lastMessage;
  final int unreadCount;

  Chat({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    List<ChatParticipant> participantsList = [];
    if (json['participants'] != null) {
      participantsList = (json['participants'] as List)
          .map((p) => ChatParticipant.fromJson(p))
          .toList();
    }

    Message? lastMsg;
    if (json['last_message'] != null) {
      lastMsg = Message.fromJson(json['last_message']);
    }

    return Chat(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'private',
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      participants: participantsList,
      lastMessage: lastMsg,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  // Get chat title (for private chats, it's the other user's name)
  String getChatTitle(int currentUserId) {
    if (type == 'private' && participants.isNotEmpty) {
      final otherUser = participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants.first,
      );
      return otherUser.fullName;
    }
    return 'Group Chat';
  }

  // Get chat avatar (for private chats, it's the other user's profile image)
  String? getChatAvatar(int currentUserId) {
    if (type == 'private' && participants.isNotEmpty) {
      final otherUser = participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants.first,
      );
      return otherUser.profileImage;
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Parse the datetime - DateTime.parse handles both UTC and local formats
        final parsed = DateTime.parse(value);
        // If it's UTC, convert to local time for proper time difference calculation
        if (parsed.isUtc) {
          return parsed.toLocal();
        }
        return parsed;
      } catch (e) {
        print('Error parsing datetime: $value - $e');
        return null;
      }
    }
    return null;
  }
}
