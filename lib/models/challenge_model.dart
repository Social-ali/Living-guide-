import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationDays;
  final int targetValue;
  final String unit;
  final String difficulty;
  final int points;
  final String imageUrl;
  final List<String> tips;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.targetValue,
    required this.unit,
    required this.difficulty,
    required this.points,
    required this.imageUrl,
    required this.tips,
    required this.createdAt,
  });

  factory Challenge.fromFirestore(Map<String, dynamic> data, String id) {
    return Challenge(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      durationDays: (data['durationDays'] ?? 0) as int,
      targetValue: (data['targetValue'] ?? 0) as int,
      unit: data['unit'] ?? '',
      difficulty: data['difficulty'] ?? '',
      points: (data['points'] ?? 0) as int,
      imageUrl: data['imageUrl'] ?? '',
      tips: List<String>.from(data['tips'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'durationDays': durationDays,
      'targetValue': targetValue,
      'unit': unit,
      'difficulty': difficulty,
      'points': points,
      'imageUrl': imageUrl,
      'tips': tips,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class UserChallenge {
  final String id;
  final String userId;
  final String challengeId;
  final DateTime acceptedAt;
  final int currentProgress;
  final bool isCompleted;
  final List<ProgressEntry> progressEntries;
  final DateTime? completedAt;

  UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.acceptedAt,
    required this.currentProgress,
    required this.isCompleted,
    required this.progressEntries,
    this.completedAt,
  });

  factory UserChallenge.fromFirestore(Map<String, dynamic> data, String id) {
    return UserChallenge(
      id: id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      acceptedAt:
          (data['acceptedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentProgress: (data['currentProgress'] ?? 0) as int,
      isCompleted: data['isCompleted'] ?? false,
      progressEntries:
          (data['progressEntries'] as List<dynamic>?)
              ?.map(
                (entry) => ProgressEntry.fromMap(entry as Map<String, dynamic>),
              )
              .toList() ??
          [],
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'acceptedAt': Timestamp.fromDate(acceptedAt),
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'progressEntries': progressEntries.map((entry) => entry.toMap()).toList(),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }
}

class ProgressEntry {
  final DateTime date;
  final int value;
  final String note;

  ProgressEntry({required this.date, required this.value, required this.note});

  factory ProgressEntry.fromMap(Map<String, dynamic> data) {
    return ProgressEntry(
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      value: (data['value'] ?? 0) as int,
      note: data['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': Timestamp.fromDate(date), 'value': value, 'note': note};
  }
}
