import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import 'chat_conversation_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];
  bool _isLoading = false;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadChats();
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
      print('Error loading user ID in ChatsPage: $e');
      setState(() {
        _currentUserId = 0;
      });
    }
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chats = await _chatService.getChats(limit: 50);
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading chats: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      return _buildChatItem(_chats[index]);
                    },
                  ),
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
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation from a post',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Chat chat) {
    final chatTitle = chat.getChatTitle(_currentUserId);
    final chatAvatar = chat.getChatAvatar(_currentUserId);
    final lastMessage = chat.lastMessage;
    final hasUnread = chat.unreadCount > 0;

    return Container(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationPage(
                chat: chat,
                currentUserId: _currentUserId,
              ),
            ),
          ).then((_) => _loadChats());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF1976D2),
                    backgroundImage: chatAvatar != null
                        ? CachedNetworkImageProvider(chatAvatar)
                        : null,
                    child: chatAvatar == null
                        ? Text(
                            chatTitle.isNotEmpty ? chatTitle[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Chat info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chatTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            lastMessage.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnread ? const Color(0xFF1976D2) : Colors.grey[600],
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getLastMessagePreview(lastMessage),
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread ? Colors.black87 : Colors.grey[600],
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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
      ),
    );
  }

  String _getLastMessagePreview(Message? message) {
    if (message == null) return 'No messages yet';

    final isMe = message.senderId == _currentUserId;
    final prefix = isMe ? 'You: ' : '';

    if (message.messageType == 'photo') {
      return '$prefix📷 Photo';
    } else if (message.messageType == 'video') {
      return '$prefix🎥 Video';
    } else {
      return '$prefix${message.content ?? 'Message'}';
    }
  }
}
