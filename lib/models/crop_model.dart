class Crop {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final List<String> growingSeasons;
  final String imageUrl;
  final Map<String, dynamic> characteristics;

  Crop({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.growingSeasons,
    required this.imageUrl,
    required this.characteristics,
  });

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      scientificName: map['scientificName'] ?? '',
      description: map['description'] ?? '',
      growingSeasons: List<String>.from(map['growingSeasons'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      characteristics: map['characteristics'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'growingSeasons': growingSeasons,
      'imageUrl': imageUrl,
      'characteristics': characteristics,
    };
  }
}
