import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/trip_model.dart';
import '../../models/itinerary.dart';
import 'packing_list_screen.dart'; // 👈 Crucial to link your weather/packing AI

class ItineraryScreen extends StatelessWidget {
  final Trip trip;
  final List<Itinerary> activities;

  const ItineraryScreen({
    super.key,
    required this.trip,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0D1B2A), const Color(0xFF000510)],
                ),
              ),
            ),
          ),

          // 2. MAIN CONTENT
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: activities.isEmpty
                      ? _buildEmptyState()
                      : _buildTimeline(),
                ),
                // Padding for the bottom button so the list doesn't get hidden
                const SizedBox(height: 100),
              ],
            ),
          ),

          // 3. THE "MISSING" SMART PACKING BUTTON
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildSmartAIButton(context),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TRIP ITINERARY", style: GoogleFonts.oswald(color: const Color(0xFF4FC3F7), letterSpacing: 2)),
              Text(trip.destination.toUpperCase(), style: GoogleFonts.monoton(fontSize: 28, color: Colors.white, letterSpacing: 4)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 30),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Line & Dot
            Column(
              children: [
                Container(
                  width: 15, height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFB53B), // Luxury Gold
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: const Color(0xFFCFB53B).withOpacity(0.5), blurRadius: 10)],
                  ),
                ),
                if (index != activities.length - 1)
                  Container(width: 2, height: 80, color: Colors.white12),
              ],
            ),
            const SizedBox(width: 20),

            // Activity Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("DAY ${activity.dayNumber}", style: const TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(activity.timeSlot, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(activity.placeName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: Colors.white24, size: 80),
          const SizedBox(height: 20),
          const Text("No activities planned yet.", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildSmartAIButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ]
      ),
      child: ElevatedButton(
        onPressed: () {
          // 👇 THIS IS THE MAGIC LINK TO YOUR WEATHER & PACKING AI
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PackingListScreen(trip: trip),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.black),
            const SizedBox(width: 10),
            Text("GENERATE SMART PACKING LIST", style: GoogleFonts.oswald(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}