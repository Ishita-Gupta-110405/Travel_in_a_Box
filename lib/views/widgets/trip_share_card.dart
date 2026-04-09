import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class TripShareCard extends StatefulWidget {
  final String destination;
  final int days;
  final String pace;
  final List<String> topItineraryItems;

  const TripShareCard({
    Key? key,
    required this.destination,
    required this.days,
    required this.pace,
    required this.topItineraryItems,
  }) : super(key: key);

  @override
  State<TripShareCard> createState() => _TripShareCardState();
}

class _TripShareCardState extends State<TripShareCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareTrip() async {
    setState(() => _isSharing = true);

    try {
      // Capture the widget as image bytes (Works on Web & Mobile)
      final Uint8List? imageBytes = await _screenshotController.capture();

      if (imageBytes != null) {
        // We create an XFile directly from memory bytes for Web compatibility
        final file = XFile.fromData(
          imageBytes,
          mimeType: 'image/png',
          name: 'trip_summary.png',
        );

        await Share.shareXFiles(
          [file],
          text: 'Check out my upcoming trip to ${widget.destination} planned with Travel in a Box! ✈️📦',
        );
      }
    } catch (e) {
      debugPrint('Error sharing trip: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share. Try saving as image instead!')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // This is the part that gets "Photographed"
        Screenshot(
          controller: _screenshotController,
          child: Container(
            width: 350, // Fixed width looks better in shared images
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF000510), // Matches your logo background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.destination.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Icon(Icons.auto_awesome, color: Color(0xFF4FC3F7), size: 30),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.days} DAYS • ${widget.pace.toUpperCase()} PACE',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4FC3F7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white24, thickness: 1),
                ),
                const Text(
                  'ITINERARY HIGHLIGHTS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                // Display the top 3-4 items
                ...widget.topItineraryItems.take(4).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFF4FC3F7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'AI PLANNED BY TRAVEL IN A BOX',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // The actual Share Button
        SizedBox(
          width: 350,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _isSharing ? null : _shareTrip,
            icon: _isSharing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.ios_share_rounded, color: Color(0xFF000510)),
            label: Text(
                _isSharing ? 'GENERATING IMAGE...' : 'SHARE WITH FRIENDS',
                style: const TextStyle(fontSize: 14, color: Color(0xFF000510), fontWeight: FontWeight.bold)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
              shadowColor: const Color(0xFF4FC3F7).withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}