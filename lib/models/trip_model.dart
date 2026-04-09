class Trip {
  final String id;
  final String destination;
  final int days;
  final String pace;
  final List<String> preferences;
  final DateTime? startDate;
  final DateTime? endDate;

  Trip({
    required this.id,
    required this.destination,
    required this.days,
    required this.pace,
    required this.preferences,
    this.startDate,
    this.endDate,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'days': days,
      'pace': pace,
      'preferences': preferences,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      destination: map['destination'] ?? '',
      days: map['days'] ?? 1,
      pace: map['pace'] ?? 'Balanced',
      preferences: List<String>.from(map['preferences'] ?? []),
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}