import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'donation_page.dart';
import 'support_page.dart';
import 'post_page.dart';
import 'nearby_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final bool isGuest;

  const HomePage({Key? key, this.isGuest = false}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SupportPage(isGuest: widget.isGuest),
      DonationPage(onCreatePost: () => _onItemTapped(2)),
      const PostPage(),
      NearbyPage(isGuest: widget.isGuest),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isGuest: widget.isGuest,
      ),
    );
  }
}
