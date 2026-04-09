import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/trip_model.dart';

class PackingViewModel extends ChangeNotifier {
  List<WardrobeItem> _suggestedItems = [];

  List<WardrobeItem> get suggestedItems => _suggestedItems;

  bool _isAnalyzing = false;

  bool get isAnalyzing => _isAnalyzing;

  String _weatherCondition = '';

  String get weatherCondition => _weatherCondition;

  String _weatherMessage = '';

  String get weatherMessage => _weatherMessage;

  // 👇 NEW: We need to store the actual temperature to make smart decisions
  int _currentTemp = 20;

  // --- 1. THE LIVE WEATHER API CALL ---
  Future<void> _fetchLiveWeather(String city) async {
    try {
      // NOTE: Get a free key at openweathermap.org.
      // Replace 'YOUR_API_KEY' with your actual key.
      const apiKey = '430e30797462d23cc081eef322904c01';
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentTemp = data['main']['temp'].round(); // Save the temperature!
        _weatherCondition = data['weather'][0]['main'];

        _weatherMessage =
        "Live forecast: $_currentTemp°C and $_weatherCondition in $city. Packing list adjusted.";
      } else {
        _weatherCondition = 'Standard';
        _weatherMessage = "Standard packing profile applied for $city.";
      }
    } catch (e) {
      _weatherCondition = 'Standard';
      _weatherMessage = "Offline Mode: Standard packing profile applied.";
    }
  }

  // --- 2. THE UPGRADED SMART AI LOGIC ---
  Future<void> generateSmartPackingList(Trip trip,
      List<WardrobeItem> closetItems) async {
    _isAnalyzing = true;
    _suggestedItems = [];
    _weatherMessage = "Connecting to global weather satellites...";
    notifyListeners();

    await _fetchLiveWeather(trip.destination);

    List<String> activeTags = [...trip.preferences];

    // 👇 FIX 1: Tell the AI that Dresses are for warm weather
    if (_currentTemp <= 12) {
      activeTags.addAll(
          ['#winter', '#heavy', '#warm', '#jacket', '#sweater', '#fullsleeve']);
    } else if (_currentTemp >= 25) {
      // Added #dresses and #sundress here!
      activeTags.addAll([
        '#summer',
        '#sunglasses',
        '#lightweight',
        '#cotton',
        '#shorts',
        '#dresses',
        '#sundress'
      ]);
    } else {
      activeTags.addAll(['#mild', '#layers', '#casual', '#denim', '#dresses']);
    }

    // 👇 FIX 2: Layer precipitation on top of the temperature
    if (_weatherCondition == 'Rain' || _weatherCondition == 'Drizzle') {
      activeTags.addAll(['#rain', '#waterproof', '#umbrella']);
    } else if (_weatherCondition == 'Snow') {
      activeTags.addAll(['#snow', '#boots', '#winter']);
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    List<WardrobeItem> backupTops = [];
    List<WardrobeItem> backupBottoms = [];
    List<WardrobeItem> backupShoes = [];
    // 👇 FIX 2: Create backup lists for the missing categories
    List<WardrobeItem> backupDresses = [];
    List<WardrobeItem> backupNightGowns = [];

    for (var item in closetItems) {
      bool shouldInclude = false;

      // Tag Matching
      // 1. Tag Matching (Leave your existing tag matching loop here)
      if (shouldInclude) {
        _suggestedItems.add(item);
      } else {
        if (item.category == 'Tops') backupTops.add(item);
        if (item.category == 'Bottoms') backupBottoms.add(item);
        if (item.category == 'Shoes') backupShoes.add(item);
        // 👇 FIX 3: Catch rejected dresses and gowns
        if (item.category == 'Dresses') backupDresses.add(item);
        if (item.category == 'Night Gowns') backupNightGowns.add(item);
      }

      // 2. THE UPGRADED "SMART ESSENTIALS" RULE
      if (item.category == 'Electronics') {
        shouldInclude = true; // Always pack laptop/chargers
      }

      if (item.category == 'Essentials') {
        shouldInclude = true; // Default to packing (Passport, Toothbrush, etc.)

        // CONDITIONAL OVERRIDES:
        // If it's an umbrella, strip it away unless it's actually raining
        if (item.name.toLowerCase().contains('umbrella') &&
            !activeTags.contains('#rain')) {
          shouldInclude = false;
        }

        // If it's sunscreen, strip it away unless it's hot or sunny
        if (item.name.toLowerCase().contains('sunscreen') &&
            !activeTags.contains('#summer') && _weatherCondition != 'Clear') {
          shouldInclude = false;
        }
      }

      if (shouldInclude) {
        _suggestedItems.add(item);
      } else {
        if (item.category == 'Tops') backupTops.add(item);
        if (item.category == 'Bottoms') backupBottoms.add(item);
        if (item.category == 'Shoes') backupShoes.add(item);
      }
    }

    // --- THE UPGRADED "SMART QUOTA" BASELINE RULES ---

    // 1. Calculate what the AI has already packed from your tags
    int packedTops = _suggestedItems
        .where((i) => i.category == 'Tops')
        .length;
    int packedBottoms = _suggestedItems
        .where((i) => i.category == 'Bottoms')
        .length;
    int packedShoes = _suggestedItems
        .where((i) => i.category == 'Shoes')
        .length;
    int packedNightGowns = _suggestedItems
        .where((i) => i.category == 'Night Gowns')
        .length;
    int packedDresses = _suggestedItems
        .where((i) => i.category == 'Dresses')
        .length;

    // 2. Fill the Gaps (The Quotas)
    // Always ensure at least 3 tops and 2 bottoms
    if (packedTops < 3 && backupTops.isNotEmpty) {
      _suggestedItems.addAll(backupTops.take(3 - packedTops));
    }
    if (packedBottoms < 2 && backupBottoms.isNotEmpty) {
      _suggestedItems.addAll(backupBottoms.take(2 - packedBottoms));
    }
    if (packedShoes < 1 && backupShoes.isNotEmpty) {
      _suggestedItems.addAll(backupShoes.take(1 - packedShoes));
    }

    // 3. The "Sleepwear" Quota: Always pack up to 2 Night Gowns
    if (packedNightGowns < 2 && backupNightGowns.isNotEmpty) {
      _suggestedItems.addAll(backupNightGowns.take(2 - packedNightGowns));
    }

    // 4. The "Sundress" Quota: If it's warm (20°C+), ensure at least 3 dresses!
    if (_currentTemp >= 20 && packedDresses < 3 && backupDresses.isNotEmpty) {
      _suggestedItems.addAll(backupDresses.take(3 - packedDresses));
    }

    // (Optional) If it's cold, maybe ensure at least 1 dress if you wear winter dresses
    if (_currentTemp < 20 && packedDresses < 1 && backupDresses.isNotEmpty) {
      _suggestedItems.addAll(backupDresses.take(1 - packedDresses));
    }

    // Remove exact duplicates just in case
    _suggestedItems = _suggestedItems.toSet().toList();

    _isAnalyzing = false;
    notifyListeners();
  }
}