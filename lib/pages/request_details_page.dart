import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/supporter_model.dart' as supporter_model;
import '../services/post_service.dart';
import '../widgets/full_screen_image_viewer.dart';

class RequestDetailsPage extends StatefulWidget {
  final Post post;

  const RequestDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  int _currentMediaPage = 0;
  List<supporter_model.Supporter> _supporters = [];
  bool _isLoadingSupporters = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Request posts: Details, Reactions, Comments, Supporters (4 tabs)
    _tabController = TabController(length: 4, vsync: this);
    _loadSupporters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSupporters() async {
    print('🔍 DEBUG: Loading supporters for request post');
    print('🔍 DEBUG: Post ID: ${widget.post.id}');

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

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = [
      const Tab(text: 'Details', icon: Icon(Icons.info_outline, size: 20)),
      const Tab(text: 'Reactions', icon: Icon(Icons.favorite, size: 20)),
      const Tab(text: 'Comments', icon: Icon(Icons.comment, size: 20)),
      Tab(
        text: 'Supporters (${_supporters.length})',
        icon: const Icon(Icons.people, size: 20),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('Request Details', style: TextStyle(color: Colors.white)),
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildReactionsTab(),
          _buildCommentsTab(),
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
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Request',
                    style: TextStyle(
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
                Row(
                  children: [
                    _buildAnalyticCard(
                      icon: Icons.people,
                      label: 'Supporters',
                      value: widget.post.supporterCount.toString(),
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Container()),
                  ],
                ),
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
      child: Container(
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
    return Row(
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
    );
  }

  Widget _buildSupporterReceiptItem(supporter_model.Supporter supporter) {
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            imageUrls: supporter.proofs,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
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
