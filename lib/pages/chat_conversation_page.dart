import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatConversationPage extends StatefulWidget {
  final Chat chat;
  final int currentUserId;

  const ChatConversationPage({
    Key? key,
    required this.chat,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsSeen();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('=== CHAT DEBUG ===');
      print('Current User ID: ${widget.currentUserId}');

      final messages = await _chatService.getMessages(widget.chat.id, limit: 100);

      if (messages.isNotEmpty) {
        print('First message sender ID: ${messages.first.senderId}');
        print('First message content: ${messages.first.content}');
      }

      if (mounted) {
        setState(() {
          _messages = messages.reversed.toList(); // Reverse to show oldest first
          _isLoading = false;
        });

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading messages: $e');
    }
  }

  Future<void> _markMessagesAsSeen() async {
    await _chatService.markMessagesAsSeen(widget.chat.id);
  }

  Future<void> _sendTextMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final message = await _chatService.sendTextMessage(widget.chat.id, content);

      if (message != null && mounted) {
        _messageController.clear();
        setState(() {
          _messages.add(message);
          _isSending = false;
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() {
          _isSending = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      print('Error sending message: $e');
    }
  }

  Future<void> _pickAndSendPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _isSending = true;
        });

        final message = await _chatService.sendPhotoMessage(
          widget.chat.id,
          [image.path],
        );

        if (message != null && mounted) {
          setState(() {
            _messages.add(message);
            _isSending = false;
          });

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          setState(() {
            _isSending = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to send photo')),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      print('Error picking/sending photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatTitle = widget.chat.getChatTitle(widget.currentUserId);
    final chatAvatar = widget.chat.getChatAvatar(widget.currentUserId);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: chatAvatar != null
                  ? CachedNetworkImageProvider(chatAvatar)
                  : null,
              child: chatAvatar == null
                  ? Text(
                      chatTitle.isNotEmpty ? chatTitle[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                chatTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == widget.currentUserId;
                          final showAvatar = !isMe && (index == 0 ||
                              _messages[index - 1].senderId != message.senderId);

                          print('Message ${index + 1}: senderId=${message.senderId}, currentUserId=${widget.currentUserId}, isMe=$isMe');

                          return _buildMessageBubble(message, isMe, showAvatar);
                        },
                      ),
          ),

          // Message input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  // Attach photo button
                  IconButton(
                    icon: const Icon(Icons.photo, color: Color(0xFF1976D2)),
                    onPressed: _isSending ? null : _pickAndSendPhoto,
                  ),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF1976D2)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1976D2),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: _sendTextMessage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe, bool showAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1976D2),
              backgroundImage: message.senderProfileImage != null
                  ? CachedNetworkImageProvider(message.senderProfileImage!)
                  : null,
              child: message.senderProfileImage == null
                  ? Text(
                      message.senderName.isNotEmpty
                          ? message.senderName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          if (!isMe && !showAvatar)
            const SizedBox(width: 40), // Spacer for alignment
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF1976D2) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show sender name for group chats
                      if (!isMe && widget.chat.type == 'group') ...[
                        Text(
                          message.senderName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      // Message content
                      if (message.messageType == 'text')
                        Text(
                          message.content ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        )
                      else if (message.messageType == 'photo' && message.media.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...message.media.map((media) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: media.mediaUrl,
                                      width: 200,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 200,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 200,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                )),
                            if (message.content != null && message.content!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  message.content!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isMe ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
