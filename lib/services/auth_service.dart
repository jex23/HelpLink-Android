import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/signup_request.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Register new user
  Future<AuthResponse> register(SignupRequest request) async {
    try {
      print('=== REGISTRATION DEBUG START ===');
      var uri = Uri.parse(ApiConstants.registerUrl);
      print('Registration URL: $uri');

      var multipartRequest = http.MultipartRequest('POST', uri);

      // Add form fields
      var formFields = request.toFormFields();
      multipartRequest.fields.addAll(formFields);
      print('Form fields: $formFields');

      // Add profile image if provided
      if (request.profileImage != null) {
        print('Adding profile image: ${request.profileImage!.path}');
        final file = request.profileImage!;
        if (await file.exists()) {
          final fileSize = await file.length();
          print('Profile image exists: $fileSize bytes');
          var profileImageFile = await http.MultipartFile.fromPath(
            'profile_image',
            file.path,
          );
          print('Profile image multipart: field="${profileImageFile.field}", filename="${profileImageFile.filename}", contentType=${profileImageFile.contentType}');
          multipartRequest.files.add(profileImageFile);
        } else {
          print('ERROR: Profile image file does not exist!');
        }
      } else {
        print('No profile image provided');
      }

      // Add verification selfie if provided
      if (request.verificationSelfie != null) {
        print('Adding verification selfie: ${request.verificationSelfie!.path}');
        final file = request.verificationSelfie!;
        if (await file.exists()) {
          final fileSize = await file.length();
          print('Verification selfie exists: $fileSize bytes');
          var verificationSelfieFile = await http.MultipartFile.fromPath(
            'verification_selfie',
            file.path,
          );
          print('Verification selfie multipart: field="${verificationSelfieFile.field}", filename="${verificationSelfieFile.filename}", contentType=${verificationSelfieFile.contentType}');
          multipartRequest.files.add(verificationSelfieFile);
        } else {
          print('ERROR: Verification selfie file does not exist!');
        }
      } else {
        print('No verification selfie provided');
      }

      // Add valid ID if provided
      if (request.validId != null) {
        print('Adding valid ID: ${request.validId!.path}');
        final file = request.validId!;
        if (await file.exists()) {
          final fileSize = await file.length();
          print('Valid ID exists: $fileSize bytes');
          var validIdFile = await http.MultipartFile.fromPath(
            'valid_id',
            file.path,
          );
          print('Valid ID multipart: field="${validIdFile.field}", filename="${validIdFile.filename}", contentType=${validIdFile.contentType}');
          multipartRequest.files.add(validIdFile);
        } else {
          print('ERROR: Valid ID file does not exist!');
        }
      } else {
        print('No valid ID provided');
      }

      print('Total files attached: ${multipartRequest.files.length}');
      print('Files in request:');
      for (var file in multipartRequest.files) {
        print('  - ${file.field}: ${file.filename} (${file.contentType})');
      }
      print('Sending request...');

      // Send request
      var streamedResponse = await multipartRequest.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('Registration successful!');
        var jsonResponse = json.decode(response.body);
        var authResponse = AuthResponse.fromJson(jsonResponse);

        // Save token and user data
        await saveToken(authResponse.token);
        await saveUser(authResponse.user);

        print('=== REGISTRATION DEBUG END ===');
        return authResponse;
      } else {
        print('Registration failed with status: ${response.statusCode}');
        var errorData = json.decode(response.body);
        print('Error data: $errorData');
        throw Exception(errorData['error'] ?? 'Registration failed');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HttpException: $e');
      throw Exception('Server error. Please try again later.');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponse> login(String email, String password) async {
    try {
      print('=== LOGIN SERVICE DEBUG START ===');
      print('Login URL: ${ApiConstants.loginUrl}');
      print('Email: $email');

      var response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Login successful!');
        var jsonResponse = json.decode(response.body);
        var authResponse = AuthResponse.fromJson(jsonResponse);

        // Save token and user data
        await saveToken(authResponse.token);
        await saveUser(authResponse.user);

        print('=== LOGIN SERVICE DEBUG END ===');
        return authResponse;
      } else {
        print('Login failed with status: ${response.statusCode}');
        var errorData = json.decode(response.body);
        print('Error data: $errorData');
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HttpException: $e');
      throw Exception('Server error. Please try again later.');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      String? token = await getToken();
      if (token == null) {
        return null;
      }

      var response = await http.get(
        Uri.parse(ApiConstants.meUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var user = User.fromJson(jsonResponse['user']);
        await saveUser(user);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Save token to local storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user to local storage
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Get user from local storage
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get file URL with authentication
  Future<String?> getFileUrl(String filePath) async {
    try {
      String? token = await getToken();
      if (token == null) {
        return null;
      }

      var response = await http.get(
        Uri.parse(ApiConstants.fileUrl(filePath)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
