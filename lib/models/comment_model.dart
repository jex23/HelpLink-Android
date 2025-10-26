import 'dart:io';

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final int? parentId;
  final String status; // 'visible', 'hidden', 'deleted'
  final DateTime createdAt;
  final DateTime updatedAt;

  // User info
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? badge;

  // Replies (for parent comments)
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.badge,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['post_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      content: json['content'] ?? '',
      parentId: json['parent_id'],
      status: json['status'] ?? 'visible',
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['profile_image'],
      badge: json['badge'],
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((reply) => Comment.fromJson(reply))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'badge': badge,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }

  String get fullName => '$firstName $lastName';

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

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Try ISO 8601 format first
        return DateTime.parse(value);
      } catch (e) {
        try {
          // Try HTTP/RFC 2822 format (e.g., "Fri, 24 Oct 2025 13:23:20 GMT")
          return HttpDate.parse(value);
        } catch (e2) {
          print('Failed to parse date: $value');
          return null;
        }
      }
    }
    return null;
  }
}
