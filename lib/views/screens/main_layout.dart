import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/trip_model.dart';
import '../../models/itinerary.dart';
import '../../viewmodels/trip_viewmodel.dart';
import '../../services/auth_service.dart';
import 'itinerary_screen.dart';
import 'closet_screen.dart';
import 'community_screen.dart';
import 'profile_dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _cityController = TextEditingController();
  Offset _mousePos = const Offset(0, 0);

  String _bgUrl = 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2070';
  bool _isGenerating = false;

  late AnimationController _planeController;
  late Animation<Offset> _planeAnimation;
  late Animation<double> _planeRotation;

  final Map<String, String> _cityImages = {
    'paris': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073&auto=format&fit=crop',
    'london': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?q=80&w=2070&auto=format&fit=crop',
    'tokyo': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=2094&auto=format&fit=crop',
    'new york': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?q=80&w=2070&auto=format&fit=crop',
    'dubai': 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=2070&auto=format&fit=crop',
    'rome': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?q=80&w=1996&auto=format&fit=crop',
    'amsterdam': 'https://images.unsplash.com/photo-1517736996303-4e64a4f887ee?q=80&w=2070&auto=format&fit=crop',
    'sydney': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?q=80&w=2070&auto=format&fit=crop',
    'singapore': 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?q=80&w=2070&auto=format&fit=crop',
    'barcelona': 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?q=80&w=2070&auto=format&fit=crop',
    'kyoto': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=2070&auto=format&fit=crop',
    'bali': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=2070&auto=format&fit=crop',
    'santorini': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac542?q=80&w=2070&auto=format&fit=crop',
    'maldives': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=2070&auto=format&fit=crop',
    'cape town': 'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?q=80&w=2070&auto=format&fit=crop',
    'venice': 'https://images.unsplash.com/photo-1514890547357-a9ee288728e0?q=80&w=2070&auto=format&fit=crop',
    'istanbul': 'https://images.unsplash.com/photo-1522206090906-8d6bd6e19e7a?q=80&w=2070&auto=format&fit=crop',
    'rio de janeiro': 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?q=80&w=2070&auto=format&fit=crop',
    'seoul': 'https://images.unsplash.com/photo-1517154421773-0529f29ea451?q=80&w=2070&auto=format&fit=crop',
    'bangkok': 'https://images.unsplash.com/photo-1508009603885-50cf7cbf0eb5?q=80&w=2070&auto=format&fit=crop',
    'los angeles': 'https://images.unsplash.com/photo-1515896769740-3d5e0f5fd2f5?q=80&w=2070&auto=format&fit=crop',
    'miami': 'https://images.unsplash.com/photo-1506501139174-099022df5260?q=80&w=2071&auto=format&fit=crop',
    'mumbai': 'https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?q=80&w=2070&auto=format&fit=crop',
    'delhi': 'https://images.unsplash.com/photo-1587474260584-136574528ed5?q=80&w=2070&auto=format&fit=crop',
    'manipal': 'https://images.unsplash.com/photo-1600093463592-8e36ae95ef56?q=80&w=2000&auto=format&fit=crop',
    'berlin': 'https://images.unsplash.com/photo-1599946347371-68eb71b16afc?q=80&w=2070&auto=format&fit=crop',
  };

  @override
  void initState() {
    super.initState();

    _planeController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 7)
    );

    _planeAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 1.2),
      end: const Offset(1.2, -1.2),
    ).animate(CurvedAnimation(
        parent: _planeController,
        curve: Curves.linear
    ));

    _planeRotation = Tween<double>(
      begin: 0.0,
      end: -0.01,
    ).animate(CurvedAnimation(
        parent: _planeController,
        curve: Curves.easeOut
    ));
  }

  void _updateBackground(String city) {
    if (city.isEmpty) return;
    final String searchKey = city.toLowerCase().trim();
    setState(() {
      _bgUrl = _cityImages[searchKey] ?? 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=2074&auto=format&fit=crop';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildPremiumAppBar(),
      body: MouseRegion(
        onHover: (event) => setState(() => _mousePos = event.localPosition),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(seconds: 2),
              child: Image.network(_bgUrl, key: ValueKey(_bgUrl), fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF000510))),
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            _buildLaserGlow(),

            IgnorePointer(
              child: SlideTransition(
                position: _planeAnimation,
                child: RotationTransition(
                  turns: _planeRotation,
                  child: Center(
                    child: SizedBox(
                      width: 250,
                      child: Image.asset(
                        'assets/plane.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.airplanemode_active,
                          color: Color(0xFF4FC3F7),
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeLandingPage(),
                  _buildSavedTripsContent(),
                  const ClosetScreen(),
                  const CommunityScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    final user = FirebaseAuth.instance.currentUser;
    final String userDisplayName = user?.email?.split('@')[0] ?? 'Traveler';

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 90,
      leadingWidth: 80,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TRAVEL IN A BOX", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          Text("Welcome back, $userDisplayName!", style: const TextStyle(fontSize: 13, color: Color(0xFF4FC3F7), fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [_buildProfileMenu(), const SizedBox(width: 15)],
    );
  }

  Widget _buildHomeLandingPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          SizedBox(
            height: 100,
            child: DefaultTextStyle(
              style: GoogleFonts.monoton(fontSize: 45, color: const Color(0xFF4FC3F7), letterSpacing: 5),
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TypewriterAnimatedText('UNBOX THE WORLD'),
                  TypewriterAnimatedText('AI-CURATED TRAVEL'),
                  TypewriterAnimatedText('TRAVEL IN A BOX'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text("Premium travel planning. Your itinerary, your style—all in one place.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 60),
          _buildSearchAndPlanBox(),
          const SizedBox(height: 80),
          Text("POPULAR DESTINATIONS", style: GoogleFonts.monoton(fontSize: 18, color: Colors.white, letterSpacing: 2)),
          const SizedBox(height: 30),
          _buildCityCarousel(),
          const SizedBox(height: 80),
          Text("OUR SERVICES", style: GoogleFonts.monoton(fontSize: 18, color: Colors.white, letterSpacing: 2)),
          const SizedBox(height: 30),
          _buildFeatureGrid(),
          const SizedBox(height: 100),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSearchAndPlanBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.12))
          ),
          child: Column(
            children: [
              TextField(
                controller: _cityController,
                onSubmitted: _updateBackground,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Where to?",
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFF4FC3F7)),
                    filled: true, fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : () {
                    _updateBackground(_cityController.text);
                    if (_cityController.text.trim().isEmpty) return;
                    _showTripPlannerDialog(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FC3F7)),
                  child: Text(_isGenerating ? "PLANNING..." : "CUSTOMIZE TRIP",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        enlargeCenterPage: true,
        autoPlay: true,
        viewportFraction: 0.25,
        enableInfiniteScroll: true,
      ),
      items: _cityImages.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(image: NetworkImage(entry.value), fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
            ),
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(20),
            child: Text(entry.key.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHoverCard("MY ITINERARIES", Icons.map_outlined, "AI-generated travel paths.", () => setState(() => _selectedIndex = 1)),
        const SizedBox(width: 40),
        _buildHoverCard("VIRTUAL CLOSET", Icons.checkroom_outlined, "Pack smart, travel light.", () => setState(() => _selectedIndex = 2)),
      ],
    );
  }

  Widget _buildHoverCard(String title, IconData icon, String desc, VoidCallback onTap) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setCardState) {
        return MouseRegion(
          onEnter: (_) => setCardState(() => isHovered = true),
          onExit: (_) => setCardState(() => isHovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedScale(
              scale: isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 250, padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: isHovered ? const Color(0xFF4FC3F7).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isHovered ? const Color(0xFF4FC3F7) : Colors.white12),
                  boxShadow: isHovered ? [BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.3), blurRadius: 20)] : [],
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 45, color: const Color(0xFF4FC3F7)),
                    const SizedBox(height: 20),
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 60),
      color: Colors.black.withOpacity(0.4),
      child: Column(
        children: [
          Image.asset('assets/logo.png', height: 50),
          const SizedBox(height: 20),
          Text("Contact: ${user?.email ?? 'support@travelinabox.com'}", style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 10),
          const Text("© 2026 Travel In A Box. All Rights Reserved.", style: TextStyle(color: Colors.white24, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') {
          Provider.of<TripViewModel>(context, listen: false).clearData();
          await AuthService().signOut();
          if (mounted) Navigator.pushReplacementNamed(context, '/login');
        } else if (value == 'profile') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileDashboardScreen()));
        }
      },
      offset: const Offset(0, 50),
      color: const Color(0xFF0A1220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0x334FC3F7))),
      icon: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x804FC3F7), width: 1.5)),
        child: const CircleAvatar(radius: 18, backgroundColor: Color(0xFF000510), child: Icon(Icons.person, color: Colors.white, size: 20)),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.person_outline, color: Color(0xFF4FC3F7)), title: Text('Profile', style: TextStyle(color: Colors.white)))),
        const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.redAccent), title: Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))),
      ],
    );
  }

  void _showTripPlannerDialog(BuildContext context) {
    showGeneralDialog(
      context: context, barrierDismissible: true, barrierLabel: "Dismiss", transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Center(child: TripPlannerDialog(
        city: _cityController.text,
        onGenerate: (int days, String pace, List<String> vibes) async {
          setState(() => _isGenerating = true);
          await _planeController.forward(from: 0);
          final viewModel = Provider.of<TripViewModel>(context, listen: false);
          bool success = await viewModel.generateTrip(destination: _cityController.text, startDate: DateTime.now(), endDate: DateTime.now().add(Duration(days: days - 1)), pace: pace, preferences: vibes);
          if (success && mounted) {
            final lastTrip = viewModel.trips.last;
            await Future.delayed(const Duration(milliseconds: 500));
            final activities = viewModel.getItineraryForTrip(lastTrip.id);
            setState(() => _isGenerating = false);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ItineraryScreen(trip: lastTrip, activities: activities))).then((_) {
              _planeController.reset();
              setState(() => _selectedIndex = 1);
            });
          } else if (mounted) {
            setState(() => _isGenerating = false);
            _planeController.reset();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage)));
          }
        },
      )),
      transitionBuilder: (context, anim1, anim2, child) => Transform.scale(scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value, child: FadeTransition(opacity: anim1, child: child)),
    );
  }

  Widget _buildSavedTripsContent() {
    return Consumer<TripViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.trips.isEmpty) return const Center(child: Text("No trips saved.", style: TextStyle(color: Colors.white)));
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: viewModel.trips.length,
          itemBuilder: (context, index) {
            final trip = viewModel.trips[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x334FC3F7))),
              child: ListTile(
                leading: const Icon(Icons.flight_takeoff, color: Color(0xFF4FC3F7)),
                title: Text(trip.destination.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("${trip.days} Days • ${trip.pace} Pace", style: const TextStyle(color: Colors.white54)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ItineraryScreen(trip: trip, activities: viewModel.getItineraryForTrip(trip.id)))),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLaserGlow() {
    return Positioned(
      left: _mousePos.dx - 100, top: _mousePos.dy - 100,
      child: IgnorePointer(child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0x1A4FC3F7), Colors.transparent])))),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.all(30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.white.withOpacity(0.05),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF4FC3F7),
            unselectedItemColor: Colors.white30,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'My Trips'),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Closet'),
              BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Community'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _planeController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}

