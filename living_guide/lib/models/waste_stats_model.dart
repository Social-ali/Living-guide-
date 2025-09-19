import 'package:cloud_firestore/cloud_firestore.dart';

class WasteStats {
  final String id;
  final String userId;
  final String
  wasteType; // 'plastic', 'paper', 'glass', 'metal', 'organic', 'electronic'
  final double quantity; // in kg or appropriate unit
  final String unit; // 'kg', 'items', 'bottles', etc.
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  WasteStats({
    required this.id,
    required this.userId,
    required this.wasteType,
    required this.quantity,
    required this.unit,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  factory WasteStats.fromFirestore(Map<String, dynamic> data, String id) {
    return WasteStats(
      id: id,
      userId: data['userId'] ?? '',
      wasteType: data['wasteType'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? 'kg',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'wasteType': wasteType,
      'quantity': quantity,
      'unit': unit,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Get display name for waste type
  String get wasteTypeDisplayName {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return 'Plastic';
      case 'paper':
        return 'Paper';
      case 'glass':
        return 'Glass';
      case 'metal':
        return 'Metal';
      case 'organic':
        return 'Organic';
      case 'electronic':
        return 'Electronic';
      default:
        return wasteType;
    }
  }

  // Get color for waste type
  static Map<String, int> get wasteTypeColors {
    return {
      'plastic': 0xFF2196F3, // Blue
      'paper': 0xFF4CAF50, // Green
      'glass': 0xFFFF9800, // Orange
      'metal': 0xFF9C27B0, // Purple
      'organic': 0xFF795548, // Brown
      'electronic': 0xFF607D8B, // Grey
    };
  }
}

class WasteSummary {
  final String wasteType;
  final double totalQuantity;
  final int entryCount;
  final DateTime lastEntryDate;

  WasteSummary({
    required this.wasteType,
    required this.totalQuantity,
    required this.entryCount,
    required this.lastEntryDate,
  });

  String get wasteTypeDisplayName {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return 'Plastic';
      case 'paper':
        return 'Paper';
      case 'glass':
        return 'Glass';
      case 'metal':
        return 'Metal';
      case 'organic':
        return 'Organic';
      case 'electronic':
        return 'Electronic';
      default:
        return wasteType;
    }
  }
}
