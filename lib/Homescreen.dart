import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'Homescreenpage.dart';
import 'profilescreen.dart';
import 'scheme.dart';
import 'cummunity.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int indexofbn = 0; // Track the selected index of the BottomNavigationBar

  List<Widget> get _pages => [
    Homescreenpage(
      onViewAllTap: () {
        setState(() {
          indexofbn = 1; // Navigate to the Scheme screen
        });
      },
    ),
    Scheme(), // Scheme screen
    const Placeholder(), // Placeholder for Market page
    CommunityPage(), // Placeholder for Community page
    const Profilescreen(), // Profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: indexofbn, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 2,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            indexofbn = index;
          });
        },
        currentIndex: indexofbn,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.document),
            label: "Schemes",
          ),
          BottomNavigationBarItem(icon: Icon(Iconsax.shop), label: "Market"),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.people),
            label: "Community",
          ),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: "Profile"),
        ],
      ),
    );
  }
}
