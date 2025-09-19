import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final List<String> dietaryTags; // plant-based, vegan, vegetarian, etc.
  final List<String> categories; // breakfast, lunch, dinner, snack, etc.
  final bool isPlantBased;
  final bool isOrganic;
  final bool isLocal;
  final double carbonFootprint; // in kg CO2 per serving
  final int caloriesPerServing;
  final String difficulty; // Easy, Medium, Hard
  final DateTime createdAt;
  final String authorId;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.dietaryTags,
    required this.categories,
    required this.isPlantBased,
    required this.isOrganic,
    required this.isLocal,
    required this.carbonFootprint,
    required this.caloriesPerServing,
    required this.difficulty,
    required this.createdAt,
    required this.authorId,
  });

  factory Recipe.fromFirestore(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      prepTimeMinutes: (data['prepTimeMinutes'] ?? 0).toInt(),
      cookTimeMinutes: (data['cookTimeMinutes'] ?? 0).toInt(),
      servings: (data['servings'] ?? 1).toInt(),
      dietaryTags: List<String>.from(data['dietaryTags'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      isPlantBased: data['isPlantBased'] ?? false,
      isOrganic: data['isOrganic'] ?? false,
      isLocal: data['isLocal'] ?? false,
      carbonFootprint: (data['carbonFootprint'] ?? 0.0).toDouble(),
      caloriesPerServing: (data['caloriesPerServing'] ?? 0).toInt(),
      difficulty: data['difficulty'] ?? 'Medium',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorId: data['authorId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'dietaryTags': dietaryTags,
      'categories': categories,
      'isPlantBased': isPlantBased,
      'isOrganic': isOrganic,
      'isLocal': isLocal,
      'carbonFootprint': carbonFootprint,
      'caloriesPerServing': caloriesPerServing,
      'difficulty': difficulty,
      'createdAt': Timestamp.fromDate(createdAt),
      'authorId': authorId,
    };
  }

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  String get totalTimeFormatted {
    final hours = totalTimeMinutes ~/ 60;
    final minutes = totalTimeMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  List<String> get filterTags {
    final tags = <String>[];
    if (isPlantBased) tags.add('Plant-based');
    if (isOrganic) tags.add('Organic');
    if (isLocal) tags.add('Local');
    tags.addAll(dietaryTags);
    return tags;
  }

  // Get color for difficulty
  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50); // Green
      case 'medium':
        return const Color(0xFFFF9800); // Orange
      case 'hard':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }
}

class MealPlan {
  final String id;
  final String userId;
  final DateTime date;
  final List<MealPlanItem> meals;
  final DateTime createdAt;

  MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.meals,
    required this.createdAt,
  });

  factory MealPlan.fromFirestore(Map<String, dynamic> data, String id) {
    return MealPlan(
      id: id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      meals:
          (data['meals'] as List<dynamic>?)
              ?.map((meal) => MealPlanItem.fromMap(meal))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class MealPlanItem {
  final String mealType; // breakfast, lunch, dinner, snack
  final String recipeId;
  final String recipeTitle;
  final int servings;

  MealPlanItem({
    required this.mealType,
    required this.recipeId,
    required this.recipeTitle,
    required this.servings,
  });

  factory MealPlanItem.fromMap(Map<String, dynamic> data) {
    return MealPlanItem(
      mealType: data['mealType'] ?? '',
      recipeId: data['recipeId'] ?? '',
      recipeTitle: data['recipeTitle'] ?? '',
      servings: (data['servings'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealType': mealType,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'servings': servings,
    };
  }
}
