import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth
import '../../viewmodels/trip_viewmodel.dart';
import '../../viewmodels/closet_viewmodel.dart';

class ProfileDashboardScreen extends StatelessWidget {
  const ProfileDashboardScreen({super.key});

  Map<String, dynamic> _getPassportTheme(int tripCount) {
    if (tripCount >= 6) {
      return {
        "title": "ELITE AMBASSADOR",
        "color": const Color(0xFF1A1A1A),
        "accent": const Color(0xFFD4AF37),
        "label": "PLATINUM STATUS"
      };
    } else if (tripCount >= 3) {
      return {
        "title": "GLOBAL EXPLORER",
        "color": const Color(0xFF2F3E46),
        "accent": const Color(0xFFE5E5E5),
        "label": "SILVER STATUS"
      };
    } else {
      return {
        "title": "REPUBLIC OF ADVENTURE",
        "color": const Color(0xFF0D1B2A),
        "accent": const Color(0xFFCFB53B),
        "label": "STANDARD STATUS"
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripVM = Provider.of<TripViewModel>(context);
    final closetVM = Provider.of<ClosetViewModel>(context);

    // --- NEW UPDATE: DYNAMIC USER DATA ---
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? 'Traveler';
    final String userFirstName = user?.email?.split('@')[0].toUpperCase() ?? 'GUEST';

    final theme = _getPassportTheme(tripVM.trips.length);

    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("DIGITAL PASSPORT", style: GoogleFonts.monoton(letterSpacing: 2, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: theme["accent"].withOpacity(0.1),
                      blurRadius: 100,
                      spreadRadius: 50
                  )
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  FlipCard(
                    side: CardSide.FRONT,
                    direction: FlipDirection.HORIZONTAL,
                    front: _buildPassportFront(theme, userFirstName, userEmail),
                    back: _buildPassportBack(tripVM.trips.length, closetVM.items.length, theme),
                  ),

                  const SizedBox(height: 40),
                  _buildSectionTitle("RECENT STAMPS"),
                  const SizedBox(height: 20),
                  _buildRecentStamps(tripVM, theme["accent"]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportFront(Map<String, dynamic> theme, String name, String email) {
    return Container(
      width: 350, height: 580,
      decoration: BoxDecoration(
        color: theme["color"],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme["accent"], width: 2),
        boxShadow: [const BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Icon(Icons.public, color: theme["accent"], size: 50),
          const SizedBox(height: 15),
          Text(theme["title"], style: GoogleFonts.oswald(color: theme["accent"], fontSize: 16, letterSpacing: 2)),
          Divider(color: theme["accent"], thickness: 1, height: 30),

          Container(
            width: 110, height: 140,
            decoration: BoxDecoration(
              color: Colors.white10,
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, size: 70, color: Colors.white24),
          ),

          const SizedBox(height: 25),
          // --- DYNAMIC FIELDS ---
          _buildPassportField("SURNAME", name, theme["accent"]),
          _buildPassportField("GIVEN EMAIL", email, theme["accent"]),
          _buildPassportField("STATUS", theme["label"], theme["accent"]),

          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text("PASSPORT", style: GoogleFonts.monoton(color: theme["accent"].withOpacity(0.3), fontSize: 22)),
          )
        ],
      ),
    );
  }

  Widget _buildPassportBack(int tripCount, int itemCount, Map<String, dynamic> theme) {
    return Container(
      width: 350, height: 580,
      decoration: BoxDecoration(
        color: theme["color"],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme["accent"], width: 1),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("TRAVEL STATS", style: GoogleFonts.monoton(color: theme["accent"], fontSize: 20)),
          const SizedBox(height: 40),
          _buildStatRow("STAMPS COLLECTED", tripCount.toString(), Icons.confirmation_number_outlined, theme["accent"]),
          _buildStatRow("ITEMS UNBOXED", itemCount.toString(), Icons.inventory_2_outlined, theme["accent"]),
          _buildStatRow("MILES CALCULATED", "${tripCount * 1250} km", Icons.auto_awesome, theme["accent"]),
          const SizedBox(height: 40),
          const Text("Tap to view ID", style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPassportField(String label, String value, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: accent.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: GoogleFonts.courierPrime(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecentStamps(TripViewModel vm, Color accentColor) {
    if (vm.trips.isEmpty) return const Text("No stamps yet.", style: TextStyle(color: Colors.white24));
    return Wrap(
      spacing: 20, runSpacing: 20,
      children: vm.trips.map((trip) => Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
        ),
        child: Center(
          child: Transform.rotate(
            angle: -0.2,
            child: Text(
              trip.destination.length >= 3 ? trip.destination.substring(0, 3).toUpperCase() : trip.destination.toUpperCase(),
              style: GoogleFonts.courierPrime(color: accentColor.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.monoton(color: Colors.white, fontSize: 16, letterSpacing: 2)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Colors.white12)),
      ],
    );
  }
}