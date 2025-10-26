import 'package:flutter/material.dart';

class VolunteerOpportunitiesPage extends StatefulWidget {
  const VolunteerOpportunitiesPage({Key? key}) : super(key: key);

  @override
  State<VolunteerOpportunitiesPage> createState() => _VolunteerOpportunitiesPageState();
}

class _VolunteerOpportunitiesPageState extends State<VolunteerOpportunitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Volunteer Opportunities'),
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
              decoration: InputDecoration(
                hintText: 'Search opportunities...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Color(0xFF1976D2)),
                  onPressed: () {
                    // TODO: Show filter options
                  },
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('This Week'),
                  _buildFilterChip('Nearby'),
                  _buildFilterChip('One-time'),
                  _buildFilterChip('Ongoing'),
                ],
              ),
            ),
          ),

          // Opportunities List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOpportunityCard(
                  title: 'Community Food Drive',
                  organization: 'Hope Foundation',
                  location: 'Quezon City',
                  date: 'Dec 15, 2024',
                  volunteers: '12/20 volunteers',
                  description: 'Help distribute food packages to families in need',
                  isVerified: true,
                  isUrgent: false,
                  category: 'Food Distribution',
                ),
                _buildOpportunityCard(
                  title: 'Medical Mission Assistance',
                  organization: 'Health For All',
                  location: 'Manila',
                  date: 'Dec 20, 2024',
                  volunteers: '8/15 volunteers',
                  description: 'Assist doctors in providing free medical checkups',
                  isVerified: true,
                  isUrgent: true,
                  category: 'Healthcare',
                ),
                _buildOpportunityCard(
                  title: 'School Cleanup Day',
                  organization: 'Local Elementary School',
                  location: 'Makati',
                  date: 'Dec 18, 2024',
                  volunteers: '5/10 volunteers',
                  description: 'Help clean and paint school facilities',
                  isVerified: false,
                  isUrgent: false,
                  category: 'Education',
                ),
                _buildOpportunityCard(
                  title: 'Tree Planting Activity',
                  organization: 'Green Earth Movement',
                  location: 'Antipolo',
                  date: 'Dec 22, 2024',
                  volunteers: '20/30 volunteers',
                  description: 'Join us in planting 100 trees for the environment',
                  isVerified: true,
                  isUrgent: false,
                  category: 'Environment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF1976D2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOpportunityCard({
    required String title,
    required String organization,
    required String location,
    required String date,
    required String volunteers,
    required String description,
    required bool isVerified,
    required bool isUrgent,
    required String category,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to opportunity details
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badges
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 24,
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
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              organization,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF1976D2),
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

                  // Info Row
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(volunteers, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to application
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Now',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
