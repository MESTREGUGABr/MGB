class GameModel {
  final int id;
  final String name;
  final String? backgroundImage;
  final DateTime? released;
  final double? rating;
  final List<String> platforms;
  final String? description;

  GameModel({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.released,
    this.rating,
    required this.platforms,
    this.description,
  });

  factory GameModel.fromRawg(Map<String, dynamic> map) {
    return GameModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String? ?? 'Unknown',
      backgroundImage: map['background_image'] as String?,
      released: map['released'] != null && (map['released'] as String).isNotEmpty
          ? DateTime.tryParse(map['released'] as String)
          : null,
      rating: (map['rating'] as num?)?.toDouble(),
      platforms: ((map['platforms'] as List?) ?? const [])
          .map((e) => (e['platform']?['name'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .cast<String>()
          .toList(),
      description: map['description_raw'] as String? ?? map['description'] as String?,
    );
  }
}
