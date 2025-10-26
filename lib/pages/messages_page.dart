import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import 'chat_conversation_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  List<Chat> _chats = [];
  List<Chat> _filteredChats = [];
  bool _isLoading = false;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final userId = userData['id'];

        print('=== Messages Page User ID Debug ===');
        print('User data found: $userDataString');
        print('Extracted user ID: $userId');

        setState(() {
          _currentUserId = userId ?? 0;
        });
      } else {
        print('=== Messages Page User ID Debug ===');
        print('No user_data found in SharedPreferences');
        setState(() {
          _currentUserId = 0;
        });
      }
    } catch (e) {
      print('Error loading user ID: $e');
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
      print('=== Loading Chats Debug ===');
      print('Calling ChatService.getChats()...');
      final chats = await _chatService.getChats(limit: 50);
      print('Received ${chats.length} chats from API');
      if (chats.isNotEmpty) {
        print('First chat: ${chats[0].id}');
      }

      if (mounted) {
        setState(() {
          _chats = chats;
          _filteredChats = chats;
          _isLoading = false;
        });
        print('State updated: _chats.length = ${_chats.length}');
        print('State updated: _filteredChats.length = ${_filteredChats.length}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading chats: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _handleRefresh() async {
    await _loadChats();
  }

  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredChats = _chats;
      });
    } else {
      setState(() {
        _filteredChats = _chats.where((chat) {
          final chatTitle = chat.getChatTitle(_currentUserId).toLowerCase();
          return chatTitle.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterChats,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredChats.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredChats.length,
                          itemBuilder: (context, index) {
                            return _buildChatItem(_filteredChats[index]);
                          },
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasUnread ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with unread indicator
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (hasUnread)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Message content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLastMessagePreview(lastMessage),
                      style: TextStyle(
                        fontSize: 14,
                        color: hasUnread ? Colors.black87 : Colors.grey[600],
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Time and badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (lastMessage != null)
                    Text(
                      lastMessage.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasUnread ? const Color(0xFF1976D2) : Colors.grey[500],
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  if (hasUnread) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2),
                        shape: BoxShape.circle,
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
                ],
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
      final content = message.content ?? 'Message';
      const maxLength = 50; // Maximum characters before truncation

      if (content.length > maxLength) {
        return '$prefix${content.substring(0, maxLength)}...';
      }
      return '$prefix$content';
    }
  }
}
