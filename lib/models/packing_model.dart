class PackingModel {
  final int? id;
  final int tripId;
  final String itemName;
  final String category; // 'Clothes', 'Toiletries', 'Electronics'
  bool isPacked;

  PackingModel({
    this.id,
    required this.tripId,
    required this.itemName,
    required this.category,
    this.isPacked = false,
  });

  // Convert a Map (from SQLite) into a PackingModel Object
  factory PackingModel.fromMap(Map<String, dynamic> map) {
    return PackingModel(
      id: map['id'],
      tripId: map['tripId'],
      itemName: map['itemName'],
      category: map['category'],
      // SQLite stores booleans as integers (1 for true, 0 for false)
      isPacked: map['isPacked'] == 1,
    );
  }

  // Convert a PackingModel Object into a Map (to save into SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'itemName': itemName,
      'category': category,
      'isPacked': isPacked ? 1 : 0,
    };
  }
}