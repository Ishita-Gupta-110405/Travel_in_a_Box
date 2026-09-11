import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Your actual API key is loaded and ready
  static const String _apiKey = "";
  static const String _baseUrl = "https://api.geoapify.com/v2/places";

  /// 1. DYNAMIC GEOCODING
  Future<Map<String, double>?> getCoordinates(String cityName) async {
    // NEW: .trim() removes any accidental spaces at the beginning or end!
    final String cleanCity = cityName.trim();
    final String encodedCity = Uri.encodeComponent(cleanCity);
    final String url = "https://api.geoapify.com/v1/geocode/search?text=$encodedCity&apiKey=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final properties = data['features'][0]['properties'];
          return {
            'lat': properties['lat'],
            'lon': properties['lon']
          };
        }
      }
      print("Geocoder failed to find city. Status: ${response.statusCode}");
      return null;
    } catch (e) {
      print("Geocoding Network Error: $e");
      return null;
    }
  }

  /// 2. FETCH PLACES
  // Notice we dropped the radius back to 10,000 to keep Geoapify happy!
  Future<List<Map<String, dynamic>>> fetchPlaces(double lat, double lon, {
    int radius = 50000, // 👈 INCREASED DEFAULT TO 50KM for islands/nature
    String categoryQuery = 'tourism.sights,beach,natural.water,accommodation.hotel' // 👈 VERIFIED CATEGORIES
  }) async {
    // Geoapify expects circle:lon,lat,radius
    final String url = "$_baseUrl?categories=$categoryQuery&filter=circle:$lon,$lat,$radius&bias=proximity:$lon,$lat&limit=30&apiKey=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Geoapify returns results in the 'features' list
        final List<dynamic> features = data['features'] ?? [];
        List<Map<String, dynamic>> places = [];

        Set<String> seenNames = {};

        for (var feature in features) {
          final properties = feature['properties'];

          // Ensure we have a valid properties object and a name
          if (properties != null && properties.containsKey('name') && properties['name'] != null && properties['name'].toString().isNotEmpty) {
            final String placeName = properties['name'];

            if (!seenNames.contains(placeName)) {
              seenNames.add(placeName);
              places.add({
                'name': placeName,
                'categories': properties['categories'] ?? [],
                'lat': properties['lat'],
                'lon': properties['lon'],
              });
            }
          }
        }
        return places;
      } else {
        debugPrint("API Error: ${response.statusCode}");
        debugPrint("Geoapify Error Message: ${response.body}");
        return []; // Return empty list instead of throwing so it triggers your dynamic fallback
      }
    } catch (e) {
      debugPrint("Network Error in fetchPlaces: $e");
      // 🚩 CHECK THIS: If _getMockData() contains Paris, that is your problem.
      // I recommend returning an empty list [] so your ViewModel handles the fallback.
      return [];
    }
  }

  /// 3. THE FALLBACK
  List<Map<String, dynamic>> _getMockData() {
    return [
      {"name": "Eiffel Tower", "categories": ["tourism.sights"], "lat": 48.858, "lon": 2.294},
      {"name": "Louvre Museum", "categories": ["tourism.museum"], "lat": 48.860, "lon": 2.337},
      {"name": "Seine River Cruise", "categories": ["tourism.tour"], "lat": 48.855, "lon": 2.320},
      {"name": "Notre-Dame Cathedral", "categories": ["tourism.sights"], "lat": 48.852, "lon": 2.349},
    ];
  }
}
