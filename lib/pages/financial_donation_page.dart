import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FinancialDonationPage extends StatefulWidget {
  const FinancialDonationPage({Key? key}) : super(key: key);

  @override
  State<FinancialDonationPage> createState() => _FinancialDonationPageState();
}

class _FinancialDonationPageState extends State<FinancialDonationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Financial Donation'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Important Notice
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.amber.shade50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Important Notice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'HelpLink does not handle money directly. All donations go directly to verified organizations\' official accounts. Please verify the organization before donating.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Verified Organizations Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verified Organizations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'These organizations have been verified by HelpLink',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildOrganizationCard(
                    name: 'Hope Foundation Philippines',
                    description: 'Providing relief and assistance to disaster-affected communities',
                    category: 'Disaster Relief',
                    rating: 4.9,
                    donations: '5,234',
                    bankName: 'BDO',
                    accountName: 'Hope Foundation Philippines',
                    accountNumber: '1234567890',
                    gcashNumber: '09171234567',
                  ),
                  _buildOrganizationCard(
                    name: 'Bayanihan Community Fund',
                    description: 'Supporting underprivileged families with food and education',
                    category: 'Community Support',
                    rating: 4.8,
                    donations: '3,891',
                    bankName: 'BPI',
                    accountName: 'Bayanihan Community Fund Inc.',
                    accountNumber: '9876543210',
                    gcashNumber: '09189876543',
                  ),
                  _buildOrganizationCard(
                    name: 'Medical Aid Network',
                    description: 'Providing free medical assistance to those in need',
                    category: 'Healthcare',
                    rating: 4.9,
                    donations: '4,567',
                    bankName: 'Metrobank',
                    accountName: 'Medical Aid Network Foundation',
                    accountNumber: '5555666677',
                    gcashNumber: '09175556666',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationCard({
    required String name,
    required String description,
    required String category,
    required double rating,
    required String donations,
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String gcashNumber,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xFF1976D2),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$rating',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Icon(Icons.favorite, color: Colors.pink, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$donations donors',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Divider
            const Divider(),
            const SizedBox(height: 12),

            // Bank Account Info
            const Text(
              'Bank Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildAccountInfo('Bank', bankName),
            _buildAccountInfo('Account Name', accountName),
            _buildCopyableInfo('Account Number', accountNumber),
            const SizedBox(height: 12),

            // GCash Info
            const Text(
              'GCash',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildCopyableInfo('GCash Number', gcashNumber),
            const SizedBox(height: 16),

            // Donate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showDonationDialog(context, name);
                },
                icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                label: const Text(
                  'Donate Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showDonationDialog(BuildContext context, String orgName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Important Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please transfer your donation directly to $orgName\'s official account.'),
            const SizedBox(height: 12),
            const Text(
              'After transferring, you can:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Upload proof of donation'),
            const Text('• Track your donation history'),
            const Text('• Get a digital receipt'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to donation proof upload
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('I Understand', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
