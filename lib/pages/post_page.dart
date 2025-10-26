import 'package:flutter/material.dart';
import 'dart:io';
import '../services/post_service.dart';
import '../utils/image_picker_helper.dart';
import '../utils/location_helper.dart';
import '../widgets/location_picker_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final PostService _postService = PostService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedPostType = 'donation';
  String _selectedCategory = 'General';
  List<File> _selectedPhotos = [];
  List<File> _selectedVideos = [];
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Create Post'),
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Type Selection
            const Text(
              'Post Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPostTypeOption('donation', 'Donation', Icons.volunteer_activism),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPostTypeOption('request', 'Request', Icons.help_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Title Field
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter your post title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Dropdown
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                underline: Container(),
                items: [
                  'General',
                  'Community Support',
                  'Resources',
                  'Services',
                  'Question',
                  'Other',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Description Field
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'What would you like to share?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Address Field with Location Picker
            const Text(
              'Address (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter location or address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickLocationOnMap,
                    icon: const Icon(Icons.map),
                    label: const Text('Pick on Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_latitude != null && _longitude != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location set: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _latitude = null;
                          _longitude = null;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Photos Section
            const Text(
              'Add Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedPhotos.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPhotos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedPhotos.length) {
                      return _buildAddPhotoButton();
                    }
                    return _buildPhotoPreview(_selectedPhotos[index], index);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ] else
              _buildAddPhotoButton(),
            const SizedBox(height: 24),

            // Videos Section
            const Text(
              'Add Videos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedVideos.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedVideos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedVideos.length) {
                      return _buildAddVideoButton();
                    }
                    return _buildVideoPreview(_selectedVideos[index], index);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ] else
              _buildAddVideoButton(),
            const SizedBox(height: 32),

            // Post Guidelines
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                      SizedBox(width: 8),
                      Text(
                        'Posting Guidelines',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Be respectful and kind\n'
                    '• Keep content appropriate\n'
                    '• No spam or self-promotion\n'
                    '• Protect privacy and personal information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Posting...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Create Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    ),
    // Loading overlay
    if (_isLoading)
      Container(
        color: Colors.black54,
        child: const Center(
          child: Card(
            margin: EdgeInsets.all(24),
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1976D2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Creating your post...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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

  Widget _buildPostTypeOption(String type, String label, IconData icon) {
    bool isSelected = _selectedPostType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPostType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2).withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _pickPhotos,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1976D2), width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: Color(0xFF1976D2), size: 32),
            SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(File photo, int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(photo),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPhotos.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhotos() async {
    final photos = await ImagePickerHelper.pickMultipleImages();
    if (photos != null && photos.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(photos);
      });
    }
  }

  Widget _buildAddVideoButton() {
    return InkWell(
      onTap: _pickVideos,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1976D2), width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, color: Color(0xFF1976D2), size: 32),
            SizedBox(height: 4),
            Text(
              'Add Video',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(File video, int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.video_file, size: 40, color: Color(0xFF1976D2)),
                const SizedBox(height: 4),
                Text(
                  video.path.split('/').last.length > 10
                      ? '${video.path.split('/').last.substring(0, 10)}...'
                      : video.path.split('/').last,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedVideos.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVideos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedVideos.addAll(result.paths.map((path) => File(path!)).toList());
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking videos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await LocationHelper.handleLocationPermission();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied. Please enable it in settings.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final position = await LocationHelper.getCurrentPosition();
      if (position == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get current location.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Get address from coordinates
      final address = await LocationHelper.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address != null) {
        _addressController.text = address;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickLocationOnMap() async {
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialLatitude: _latitude,
        initialLongitude: _longitude,
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });

      // Get address from coordinates
      final address = await LocationHelper.getAddressFromCoordinates(
        result['latitude']!,
        result['longitude']!,
      );

      if (address != null) {
        _addressController.text = address;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location selected on map!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handlePost() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final post = await _postService.createPost(
        postType: _selectedPostType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        latitude: _latitude,
        longitude: _longitude,
        photos: _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
        videos: _selectedVideos.isNotEmpty ? _selectedVideos : null,
      );

      if (!mounted) return;

      if (post != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear fields
        _titleController.clear();
        _descriptionController.clear();
        _addressController.clear();
        setState(() {
          _selectedCategory = 'General';
          _selectedPostType = 'donation';
          _selectedPhotos = [];
          _selectedVideos = [];
          _latitude = null;
          _longitude = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create post. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
