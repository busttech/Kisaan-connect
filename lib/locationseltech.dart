import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'Homescreen.dart';
import 'package:lottie/lottie.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? selectedVillage;
  bool isSaving = false;

  final List<String> villages = [
    'Malhargarh',
    'Suthaliya',
    'Biaora',
    'Kurawar',
    'Khujner',
    'Pipliya Kulmi',
    'Jirapur',
    'Narsinghgarh',
  ];

  Future<void> saveUserLocationToFirebase(String village) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated");
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    try {
      await userRef.set({
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'state': 'Madhya Pradesh',
        'district': 'Rajgarh',
        'village': village,
      }, SetOptions(merge: true));
    } catch (e) {
      throw e;
    }
  }

  void _submitLocation() async {
    if (selectedVillage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select your village.")));
      return;
    }

    setState(() {
      isSaving = true;
    });

    await saveUserLocationToFirebase(selectedVillage!);

    setState(() {
      isSaving = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Homescreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Your Location',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Where is your farm located?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // State & District (Fixed)
            _buildLocationCard("State", "Madhya Pradesh"),
            _buildLocationCard("District", "Rajgarh"),

            const SizedBox(height: 16),

            // Village Dropdown
            Text(
              "Select Village/Town",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField2<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              hint: Text("Choose village", style: GoogleFonts.poppins()),
              items:
                  villages
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: GoogleFonts.poppins()),
                        ),
                      )
                      .toList(),
              value: selectedVillage,
              onChanged: (value) {
                setState(() => selectedVillage = value);
              },
              buttonStyleData: const ButtonStyleData(height: 35),
              menuItemStyleData: const MenuItemStyleData(height: 40),
            ),

            Lottie.asset(
              'assets/images/fsmerslottie.json',
              width: 200,
              height: 220,
              fit: BoxFit.fill,
            ),

            const Spacer(),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedVillage != null && !isSaving
                        ? () {
                          _submitLocation();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    isSaving
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          "Continue",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.green[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
