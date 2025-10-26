import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../models/profile_option.dart';
import '../services/profile_service.dart';
import '../components/app_header.dart';
import 'login_page.dart';
import 'profile_edit_page.dart';
import 'view_credentials_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _profileService.loadUserData();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await _profileService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  List<ProfileOption> _getProfileOptions() {
    return [
      ProfileOption(
        icon: Icons.edit,
        title: 'Edit Profile',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileEditPage()),
          );
        },
      ),
      ProfileOption(
        icon: Icons.verified_user,
        title: 'View Credentials',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ViewCredentialsPage()),
          );
        },
      ),
      ProfileOption(
        icon: Icons.logout,
        title: 'Logout',
        onTap: _handleLogout,
        isDestructive: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final profileOptions = _getProfileOptions();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(title: 'Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),

                  // User Info Card
                  _buildAccountInfoCard(),
                  const SizedBox(height: 16),

                  // Profile Options
                  ...profileOptions
                      .map((option) => _buildProfileOption(option))
                      .toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF1976D2),
          backgroundImage: _user?.profileImage != null && _user!.profileImage!.isNotEmpty
              ? CachedNetworkImageProvider(_user!.profileImage!)
              : null,
          child: _user?.profileImage != null && _user!.profileImage!.isNotEmpty
              ? null
              : Text(
                  _user != null && _user!.firstName.isNotEmpty && _user!.lastName.isNotEmpty
                      ? '${_user!.firstName[0].toUpperCase()}${_user!.lastName[0].toUpperCase()}'
                      : (_user != null && _user!.firstName.isNotEmpty
                          ? _user!.firstName[0].toUpperCase()
                          : 'U'),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Text(
          _user != null && _user!.fullName.trim().isNotEmpty
              ? _user!.fullName
              : 'User Profile',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _user?.email ?? 'user@example.com',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _profileService.getBadgeColor(_user?.badge),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _profileService.getBadgeText(_user?.badge),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_user?.accountType != null && _user!.accountType.isNotEmpty) ...[
          const SizedBox(height: 4),
          Chip(
            label: Text(
              _user!.accountType.toUpperCase(),
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_user?.number != null)
              _buildInfoRow(Icons.phone, 'Phone', _user!.number!),
            if (_user?.address != null)
              _buildInfoRow(Icons.location_on, 'Address', _user!.address!),
            if (_user?.age != null)
              _buildInfoRow(Icons.cake, 'Age', '${_user!.age}'),
            _buildInfoRow(
              Icons.calendar_today,
              'Member Since',
              _user != null
                  ? _profileService.formatJoinDate(_user!.createdAt)
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(ProfileOption option) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          option.icon,
          color: option.isDestructive ? Colors.red : const Color(0xFF1976D2),
        ),
        title: Text(
          option.title,
          style: TextStyle(
            color: option.isDestructive ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: option.onTap,
      ),
    );
  }
}
