import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/password_change_request.dart';
import '../models/profile_update_request.dart';
import '../services/credentials_service.dart';
import '../services/profile_service.dart';
import '../utils/image_picker_helper.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _credentialsService = CredentialsService();
  final _profileService = ProfileService();
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Profile fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _numberController = TextEditingController();

  // Password change fields
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoadingUser = true;
  bool _isUpdatingProfile = false;
  bool _isUpdatingProfileImage = false;
  bool _isChangingPassword = false;
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  User? _user;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _numberController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _profileService.loadUserData();
      setState(() {
        _user = user;
        _isLoadingUser = false;

        // Populate form fields
        if (user != null) {
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _addressController.text = user.address ?? '';
          _ageController.text = user.age?.toString() ?? '';
          _numberController.text = user.number ?? '';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final file = await ImagePickerHelper.showImageSourceDialog(context);
    if (file != null) {
      setState(() {
        _newProfileImage = file;
      });
    }
  }

  Future<void> _updateProfileImage() async {
    if (_newProfileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile image')),
      );
      return;
    }

    setState(() {
      _isUpdatingProfileImage = true;
    });

    try {
      await _credentialsService.updateProfileImage(_newProfileImage!);

      setState(() {
        _isUpdatingProfileImage = false;
        _newProfileImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
      }

      // Reload user data
      await _loadUserData();
    } catch (e) {
      setState(() {
        _isUpdatingProfileImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile image: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      final request = ProfileUpdateRequest(
        firstName: _firstNameController.text.isNotEmpty
            ? _firstNameController.text
            : null,
        lastName: _lastNameController.text.isNotEmpty
            ? _lastNameController.text
            : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        age: _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text)
            : null,
        number: _numberController.text.isNotEmpty
            ? _numberController.text
            : null,
      );

      await _credentialsService.updateProfile(request);

      setState(() {
        _isUpdatingProfile = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }

      // Reload user data
      await _loadUserData();
    } catch (e) {
      setState(() {
        _isUpdatingProfile = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final request = PasswordChangeRequest(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      final response = await _credentialsService.changePassword(request);

      setState(() {
        _isChangingPassword = false;
      });

      // Clear password fields
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      setState(() {
        _isChangingPassword = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  _buildProfileImageSection(),
                  const SizedBox(height: 24),

                  // Profile Information Section
                  _buildProfileInfoSection(),
                  const SizedBox(height: 24),

                  // Password Change Section
                  _buildPasswordChangeSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImageSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Profile Image',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF1976D2),
                    backgroundImage: _newProfileImage != null
                        ? FileImage(_newProfileImage!)
                        : (_user?.profileImage != null &&
                                _user!.profileImage!.isNotEmpty
                            ? NetworkImage(_user!.profileImage!)
                            : null) as ImageProvider?,
                    child: _newProfileImage == null &&
                            (_user?.profileImage == null ||
                                _user!.profileImage!.isEmpty)
                        ? Text(
                            _user != null &&
                                    _user!.firstName.isNotEmpty &&
                                    _user!.lastName.isNotEmpty
                                ? '${_user!.firstName[0].toUpperCase()}${_user!.lastName[0].toUpperCase()}'
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF1976D2),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            size: 20, color: Colors.white),
                        onPressed: _pickProfileImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_newProfileImage != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isUpdatingProfileImage ? null : _updateProfileImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUpdatingProfileImage
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update Profile Image'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (Read-only)
              TextFormField(
                initialValue: _user?.email ?? '',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email (cannot be changed)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUpdatingProfile ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isUpdatingProfile
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordChangeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Old Password
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_showOldPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_showOldPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showOldPassword = !_showOldPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChangingPassword ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isChangingPassword
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Change Password',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
