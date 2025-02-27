import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all properties from Firestore
  Future<List<Map<String, dynamic>>> getProperties() async {
    try {
      final snapshot = await _firestore.collection('properties').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch properties: $e');
    }
  }

  /// Add a new property to Firestore
  Future<void> addProperty(Map<String, dynamic> property, String landlordId, String imageUrl) async {
    try {
      await _firestore.collection('properties').add({
      'imageUrl': imageUrl, // Store the image URL or path in Firestore
      ...property,
      'landlordId': landlordId,
      'isAvailable': true,
      });
    } catch (e) {
      throw Exception('Failed to add property: $e');
    }
  }

  /// Fetch properties belonging to a specific landlord
  Future<List<Map<String, dynamic>>> getPropertiesByLandlord(String landlordId) async {
    try {
      final snapshot = await _firestore
          .collection('properties')
          .where('landlordId', isEqualTo: landlordId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch landlord properties: $e');
    }
  }

  /// Update an existing property in Firestore
  Future<void> updateProperty(String id, Map<String, dynamic> updatedProperty) async {
    try {
      await _firestore.collection('properties').doc(id).update(updatedProperty);
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  /// Delete a property from Firestore
  Future<void> deleteProperty(String id) async {
    try {
      await _firestore.collection('properties').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  /// Mark a property as booked
  Future<void> bookProperty(String id) async {
    try {
      await _firestore.collection('properties').doc(id).update({
        'isAvailable': false, // Set the property as unavailable
      });
    } catch (e) {
      throw Exception('Failed to book property: $e');
    }
  }

  /// Mark a property as available again
  Future<void> unbookProperty(String id) async {
    try {
      await _firestore.collection('properties').doc(id).update({
        'isAvailable': true, // Set the property as available
      });
    } catch (e) {
      throw Exception('Failed to unbook property: $e');
    }
  }

  /// Search properties by title or location
  Future<List<Map<String, dynamic>>> searchProperties(String query) async {
    try {
      final snapshot = await _firestore
          .collection('properties')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '$query\uf8ff') // Case-insensitive search
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search properties: $e');
    }
  }
}