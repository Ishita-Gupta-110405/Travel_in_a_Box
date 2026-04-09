import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../models/trip_model.dart';
import '../models/itinerary.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Collection References
  CollectionReference get _closetRef => _db.collection('users').doc(uid).collection('closet');
  CollectionReference get _tripsRef => _db.collection('users').doc(uid).collection('trips');
  CollectionReference get _itineraryRef => _db.collection('users').doc(uid).collection('itineraries');

  // --- CLOSET METHODS ---
  Stream<List<WardrobeItem>> getClosetStream() {
    return _closetRef.snapshots().map((snap) =>
        snap.docs.map((doc) => WardrobeItem.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> saveItem(WardrobeItem item) async => await _closetRef.add(item.toMap());
  Future<void> deleteItem(String id) async => await _closetRef.doc(id).delete();

  // --- TRIP & ITINERARY METHODS ---
  Stream<List<Trip>> getTripsStream() {
    return _tripsRef.snapshots().map((snap) =>
        snap.docs.map((doc) => Trip.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Itinerary>> getItinerariesStream() {
    return _itineraryRef.snapshots().map((snap) =>
        snap.docs.map((doc) => Itinerary.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Uses a Batch to ensure Trip and all Activities save at once
  Future<void> saveTripAndItinerary(Trip trip, List<Itinerary> activities) async {
    WriteBatch batch = _db.batch();

    batch.set(_tripsRef.doc(trip.id), trip.toMap());

    for (var activity in activities) {
      batch.set(_itineraryRef.doc(activity.id), activity.toMap());
    }

    await batch.commit();
  }

  Future<void> deleteTrip(String tripId) async {
    // Note: In a real app, you'd also delete the related itineraries here
    await _tripsRef.doc(tripId).delete();
  }
}