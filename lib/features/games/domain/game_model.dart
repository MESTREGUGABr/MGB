import 'dart:convert';

class GameModel {
  final int id;
  final String name;
  final String? description; // vem no endpoint de detalhes
  final String? backgroundImage;
  final DateTime? released;
  final double? rating;
  final List<String> platforms;

  GameModel({
    required this.id,
    required this.name,
    this.description,
    this.backgroundImage,
    this.released,
    this.rating,
    this.platforms = const [],
  });

  factory GameModel.fromRawg(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      name: map['name'] ?? '',
      backgroundImage: map['background_image'],
      released: map['released'] != null && map['released'] != ''
          ? DateTime.tryParse(map['released'])
          : null,
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : null,
      platforms: (map['platforms'] as List? ?? [])
          .map((p) => p['platform']?['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'backgroundImage': backgroundImage,
      'released': released?.toIso8601String(),
      'rating': rating,
      'platforms': platforms,
    };
  }

  String toJson() => jsonEncode(toMap());
}
