import 'dart:io';
import 'comment_model.dart';

// Helper classes for expanded data
class Reaction {
  final int id;
  final int userId;
  final String reactionType;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? badge;

  Reaction({
    required this.id,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.badge,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      reactionType: json['reaction_type'] ?? 'like',
      createdAt: Post._parseDateTime(json['created_at']) ?? DateTime.now(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['profile_image'],
      badge: json['badge'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Donator {
  final int id;
  final int userId;
  final double amount;
  final String? message;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? badge;

  Donator({
    required this.id,
    required this.userId,
    required this.amount,
    this.message,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.badge,
  });

  factory Donator.fromJson(Map<String, dynamic> json) {
    return Donator(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      amount: Post._parseDouble(json['amount']) ?? 0.0,
      message: json['message'],
      createdAt: Post._parseDateTime(json['created_at']) ?? DateTime.now(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['profile_image'],
      badge: json['badge'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Supporter {
  final int id;
  final int userId;
  final String supportType;
  final String? message;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? badge;

  Supporter({
    required this.id,
    required this.userId,
    required this.supportType,
    this.message,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.badge,
  });

  factory Supporter.fromJson(Map<String, dynamic> json) {
    return Supporter(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      supportType: json['support_type'] ?? 'share',
      message: json['message'],
      createdAt: Post._parseDateTime(json['created_at']) ?? DateTime.now(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['profile_image'],
      badge: json['badge'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Post {
  final int id;
  final int userId;
  final String postType; // 'donation' or 'request'
  final String title;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String status; // 'active', 'closed', 'pending'
  final List<String> photos;
  final List<String> videos;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User info
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? badge;

  // Interaction counts
  final int reactionCount;
  final int commentCount;
  final int donatorCount;
  final int supporterCount;
  final double totalDonations;

  // Current user's interaction
  final String? userReaction;
  final bool userDonated;
  final bool userSupported;

  // Expanded data (only populated from /api/posts/donations and /api/posts/requests endpoints)
  final List<Reaction>? reactions;
  final List<Donator>? donators;
  final List<Supporter>? supporters;
  final List<Comment>? comments;

  Post({
    required this.id,
    required this.userId,
    required this.postType,
    required this.title,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    required this.status,
    required this.photos,
    required this.videos,
    required this.createdAt,
    required this.updatedAt,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.badge,
    required this.reactionCount,
    required this.commentCount,
    required this.donatorCount,
    required this.supporterCount,
    required this.totalDonations,
    this.userReaction,
    required this.userDonated,
    required this.userSupported,
    this.reactions,
    this.donators,
    this.supporters,
    this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      postType: json['post_type'] ?? 'donation',
      title: json['title'] ?? '',
      description: json['description'],
      address: json['address'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      status: json['status'] ?? 'active',
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
      videos: json['videos'] != null ? List<String>.from(json['videos']) : [],
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['profile_image'],
      badge: json['badge'],
      reactionCount: json['reaction_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      donatorCount: json['donator_count'] ?? 0,
      supporterCount: json['supporter_count'] ?? 0,
      totalDonations: _parseDouble(json['total_donations']) ?? 0.0,
      userReaction: json['user_reaction'],
      userDonated: json['user_donated'] ?? false,
      userSupported: json['user_supported'] ?? false,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((r) => Reaction.fromJson(r))
              .toList()
          : null,
      donators: json['donators'] != null
          ? (json['donators'] as List)
              .map((d) => Donator.fromJson(d))
              .toList()
          : null,
      supporters: json['supporters'] != null
          ? (json['supporters'] as List)
              .map((s) => Supporter.fromJson(s))
              .toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((c) => Comment.fromJson(c))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_type': postType,
      'title': title,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'photos': photos,
      'videos': videos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'badge': badge,
      'reaction_count': reactionCount,
      'comment_count': commentCount,
      'donator_count': donatorCount,
      'supporter_count': supporterCount,
      'total_donations': totalDonations,
      'user_reaction': userReaction,
      'user_donated': userDonated,
      'user_supported': userSupported,
      if (reactions != null) 'reactions': reactions!.map((r) => {
        'id': r.id,
        'user_id': r.userId,
        'reaction_type': r.reactionType,
        'created_at': r.createdAt.toIso8601String(),
        'first_name': r.firstName,
        'last_name': r.lastName,
        'profile_image': r.profileImage,
        'badge': r.badge,
      }).toList(),
      if (donators != null) 'donators': donators!.map((d) => {
        'id': d.id,
        'user_id': d.userId,
        'amount': d.amount,
        'message': d.message,
        'created_at': d.createdAt.toIso8601String(),
        'first_name': d.firstName,
        'last_name': d.lastName,
        'profile_image': d.profileImage,
        'badge': d.badge,
      }).toList(),
      if (supporters != null) 'supporters': supporters!.map((s) => {
        'id': s.id,
        'user_id': s.userId,
        'support_type': s.supportType,
        'message': s.message,
        'created_at': s.createdAt.toIso8601String(),
        'first_name': s.firstName,
        'last_name': s.lastName,
        'profile_image': s.profileImage,
        'badge': s.badge,
      }).toList(),
      if (comments != null) 'comments': comments!.map((c) => c.toJson()).toList(),
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

  // Helper method to safely parse double from JSON (handles both String and num)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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
