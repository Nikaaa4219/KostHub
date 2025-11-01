class Room {
  final String id;
  final String name;
  final String location;
  final double price; // per night
  final double rating; // e.g. 4.5
  final int reviews;
  final String assetImage;

  Room({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.assetImage,
  });
}

// Sample data - replace assetImage strings with real asset paths
final List<Room> sampleRooms = [
  Room(
    id: 'r1',
    name: 'Grand KostHub Hotel',
    location: 'Jakarta, Indonesia',
    price: 120.0,
    rating: 4.8,
    reviews: 128,
    assetImage: 'assets/images/room1.jpg',
  ),
  Room(
    id: 'r2',
    name: 'Comfort Suites',
    location: 'Bandung, Indonesia',
    price: 85.0,
    rating: 4.5,
    reviews: 89,
    assetImage: 'assets/images/room2.jpg',
  ),
  Room(
    id: 'r3',
    name: 'Seaside Retreat',
    location: 'Bali, Indonesia',
    price: 200.0,
    rating: 4.9,
    reviews: 210,
    assetImage: 'assets/images/room3.jpg',
  ),
  Room(
    id: 'r4',
    name: 'City Center Inn',
    location: 'Yogyakarta, Indonesia',
    price: 60.0,
    rating: 4.2,
    reviews: 45,
    assetImage: 'assets/images/room4.jpg',
  ),
];
