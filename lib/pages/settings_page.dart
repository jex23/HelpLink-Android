import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _locationServices = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          _buildSettingsTile(
            icon: Icons.verified,
            title: 'Verification Status',
            subtitle: 'View your verification status',
            onTap: () {
              // TODO: Navigate to verification
            },
          ),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.email,
            title: 'Email Notifications',
            subtitle: 'Receive email updates',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.sms,
            title: 'SMS Notifications',
            subtitle: 'Receive SMS alerts',
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),

          // Privacy & Security Section
          _buildSectionHeader('Privacy & Security'),
          _buildSwitchTile(
            icon: Icons.location_on,
            title: 'Location Services',
            subtitle: 'Allow location access for better matches',
            value: _locationServices,
            onChanged: (value) {
              setState(() {
                _locationServices = value;
              });
            },
          ),
          _buildSettingsTile(
            icon: Icons.block,
            title: 'Blocked Users',
            subtitle: 'Manage blocked accounts',
            onTap: () {
              // TODO: Navigate to blocked users
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // TODO: Show privacy policy
            },
          ),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // TODO: Show language picker
            },
          ),

          // Support Section
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Help Center',
            subtitle: 'Get help and support',
            onTap: () {
              // TODO: Navigate to help center
            },
          ),
          _buildSettingsTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            subtitle: 'Share your thoughts with us',
            onTap: () {
              // TODO: Show feedback form
            },
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),

          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              _showLogoutDialog();
            },
            iconColor: Colors.orange,
          ),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: () {
              _showDeleteAccountDialog();
            },
            iconColor: Colors.red,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF1976D2)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFF1976D2),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1976D2),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1976D2),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About HelpLink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('HelpLink connects donors, volunteers, and beneficiaries to make helping easier and more effective.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
