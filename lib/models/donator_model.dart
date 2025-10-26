import 'package:intl/intl.dart';

class Donator {
  final int id;
  final int postId;
  final int userId;
  final double amount;
  final String verificationStatus;
  final String? message;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String postTitle;
  final String postType;
  final List<String> proofs;

  Donator({
    required this.id,
    required this.postId,
    required this.userId,
    required this.amount,
    required this.verificationStatus,
    this.message,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.postTitle,
    required this.postType,
    required this.proofs,
  });

  String get fullName => '$firstName $lastName';

  factory Donator.fromJson(Map<String, dynamic> json) {
    // Parse date - handle both ISO 8601 and RFC 1123 formats
    DateTime parseDate(String dateStr) {
      try {
        // Try ISO 8601 format first
        return DateTime.parse(dateStr);
      } catch (e) {
        // If that fails, try RFC 1123 format (e.g., "Sat, 25 Oct 2025 10:25:04 GMT")
        try {
          return DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(dateStr);
        } catch (e2) {
          // Fallback to current time if all parsing fails
          print('Error parsing date: $dateStr');
          return DateTime.now();
        }
      }
    }

    // Parse proofs - handle both string array and object array formats
    List<String> parseProofs(dynamic proofsData) {
      if (proofsData == null) return [];

      final proofsList = proofsData as List<dynamic>;
      return proofsList.map((e) {
        if (e is String) {
          return e;
        } else if (e is Map<String, dynamic>) {
          // Extract image_url from object
          return e['image_url'] as String;
        }
        return '';
      }).where((url) => url.isNotEmpty).toList();
    }

    return Donator(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: (json['user_id'] as int?) ?? 0, // Handle missing user_id
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      message: json['message'] as String?,
      createdAt: parseDate(json['created_at'] as String),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profileImage: json['profile_image'] as String?,
      postTitle: json['post_title'] as String,
      postType: json['post_type'] as String,
      proofs: parseProofs(json['proofs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'amount': amount,
      'verification_status': verificationStatus,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'post_title': postTitle,
      'post_type': postType,
      'proofs': proofs,
    };
  }
}
