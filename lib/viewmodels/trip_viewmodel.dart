import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/itinerary.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';

class TripViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestore = FirestoreService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  List<Itinerary> _allItineraries = [];
  List<Itinerary> get currentItinerary => _allItineraries;

  TripViewModel() {
    _listenToData();
  }

  void _listenToData() {
    _firestore.getTripsStream().listen((newList) {
      _trips = newList;
      notifyListeners();
    });
    _firestore.getItinerariesStream().listen((newList) {
      _allItineraries = newList;
      notifyListeners();
    });
  }

  // --- NEW UPDATE: CLEAR DATA ON LOGOUT ---
  void clearData() {
    _trips = [];
    _allItineraries = [];
    _errorMessage = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> addTrip(Trip trip, List<Itinerary> activities) async {
    try {
      await _firestore.saveTripAndItinerary(trip, activities);
    } catch (e) {
      debugPrint("Error saving trip: $e");
    }
  }

  Future<bool> generateTrip({
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? pace,
    List<String>? preferences,
    Trip? tripObject,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    String targetDestination = tripObject?.destination ?? destination ?? 'Destination';
    String currentTripId = tripObject?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    int calculatedDays = tripObject?.days ?? 1;
    if (startDate != null && endDate != null) {
      calculatedDays = endDate.difference(startDate).inDays + 1;
    }

    try {
      final coords = await _apiService.getCoordinates(targetDestination);
      List<Itinerary> newActivities = [];

      if (coords != null) {
        final places = await _apiService.fetchPlaces(
            coords['lat']!,
            coords['lon']!,
            radius: 50000,
            categoryQuery: 'tourism.sights,beach,natural.water,accommodation.hotel'
        );

        int placeIndex = 0;
        List<String> timeSlots = ['Morning', 'Afternoon', 'Evening'];

        for (int day = 1; day <= calculatedDays; day++) {
          for (String slot in timeSlots) {
            if (placeIndex < places.length) {
              var placeData = places[placeIndex];
              String name = placeData['name'] ?? placeData['properties']?['name'] ?? "Scenic Spot";

              newActivities.add(
                  Itinerary(
                    id: "${currentTripId}_${day}_$slot",
                    tripId: currentTripId,
                    dayNumber: day,
                    timeSlot: slot,
                    placeName: name,
                  )
              );
              placeIndex++;
            }
          }
        }
      }

      if (newActivities.isEmpty) {
        for (int day = 1; day <= calculatedDays; day++) {
          newActivities.add(Itinerary(
            id: "${currentTripId}_${day}_fallback",
            tripId: currentTripId,
            dayNumber: day,
            timeSlot: "Full Day",
            placeName: "Relax and Explore $targetDestination",
          ));
        }
      }

      Trip newlyGeneratedTrip = Trip(
        id: currentTripId,
        destination: targetDestination,
        days: calculatedDays,
        pace: pace ?? 'Standard',
        preferences: preferences ?? [],
        startDate: startDate,
        endDate: endDate,
      );

      await _firestore.saveTripAndItinerary(newlyGeneratedTrip, newActivities);

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint("Error in generateTrip: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Itinerary> getItineraryForTrip(String tripId) {
    return _allItineraries.where((activity) => activity.tripId == tripId).toList();
  }
}