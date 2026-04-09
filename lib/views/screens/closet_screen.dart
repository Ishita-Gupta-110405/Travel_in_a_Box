import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/closet_viewmodel.dart';
import '../widgets/add_wardrobe_item_dialog.dart';
import 'category_items_screen.dart'; // We'll create this next

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  bool _isOpened = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final closetVM = Provider.of<ClosetViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE LUXURY INTERIOR
          Positioned.fill(
            child: Image.asset(
              'assets/closet.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF000510)),
            ),
          ),

          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),

          // 2. THE INTERACTIVE SECTIONS
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("WALK-IN CLOSET", style: GoogleFonts.monoton(fontSize: 32, color: Colors.white, letterSpacing: 6)),
                  const SizedBox(height: 10),
                  Text("CURATED COLLECTIONS", style: GoogleFonts.oswald(color: const Color(0xFF4FC3F7), letterSpacing: 2)),
                  const SizedBox(height: 40),
                  Expanded(child: _buildSectionGrid(closetVM)),
                ],
              ),
            ),
          ),

          // 3. THE DOORS
          _buildDoor(isLeft: true, offset: _isOpened ? -screenWidth / 2 : 0, width: screenWidth / 2, height: screenHeight),
          _buildDoor(isLeft: false, offset: _isOpened ? -screenWidth / 2 : 0, width: screenWidth / 2, height: screenHeight),

          // 4. FLOATING ACTION BUTTON
          if (_isOpened)
            Positioned(
              bottom: 40, right: 40,
              child: FloatingActionButton.extended(
                onPressed: () => showDialog(context: context, builder: (context) => const AddWardrobeItemDialog()),
                backgroundColor: const Color(0xFF4FC3F7),
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text("UNBOX ITEM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDoor({required bool isLeft, required double offset, required double width, required double height}) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutExpo,
      left: isLeft ? offset : null,
      right: !isLeft ? offset : null,
      top: 0,
      child: GestureDetector(
        onTap: () => setState(() => _isOpened = true),
        child: Container(
          width: width, height: height,
          decoration: BoxDecoration(
            image: const DecorationImage(image: AssetImage('assets/door_texture.jpg'), fit: BoxFit.cover),
            border: Border(
              right: isLeft ? const BorderSide(color: Color(0xFFCFB53B), width: 2) : BorderSide.none,
              left: !isLeft ? const BorderSide(color: Color(0xFFCFB53B), width: 2) : BorderSide.none,
            ),
          ),
          child: Center(
            child: Container(
              width: 6, height: 150,
              decoration: BoxDecoration(color: const Color(0xFFCFB53B), borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionGrid(ClosetViewModel vm) {
    final sections = [
      {'name': 'Tops', 'icon': Icons.checkroom},
      {'name': 'Bottoms', 'icon': Icons.accessibility_new},
      {'name': 'Dresses', 'icon': Icons.style},
      {'name': 'Night Gowns', 'icon': Icons.nightlight_round},
      {'name': 'Jackets', 'icon': Icons.style},
      {'name': 'Electronics', 'icon': Icons.devices_other},
      {'name': 'Essentials', 'icon': Icons.medical_services_outlined},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 30, mainAxisSpacing: 30, childAspectRatio: 1.4,
      ),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final name = sections[index]['name'] as String;
        return HoverSectionCard(
          name: name,
          icon: sections[index]['icon'] as IconData,
          itemCount: vm.getItemCount(name), // 👈 Dynamic Count from ViewModel
        );
      },
    );
  }
}

class HoverSectionCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final int itemCount;
  const HoverSectionCard({super.key, required this.name, required this.icon, required this.itemCount});

  @override
  State<HoverSectionCard> createState() => _HoverSectionCardState();
}

class _HoverSectionCardState extends State<HoverSectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryItemsScreen(category: widget.name))),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _isHovered ? const Color(0xFF4FC3F7) : Colors.white12, width: _isHovered ? 2 : 1),
            boxShadow: _isHovered ? [BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.3), blurRadius: 20)] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 45, color: _isHovered ? const Color(0xFF4FC3F7) : Colors.white54),
              const SizedBox(height: 10),
              Text(widget.name.toUpperCase(), style: GoogleFonts.oswald(color: Colors.white, fontSize: 16, letterSpacing: 2)),
              Text("${widget.itemCount} ITEMS", style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}