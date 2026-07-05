class DogRunMapData {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int activeDogCount;

  DogRunMapData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.activeDogCount,
  });

  factory DogRunMapData.fromJson(Map<String, dynamic> json) {
    return DogRunMapData(
      id: json['id'],
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      activeDogCount: json['activeDogCount'],
    );
  }
}