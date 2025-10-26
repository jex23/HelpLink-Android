import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/post_service.dart';
import '../services/chat_service.dart';
import '../models/post_model.dart';
import '../components/app_header.dart';
import 'comments_page.dart';
import 'post_donation_page.dart';
import 'post_support_page.dart';
import 'post_details_page.dart';
import 'chat_conversation_page.dart';
import 'login_page.dart';

class SupportPage extends StatefulWidget {
  final bool isGuest;

  const SupportPage({Key? key, this.isGuest = false}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final PostService _postService = PostService();
  final ChatService _chatService = ChatService();
  String _selectedTab = 'All';
  List<Post> _allPosts = [];
  bool _isLoading = false;
  final Map<int, int> _currentMediaPages = {}; // Track current page for each post
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final userId = userData['id'];

        setState(() {
          _currentUserId = userId ?? 0;
        });
      } else {
        setState(() {
          _currentUserId = 0;
        });
      }
    } catch (e) {
      print('Error loading user ID in SupportPage: $e');
      setState(() {
        _currentUserId = 0;
      });
    }
  }

  Future<void> _loadPosts({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all posts with expanded data (donators and supporters)
      final posts = await _postService.getAllPosts(
        status: 'active',
        limit: 50,
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          _allPosts = posts;
          // Sort by creation date (newest first)
          _allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading posts: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await _loadPosts(forceRefresh: true);
  }

  List<Post> get _filteredPosts {
    if (_selectedTab == 'All') {
      return _allPosts;
    } else if (_selectedTab == 'Donations') {
      return _allPosts.where((post) => post.postType == 'donation').toList();
    } else {
      return _allPosts.where((post) => post.postType == 'request').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(title: 'Home'),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (widget.isGuest)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _handleSignIn,
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text('Sign In'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    _buildTab('All'),
                    const SizedBox(width: 8),
                    _buildTab('Donations'),
                    const SizedBox(width: 8),
                    _buildTab('Requests'),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = _selectedTab == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final posts = _filteredPosts;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No posts available at the moment',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...posts.map((post) => _buildPostCard(post)),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1976D2),
                  backgroundImage: post.profileImage != null
                      ? CachedNetworkImageProvider(post.profileImage!)
                      : null,
                  child: post.profileImage == null
                      ? Text(
                          post.fullName.isNotEmpty
                              ? post.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: post.postType == 'donation' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.postType == 'donation' ? 'Donation' : 'Request',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Chat button (only for logged in users and not their own posts)
                if (!widget.isGuest && post.userId != _currentUserId) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    onPressed: () => _handleStartChat(post),
                    tooltip: 'Chat with ${post.fullName}',
                    color: const Color(0xFF1976D2),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailsPage(post: post),
                      ),
                    );
                  },
                  tooltip: 'View Details',
                  color: const Color(0xFF1976D2),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Title and Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (post.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Photos/Videos
          if (post.photos.isNotEmpty || post.videos.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMediaGallery(post),
          ],

          // Location
          if (post.address != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      post.address!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Reaction Stats
          if (post.reactionCount > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${post.reactionCount} ${post.reactionCount == 1 ? 'reaction' : 'reactions'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
          ],

          const Divider(height: 1),

          // Reaction Buttons (disabled for guests)
          if (!widget.isGuest)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildReactionButton(post, 'like', Icons.thumb_up_outlined, Icons.thumb_up, Colors.blue),
                  _buildReactionButton(post, 'love', Icons.favorite_border, Icons.favorite, Colors.red),
                  _buildReactionButton(post, 'care', Icons.favorite_border, Icons.favorite, Colors.pink),
                  _buildReactionButton(post, 'support', Icons.volunteer_activism_outlined, Icons.volunteer_activism, Colors.green),
                ],
              ),
            ),
          if (!widget.isGuest)
            const Divider(height: 1),

          // Donate/Support Button Section (disabled for guests)
          if (!widget.isGuest) ...[
            _buildActionButton(post),
            const Divider(height: 1),
          ],

          // Comments Section
          _buildCommentsSection(post),
        ],
      ),
    );
  }

  Widget _buildActionButton(Post post) {
    // Show Donate button for donation posts, Support button for request posts
    final isDonation = post.postType == 'donation';
    final buttonLabel = isDonation ? 'Donate' : 'Support';
    final buttonIcon = isDonation ? Icons.attach_money : Icons.volunteer_activism;
    final buttonColor = isDonation ? Colors.green : Colors.purple;
    final hasActed = isDonation ? post.userDonated : post.userSupported;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Show stats if applicable
          if (isDonation && post.donatorCount > 0) ...[
            Icon(Icons.people, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${post.donatorCount} ${post.donatorCount == 1 ? 'donor' : 'donors'}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            if (post.totalDonations > 0) ...[
              const SizedBox(width: 4),
              Text(
                '• ₱${post.totalDonations.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 13, color: Colors.green[700], fontWeight: FontWeight.bold),
              ),
            ],
            const Spacer(),
          ],
          if (!isDonation && post.supporterCount > 0) ...[
            Icon(Icons.people, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${post.supporterCount} ${post.supporterCount == 1 ? 'supporter' : 'supporters'}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const Spacer(),
          ],
          if ((isDonation && post.donatorCount == 0) || (!isDonation && post.supporterCount == 0))
            const Spacer(),
          // Action button
          ElevatedButton.icon(
            onPressed: hasActed ? null : () => _handleActionButton(post),
            icon: Icon(buttonIcon, size: 18),
            label: Text(hasActed ? '${buttonLabel}d' : buttonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasActed ? Colors.grey : buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleActionButton(Post post) async {
    final isDonation = post.postType == 'donation';

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isDonation
            ? PostDonationPage(post: post)
            : PostSupportPage(post: post),
      ),
    );

    // Refresh if action was successful
    if (result == true && mounted) {
      await _loadPosts(forceRefresh: true);
    }
  }

  Widget _buildMediaGallery(Post post) {
    final allMedia = [...post.photos, ...post.videos];
    if (allMedia.isEmpty) return const SizedBox.shrink();

    // Initialize current page for this post if not already set
    _currentMediaPages.putIfAbsent(post.id, () => 0);

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: allMedia.length,
            onPageChanged: (index) {
              setState(() {
                _currentMediaPages[post.id] = index;
              });
            },
                itemBuilder: (context, index) {
                  final mediaUrl = allMedia[index];
                  final isVideo = post.videos.contains(mediaUrl);

                  if (isVideo) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VIDEO',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return CachedNetworkImage(
                    imageUrl: mediaUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 48),
                    ),
                  );
                },
              ),
          // Page indicators - only show if more than 1 media item
          if (allMedia.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  allMedia.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentMediaPages[post.id] == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(Post post, String reactionType, IconData icon, IconData filledIcon, Color color) {
    final isReacted = post.userReaction == reactionType;

    return Expanded(
      child: InkWell(
        onTap: () => _handleReaction(post, reactionType),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isReacted ? filledIcon : icon,
                size: 20,
                color: isReacted ? color : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                reactionType[0].toUpperCase() + reactionType.substring(1),
                style: TextStyle(
                  color: isReacted ? color : Colors.grey[700],
                  fontSize: 13,
                  fontWeight: isReacted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection(Post post) {
    if (post.comments == null || post.comments!.isEmpty) {
      // For guests, show a message but don't allow commenting
      if (widget.isGuest) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.comment_outlined, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                'No comments yet',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _showCommentDialog(post),
          child: Row(
            children: [
              Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Be the first to comment',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Show first 2 comments
        ...post.comments!.take(2).map((comment) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF1976D2),
                backgroundImage: comment.profileImage != null
                    ? CachedNetworkImageProvider(comment.profileImage!)
                    : null,
                child: comment.profileImage == null
                    ? Text(
                        comment.fullName.isNotEmpty
                            ? comment.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.fullName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),

        // View all comments button (only for logged in users)
        if (post.commentCount > 2 && !widget.isGuest) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => _showCommentDialog(post),
              child: Text(
                'View all ${post.commentCount} comments',
                style: const TextStyle(
                  color: Color(0xFF1976D2),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],

        // Add comment button (only for logged in users)
        if (!widget.isGuest)
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () => _showCommentDialog(post),
              child: Row(
                children: [
                  Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Write a comment...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleReaction(Post post, String reactionType) async {
    // Optimistic UI update
    setState(() {
      final index = _allPosts.indexWhere((p) => p.id == post.id);

      if (index != -1) {
        final isRemoving = post.userReaction == reactionType;

        // Update the count and user reaction
        final updatedPost = Post(
          id: post.id,
          userId: post.userId,
          postType: post.postType,
          title: post.title,
          description: post.description,
          address: post.address,
          latitude: post.latitude,
          longitude: post.longitude,
          status: post.status,
          photos: post.photos,
          videos: post.videos,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          firstName: post.firstName,
          lastName: post.lastName,
          profileImage: post.profileImage,
          badge: post.badge,
          reactionCount: isRemoving ? post.reactionCount - 1 : (post.userReaction == null ? post.reactionCount + 1 : post.reactionCount),
          commentCount: post.commentCount,
          donatorCount: post.donatorCount,
          supporterCount: post.supporterCount,
          totalDonations: post.totalDonations,
          userReaction: isRemoving ? null : reactionType,
          userDonated: post.userDonated,
          userSupported: post.userSupported,
          reactions: post.reactions,
          donators: post.donators,
          supporters: post.supporters,
          comments: post.comments,
        );

        _allPosts[index] = updatedPost;
      }
    });

    // Call API
    try {
      if (post.userReaction == reactionType) {
        // Remove reaction
        await _postService.removeReaction(post.id);
      } else {
        // Add/update reaction
        await _postService.addReaction(post.id, reactionType);
      }
    } catch (e) {
      // Revert on error
      print('Error handling reaction: $e');
      await _loadPosts(forceRefresh: true);
    }
  }

  Future<void> _showCommentDialog(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(post: post),
      ),
    );
    // Refresh posts when returning from comments page
    await _loadPosts(forceRefresh: true);
  }

  Future<void> _handleStartChat(Post post) async {
    // Don't allow chatting with yourself
    if (post.userId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final chat = await _chatService.createOrGetPrivateChat(post.userId);

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      if (chat != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationPage(
              chat: chat,
              currentUserId: _currentUserId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start chat')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error starting chat')),
        );
      }
    }
  }

  void _handleSignIn() {
    // Navigate to login page and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
