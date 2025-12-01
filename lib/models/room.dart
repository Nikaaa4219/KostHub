// File: lib/models/room.dart

class Room {
  final String id;
  final String name;
  final String location;
  final double price; // per night
  final double rating; // e.g. 4.5
  final int reviews;
  final String assetImage;
  // Koordinat Latitude & Longitude
  final double latitude;
  final double longitude;

  Room({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.assetImage,
    required this.latitude,
    required this.longitude,
  });
}

// DATA DUMMY DENGAN KOORDINAT YANG ANDA PILIH
final List<Room> sampleRooms = [
  Room(
    id: 'r1',
    name: 'Grand KostHub Hotel',
    location: 'Jakarta, Indonesia',
    price: 120.0,
    rating: 4.8,
    reviews: 128,
    assetImage: 'assets/images/PNG-KostHub/Hotel4.png',
    // Koordinat Pilihan Anda:
    latitude: -6.223742,
    longitude: 106.833859,
  ),
  Room(
    id: 'r2',
    name: 'Comfort Suites',
    location: 'Bandung, Indonesia',
    price: 85.0,
    rating: 4.5,
    reviews: 89,
    assetImage: 'assets/images/PNG-KostHub/Hotel1.png',
    // Koordinat Pilihan Anda:
    latitude: -6.923422359105052,
    longitude: 107.62363656178339,
  ),
  Room(
    id: 'r3',
    name: 'Seaside Retreat',
    location: 'Bali, Indonesia',
    price: 200.0,
    rating: 4.9,
    reviews: 210,
    assetImage: 'assets/images/PNG-KostHub/Hotel2.png',
    // Koordinat Pilihan Anda:
    latitude: -8.813409282913042,
    longitude: 115.21102137660674,
  ),
  Room(
    id: 'r4',
    name: 'City Center Inn',
    location: 'Yogyakarta, Indonesia',
    price: 60.0,
    rating: 4.2,
    reviews: 45,
    assetImage: 'assets/images/PNG-KostHub/Hotel3.png',
    // Koordinat Pilihan Anda:
    latitude: -7.773812987646052,
    longitude: 110.36847798544744,
  ),
];
