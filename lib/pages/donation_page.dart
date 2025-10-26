import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';
import '../models/post_model.dart';
import '../components/app_header.dart';
import 'donation_details_page.dart';
import 'request_details_page.dart';

class DonationPage extends StatefulWidget {
  final VoidCallback? onCreatePost;

  const DonationPage({Key? key, this.onCreatePost}) : super(key: key);

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  String _selectedFilter = 'All';
  List<Post> _myPosts = [];
  bool _isLoading = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getUser();
    if (mounted) {
      setState(() {
        _currentUserId = user?.id;
      });
    }
  }

  Future<void> _loadPosts({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use new expanded endpoints that include reactions, comments, donators, and supporters
      final donations = await _postService.getDonationPosts(
        status: 'active',
        limit: 50,
        forceRefresh: forceRefresh,
      );

      final requests = await _postService.getRequestPosts(
        status: 'active',
        limit: 50,
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          // Combine and filter to show only current user's posts
          final allPosts = [...donations, ...requests];
          _myPosts = _currentUserId != null
              ? allPosts.where((post) => post.userId == _currentUserId).toList()
              : [];

          // Sort by creation date (newest first)
          _myPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
    if (_selectedFilter == 'All') {
      return _myPosts;
    } else if (_selectedFilter == 'Donations') {
      return _myPosts.where((post) => post.postType == 'donation').toList();
    } else {
      return _myPosts.where((post) => post.postType == 'request').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(title: 'My Posts'),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF1976D2), size: 28),
                      onPressed: widget.onCreatePost,
                      tooltip: 'Create Post',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterTab('All'),
                    const SizedBox(width: 8),
                    _buildFilterTab('Donations'),
                    const SizedBox(width: 8),
                    _buildFilterTab('Requests'),
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

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
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
    final emptyMessage = _selectedFilter == 'All'
        ? 'No posts yet'
        : _selectedFilter == 'Donations'
            ? 'No donations yet'
            : 'No requests yet';

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: posts.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Icon(
                        Icons.post_add,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your posts will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: widget.onCreatePost,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Create Post', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(posts[index]);
              },
            ),
    );
  }

  Widget _buildPostCard(Post post) {
    final allMedia = [...post.photos, ...post.videos];
    final hasMedia = allMedia.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to appropriate details page based on post type
          if (post.postType == 'donation') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DonationDetailsPage(post: post),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestDetailsPage(post: post),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail or placeholder
              if (hasMedia)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: post.videos.contains(allMedia[0])
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                color: Colors.black87,
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: allMedia[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 24),
                            ),
                          ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (post.postType == 'donation' ? Colors.green : Colors.orange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    post.postType == 'donation' ? Icons.volunteer_activism : Icons.help_outline,
                    size: 32,
                    color: post.postType == 'donation' ? Colors.green : Colors.orange,
                  ),
                ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post type and status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: post.postType == 'donation' ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.postType == 'donation' ? 'Donation' : 'Request',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          post.status == 'active' ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: post.status == 'active' ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          post.status == 'active' ? 'Active' : 'Closed',
                          style: TextStyle(
                            fontSize: 11,
                            color: post.status == 'active' ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (hasMedia && allMedia.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.image, size: 12, color: Colors.grey[700]),
                                const SizedBox(width: 2),
                                Text(
                                  '${allMedia.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Stats row
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${post.reactionCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.comment, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${post.commentCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        if (post.postType == 'request' && post.donatorCount > 0) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.volunteer_activism, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${post.donatorCount}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          post.timeAgo,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}