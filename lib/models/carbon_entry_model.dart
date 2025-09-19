import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarbonEntry {
  final String id;
  final String userId;
  final String activityType;
  final String activityDescription;
  final double quantity;
  final String unit;
  final double carbonImpact; // in kg CO2
  final DateTime date;
  final DateTime createdAt;
  final String? notes;

  CarbonEntry({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.activityDescription,
    required this.quantity,
    required this.unit,
    required this.carbonImpact,
    required this.date,
    required this.createdAt,
    this.notes,
  });

  factory CarbonEntry.fromFirestore(Map<String, dynamic> data, String id) {
    return CarbonEntry(
      id: id,
      userId: data['userId'] ?? '',
      activityType: data['activityType'] ?? '',
      activityDescription: data['activityDescription'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? '',
      carbonImpact: (data['carbonImpact'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'activityType': activityType,
      'activityDescription': activityDescription,
      'quantity': quantity,
      'unit': unit,
      'carbonImpact': carbonImpact,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  // Get activity icon
  IconData get activityIcon {
    switch (activityType.toLowerCase()) {
      case 'transportation':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'energy':
        return Icons.electrical_services;
      case 'waste':
        return Icons.delete;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.eco;
    }
  }

  // Get activity color
  Color get activityColor {
    switch (activityType.toLowerCase()) {
      case 'transportation':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'energy':
        return Colors.yellow.shade700;
      case 'waste':
        return Colors.brown;
      case 'shopping':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }
}

class ActivityType {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<ActivityOption> options;

  const ActivityType({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.options,
  });
}

class ActivityOption {
  final String name;
  final String unit;
  final double carbonFactor; // kg CO2 per unit

  const ActivityOption({
    required this.name,
    required this.unit,
    required this.carbonFactor,
  });

  double calculateCarbonImpact(double quantity) {
    return quantity * carbonFactor;
  }
}

// Predefined activity types and options
class CarbonCalculator {
  static const List<ActivityType> activityTypes = [
    ActivityType(
      name: 'Transportation',
      description: 'Track your travel emissions',
      icon: Icons.directions_car,
      color: Colors.blue,
      options: [
        ActivityOption(
          name: 'Driving (gas car)',
          unit: 'km',
          carbonFactor: 0.192,
        ), // kg CO2 per km
        ActivityOption(
          name: 'Driving (electric car)',
          unit: 'km',
          carbonFactor: 0.053,
        ),
        ActivityOption(name: 'Bus ride', unit: 'km', carbonFactor: 0.089),
        ActivityOption(name: 'Train ride', unit: 'km', carbonFactor: 0.041),
        ActivityOption(
          name: 'Flight (domestic)',
          unit: 'km',
          carbonFactor: 0.255,
        ),
        ActivityOption(
          name: 'Flight (international)',
          unit: 'km',
          carbonFactor: 0.150,
        ),
        ActivityOption(name: 'Cycling', unit: 'km', carbonFactor: 0.0),
        ActivityOption(name: 'Walking', unit: 'km', carbonFactor: 0.0),
      ],
    ),
    ActivityType(
      name: 'Food',
      description: 'Track your food-related emissions',
      icon: Icons.restaurant,
      color: Colors.orange,
      options: [
        ActivityOption(
          name: 'Beef meal',
          unit: 'servings',
          carbonFactor: 27.0,
        ), // kg CO2 per serving
        ActivityOption(
          name: 'Chicken meal',
          unit: 'servings',
          carbonFactor: 6.9,
        ),
        ActivityOption(name: 'Fish meal', unit: 'servings', carbonFactor: 5.0),
        ActivityOption(
          name: 'Vegetarian meal',
          unit: 'servings',
          carbonFactor: 2.0,
        ),
        ActivityOption(name: 'Vegan meal', unit: 'servings', carbonFactor: 1.5),
        ActivityOption(name: 'Dairy products', unit: 'kg', carbonFactor: 3.2),
        ActivityOption(
          name: 'Plant-based milk',
          unit: 'liters',
          carbonFactor: 0.5,
        ),
      ],
    ),
    ActivityType(
      name: 'Energy',
      description: 'Track your energy consumption',
      icon: Icons.electrical_services,
      color: Colors.yellow,
      options: [
        ActivityOption(
          name: 'Electricity usage',
          unit: 'kWh',
          carbonFactor: 0.429,
        ), // kg CO2 per kWh (average)
        ActivityOption(name: 'Natural gas', unit: 'm³', carbonFactor: 2.02),
        ActivityOption(name: 'Heating oil', unit: 'liters', carbonFactor: 2.68),
        ActivityOption(name: 'Solar energy', unit: 'kWh', carbonFactor: 0.0),
      ],
    ),
    ActivityType(
      name: 'Waste',
      description: 'Track your waste generation',
      icon: Icons.delete,
      color: Colors.brown,
      options: [
        ActivityOption(name: 'Plastic waste', unit: 'kg', carbonFactor: 6.0),
        ActivityOption(name: 'Paper waste', unit: 'kg', carbonFactor: 3.5),
        ActivityOption(name: 'Organic waste', unit: 'kg', carbonFactor: 0.8),
        ActivityOption(name: 'Glass waste', unit: 'kg', carbonFactor: 0.5),
        ActivityOption(name: 'Metal waste', unit: 'kg', carbonFactor: 1.2),
      ],
    ),
    ActivityType(
      name: 'Shopping',
      description: 'Track your consumption emissions',
      icon: Icons.shopping_bag,
      color: Colors.purple,
      options: [
        ActivityOption(
          name: 'Clothing (new)',
          unit: 'items',
          carbonFactor: 15.0,
        ),
        ActivityOption(name: 'Electronics', unit: 'kg', carbonFactor: 50.0),
        ActivityOption(name: 'Furniture', unit: 'kg', carbonFactor: 20.0),
        ActivityOption(
          name: 'Second-hand items',
          unit: 'kg',
          carbonFactor: 2.0,
        ),
      ],
    ),
  ];

  static ActivityType? getActivityType(String name) {
    try {
      return activityTypes.firstWhere((type) => type.name == name);
    } catch (e) {
      return null;
    }
  }

  static ActivityOption? getActivityOption(
    String activityType,
    String optionName,
  ) {
    final type = getActivityType(activityType);
    if (type == null) return null;

    try {
      return type.options.firstWhere((option) => option.name == optionName);
    } catch (e) {
      return null;
    }
  }

  static double calculateCarbonImpact(
    String activityType,
    String optionName,
    double quantity,
  ) {
    final option = getActivityOption(activityType, optionName);
    if (option == null) return 0.0;

    return option.calculateCarbonImpact(quantity);
  }
}
