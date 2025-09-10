import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryEntry {
  final String userId;
  final int gameId;
  final String name;
  final String? backgroundImage;
  final String status;
  final int rating;
  final DateTime addedAt;
  final DateTime updatedAt;

  const LibraryEntry({
    required this.userId,
    required this.gameId,
    required this.name,
    this.backgroundImage,
    required this.status,
    required this.rating,
    required this.addedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gameId': gameId,
      'name': name,
      'backgroundImage': backgroundImage,
      'status': status,
      'rating': rating,
      'addedAt': Timestamp.fromDate(addedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LibraryEntry.fromMap(Map<String, dynamic> map) {
    return LibraryEntry(
      userId: map['userId'] as String,
      gameId: (map['gameId'] as num).toInt(),
      name: map['name'] as String,
      backgroundImage: map['backgroundImage'] as String?,
      status: map['status'] as String,
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      addedAt: (map['addedAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
