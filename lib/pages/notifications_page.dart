import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            icon: Icons.favorite,
            iconColor: Colors.pink,
            title: 'New Match Found!',
            message: 'Your donation matches a request in your area',
            time: '5 min ago',
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.message,
            iconColor: Colors.blue,
            title: 'New Message',
            message: 'Maria sent you a message about winter jackets',
            time: '1 hour ago',
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: 'Transaction Completed',
            message: 'Your donation has been successfully delivered',
            time: '3 hours ago',
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.star,
            iconColor: Colors.amber,
            title: 'New Rating Received',
            message: 'John Doe rated your donation 5 stars',
            time: '1 day ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.verified,
            iconColor: Colors.purple,
            title: 'Verification Approved',
            message: 'Your organization has been verified',
            time: '2 days ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.volunteer_activism,
            iconColor: Colors.green,
            title: 'Volunteer Opportunity',
            message: 'New volunteer opportunity near you',
            time: '3 days ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.announcement,
            iconColor: Colors.orange,
            title: 'Urgent Request',
            message: 'Critical need for medical supplies in your area',
            time: '5 days ago',
            isRead: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Handle notification tap
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
