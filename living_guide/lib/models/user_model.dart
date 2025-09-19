import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLogin;
  final DateTime updatedAt;
  final int totalChallengesCompleted;
  final int totalPoints;
  final double carbonFootprint;
  final double wasteReduced;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLogin,
    required this.updatedAt,
    this.totalChallengesCompleted = 0,
    this.totalPoints = 0,
    this.carbonFootprint = 0.0,
    this.wasteReduced = 0.0,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalChallengesCompleted: (data['totalChallengesCompleted'] ?? 0).toInt(),
      totalPoints: (data['totalPoints'] ?? 0).toInt(),
      carbonFootprint: (data['carbonFootprint'] ?? 0.0).toDouble(),
      wasteReduced: (data['wasteReduced'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'totalChallengesCompleted': totalChallengesCompleted,
      'totalPoints': totalPoints,
      'carbonFootprint': carbonFootprint,
      'wasteReduced': wasteReduced,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? lastLogin,
    DateTime? updatedAt,
    int? totalChallengesCompleted,
    int? totalPoints,
    double? carbonFootprint,
    double? wasteReduced,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      updatedAt: updatedAt ?? this.updatedAt,
      totalChallengesCompleted:
          totalChallengesCompleted ?? this.totalChallengesCompleted,
      totalPoints: totalPoints ?? this.totalPoints,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      wasteReduced: wasteReduced ?? this.wasteReduced,
    );
  }
}
