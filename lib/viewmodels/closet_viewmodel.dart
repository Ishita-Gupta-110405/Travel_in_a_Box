import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';

class ClosetViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  // The local copy of our cloud data
  List<WardrobeItem> _items = [];
  bool _isLoading = false;

  List<WardrobeItem> get items => _items;
  bool get isLoading => _isLoading;

  ClosetViewModel() {
    // Start listening to the cloud database immediately
    _listenToCloset();
  }

  // --- DATABASE SYNC ---

  void _listenToCloset() {
    _isLoading = true;
    _firestore.getClosetStream().listen((updatedItems) {
      _items = updatedItems;
      _isLoading = false;
      notifyListeners(); // Updates the UI across the whole app
    });
  }

  // --- CRUD OPERATIONS ---

  Future<void> addItem(WardrobeItem item) async {
    try {
      await _firestore.saveItem(item);
      // No need to manually add to list; the stream listener catches it!
    } catch (e) {
      debugPrint("Error adding item to box: $e");
    }
  }

  Future<void> removeItem(String id) async {
    try {
      await _firestore.deleteItem(id);
    } catch (e) {
      debugPrint("Error removing item from box: $e");
    }
  }

  // --- LOGOUT CLEANUP ---

  void clearItems() {
    _items = [];
    notifyListeners();
  }

  // --- AI & FILTER LOGIC ---

  /// Returns items for a specific section (e.g., 'Electronics' or 'Dresses')
  List<WardrobeItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  /// The "Smart AI" logic: Finds items that match specific trip vibes
  /// e.g. if vibes are ['#Beach', '#Summer'], it finds matching clothes
  List<WardrobeItem> getSmartSuggestions(List<String> tripVibes) {
    if (tripVibes.isEmpty) return [];

    return _items.where((item) {
      // Returns true if any tag in the item matches the trip vibes
      return item.tags.any((tag) => tripVibes.contains(tag));
    }).toList();
  }

  /// Quick count for the Section Grid UI
  int getItemCount(String category) {
    return _items.where((item) => item.category == category).length;
  }
}