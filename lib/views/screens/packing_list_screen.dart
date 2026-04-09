import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/trip_model.dart';
import '../../viewmodels/packing_viewmodel.dart';
import '../../viewmodels/closet_viewmodel.dart';

class PackingListScreen extends StatefulWidget {
  final Trip trip;
  const PackingListScreen({super.key, required this.trip});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final closetItems = Provider.of<ClosetViewModel>(context, listen: false).items;
      Provider.of<PackingViewModel>(context, listen: false)
          .generateSmartPackingList(widget.trip, closetItems);
    });
  }

  // Determines the correct icon based on the live weather data
  IconData _getWeatherIcon(String condition) {
    if (condition == 'Rain' || condition == 'Drizzle') return Icons.water_drop;
    if (condition == 'Clear') return Icons.wb_sunny;
    if (condition == 'Snow') return Icons.ac_unit;
    return Icons.cloud; // Default
  }

  @override
  Widget build(BuildContext context) {
    final packingVM = Provider.of<PackingViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("SMART PACKING LIST", style: GoogleFonts.monoton(fontSize: 16)),
        centerTitle: true,
      ),
      body: packingVM.isAnalyzing
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF4FC3F7)),
            const SizedBox(height: 20),
            Text(packingVM.weatherMessage, style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
          ],
        ),
      )
          : Column(
        children: [
          // 1. THE LIVE WEATHER BANNER
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.05),
                border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
                ]
            ),
            child: Row(
              children: [
                Icon(_getWeatherIcon(packingVM.weatherCondition), color: const Color(0xFF4FC3F7), size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    packingVM.weatherMessage,
                    style: GoogleFonts.oswald(color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),

          // 2. THE CURATED ITEMS LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: packingVM.suggestedItems.length,
              itemBuilder: (context, index) {
                final item = packingVM.suggestedItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                          item.imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => const Icon(Icons.inventory, color: Colors.white24)
                      ),
                    ),
                    title: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(item.subType, style: const TextStyle(color: Color(0xFF4FC3F7))),
                    trailing: const Icon(Icons.check_circle, color: Color(0xFFCFB53B)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}