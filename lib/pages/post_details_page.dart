import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/donator_model.dart' as donator_model;
import '../models/supporter_model.dart' as supporter_model;
import '../services/post_service.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;

  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  int _currentMediaPage = 0; // Track current media page
  List<donator_model.Donator> _donators = [];
  List<supporter_model.Supporter> _supporters = [];
  bool _isLoadingDonators = false;
  bool _isLoadingSupporters = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Create tab controller with different number of tabs based on post type
    // Request posts: Details, Reactions, Comments, Donors, Supporters (5 tabs)
    // Donation posts: Details, Reactions, Comments, Supporters (4 tabs)
    final tabCount = widget.post.postType == 'request' ? 5 : 4;
    _tabController = TabController(length: tabCount, vsync: this);
    _loadDonatorsAndSupporters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDonatorsAndSupporters() async {
    // Fetch relevant data based on post type
    // Request posts -> show BOTH donators (money) AND supporters (volunteers, shares, etc.)
    // Donation posts -> show ONLY supporters (people who claimed/received or helped promote)

    print('🔍 DEBUG: Loading data for post type: ${widget.post.postType}');
    print('🔍 DEBUG: Post ID: ${widget.post.id}');

    if (widget.post.postType == 'request') {
      // Request posts need BOTH donators and supporters
      print('🔍 DEBUG: Fetching donators AND supporters for request post...');
      setState(() {
        _isLoadingDonators = true;
        _isLoadingSupporters = true;
      });

      try {
        // Fetch both in parallel
        final results = await Future.wait([
          _postService.getDonatorsByPostId(postId: widget.post.id),
          _postService.getSupportersByPostId(postId: widget.post.id),
        ]);

        print('✅ DEBUG: Received ${(results[0] as List).length} donators');
        print('✅ DEBUG: Received ${(results[1] as List).length} supporters');

        if (mounted) {
          setState(() {
            _donators = results[0] as List<donator_model.Donator>;
            _supporters = results[1] as List<supporter_model.Supporter>;
            _isLoadingDonators = false;
            _isLoadingSupporters = false;
          });
        }
      } catch (e) {
        print('❌ DEBUG: Error fetching donators/supporters: $e');
        if (mounted) {
          setState(() {
            _isLoadingDonators = false;
            _isLoadingSupporters = false;
          });
        }
      }
    } else if (widget.post.postType == 'donation') {
      // Donation posts only need supporters
      print('🔍 DEBUG: Fetching supporters for donation post...');
      setState(() {
        _isLoadingSupporters = true;
      });

      try {
        final supporters = await _postService.getSupportersByPostId(postId: widget.post.id);
        print('✅ DEBUG: Received ${supporters.length} supporters');

        if (mounted) {
          setState(() {
            _supporters = supporters;
            _isLoadingSupporters = false;
          });
        }
      } catch (e) {
        print('❌ DEBUG: Error fetching supporters: $e');
        if (mounted) {
          setState(() {
            _isLoadingSupporters = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build tabs based on post type
    final List<Tab> tabs = [
      const Tab(text: 'Details', icon: Icon(Icons.info_outline, size: 20)),
      const Tab(text: 'Reactions', icon: Icon(Icons.favorite, size: 20)),
      const Tab(text: 'Comments', icon: Icon(Icons.comment, size: 20)),
    ];

    // Add Donors tab only for request posts
    if (widget.post.postType == 'request') {
      tabs.add(Tab(
        text: 'Donors (${_donators.length})',
        icon: const Icon(Icons.volunteer_activism, size: 20),
      ));
    }

    // Add Supporters tab for all posts
    tabs.add(Tab(
      text: 'Supporters (${_supporters.length})',
      icon: const Icon(Icons.people, size: 20),
    ));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: Text(
          widget.post.postType == 'donation' ? 'Donation Details' : 'Request Details',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Show options menu (Edit, Delete, Close Post)
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          isScrollable: false,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildReactionsTab(),
          _buildCommentsTab(),
          if (widget.post.postType == 'request') _buildDonorsTab(),
          _buildSupportersTab(),
        ],
      ),
    );
  }

  // Details Tab
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.post.postType == 'donation' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.post.postType == 'donation' ? 'Donation' : 'Request',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status
                  Row(
                    children: [
                      Icon(
                        widget.post.status == 'active' ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: widget.post.status == 'active' ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.status == 'active' ? 'Active' : 'Closed',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.post.status == 'active' ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.timeAgo,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Analytics Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildAnalyticCard(
                        icon: Icons.favorite,
                        label: 'Reactions',
                        value: widget.post.reactionCount.toString(),
                        color: Colors.red,
                      ),
                      const SizedBox(width: 12),
                      _buildAnalyticCard(
                        icon: Icons.comment,
                        label: 'Comments',
                        value: widget.post.commentCount.toString(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Show relevant metrics based on post type
                  if (widget.post.postType == 'request')
                    // Request posts show donators and their total donations
                    Row(
                      children: [
                        _buildAnalyticCard(
                          icon: Icons.volunteer_activism,
                          label: 'Donors',
                          value: widget.post.donatorCount.toString(),
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildAnalyticCard(
                          icon: Icons.people,
                          label: 'Supporters',
                          value: widget.post.supporterCount.toString(),
                          color: Colors.purple,
                        ),
                      ],
                    )
                  else if (widget.post.postType == 'donation')
                    // Donation posts show supporters (people who helped share/promote)
                    Row(
                      children: [
                        _buildAnalyticCard(
                          icon: Icons.people,
                          label: 'Supporters',
                          value: widget.post.supporterCount.toString(),
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Container()), // Empty space for symmetry
                      ],
                    ),
                  if (widget.post.postType == 'request' && widget.post.totalDonations > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.green, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Donations',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₱${widget.post.totalDonations.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Description Section
            if (widget.post.description != null) ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.post.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Media Section
            if (widget.post.photos.isNotEmpty || widget.post.videos.isNotEmpty) ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Media',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: _buildMediaGallery(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Location Section
            if (widget.post.address != null) ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF1976D2)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.post.address!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.post.latitude != null && widget.post.longitude != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Coordinates: ${widget.post.latitude!.toStringAsFixed(6)}, ${widget.post.longitude!.toStringAsFixed(6)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 16),
          ],
        ),
    );
  }

  // Reactions Tab
  Widget _buildReactionsTab() {
    print('🔍 DEBUG: Building reactions tab. Reactions: ${widget.post.reactions?.length ?? 0}');

    if (widget.post.reactions == null || widget.post.reactions!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reactions yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reactions Breakdown (${widget.post.reactionCount})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReactionsBreakdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Comments Tab
  Widget _buildCommentsTab() {
    print('🔍 DEBUG: Building comments tab. Comments: ${widget.post.comments?.length ?? 0}');

    if (widget.post.comments == null || widget.post.comments!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.post.comments!.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildCommentItem(widget.post.comments![index]),
        );
      },
    );
  }

  // Donors Tab (only for request posts)
  Widget _buildDonorsTab() {
    print('🔍 DEBUG: Building donors tab. Donors: ${_donators.length}, Loading: $_isLoadingDonators');

    if (_isLoadingDonators) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_donators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No donations yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to donate!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _donators.length,
      itemBuilder: (context, index) {
        return _buildDonatorReceiptItem(_donators[index]);
      },
    );
  }

  // Supporters Tab
  Widget _buildSupportersTab() {
    print('🔍 DEBUG: Building supporters tab. Supporters: ${_supporters.length}, Loading: $_isLoadingSupporters');

    if (_isLoadingSupporters) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_supporters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No supporters yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to support!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _supporters.length,
      itemBuilder: (context, index) {
        return _buildSupporterReceiptItem(_supporters[index]);
      },
    );
  }

  Widget _buildAnalyticCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGallery() {
    final allMedia = [...widget.post.photos, ...widget.post.videos];
    if (allMedia.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        PageView.builder(
          itemCount: allMedia.length,
          onPageChanged: (index) {
            setState(() {
              _currentMediaPage = index;
            });
          },
              itemBuilder: (context, index) {
                final mediaUrl = allMedia[index];
                final isVideo = widget.post.videos.contains(mediaUrl);

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
                    color: _currentMediaPage == index
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
    );
  }

  Widget _buildReactionsBreakdown() {
    final reactions = widget.post.reactions!;
    final reactionCounts = <String, int>{};

    for (var reaction in reactions) {
      reactionCounts[reaction.reactionType] = (reactionCounts[reaction.reactionType] ?? 0) + 1;
    }

    final reactionIcons = {
      'like': {'icon': Icons.thumb_up, 'color': Colors.blue},
      'love': {'icon': Icons.favorite, 'color': Colors.red},
      'care': {'icon': Icons.favorite, 'color': Colors.pink},
      'support': {'icon': Icons.volunteer_activism, 'color': Colors.green},
    };

    return Column(
      children: reactionCounts.entries.map((entry) {
        final reactionData = reactionIcons[entry.key];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                reactionData?['icon'] as IconData,
                color: reactionData?['color'] as Color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                entry.key[0].toUpperCase() + entry.key.substring(1),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (reactionData?['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: reactionData?['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1976D2),
            backgroundImage: comment.profileImage != null
                ? CachedNetworkImageProvider(comment.profileImage!)
                : null,
            child: comment.profileImage == null
                ? Text(
                    comment.fullName.isNotEmpty ? comment.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
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
    );
  }

  Widget _buildDonatorReceiptItem(donator_model.Donator donator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                backgroundImage: donator.profileImage != null
                    ? CachedNetworkImageProvider(donator.profileImage!)
                    : null,
                child: donator.profileImage == null
                    ? Text(
                        donator.fullName.isNotEmpty ? donator.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donator.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      donator.createdAt.toString().substring(0, 16),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₱${donator.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (donator.message != null && donator.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                donator.message!,
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
            ),
          ],
          if (donator.proofs.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Proof of Donation:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: donator.proofs.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: donator.proofs[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 32, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: donator.verificationStatus == 'verified'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              donator.verificationStatus == 'verified' ? 'Verified' : 'Pending Verification',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: donator.verificationStatus == 'verified' ? Colors.green[800] : Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupporterReceiptItem(supporter_model.Supporter supporter) {
    // Get support type icon
    IconData supportIcon;
    switch (supporter.supportType) {
      case 'share':
        supportIcon = Icons.share;
        break;
      case 'volunteer':
        supportIcon = Icons.volunteer_activism;
        break;
      case 'prayer':
        supportIcon = Icons.favorite;
        break;
      default:
        supportIcon = Icons.support;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.purple,
                backgroundImage: supporter.profileImage != null
                    ? CachedNetworkImageProvider(supporter.profileImage!)
                    : null,
                child: supporter.profileImage == null
                    ? Text(
                        supporter.fullName.isNotEmpty ? supporter.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supporter.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      supporter.createdAt.toString().substring(0, 16),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(supportIcon, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      supporter.supportType[0].toUpperCase() + supporter.supportType.substring(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (supporter.message != null && supporter.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                supporter.message!,
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
            ),
          ],
          if (supporter.proofs.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Proof of Support:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: supporter.proofs.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: supporter.proofs[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 32, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
