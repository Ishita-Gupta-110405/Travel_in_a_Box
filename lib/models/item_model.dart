class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final String subType; // 👈 Verified: We are using 'subType'
  final String color;
  final String imageUrl;
  final List<String> tags;// 👈 Verified: For AI pairing
  final bool isShareable;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subType,
    required this.color,
    required this.imageUrl,
    this.isShareable = false,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'subType': subType,
      'color': color,
      'imageUrl': imageUrl,
      'tags': tags,
      'isShareable': isShareable,
    };
  }

  factory WardrobeItem.fromMap(Map<String, dynamic> map, String documentId) {
    return WardrobeItem(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      subType: map['subType'] ?? '',
      color: map['color'] ?? '',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      tags: List<String>.from(map['tags'] ?? []),
      isShareable:   map['isShareable'] ?? false,
    );
  }
}