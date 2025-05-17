import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreenpage extends StatefulWidget {
  final VoidCallback onViewAllTap;
  Homescreenpage({Key? key, required this.onViewAllTap}) : super(key: key);

  @override
  State<Homescreenpage> createState() => _HomescreenpageState();
}

class _HomescreenpageState extends State<Homescreenpage> {
  String? day;
  String? year;
  String? month;
  String? dayname;
  String? _cachedPhotoUrl;
  String? _name;
  bool _isLoadingPhoto = true;
  String formatDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, y');
    return formatter.format(now); // e.g., Monday, May 12, 2025
  }

  bool? islodingPhoto = false;
  List<Map<String, dynamic>>? cachedSchemeAlerts;
  List<Map<String, dynamic>>? cachedMarketAlerts;

  @override
  void initState() {
    super.initState();
    _loadCachedData(); // Load cached data first
    _fetchUserPhotoUrl();

    preloadData();
  }

  void preloadData() async {
    await fetchSchemeAlerts();
    await fetchMarketAlerts();
    setState(() {}); // Rebuild the widget after preloading data
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning, $_name!";
    } else if (hour < 17) {
      return "Good Afternoon, $_name!";
    } else {
      return "Good Evening, $_name!";
    }
  }

  Future<List<Map<String, dynamic>>> fetchSchemeAlerts() async {
    if (cachedSchemeAlerts != null) {
      return cachedSchemeAlerts!;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('scheme_alerts').get();
    cachedSchemeAlerts = snapshot.docs.map((doc) => doc.data()).toList();
    return cachedSchemeAlerts!;
  }

  Future<List<Map<String, dynamic>>> fetchMarketAlerts() async {
    if (cachedMarketAlerts != null) {
      return cachedMarketAlerts!;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('market_alerts').get();
    cachedMarketAlerts = snapshot.docs.map((doc) => doc.data()).toList();
    return cachedMarketAlerts!;
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'monetization_on':
        return Icons.monetization_on;
      case 'policy':
        return Icons.policy;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.info; // Default icon
    }
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cachedPhotoUrl = prefs.getString('photoUrl');
      _name = prefs.getString('name');
      _isLoadingPhoto = false; // Stop loading as cached data is loaded
    });
  }

  Future<void> _fetchUserPhotoUrl() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final photoUrl = data?['photoUrl'];
        final name = data?['name'].split(" ")[0];

        // Save data to local cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('photoUrl', photoUrl ?? '');
        await prefs.setString('name', name ?? '');

        setState(() {
          _cachedPhotoUrl = photoUrl;
          _name = name;
        });
      }
    } catch (e) {
      print("Error fetching user photo URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: SizedBox(
          child: Image.asset('assets/images/lo.png', cacheHeight: 50),
        ),
        actions: [
          // Notification Icon
          IconButton(
            icon: Icon(Iconsax.notification, color: Colors.black),
            onPressed: () {
              // Handle notification icon press
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Notifications clicked")));
            },
          ),
          // User Profile Image
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child:
                _isLoadingPhoto
                    ? CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : CircleAvatar(
                      backgroundImage:
                          _cachedPhotoUrl != null
                              ? NetworkImage(_cachedPhotoUrl!)
                              : null,
                      backgroundColor: Colors.grey[300],
                      child:
                          _cachedPhotoUrl == null
                              ? Icon(Icons.person, color: Colors.white)
                              : null,
                    ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Row(
              children: [
                const Icon(
                      Icons.wb_sunny_outlined,
                      color: Color.fromRGBO(251, 192, 45, 1),
                      size: 30,
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(
                      begin: 3,
                      end: -3,
                      duration: 1.seconds,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .moveY(
                      begin: -3,
                      end: 3,
                      duration: 1.seconds,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    greeting(),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().slideX(duration: 1400.ms),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatDate(),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Weather",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                                Icons.wb_sunny_outlined,
                                size: 30,
                                color: Colors.amber,
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .moveY(
                                begin: 3,
                                end: -3,
                                duration: 1.seconds,
                                curve: Curves.easeInOut,
                              )
                              .then()
                              .moveY(
                                begin: -3,
                                end: 3,
                                duration: 1.seconds,
                                curve: Curves.easeInOut,
                              ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "28°C",
                                style: GoogleFonts.poppins(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Sunny",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rajgarh,MP",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Humidity: 65%,\nWind: 12 km/h",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 20),

            // Scheme Alerts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scheme Alerts",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onViewAllTap,
                  child: Text(
                    "View All",
                    style: GoogleFonts.poppins(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchSchemeAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No scheme alerts available."));
                }

                final schemeAlerts = snapshot.data!;
                return Column(
                  children:
                      schemeAlerts.map((alert) {
                        return Column(
                          children: [
                            _buildSchemeCard(
                              alert['tittle'] ??
                                  "No Title", // Provide a default value if null
                              alert['subtitle'] ??
                                  "No Subtitle", // Provide a default value if null
                              alert['badge'] ??
                                  "No Badge", // Provide a default value if null
                              Color(
                                int.tryParse(
                                      alert['badgeColor']?.replaceFirst(
                                            '#',
                                            '0xff',
                                          ) ??
                                          '0xff4CAF50',
                                    ) ??
                                    0xff4CAF50, // Default to green if null or invalid
                              ),
                              _getIconFromName(
                                alert['icon'] ?? "info",
                              ), // Default to "info" icon if null
                              Color(
                                int.tryParse(
                                      alert['iconBgColor']?.replaceFirst(
                                            '#',
                                            '0xff',
                                          ) ??
                                          '0xffC8E6C9',
                                    ) ??
                                    0xffC8E6C9, // Default to light green if null or invalid
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
            // Market Alerts Section
            Text(
              "Market Alerts",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchMarketAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No market alerts available."));
                }

                final marketAlerts = snapshot.data!.take(3).toList();
                return SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        marketAlerts.map((alert) {
                          return _buildMarketCard(
                            alert['crop'] ?? "No Crop", // Default value if null
                            alert['price'] ??
                                "No Price", // Default value if null
                            alert['change'] ??
                                "No Change", // Default value if null
                            Color(
                              int.tryParse(
                                    alert['color']?.replaceFirst('#', '0xff') ??
                                        '0xff4CAF50',
                                  ) ??
                                  0xff4CAF50, // Default to green if null or invalid
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeCard(
    String title,
    String subtitle,
    String badge,
    Color badgeColor,
    IconData icon,
    Color iconBgColor,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onViewAllTap, // On tap action
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black54, size: 24),
              ),
              const SizedBox(width: 16),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 650.ms);
  }

  Widget _buildMarketCard(
    String crop,
    String price,
    String change,
    Color color,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            crop,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(change, style: GoogleFonts.poppins(fontSize: 12, color: color)),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
