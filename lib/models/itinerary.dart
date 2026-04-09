class Itinerary {
  final String id;
  final String tripId;
  final int dayNumber;
  final String timeSlot;
  final String placeName;

  Itinerary({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.timeSlot,
    required this.placeName,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'dayNumber': dayNumber,
      'timeSlot': timeSlot,
      'placeName': placeName,
    };
  }

  // Create from Firestore Map
  factory Itinerary.fromMap(Map<String, dynamic> map) {
    return Itinerary(
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      dayNumber: map['dayNumber'] ?? 1,
      timeSlot: map['timeSlot'] ?? '',
      placeName: map['placeName'] ?? '',
    );
  }
}