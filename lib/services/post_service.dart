import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/donator_model.dart' as donator_model;
import '../models/supporter_model.dart' as supporter_model;
import 'post_cache_service.dart';

class PostService {
  final PostCacheService _cacheService = PostCacheService();
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create a new post
  Future<Post?> createPost({
    required String postType,
    required String title,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    List<File>? photos,
    List<File>? videos,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.postUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['post_type'] = postType;
      request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (address != null) request.fields['address'] = address;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add photo files
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
        }
      }

      // Add video files
      if (videos != null && videos.isNotEmpty) {
        for (var video in videos) {
          request.files.add(await http.MultipartFile.fromPath('videos', video.path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Post.fromJson(data['post']);
      } else {
        print('Create post failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Create post error: $e');
      return null;
    }
  }

  // Get posts with filters
  Future<List<Post>> getPosts({
    int? userId,
    String? postType,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (userId != null) queryParams['user_id'] = userId.toString();
      if (postType != null) queryParams['post_type'] = postType;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(ApiConstants.postUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = (data['posts'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
        return posts;
      } else {
        print('Get posts failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get posts error: $e');
      return [];
    }
  }

  // Get all posts with expanded data (reactions, comments, donators, supporters)
  Future<List<Post>> getAllPosts({
    int? userId,
    String? status,
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    try {
      // Generate cache key
      final cacheKey = PostCacheService.getAllPostsCacheKey(
        status: status,
        userId: userId,
      );

      // Return cached data if available and not forcing refresh
      if (!forceRefresh && offset == 0) {
        final cachedPosts = _cacheService.getCachedPosts(cacheKey);
        if (cachedPosts != null) {
          return cachedPosts;
        }
      }

      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'expand': 'true', // Request expanded data
      };

      if (userId != null) queryParams['user_id'] = userId.toString();
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(ApiConstants.postUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = (data['posts'] as List)
            .map((post) => Post.fromJson(post))
            .toList();

        // Cache the results only for first page
        if (offset == 0) {
          _cacheService.cachePosts(cacheKey, posts);
        }

        return posts;
      } else {
        print('Get all posts failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get all posts error: $e');
      return [];
    }
  }

  // Get donation posts with expanded data (reactions, comments, donators, supporters)
  Future<List<Post>> getDonationPosts({
    int? userId,
    String? status,
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    try {
      // Generate cache key
      final cacheKey = PostCacheService.getDonationsCacheKey(
        status: status,
        userId: userId,
      );

      // Return cached data if available and not forcing refresh
      if (!forceRefresh && offset == 0) {
        final cachedPosts = _cacheService.getCachedPosts(cacheKey);
        if (cachedPosts != null) {
          return cachedPosts;
        }
      }

      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (userId != null) queryParams['user_id'] = userId.toString();
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(ApiConstants.donationsUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = (data['posts'] as List)
            .map((post) => Post.fromJson(post))
            .toList();

        // Cache the results only for first page
        if (offset == 0) {
          _cacheService.cachePosts(cacheKey, posts);
        }

        return posts;
      } else {
        print('Get donation posts failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get donation posts error: $e');
      return [];
    }
  }

  // Get request posts with expanded data (reactions, comments, donators, supporters)
  Future<List<Post>> getRequestPosts({
    int? userId,
    String? status,
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    try {
      // Generate cache key
      final cacheKey = PostCacheService.getRequestsCacheKey(
        status: status,
        userId: userId,
      );

      // Return cached data if available and not forcing refresh
      if (!forceRefresh && offset == 0) {
        final cachedPosts = _cacheService.getCachedPosts(cacheKey);
        if (cachedPosts != null) {
          return cachedPosts;
        }
      }

      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (userId != null) queryParams['user_id'] = userId.toString();
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(ApiConstants.requestsUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = (data['posts'] as List)
            .map((post) => Post.fromJson(post))
            .toList();

        // Cache the results only for first page
        if (offset == 0) {
          _cacheService.cachePosts(cacheKey, posts);
        }

        return posts;
      } else {
        print('Get request posts failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get request posts error: $e');
      return [];
    }
  }

  // Get a single post by ID
  Future<Post?> getPost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse(ApiConstants.postDetailUrl(postId)),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Post.fromJson(data['post']);
      } else {
        print('Get post failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get post error: $e');
      return null;
    }
  }

  // Update a post
  Future<Post?> updatePost({
    required int postId,
    String? title,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (address != null) body['address'] = address;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final response = await http.put(
        Uri.parse(ApiConstants.postDetailUrl(postId)),
        headers: _getHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Post.fromJson(data['post']);
      } else {
        print('Update post failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Update post error: $e');
      return null;
    }
  }

  // Close a post
  Future<Post?> closePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.put(
        Uri.parse(ApiConstants.postCloseUrl(postId)),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Post.fromJson(data['post']);
      } else {
        print('Close post failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Close post error: $e');
      return null;
    }
  }

  // Add or update reaction
  Future<Post?> addReaction(int postId, String reactionType) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse(ApiConstants.postReactionUrl(postId)),
        headers: _getHeaders(token),
        body: json.encode({'reaction_type': reactionType}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Post.fromJson(data['post']);
      } else {
        print('Add reaction failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Add reaction error: $e');
      return null;
    }
  }

  // Remove reaction
  Future<Post?> removeReaction(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse(ApiConstants.postReactionUrl(postId)),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Post.fromJson(data['post']);
      } else {
        print('Remove reaction failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Remove reaction error: $e');
      return null;
    }
  }

  // Add donation to a post with optional proof images
  Future<bool> addDonation({
    required int postId,
    required double amount,
    String? message,
    List<File>? proofImages,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.donatorsUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['post_id'] = postId.toString();
      request.fields['amount'] = amount.toString();
      if (message != null && message.isNotEmpty) {
        request.fields['message'] = message;
      }

      // Add proof images
      if (proofImages != null && proofImages.isNotEmpty) {
        for (var image in proofImages) {
          request.files.add(await http.MultipartFile.fromPath('proofs', image.path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Add donation failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Add donation error: $e');
      return false;
    }
  }

  // Add support to a post with optional proof images
  Future<bool> addSupport({
    required int postId,
    String supportType = 'share',
    String? message,
    List<File>? proofImages,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.supportersUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['post_id'] = postId.toString();
      request.fields['support_type'] = supportType;
      if (message != null && message.isNotEmpty) {
        request.fields['message'] = message;
      }

      // Add proof images
      if (proofImages != null && proofImages.isNotEmpty) {
        for (var image in proofImages) {
          request.files.add(await http.MultipartFile.fromPath('proofs', image.path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Add support failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Add support error: $e');
      return false;
    }
  }

  // Create a comment
  Future<Comment?> createComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final body = <String, dynamic>{'content': content};
      if (parentId != null) body['parent_id'] = parentId;

      final response = await http.post(
        Uri.parse(ApiConstants.postCommentsUrl(postId)),
        headers: _getHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Comment.fromJson(data['comment']);
      } else {
        print('Create comment failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Create comment error: $e');
      return null;
    }
  }

  // Get comments for a post
  Future<List<Comment>> getComments({
    required int postId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse(ApiConstants.postCommentsUrl(postId))
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final comments = (data['comments'] as List)
            .map((comment) => Comment.fromJson(comment))
            .toList();
        return comments;
      } else {
        print('Get comments failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get comments error: $e');
      return [];
    }
  }

  // Update a comment
  Future<Comment?> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.put(
        Uri.parse(ApiConstants.commentUrl(commentId)),
        headers: _getHeaders(token),
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Comment.fromJson(data['comment']);
      } else {
        print('Update comment failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Update comment error: $e');
      return null;
    }
  }

  // Delete a comment
  Future<bool> deleteComment(int commentId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse(ApiConstants.commentUrl(commentId)),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Delete comment failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Delete comment error: $e');
      return false;
    }
  }

  // Get donators for a specific post
  Future<List<donator_model.Donator>> getDonatorsByPostId({
    required int postId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'post_id': postId.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse(ApiConstants.donatorsUrl)
          .replace(queryParameters: queryParams);

      print('🌐 DEBUG API: Fetching donators from: $uri');
      final response = await http.get(uri, headers: _getHeaders(token));
      print('🌐 DEBUG API: Response status: ${response.statusCode}');
      print('🌐 DEBUG API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final donators = (data['donators'] as List)
            .map((donator) => donator_model.Donator.fromJson(donator))
            .toList();
        print('✅ DEBUG API: Successfully parsed ${donators.length} donators');
        return donators;
      } else {
        print('❌ Get donators failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Get donators error: $e');
      return [];
    }
  }

  // Get supporters for a specific post
  Future<List<supporter_model.Supporter>> getSupportersByPostId({
    required int postId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'post_id': postId.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse(ApiConstants.supportersUrl)
          .replace(queryParameters: queryParams);

      print('🌐 DEBUG API: Fetching supporters from: $uri');
      final response = await http.get(uri, headers: _getHeaders(token));
      print('🌐 DEBUG API: Response status: ${response.statusCode}');
      print('🌐 DEBUG API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final supporters = (data['supporters'] as List)
            .map((supporter) => supporter_model.Supporter.fromJson(supporter))
            .toList();
        print('✅ DEBUG API: Successfully parsed ${supporters.length} supporters');
        return supporters;
      } else {
        print('❌ Get supporters failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Get supporters error: $e');
      return [];
    }
  }
}
