import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../utils/image_picker_helper.dart';

class PostSupportPage extends StatefulWidget {
  final Post post;

  const PostSupportPage({Key? key, required this.post}) : super(key: key);

  @override
  State<PostSupportPage> createState() => _PostSupportPageState();
}

class _PostSupportPageState extends State<PostSupportPage> {
  final PostService _postService = PostService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  String _selectedSupportType = 'share';
  bool _isSubmitting = false;
  List<File> _proofImages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitSupport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _postService.addSupport(
        postId: widget.post.id,
        supportType: _selectedSupportType,
        message: _messageController.text.isNotEmpty ? _messageController.text : null,
        proofImages: _proofImages.isNotEmpty ? _proofImages : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your support!'),
              backgroundColor: Colors.purple,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Support failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('Show Support', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Preview
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF1976D2),
                        backgroundImage: widget.post.profileImage != null
                            ? CachedNetworkImageProvider(widget.post.profileImage!)
                            : null,
                        child: widget.post.profileImage == null
                            ? Text(
                                widget.post.fullName.isNotEmpty
                                    ? widget.post.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.post.timeAgo,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.post.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.post.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  if (widget.post.address != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.post.address!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Current Support Stats
            if (widget.post.supporterCount > 0)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, color: Colors.purple[700], size: 28),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              Text(
                                '${widget.post.supporterCount}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700],
                                ),
                              ),
                              Text(
                                'Supporters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Support Form
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Support',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Support Type Selection
                    const Text(
                      'Support Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share, size: 16),
                              SizedBox(width: 4),
                              Text('Share'),
                            ],
                          ),
                          selected: _selectedSupportType == 'share',
                          onSelected: (selected) {
                            setState(() {
                              _selectedSupportType = 'share';
                            });
                          },
                          selectedColor: Colors.purple.withOpacity(0.3),
                        ),
                        ChoiceChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volunteer_activism, size: 16),
                              SizedBox(width: 4),
                              Text('Volunteer'),
                            ],
                          ),
                          selected: _selectedSupportType == 'volunteer',
                          onSelected: (selected) {
                            setState(() {
                              _selectedSupportType = 'volunteer';
                            });
                          },
                          selectedColor: Colors.purple.withOpacity(0.3),
                        ),
                        ChoiceChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, size: 16),
                              SizedBox(width: 4),
                              Text('Prayer'),
                            ],
                          ),
                          selected: _selectedSupportType == 'prayer',
                          onSelected: (selected) {
                            setState(() {
                              _selectedSupportType = 'prayer';
                            });
                          },
                          selectedColor: Colors.purple.withOpacity(0.3),
                        ),
                        ChoiceChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.support, size: 16),
                              SizedBox(width: 4),
                              Text('Other'),
                            ],
                          ),
                          selected: _selectedSupportType == 'other',
                          onSelected: (selected) {
                            setState(() {
                              _selectedSupportType = 'other';
                            });
                          },
                          selectedColor: Colors.purple.withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Proof Images Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Proof of Support (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () async {
                                final images = await ImagePickerHelper.pickMultipleImages();
                                if (images != null && images.isNotEmpty) {
                                  setState(() {
                                    _proofImages.addAll(images);
                                    if (_proofImages.length > 5) {
                                      _proofImages = _proofImages.take(5).toList();
                                    }
                                  });
                                }
                              },
                              icon: const Icon(Icons.add_photo_alternate, size: 20),
                              label: const Text('Add Images'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        if (_proofImages.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _proofImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                        image: DecorationImage(
                                          image: FileImage(_proofImages[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _proofImages.removeAt(index);
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
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Upload screenshots or photos of your support (max 5 images)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Message Field
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Message (Optional)',
                        hintText: 'Add a message of support...',
                        prefixIcon: const Icon(Icons.message, color: Color(0xFF1976D2)),
                        alignLabelWithHint: true,
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

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitSupport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Support',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
