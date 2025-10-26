import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class ProfileService {
  final _authService = AuthService();

  Future<User?> loadUserData() async {
    try {
      final user = await _authService.getUser();
      return user;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  Color getBadgeColor(String? badge) {
    switch (badge?.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'under_review':
      case 'for_verification':
        return Colors.orange;
      case 'pending':
        return Colors.amber;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getBadgeText(String? badge) {
    switch (badge?.toLowerCase()) {
      case 'verified':
        return 'VERIFIED';
      case 'under_review':
        return 'UNDER REVIEW';
      case 'for_verification':
        return 'FOR VERIFICATION';
      case 'pending':
        return 'PENDING';
      case 'rejected':
        return 'REJECTED';
      default:
        return 'UNVERIFIED';
    }
  }

  String formatJoinDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
