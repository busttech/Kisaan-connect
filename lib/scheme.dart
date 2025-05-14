import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Scheme extends StatefulWidget {
  const Scheme({Key? key}) : super(key: key);

  @override
  State<Scheme> createState() => _SchemeState();
}

class _SchemeState extends State<Scheme> {
  bool _isSearchVisible = false; // Toggle for search bar visibility
  final TextEditingController _searchController = TextEditingController();
  List<String> cetegories = [
    "All",
    "Farming",
    "Loans",
    "Women",
    "Youth",
    "Education",
  ];
  int selectedCategoryIndex = 0; // Track the selected category index
  List<Map<String, dynamic>>? cachedSchemeAlerts2;
  String _searchQuery = '';
  List<Map<String, dynamic>>? _filteredSchemeAlerts;

  void preolod() async {
    await fetchSchemeAlerts();
    setState(() {});
  }

  void initState() {
    super.initState();
    preolod();
  }

  Future<List<Map<String, dynamic>>> fetchSchemeAlerts() async {
    if (cachedSchemeAlerts2 != null) {
      return cachedSchemeAlerts2!;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('scheme_alerts').get();
    cachedSchemeAlerts2 = snapshot.docs.map((doc) => doc.data()).toList();
    return cachedSchemeAlerts2!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          _isSearchVisible ? 120 : 60,
        ), // Adjust height dynamically
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Government Schemes",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                if (_isSearchVisible) // Show search bar if visible
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search schemes...",
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                          if (_searchQuery.isEmpty) {
                            _filteredSchemeAlerts = null;
                          } else {
                            _filteredSchemeAlerts =
                                cachedSchemeAlerts2
                                    ?.where(
                                      (alert) =>
                                          (alert['tittle'] ?? '')
                                              .toString()
                                              .toLowerCase()
                                              .contains(_searchQuery) ||
                                          (alert['description'] ?? '')
                                              .toString()
                                              .toLowerCase()
                                              .contains(_searchQuery) ||
                                          (alert['ministry'] ?? '')
                                              .toString()
                                              .toLowerCase()
                                              .contains(_searchQuery),
                                    )
                                    .toList();
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible; // Toggle visibility
                });
              },
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Horizontal Chips for Categories
            SizedBox(
              height: 50, // Constrain the height of the horizontal ListView
              child: ListView.builder(
                itemCount: cetegories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        cetegories[index],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color:
                              selectedCategoryIndex == index
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      selected: selectedCategoryIndex == index,
                      selectedColor: Colors.green[700],
                      backgroundColor: Colors.grey[300],
                      onSelected: (isSelected) {
                        setState(() {
                          selectedCategoryIndex =
                              index; // Update selected index
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
                final schemeAlerts = _filteredSchemeAlerts ?? snapshot.data!;
                return Column(
                  children:
                      schemeAlerts.map((alerts) {
                        return Column(
                          children: [
                            _bulidschemecards(
                              alerts['tittle'] ?? "Tittle",
                              alerts["description"] ?? "discripion",
                              alerts["date"] ?? "12 Map 2025",
                              alerts["ministry"] ?? "Ministry of Agriculture",
                            ),
                          ],
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulidschemecards(
    String title,
    String description,
    String date,
    String ministry,
  ) {
    return Material(
      child: SizedBox(
        height: 214,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.white, width: 0), // Green border
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => {},
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    maxLines: 3, // Limit to 2 lines
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis if text overflows
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ministry and Apply Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance, // Ministry icon
                            size: 18,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ministry,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showApplyDialog(context, title);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Green button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.green, width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          "Apply",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.green,
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
      ),
    );
  }

  void _showApplyDialog(BuildContext context, String schemeTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width:
                MediaQuery.of(context).size.width *
                1.0, // Set width to 90% of the screen
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Apply for Scheme",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Content
                Text(
                  "You are about to apply for $schemeTitle.\nPlease confirm to proceed with your application.",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _showSuccessDialog(
                          context,
                          schemeTitle,
                        ); // Show success dialog
                        // Handle the confirmation logic here
                        print("Application confirmed for $schemeTitle");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String schemeTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width:
                MediaQuery.of(context).size.width *
                1.0, // Set width to 80% of the screen
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Application Submitted",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your application for $schemeTitle has been successfully submitted. You can track its status in the Applications tab.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the success dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
