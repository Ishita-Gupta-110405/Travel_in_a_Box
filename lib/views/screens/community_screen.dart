import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/closet_viewmodel.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 Tabs: Marketplace, My Gear, Inbox
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let the main_layout background show
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          title: Text("GEAR EXCHANGE", style: GoogleFonts.monoton(fontSize: 22, color: Colors.white, letterSpacing: 3)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFFCFB53B),
            labelColor: Color(0xFFCFB53B),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.travel_explore), text: "MARKETPLACE"),
              Tab(icon: Icon(Icons.inventory_2), text: "MY GEAR"),
              Tab(icon: Icon(Icons.mail), text: "INBOX (1)"), // Fake notification badge for demo
            ],
          ),
        ),
        body: Container(
          color: const Color(0xFF000510).withOpacity(0.85),
          child: TabBarView(
            children: [
              _buildMarketplace(),
              _buildMyListings(context),
              _buildInbox(context),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // TAB 1: THE MARKETPLACE (Mock Data for Demo)
  // ====================================================================
  Widget _buildMarketplace() {
    // 👇 Fixed the broken Unsplash links!
    final communityItems = [
      {'name': 'GoPro Hero 10', 'owner': 'Rahul M.', 'distance': '1.2 km away', 'image': 'https://images.unsplash.com/photo-1522204523234-8729aa6e3d5f?q=80&w=2000'},
      {'name': 'Heavy Snow Parka', 'owner': 'Priya K.', 'distance': '3.0 km away', 'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?q=80&w=2000'},
      {'name': 'Camping Backpack', 'owner': 'Arjun S.', 'distance': '0.5 km away', 'image': 'https://images.unsplash.com/photo-1521556086772-23709b1f760e?q=80&w=2000'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: communityItems.length,
      itemBuilder: (context, index) {
        final item = communityItems[index];
        return _buildItemCard(
          context,
          imageUrl: item['image']!,
          title: item['name']!,
          subtitle: "${item['owner']} • ${item['distance']}",
          actionIcon: Icons.handshake,
          actionColor: const Color(0xFFCFB53B),
          onAction: () => _showBorrowDialog(context, item['name']!, item['owner']!),
        );
      },
    );
  }

  // ====================================================================
  // TAB 2: MY LISTINGS (Reads from your actual Database)
  // ====================================================================
  Widget _buildMyListings(BuildContext context) {
    return Consumer<ClosetViewModel>(
      builder: (context, closet, child) {
        // Filter the closet to only show items you toggled as "Shareable"
        final sharedItems = closet.items.where((item) => item.isShareable).toList();

        if (sharedItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.white24),
                const SizedBox(height: 20),
                const Text("You haven't listed any gear yet.", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Text("Toggle 'List on Community Hub' when adding items.", style: TextStyle(color: const Color(0xFF4FC3F7).withOpacity(0.8), fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sharedItems.length,
          itemBuilder: (context, index) {
            final item = sharedItems[index];
            return _buildItemCard(
              context,
              imageUrl: item.imageUrl, // Handles Base64 or Network Links automatically!
              title: item.name,
              subtitle: "Currently Available",
              actionIcon: Icons.visibility,
              actionColor: const Color(0xFF4FC3F7),
              onAction: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${item.name} is visible to nearby travelers.")),
                );
              },
            );
          },
        );
      },
    );
  }

  // ====================================================================
  // TAB 3: THE INBOX (Notification Demo)
  // ====================================================================
  Widget _buildInbox(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("PENDING REQUESTS", style: TextStyle(color: Color(0xFFCFB53B), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3F7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF0D1B2A),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Aman Verma requested your gear:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const Text("Sony DSLR Camera", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Dates: Oct 12 - Oct 15", style: TextStyle(color: const Color(0xFF4FC3F7).withOpacity(0.8), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Declined.")));
                      },
                      child: const Text("DECLINE", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCFB53B)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Approved! Messaging channel opened.", style: TextStyle(color: Colors.black))));
                      },
                      child: const Text("APPROVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // ====================================================================
  // REUSABLE UI COMPONENTS
  // ====================================================================
  Widget _buildItemCard(BuildContext context, {required String imageUrl, required String title, required String subtitle, required IconData actionIcon, required Color actionColor, required VoidCallback onAction}) {
    // Logic to handle Base64 strings from your actual database vs Network links from mock data
    Widget imageWidget;
    if (imageUrl.startsWith('data:image')) {
      imageWidget = Image.memory(
        Uri.parse(imageUrl).data!.contentAsBytes(),
        width: 120, height: 120, fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: 120, height: 120, fit: BoxFit.cover,
        // 👇 THE FIX FOR THE 404 ERROR! Falls back to a grey box if link breaks
        errorBuilder: (context, error, stackTrace) => Container(
          width: 120, height: 120, color: Colors.white10,
          child: const Icon(Icons.image_not_supported, color: Colors.white24),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            child: imageWidget,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: Icon(actionIcon, color: actionColor, size: 30),
              onPressed: onAction,
            ),
          )
        ],
      ),
    );
  }

  void _showBorrowDialog(BuildContext context, String itemName, String ownerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFCFB53B))),
        title: Text("Borrow $itemName?", style: const TextStyle(color: Colors.white)),
        content: Text("This will send a request to $ownerName. If they accept, you can arrange a meetup to exchange the gear.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCFB53B)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Request sent to $ownerName! 🚀"), backgroundColor: Colors.green),
              );
            },
            child: const Text("SEND REQUEST", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}