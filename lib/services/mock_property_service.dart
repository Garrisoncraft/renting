class MockPropertyService {
  static final List<Map<String, dynamic>> _properties = [
    {
      'id': '1',
      'title': 'Cozy Apartment in City Center',
      'description': 'A modern 2-bedroom apartment with great views',
      'price': 250,
      'location': 'Nyarutarama',
      'rooms': 2,
      'contact': '+250791955398',
      'imageUrl': 'assets/images/property1.jpg',
      'isAvailable': true,
      'landlordId': 'landlord1',
    },
    {
      'id': '2',
      'title': 'Spacious Family House',
      'description': '4-bedroom house with large garden',
      'price': 400,
      'location': 'Kabeza',
      'rooms': 4,
      'contact': '+250791955398',
      'imageUrl': 'assets/images/property2.jpg',
      'isAvailable': true,
      'landlordId': 'landlord2',
    },
    {
      'id': '3',
      'title': 'Modern Studio Apartment',
      'description': 'Compact studio with modern amenities',
      'price': 150,
      'location': 'City Center',
      'rooms': 1,
      'contact': '+250791955398',
      'imageUrl': 'assets/images/property3.jpg',
      'isAvailable': true,
      'landlordId': 'landlord1',
    },
    {
      'id': '4',
      'title': 'Luxury House',
      'description': 'Top floor penthouse with panoramic views',
      'price': 1200,
      'location': 'Nyarutarama',
      'rooms': 2,
      'contact': '+250791955398',
      'imageUrl': 'assets/images/property4.jpg',
      'isAvailable': true,
      'landlordId': 'landlord3',
    },
    {
      'id': '5',
      'title': 'Country House',
      'description': 'Charming 3-bedroom house in the countryside',
      'price': 300,
      'location': 'Kabeza',
      'rooms': 3,
      'contact': '+250791955398',
      'imageUrl': 'assets/images/property5.jpg',
      'isAvailable': true,
      'landlordId': 'landlord2',
    },


  ];

  Future<List<Map<String, dynamic>>> getProperties() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _properties;
  }

  Future<void> addProperty(Map<String, dynamic> property, String landlordId) async {
    await Future.delayed(const Duration(seconds: 1));
    _properties.add({
      ...property,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'landlordId': landlordId
    });
  }

  Future<List<Map<String, dynamic>>> getPropertiesByLandlord(String landlordId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _properties.where((p) => p['landlordId'] == landlordId).toList();
  }


  Future<void> updateProperty(String id, Map<String, dynamic> updatedProperty) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _properties.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _properties[index] = {..._properties[index], ...updatedProperty};
    }
  }

  Future<void> deleteProperty(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _properties.removeWhere((p) => p['id'] == id);
  }

  Future<void> bookProperty(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _properties.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _properties[index]['isAvailable'] = false;
    }
  }
}
