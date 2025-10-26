import 'package:flutter/material.dart';

class OrganizationVerificationPage extends StatefulWidget {
  const OrganizationVerificationPage({Key? key}) : super(key: key);

  @override
  State<OrganizationVerificationPage> createState() => _OrganizationVerificationPageState();
}

class _OrganizationVerificationPageState extends State<OrganizationVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _orgType = 'NGO';
  List<String> _uploadedDocuments = [];

  @override
  void dispose() {
    _orgNameController.dispose();
    _registrationNumberController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Organization Verification'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF1976D2), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Get Verified Badge',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Build trust by verifying your organization',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Organization Type
              const Text(
                'Organization Type',
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
                  value: _orgType,
                  isExpanded: true,
                  underline: Container(),
                  items: [
                    'NGO',
                    'Foundation',
                    'LGU',
                    'School',
                    'Civic Group',
                    'Religious Organization',
                    'Other',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _orgType = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Organization Name
              TextFormField(
                controller: _orgNameController,
                decoration: InputDecoration(
                  labelText: 'Organization Name *',
                  prefixIcon: const Icon(Icons.business, color: Color(0xFF1976D2)),
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
                    return 'Please enter organization name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Registration Number
              TextFormField(
                controller: _registrationNumberController,
                decoration: InputDecoration(
                  labelText: 'Registration Number *',
                  prefixIcon: const Icon(Icons.confirmation_number, color: Color(0xFF1976D2)),
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
                    return 'Please enter registration number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Official Address *',
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1976D2)),
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
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: 'Website (Optional)',
                  prefixIcon: const Icon(Icons.language, color: Color(0xFF1976D2)),
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

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Tell us about your organization...',
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
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Documents Upload Section
              const Text(
                'Upload Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Required: SEC Registration, DTI Permit, or any valid government-issued documents',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              // Upload Buttons
              _buildUploadButton('SEC Registration Certificate'),
              const SizedBox(height: 8),
              _buildUploadButton('DTI Permit'),
              const SizedBox(height: 8),
              _buildUploadButton('Additional Documents'),

              if (_uploadedDocuments.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...(_uploadedDocuments.map((doc) => _buildUploadedDocument(doc))),
              ],

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit for Verification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verification usually takes 2-3 business days. We\'ll notify you via email once approved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
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

  Widget _buildUploadButton(String label) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Implement file picker
        setState(() {
          _uploadedDocuments.add(label);
        });
      },
      icon: const Icon(Icons.upload_file),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1976D2),
        side: const BorderSide(color: Color(0xFF1976D2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildUploadedDocument(String docName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.description, color: Color(0xFF1976D2)),
        title: Text(docName),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              _uploadedDocuments.remove(docName);
            });
          },
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_uploadedDocuments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload at least one document'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // TODO: Implement verification submission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Submitted Successfully'),
          content: const Text('Your verification request has been submitted. We\'ll review it within 2-3 business days.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