class TripPlannerDialog extends StatefulWidget {
  final String city;
  final Function(int, String, List<String>) onGenerate;
  const TripPlannerDialog({super.key, required this.city, required this.onGenerate});
  @override State<TripPlannerDialog> createState() => _TripPlannerDialogState();
}

class _TripPlannerDialogState extends State<TripPlannerDialog> {
  int _days = 3;
  String _pace = 'Standard';
  final Set<String> _selectedPrefs = {};
  final List<String> _allPrefs = ['Beaches', 'Sports', 'Nightlife', 'Museums', 'History', 'Relaxation', 'Mountains', 'Nature'];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 500, padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: const Color(0xB30A1220),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0x4D4FC3F7))
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      Text("CUSTOMIZE TRIP", style: GoogleFonts.monoton(color: Colors.white, fontSize: 22, letterSpacing: 2)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(child: _buildCounter("Number of Days", _days, (val) => setState(() => _days = val))),
                      const SizedBox(width: 15),
                      Expanded(child: _buildDropdown("Travel Pace", _pace, ['Relaxed', 'Standard', 'Fast'], (val) => setState(() => _pace = val))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                      spacing: 8,
                      children: _allPrefs.map((p) => FilterChip(
                        label: Text(p),
                        selected: _selectedPrefs.contains(p),
                        onSelected: (s) => setState(() => s ? _selectedPrefs.add(p) : _selectedPrefs.remove(p)),
                        selectedColor: const Color(0xFF4FC3F7),
                        labelStyle: TextStyle(color: _selectedPrefs.contains(p) ? Colors.black : Colors.white),
                      )).toList()
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => widget.onGenerate(_days, _pace, _selectedPrefs.toList()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: const Text("BUILD TRIP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.remove, color: Color(0xFF4FC3F7), size: 18), onPressed: () => value > 1 ? onChanged(value - 1) : null),
          Text("$value", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add, color: Color(0xFF4FC3F7), size: 18), onPressed: () => onChanged(value + 1)),
        ])
      ]),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: const Color(0xFF0A1220), icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4FC3F7)),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => onChanged(val!),
        ))
      ]),
    );
  }
}