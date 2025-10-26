import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/post_service.dart';
import '../models/post_model.dart';
import '../utils/location_helper.dart';
import '../components/app_header.dart';
import 'post_details_page.dart';
import 'login_page.dart';
import 'dart:math' as math;

class NearbyPage extends StatefulWidget {
  final bool isGuest;

  const NearbyPage({Key? key, this.isGuest = false}) : super(key: key);

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final PostService _postService = PostService();
  final MapController _mapController = MapController();

  String _selectedFilter = 'All';
  double? _maxDistance; // null means show all distances
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = false;
  bool _isLoadingLocation = false;

  LatLng? _currentLocation;
  String _locationText = 'Fetching location...';

  // Distance filter options in km (null means "All")
  final List<double?> _distanceOptions = [null, 1, 5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoadingLocation = true;
    });

    // Get current location
    await _getCurrentLocation();

    // Load posts
    await _loadPosts();

    setState(() {
      _isLoadingLocation = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await LocationHelper.handleLocationPermission();

      if (!hasPermission) {
        setState(() {
          _locationText = 'Location permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationText = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });

      // Move map to current location
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 13.0);
      }

      // Get address from coordinates
      final address = await LocationHelper.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address != null && mounted) {
        setState(() {
          _locationText = address;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _locationText = 'Unable to get location';
        // Default to Manila if location fails
        _currentLocation = const LatLng(14.5995, 120.9842);
      });
    }
  }

  Future<void> _loadPosts({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch both donations and requests
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
          _allPosts = [...donations, ...requests];
          // Filter to only posts with valid coordinates
          _allPosts = _allPosts.where((post) =>
          post.latitude != null && post.longitude != null
          ).toList();

          _applyFilter();
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

  void _applyFilter() {
    // Filter by post type
    if (_selectedFilter == 'All') {
      _filteredPosts = _allPosts;
    } else if (_selectedFilter == 'Donations') {
      _filteredPosts = _allPosts.where((post) => post.postType == 'donation').toList();
    } else {
      _filteredPosts = _allPosts.where((post) => post.postType == 'request').toList();
    }

    // Filter by distance if max distance is set
    if (_maxDistance != null && _currentLocation != null) {
      _filteredPosts = _filteredPosts.where((post) {
        final distance = _calculateDistance(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          post.latitude!,
          post.longitude!,
        );
        return distance <= _maxDistance!;
      }).toList();
    }

    // Sort by distance from current location
    if (_currentLocation != null) {
      _filteredPosts.sort((a, b) {
        final distA = _calculateDistance(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          a.latitude!,
          a.longitude!,
        );
        final distB = _calculateDistance(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          b.latitude!,
          b.longitude!,
        );
        return distA.compareTo(distB);
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  Future<void> _handleRefresh() async {
    await _getCurrentLocation();
    await _loadPosts(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(title: 'Nearby'),
      body: Column(
        children: [
          // Location info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.location_searching, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationText,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isGuest)
                  TextButton.icon(
                    onPressed: _handleSignIn,
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Sign In'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                if (_isLoadingLocation)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (!widget.isGuest)
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Color(0xFF1976D2)),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Refresh location',
                  ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterTab('All'),
                const SizedBox(width: 8),
                _buildFilterTab('Donations'),
                const SizedBox(width: 8),
                _buildFilterTab('Requests'),
              ],
            ),
          ),

          // Distance Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.tune, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Distance:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _distanceOptions.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return _buildDistanceChip(_distanceOptions[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Map View
          Expanded(
            flex: 2,
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 13.0,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.helplink',
                  maxZoom: 19,
                ),
                // Markers for posts
                MarkerLayer(
                  markers: _filteredPosts.map((post) {
                    return Marker(
                      point: LatLng(post.latitude!, post.longitude!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _showPostBottomSheet(post);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: post.postType == 'donation'
                                ? Colors.green
                                : Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            post.postType == 'donation'
                                ? Icons.volunteer_activism
                                : Icons.help_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Current location marker
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Posts List
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearest Posts (${_filteredPosts.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _handleRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 1,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPosts.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No posts nearby',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                return _buildPostListItem(_filteredPosts[index]);
              },
            ),
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
            _applyFilter();
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

  Widget _buildDistanceChip(double? distance) {
    final isSelected = _maxDistance == distance;
    final label = distance == null ? 'All' : '${distance.toInt()}km';

    return InkWell(
      onTap: () {
        setState(() {
          _maxDistance = distance;
          _applyFilter();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPostListItem(Post post) {
    double? distance;
    if (_currentLocation != null) {
      distance = _calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        post.latitude!,
        post.longitude!,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          _showPostBottomSheet(post);
          // Move map to post location
          _mapController.move(LatLng(post.latitude!, post.longitude!), 15.0);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Type icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: post.postType == 'donation'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  post.postType == 'donation'
                      ? Icons.volunteer_activism
                      : Icons.help_outline,
                  color: post.postType == 'donation' ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Post info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.fullName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (post.address != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              post.address!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Distance
              if (distance != null) ...[
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Icon(Icons.near_me, size: 16, color: Color(0xFF1976D2)),
                    const SizedBox(height: 4),
                    Text(
                      _formatDistance(distance),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPostBottomSheet(Post post) {
    double? distance;
    if (_currentLocation != null) {
      distance = _calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        post.latitude!,
        post.longitude!,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post.postType == 'donation' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.postType == 'donation' ? 'Donation' : 'Request',
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
                  post.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // User info
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${post.timeAgo}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if (post.description != null) ...[
                  Text(
                    post.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Location info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: Color(0xFF1976D2)),
                          const SizedBox(width: 8),
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (post.address != null) ...[
                        Text(
                          post.address!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (distance != null)
                        Text(
                          '${_formatDistance(distance)} away from you',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats
                Row(
                  children: [
                    _buildStat(Icons.favorite, '${post.reactionCount}', 'Reactions'),
                    const SizedBox(width: 16),
                    _buildStat(Icons.comment, '${post.commentCount}', 'Comments'),
                    if (post.postType == 'request')
                      const SizedBox(width: 16),
                    if (post.postType == 'request')
                      _buildStat(Icons.volunteer_activism, '${post.donatorCount}', 'Donors'),
                  ],
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Move map to post location
                          _mapController.move(
                            LatLng(post.latitude!, post.longitude!),
                            16.0,
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Show on Map'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailsPage(post: post),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new, color: Colors.white),
                        label: const Text('View Details', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _handleSignIn() {
    // Navigate to login page and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }
}
