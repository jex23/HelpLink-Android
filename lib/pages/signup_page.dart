import 'dart:io';
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/auth_service.dart';
import '../models/signup_request.dart';
import '../utils/image_picker_helper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _selectedAccountType = 'Donor';

  // Image files
  File? _profileImage;
  File? _verificationSelfie;
  File? _validId;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    'images/helpLink.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Center(
                  child: Text(
                    'Join HelpLink',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Create an account to start helping',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Account Type Selection
                const Text(
                  'I want to be a:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAccountTypeSelector(),
                const SizedBox(height: 24),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
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
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Address (Optional)',
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age (Optional)',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF1976D2)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF1976D2),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
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
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1976D2)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF1976D2),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Document Upload Section
                const Text(
                  'Upload Documents (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload your documents to verify your account faster',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Image
                _buildImageUploadCard(
                  title: 'Profile Picture',
                  description: 'Upload your profile photo',
                  icon: Icons.person,
                  image: _profileImage,
                  onTap: () async {
                    print('Opening image picker for profile picture...');
                    final file = await ImagePickerHelper.showImageSourceDialog(context);
                    if (file != null) {
                      print('Profile picture selected: ${file.path}');
                      setState(() {
                        _profileImage = file;
                      });
                    } else {
                      print('No profile picture selected');
                    }
                  },
                  onRemove: () {
                    print('Removing profile picture');
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Verification Selfie with ID
                _buildImageUploadCard(
                  title: 'Selfie with ID',
                  description: 'Take a selfie holding your valid ID',
                  icon: Icons.camera_alt,
                  image: _verificationSelfie,
                  onTap: () async {
                    print('Opening image picker for verification selfie...');
                    final file = await ImagePickerHelper.showImageSourceDialog(context);
                    if (file != null) {
                      print('Verification selfie selected: ${file.path}');
                      setState(() {
                        _verificationSelfie = file;
                      });
                    } else {
                      print('No verification selfie selected');
                    }
                  },
                  onRemove: () {
                    print('Removing verification selfie');
                    setState(() {
                      _verificationSelfie = null;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Valid ID
                _buildImageUploadCard(
                  title: 'Valid ID',
                  description: 'Upload a photo of your valid ID',
                  icon: Icons.credit_card,
                  image: _validId,
                  onTap: () async {
                    print('Opening image picker for valid ID...');
                    final file = await ImagePickerHelper.showImageSourceDialog(context);
                    if (file != null) {
                      print('Valid ID selected: ${file.path}');
                      setState(() {
                        _validId = file;
                      });
                    } else {
                      print('No valid ID selected');
                    }
                  },
                  onRemove: () {
                    print('Removing valid ID');
                    setState(() {
                      _validId = null;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                      activeColor: const Color(0xFF1976D2),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: const TextStyle(fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
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

  Widget _buildAccountTypeSelector() {
    return Column(
      children: [
        _buildAccountTypeCard(
          'Donor',
          'I want to donate items or money',
          Icons.favorite,
          Colors.pink,
        ),
        const SizedBox(height: 12),
        _buildAccountTypeCard(
          'Beneficiary',
          'I need help or assistance',
          Icons.pan_tool,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildAccountTypeCard(
          'Volunteer',
          'I want to volunteer my time',
          Icons.groups,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildAccountTypeCard(
          'Organization',
          'I represent an NGO or group',
          Icons.business,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required File? image,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: image == null ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: image == null
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: const Color(0xFF1976D2), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.upload, color: Color(0xFF1976D2)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: onRemove,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Change Image'),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard(String type, String description, IconData icon, Color color) {
    bool isSelected = _selectedAccountType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAccountType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2).withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF1976D2) : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1976D2),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('=== SIGNUP PAGE DEBUG ===');
        print('Profile Image: ${_profileImage?.path ?? "null"}');
        print('Verification Selfie: ${_verificationSelfie?.path ?? "null"}');
        print('Valid ID: ${_validId?.path ?? "null"}');

        // Parse age if provided
        int? age;
        if (_ageController.text.isNotEmpty) {
          age = int.tryParse(_ageController.text);
        }

        // Create signup request
        final signupRequest = SignupRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          age: age,
          number: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          accountType: _selectedAccountType,
          profileImage: _profileImage,
          verificationSelfie: _verificationSelfie,
          validId: _validId,
        );

        print('Calling register API...');
        // Call API
        final response = await _authService.register(signupRequest);
        print('Registration response received: ${response.message}');

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } catch (e) {
        if (!mounted) return;

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
}
