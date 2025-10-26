import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/credentials_model.dart';
import '../models/password_change_request.dart';
import '../models/profile_update_request.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class CredentialsService {
  final _authService = AuthService();

  // Get user's profile image
  Future<String?> getProfileImage() async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      var response = await http.get(
        Uri.parse(ApiConstants.profileImageUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get profile image response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return ProfileImageResponse.fromJson(jsonResponse).profileImage;
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to get profile image');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      print('Get profile image error: $e');
      throw Exception('Failed to get profile image: ${e.toString()}');
    }
  }

  // Update user's profile image
  Future<UpdateProfileImageResponse> updateProfileImage(File profileImage) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      var uri = Uri.parse(ApiConstants.profileImageUrl);
      var multipartRequest = http.MultipartRequest('PUT', uri);

      // Add authorization header
      multipartRequest.headers['Authorization'] = 'Bearer $token';

      print('Adding profile image: ${profileImage.path}');
      if (await profileImage.exists()) {
        var profileImageFile = await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path,
        );
        multipartRequest.files.add(profileImageFile);
      } else {
        throw Exception('Profile image file does not exist');
      }

      print('Sending profile image update request...');
      var streamedResponse = await multipartRequest.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Update profile image response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return UpdateProfileImageResponse.fromJson(jsonResponse);
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update profile image');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      print('Update profile image error: $e');
      throw Exception('Failed to update profile image: ${e.toString()}');
    }
  }

  // Update user profile information
  Future<User> updateProfile(ProfileUpdateRequest request) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      var response = await http.put(
        Uri.parse(ApiConstants.profileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      print('Update profile response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var updatedUser = User.fromJson(jsonResponse['user']);

        // Save updated user to local storage
        await _authService.saveUser(updatedUser);

        return updatedUser;
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update profile');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      print('Update profile error: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Get user credentials (verification_selfie and valid_id)
  Future<Credentials> getCredentials() async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      var response = await http.get(
        Uri.parse(ApiConstants.credentialsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get credentials response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return CredentialsResponse.fromJson(jsonResponse).credentials;
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to get credentials');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      print('Get credentials error: $e');
      throw Exception('Failed to get credentials: ${e.toString()}');
    }
  }

  // Update user credentials
  Future<UpdateCredentialsResponse> updateCredentials({
    File? verificationSelfie,
    File? validId,
  }) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      if (verificationSelfie == null && validId == null) {
        throw Exception('At least one file must be provided');
      }

      var uri = Uri.parse(ApiConstants.credentialsUrl);
      var multipartRequest = http.MultipartRequest('PUT', uri);

      // Add authorization header
      multipartRequest.headers['Authorization'] = 'Bearer $token';

      // Add verification selfie if provided
      if (verificationSelfie != null) {
        print('Adding verification selfie: ${verificationSelfie.path}');
        if (await verificationSelfie.exists()) {
          var verificationSelfieFile = await http.MultipartFile.fromPath(
            'verification_selfie',
            verificationSelfie.path,
          );
          multipartRequest.files.add(verificationSelfieFile);
        } else {
          throw Exception('Verification selfie file does not exist');
        }
      }

      // Add valid ID if provided
      if (validId != null) {
        print('Adding valid ID: ${validId.path}');
        if (await validId.exists()) {
          var validIdFile = await http.MultipartFile.fromPath(
            'valid_id',
            validId.path,
          );
          multipartRequest.files.add(validIdFile);
        } else {
          throw Exception('Valid ID file does not exist');
        }
      }

      print('Sending credentials update request...');
      var streamedResponse = await multipartRequest.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Update credentials response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return UpdateCredentialsResponse.fromJson(jsonResponse);
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update credentials');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      print('Update credentials error: $e');
      throw Exception('Failed to update credentials: ${e.toString()}');
    }
  }

  // Get user's valid ID only
  Future<String?> getValidId() async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      var response = await http.get(
        Uri.parse(ApiConstants.idsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get ID response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['id_document']?['valid_id'];
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to get ID');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      print('Get ID error: $e');
      throw Exception('Failed to get ID: ${e.toString()}');
    }
  }

  // Change password
  Future<PasswordChangeResponse> changePassword(
      PasswordChangeRequest request) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      var response = await http.put(
        Uri.parse(ApiConstants.changePasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      print('Change password response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return PasswordChangeResponse.fromJson(jsonResponse);
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to change password');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      print('Change password error: $e');
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }
}
