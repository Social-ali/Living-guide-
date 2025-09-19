// ignore_for_file: unused_element

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/challenge_model.dart';
import '../models/waste_stats_model.dart';
import '../models/recipe_model.dart';
import '../models/carbon_entry_model.dart';
import '../models/forum_post_model.dart';

/// Custom exception for date range validation errors
class InvalidDateRangeException implements Exception {
  final String message;
  final DateTime? startDate;
  final DateTime? endDate;

  InvalidDateRangeException(this.message, {this.startDate, this.endDate});

  @override
  String toString() => 'InvalidDateRangeException: $message';
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constants for query limits to improve maintainability
  static const int _maxCarbonQueryResults = 1000;

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Product.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Search products by name or description
  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) {
      return getProducts();
    }

    return _firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where(
          'name',
          isLessThan:
              '$query'
              'z',
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Product.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Filter products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    if (category.isEmpty || category == 'All') {
      return getProducts();
    }

    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Product.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get unique categories
  Future<List<String>> getCategories() async {
    final snapshot = await _firestore.collection('products').get();
    final categories =
        snapshot.docs
            .map((doc) => doc.data()['category'] as String?)
            .where((category) => category != null && category.isNotEmpty)
            .map((category) => category!)
            .toSet()
            .toList();
    categories.sort();
    return categories;
  }

  // Add a new product (for admin purposes)
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  // Update a product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _firestore.collection('products').doc(id).update(data);
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  // ===== CHALLENGES METHODS =====

  // Get all challenges
  Stream<List<Challenge>> getChallenges() {
    return _firestore
        .collection('challenges')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get challenges by category
  Stream<List<Challenge>> getChallengesByCategory(String category) {
    if (category.isEmpty || category == 'All') {
      return getChallenges();
    }

    return _firestore
        .collection('challenges')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get challenge categories
  Future<List<String>> getChallengeCategories() async {
    final snapshot = await _firestore.collection('challenges').get();
    final categories =
        snapshot.docs
            .map((doc) => doc.data()['category'] as String?)
            .where((category) => category != null && category.isNotEmpty)
            .map((category) => category!)
            .toSet()
            .toList();
    categories.sort();
    return categories;
  }

  // ===== USER CHALLENGES METHODS =====

  // Accept a challenge (create user challenge)
  Future<String> acceptChallenge(String userId, String challengeId) async {
    final userChallenge = UserChallenge(
      id: '', // Will be set by Firestore
      userId: userId,
      challengeId: challengeId,
      acceptedAt: DateTime.now(),
      currentProgress: 0,
      isCompleted: false,
      progressEntries: [],
    );

    final docRef = await _firestore
        .collection('user_challenges')
        .add(userChallenge.toFirestore());
    return docRef.id;
  }

  // Get user's accepted challenges
  Stream<List<UserChallenge>> getUserChallenges(String userId) {
    return _firestore
        .collection('user_challenges')
        .where('userId', isEqualTo: userId)
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => UserChallenge.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Update user challenge progress
  Future<void> updateChallengeProgress(
    String userChallengeId,
    int newProgress, {
    String note = '',
  }) async {
    final progressEntry = ProgressEntry(
      date: DateTime.now(),
      value: newProgress,
      note: note,
    );

    await _firestore.collection('user_challenges').doc(userChallengeId).update({
      'currentProgress': newProgress,
      'progressEntries': FieldValue.arrayUnion([progressEntry.toMap()]),
    });
  }

  // Complete a challenge
  Future<void> completeChallenge(String userChallengeId) async {
    await _firestore.collection('user_challenges').doc(userChallengeId).update({
      'isCompleted': true,
      'completedAt': Timestamp.now(),
    });
  }

  // Get challenge details by ID
  Future<Challenge?> getChallengeById(String challengeId) async {
    final doc =
        await _firestore.collection('challenges').doc(challengeId).get();
    if (doc.exists) {
      return Challenge.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Check if user has already accepted a challenge
  Future<bool> hasUserAcceptedChallenge(
    String userId,
    String challengeId,
  ) async {
    final snapshot =
        await _firestore
            .collection('user_challenges')
            .where('userId', isEqualTo: userId)
            .where('challengeId', isEqualTo: challengeId)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  // ===== WASTE TRACKING METHODS =====

  // Add waste entry
  Future<String> addWasteEntry(WasteStats wasteStats) async {
    final docRef = await _firestore
        .collection('waste_entries')
        .add(wasteStats.toFirestore());
    return docRef.id;
  }

  // Get user's waste entries
  Stream<List<WasteStats>> getUserWasteEntries(String userId) {
    return _firestore
        .collection('waste_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WasteStats.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get waste entries for a specific date range
  Stream<List<WasteStats>> getWasteEntriesInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('waste_entries')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WasteStats.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get waste summary by type for a user
  Future<List<WasteSummary>> getWasteSummaryByType(String userId) async {
    final snapshot =
        await _firestore
            .collection('waste_entries')
            .where('userId', isEqualTo: userId)
            .get();

    final wasteMap = <String, List<WasteStats>>{};

    for (final doc in snapshot.docs) {
      final wasteStats = WasteStats.fromFirestore(doc.data(), doc.id);
      wasteMap.putIfAbsent(wasteStats.wasteType, () => []).add(wasteStats);
    }

    final summaries = <WasteSummary>[];
    wasteMap.forEach((wasteType, entries) {
      final totalQuantity = entries.fold(
        0.0,
        (total, entry) => total + entry.quantity,
      );
      final lastEntryDate =
          entries.isNotEmpty
              ? entries.reduce((a, b) => a.date.isAfter(b.date) ? a : b).date
              : DateTime.now();

      summaries.add(
        WasteSummary(
          wasteType: wasteType,
          totalQuantity: totalQuantity,
          entryCount: entries.length,
          lastEntryDate: lastEntryDate,
        ),
      );
    });

    return summaries;
  }

  // Get waste entries for chart data (last 30 days)
  Future<List<WasteStats>> getWasteEntriesForChart(
    String userId, {
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final snapshot =
        await _firestore
            .collection('waste_entries')
            .where('userId', isEqualTo: userId)
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('date')
            .get();

    return snapshot.docs
        .map((doc) => WasteStats.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Update waste entry
  Future<void> updateWasteEntry(
    String wasteEntryId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('waste_entries').doc(wasteEntryId).update(data);
  }

  // Delete waste entry
  Future<void> deleteWasteEntry(String wasteEntryId) async {
    await _firestore.collection('waste_entries').doc(wasteEntryId).delete();
  }

  // Get total waste reduced by user
  Future<double> getTotalWasteReduced(String userId) async {
    final snapshot =
        await _firestore
            .collection('waste_entries')
            .where('userId', isEqualTo: userId)
            .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final wasteStats = WasteStats.fromFirestore(doc.data(), doc.id);
      total += wasteStats.quantity;
    }
    return total;
  }

  // ===== RECIPE METHODS =====

  // Get all recipes
  Stream<List<Recipe>> getRecipes() {
    return _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Recipe.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get recipes with filters
  Stream<List<Recipe>> getFilteredRecipes({
    bool? isPlantBased,
    bool? isOrganic,
    bool? isLocal,
    String? category,
    String? difficulty,
  }) {
    Query query = _firestore.collection('recipes');

    // Apply filters
    if (isPlantBased == true) {
      query = query.where('isPlantBased', isEqualTo: true);
    }
    if (isOrganic == true) {
      query = query.where('isOrganic', isEqualTo: true);
    }
    if (isLocal == true) {
      query = query.where('isLocal', isEqualTo: true);
    }
    if (category != null && category != 'All') {
      query = query.where('categories', arrayContains: category);
    }
    if (difficulty != null && difficulty != 'All') {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Recipe.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    final doc = await _firestore.collection('recipes').doc(recipeId).get();
    if (doc.exists) {
      return Recipe.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Search recipes by title or ingredients
  Future<List<Recipe>> searchRecipes(String query) async {
    if (query.isEmpty) {
      final snapshot = await _firestore.collection('recipes').get();
      return snapshot.docs
          .map((doc) => Recipe.fromFirestore(doc.data(), doc.id))
          .toList();
    }

    // Search by title (case insensitive)
    final titleQuery =
        await _firestore
            .collection('recipes')
            .where('title', isGreaterThanOrEqualTo: query)
            .where(
              'title',
              isLessThan:
                  '$query'
                  '\uf8ff',
            )
            .get();

    final results = <Recipe>[];

    // Add title matches
    for (final doc in titleQuery.docs) {
      results.add(Recipe.fromFirestore(doc.data(), doc.id));
    }

    // Note: Firestore doesn't support full-text search on arrays like ingredients
    // For a production app, consider using Algolia or Elasticsearch for advanced search

    return results;
  }

  // Get recipe categories
  Future<List<String>> getRecipeCategories() async {
    final snapshot = await _firestore.collection('recipes').get();
    final categories = <String>{};

    for (final doc in snapshot.docs) {
      final recipeCategories = List<String>.from(
        doc.data()['categories'] ?? [],
      );
      categories.addAll(recipeCategories);
    }

    return categories.toList()..sort();
  }

  // ===== MEAL PLANNING METHODS =====

  // Create or update meal plan for a specific date
  Future<String> saveMealPlan(MealPlan mealPlan) async {
    final existingPlan =
        await _firestore
            .collection('meal_plans')
            .where('userId', isEqualTo: mealPlan.userId)
            .where('date', isEqualTo: Timestamp.fromDate(mealPlan.date))
            .get();

    if (existingPlan.docs.isNotEmpty) {
      // Update existing plan
      await _firestore
          .collection('meal_plans')
          .doc(existingPlan.docs.first.id)
          .update(mealPlan.toFirestore());
      return existingPlan.docs.first.id;
    } else {
      // Create new plan
      final docRef = await _firestore
          .collection('meal_plans')
          .add(mealPlan.toFirestore());
      return docRef.id;
    }
  }

  // Get meal plan for a specific date
  Future<MealPlan?> getMealPlan(String userId, DateTime date) async {
    final snapshot =
        await _firestore
            .collection('meal_plans')
            .where('userId', isEqualTo: userId)
            .where('date', isEqualTo: Timestamp.fromDate(date))
            .get();

    if (snapshot.docs.isNotEmpty) {
      return MealPlan.fromFirestore(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  // Get meal plans for a date range
  Stream<List<MealPlan>> getMealPlansInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('meal_plans')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MealPlan.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Add recipe to meal plan
  Future<void> addRecipeToMealPlan(
    String userId,
    DateTime date,
    MealPlanItem mealItem,
  ) async {
    final existingPlan = await getMealPlan(userId, date);

    if (existingPlan != null) {
      // Update existing plan
      final updatedMeals = [...existingPlan.meals, mealItem];
      final updatedPlan = MealPlan(
        id: existingPlan.id,
        userId: userId,
        date: date,
        meals: updatedMeals,
        createdAt: existingPlan.createdAt,
      );
      await _firestore
          .collection('meal_plans')
          .doc(existingPlan.id)
          .update(updatedPlan.toFirestore());
    } else {
      // Create new plan
      final newPlan = MealPlan(
        id: '',
        userId: userId,
        date: date,
        meals: [mealItem],
        createdAt: DateTime.now(),
      );
      await _firestore.collection('meal_plans').add(newPlan.toFirestore());
    }
  }

  // Remove recipe from meal plan
  Future<void> removeRecipeFromMealPlan(
    String mealPlanId,
    String mealType,
    String recipeId,
  ) async {
    final doc = await _firestore.collection('meal_plans').doc(mealPlanId).get();
    if (!doc.exists) return;

    final mealPlan = MealPlan.fromFirestore(doc.data()!, doc.id);
    final updatedMeals =
        mealPlan.meals
            .where(
              (meal) =>
                  !(meal.mealType == mealType && meal.recipeId == recipeId),
            )
            .toList();

    await _firestore.collection('meal_plans').doc(mealPlanId).update({
      'meals': updatedMeals.map((meal) => meal.toMap()).toList(),
    });
  }

  // Get user's favorite recipes
  Future<List<String>> getFavoriteRecipeIds(String userId) async {
    final snapshot =
        await _firestore
            .collection('user_favorites')
            .where('userId', isEqualTo: userId)
            .where('type', isEqualTo: 'recipe')
            .get();

    return snapshot.docs.map((doc) => doc.data()['itemId'] as String).toList();
  }

  // Add recipe to favorites
  Future<void> addRecipeToFavorites(String userId, String recipeId) async {
    await _firestore.collection('user_favorites').add({
      'userId': userId,
      'itemId': recipeId,
      'type': 'recipe',
      'createdAt': Timestamp.now(),
    });
  }

  // Remove recipe from favorites
  Future<void> removeRecipeFromFavorites(String userId, String recipeId) async {
    final snapshot =
        await _firestore
            .collection('user_favorites')
            .where('userId', isEqualTo: userId)
            .where('itemId', isEqualTo: recipeId)
            .where('type', isEqualTo: 'recipe')
            .get();

    for (final doc in snapshot.docs) {
      await _firestore.collection('user_favorites').doc(doc.id).delete();
    }
  }

  // ===== CARBON TRACKING METHODS =====

  // Add carbon entry
  Future<String> addCarbonEntry(CarbonEntry entry) async {
    final docRef = await _firestore
        .collection('carbon_entries')
        .add(entry.toFirestore());
    return docRef.id;
  }

  // Get user's carbon entries
  Stream<List<CarbonEntry>> getUserCarbonEntries(String userId) {
    return _firestore
        .collection('carbon_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CarbonEntry.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get carbon entries for a specific date range
  Stream<List<CarbonEntry>> getCarbonEntriesInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('carbon_entries')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CarbonEntry.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get carbon entries for chart data (last 30 days)
  Future<List<CarbonEntry>> getCarbonEntriesForChart(
    String userId, {
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final snapshot =
        await _firestore
            .collection('carbon_entries')
            .where('userId', isEqualTo: userId)
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('date')
            .get();

    return snapshot.docs
        .map((doc) => CarbonEntry.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Get total carbon impact for user
  Future<double> getTotalCarbonImpact(String userId) async {
    final snapshot =
        await _firestore
            .collection('carbon_entries')
            .where('userId', isEqualTo: userId)
            .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final entry = CarbonEntry.fromFirestore(doc.data(), doc.id);
      total += entry.carbonImpact;
    }
    return total;
  }

  // Get carbon impact by activity type
  Future<Map<String, double>> getCarbonImpactByActivityType(
    String userId,
  ) async {
    final snapshot =
        await _firestore
            .collection('carbon_entries')
            .where('userId', isEqualTo: userId)
            .get();

    final impactByType = <String, double>{};
    for (final doc in snapshot.docs) {
      final entry = CarbonEntry.fromFirestore(doc.data(), doc.id);
      impactByType[entry.activityType] =
          (impactByType[entry.activityType] ?? 0) + entry.carbonImpact;
    }
    return impactByType;
  }

  /// Retrieves daily carbon impact data for a user over the specified number of days.
  ///
  /// This method performs input validation, optimized Firestore queries, and
  /// handles edge cases gracefully while maintaining performance.
  ///
  /// Parameters:
  /// - [userId]: The user's unique identifier (required, non-empty)
  /// - [days]: Number of days to look back (default: 7, must be positive)
  ///
  /// Returns: List of maps containing date and carbon impact data
  /// Throws: [ArgumentError] for invalid inputs, [Exception] for Firestore errors
  Future<List<Map<String, dynamic>>> getDailyCarbonImpact(
    String userId, {
    int days = 7,
  }) async {
    // Input validation with descriptive error messages
    _validateCarbonImpactInputs(userId, days);

    try {
      // Create normalized date boundaries to avoid timezone inconsistencies
      final now = DateTime.now();
      final endDate = _normalizeToEndOfDay(now);
      final startDate = _calculateStartDate(endDate, days);

      // Validate date range integrity
      _validateDateRange(startDate, endDate);

      // Build optimized query with enhanced configuration and safety limits
      final query = _buildOptimizedCarbonQuery(userId, startDate, endDate);

      // Execute query with enhanced timeout handling and performance monitoring
      final snapshot = await _executeQueryWithTimeout(
        query,
        timeoutDuration: const Duration(seconds: 30),
        operationName: 'getDailyCarbonImpact',
      );

      // Log query performance for monitoring (optional)
      if (snapshot.docs.isNotEmpty) {
        // Optional: Add performance logging in debug mode
        assert(() {
          print(
            'Carbon query executed successfully: ${snapshot.docs.length} documents retrieved',
          );
          return true;
        }());
      }

      // Handle empty results efficiently
      if (snapshot.docs.isEmpty) {
        return _generateEmptyDailyImpactData(startDate, endDate);
      }

      // Process data with error resilience and performance monitoring
      return _processCarbonImpactData(snapshot.docs, startDate, endDate);
    } on FirebaseException catch (e) {
      // Handle specific Firestore errors with user-friendly messages
      switch (e.code) {
        case 'permission-denied':
          throw Exception(
            'Access denied: Unable to retrieve carbon data. Please check your permissions.',
          );
        case 'unavailable':
          throw Exception(
            'Service temporarily unavailable: Please check your internet connection and try again.',
          );
        case 'resource-exhausted':
          throw Exception(
            'Query limit exceeded: Please reduce the date range and try again.',
          );
        default:
          throw Exception(
            'Database error retrieving carbon data: ${e.message}',
          );
      }
    } catch (e) {
      // Handle unexpected errors
      throw Exception('Unexpected error retrieving carbon data: $e');
    }
  }

  /// Validates input parameters for carbon impact retrieval with enhanced error handling
  ///
  /// Performs comprehensive validation to ensure data integrity and prevent
  /// potential performance issues or invalid queries.
  ///
  /// Throws [ArgumentError] with descriptive messages for validation failures.
  void _validateCarbonImpactInputs(String userId, int days) {
    /// Validate userId parameter: must not be empty or contain only whitespace
    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'userId must not be empty or contain only whitespace. Please provide a valid user identifier.',
      );
    }

    // Validate days parameter with boundary checks
    if (days <= 0) {
      throw ArgumentError(
        'days must be a positive integer greater than 0, got: $days',
      );
    }

    // Performance safeguard: prevent excessive data retrieval
    const int maxAllowedDays = 365;
    if (days > maxAllowedDays) {
      throw ArgumentError(
        'days cannot exceed $maxAllowedDays for performance reasons. '
        'Consider reducing the date range or implementing pagination. Got: $days',
      );
    }

    // Additional validation: reasonable upper bound for practical use
    const int minReasonableDays = 1;
    const int maxReasonableDays =
        90; // Most users won't need more than 3 months
    if (days < minReasonableDays || days > maxReasonableDays) {
      // Log a warning for unusual but valid ranges
      // In production, you might want to use a logging framework here
      print(
        'Warning: Requesting $days days of carbon data. This may impact performance.',
      );
    }
  }

  /// Validates that the date range is valid and properly ordered.
  ///
  /// Throws [InvalidDateRangeException] if:
  /// - Either date is null
  /// - startDate is after endDate
  ///
  /// [startDate]: The beginning of the date range
  /// [endDate]: The end of the date range
  void _validateDateRange(DateTime? startDate, DateTime? endDate) {
    // Null safety checks
    if (startDate == null) {
      throw InvalidDateRangeException('Start date cannot be null');
    }
    if (endDate == null) {
      throw InvalidDateRangeException('End date cannot be null');
    }

    // Date range validation
    if (startDate.isAfter(endDate)) {
      throw InvalidDateRangeException(
        'Invalid date range: start date (${startDate.toIso8601String()}) '
        'cannot be after end date (${endDate.toIso8601String()})',
        startDate: startDate,
        endDate: endDate,
      );
    }

    // Optional: Handle equal dates if they should be considered invalid
    // Uncomment the following lines if equal dates are not allowed:
    // if (startDate.isAtSameMomentAs(endDate)) {
    //   throw InvalidDateRangeException(
    //     'Invalid date range: start date and end date cannot be the same',
    //     startDate: startDate,
    //     endDate: endDate,
    //   );
    // }
  }

  /// Normalizes a DateTime to end of day for consistent boundary handling
  DateTime _normalizeToEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Calculates start date for the query range
  DateTime _calculateStartDate(DateTime endDate, int days) {
    return DateTime(endDate.year, endDate.month, endDate.day - days + 1);
  }

  /// Enhanced query builder with performance optimizations and safety checks
  ///
  /// Improvements over the original implementation:
  /// - Better index utilization through optimized field ordering
  /// - Configurable result limits based on date range
  /// - Query performance hints for Firestore optimization
  /// - Enhanced documentation for maintenance
  ///
  /// Parameters:
  /// - [userId]: User identifier for filtering
  /// - [startDate]: Start of the date range (inclusive)
  /// - [endDate]: End of the date range (inclusive)
  ///
  /// Returns: Optimized Firestore query ready for execution
  Query<Map<String, dynamic>> _buildOptimizedCarbonQuery(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Calculate dynamic limit based on date range to optimize performance
    final daysDifference = endDate.difference(startDate).inDays + 1;
    final dynamicLimit = _calculateOptimalQueryLimit(daysDifference);

    return _firestore
        .collection('carbon_entries')
        // Order of where clauses optimized for Firestore composite index performance
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        // Order by date for consistent results and better caching
        .orderBy('date', descending: false)
        .limit(dynamicLimit);
  }

  /// Generates empty data structure for date range with no entries
  List<Map<String, dynamic>> _generateEmptyDailyImpactData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final result = <Map<String, dynamic>>[];
    var currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      result.add({
        'date': DateTime(currentDate.year, currentDate.month, currentDate.day),
        'impact': 0.0,
      });
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return result;
  }

  /// Enhanced data processing with better error handling and performance
  ///
  /// Improvements over the original implementation:
  /// - Batch processing for large datasets
  /// - Better memory management
  /// - Enhanced error recovery
  /// - Performance monitoring hooks
  /// - Input validation and range checking
  ///
  /// Parameters:
  /// - [docs]: Raw Firestore documents to process
  /// - [startDate]: Start of the expected date range
  /// - [endDate]: End of the expected date range
  ///
  /// Returns: Processed daily impact data with complete date coverage
  List<Map<String, dynamic>> _processCarbonImpactData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Early return for empty datasets
    if (docs.isEmpty) {
      return _generateEmptyDailyImpactData(startDate, endDate);
    }

    // Process documents in batches for better memory management
    const int batchSize = 100;
    final dailyImpact = <String, double>{};
    // ignore: unused_local_variable
    int processedCount = 0;
    int errorCount = 0;

    for (int i = 0; i < docs.length; i += batchSize) {
      final batch = docs.skip(i).take(batchSize);

      for (final doc in batch) {
        try {
          final entry = CarbonEntry.fromFirestore(doc.data(), doc.id);
          final dateKey = _formatDateKey(entry.date);

          // Validate date is within expected range
          if (_isDateInRange(entry.date, startDate, endDate)) {
            dailyImpact[dateKey] =
                (dailyImpact[dateKey] ?? 0.0) + entry.carbonImpact;
            processedCount++;
          }
        } catch (e) {
          errorCount++;
          // Log malformed entries but continue processing
          // In production, consider using a proper logging framework
          if (errorCount <= 5) {
            // Limit error logging to prevent spam
            print('Warning: Skipping malformed carbon entry ${doc.id}: $e');
          }
          continue;
        }
      }
    }

    // Optional: Log processing statistics for monitoring
    // Uncomment if logging framework is available
    // _logger.info('Processed $processedCount entries, skipped $errorCount errors');

    // Build complete date range with processed data
    return _buildCompleteDailyData(startDate, endDate, dailyImpact);
  }

  /// Builds complete daily data list ensuring all dates are represented
  List<Map<String, dynamic>> _buildCompleteDailyData(
    DateTime startDate,
    DateTime endDate,
    Map<String, double> dailyImpact,
  ) {
    final result = <Map<String, dynamic>>[];
    var currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      final dateKey = currentDate.toIso8601String().split('T')[0];
      result.add({
        'date': DateTime(currentDate.year, currentDate.month, currentDate.day),
        'impact': dailyImpact[dateKey] ?? 0.0,
      });
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return result;
  }

  // Helper method to generate empty daily data for date range

  // Helper method to build daily data list
  List<Map<String, dynamic>> _buildDailyDataList(
    DateTime startDate,
    DateTime endDate,
    Map<String, double> dailyImpact,
  ) {
    final result = <Map<String, dynamic>>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final dateKey = currentDate.toIso8601String().split('T')[0];
      result.add({
        'date': DateTime(currentDate.year, currentDate.month, currentDate.day),
        'impact': dailyImpact[dateKey] ?? 0.0,
      });
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return result;
  }

  /// Legacy method - use _calculateStartDate instead
  @deprecated
  DateTime _createStartOfDayRange(DateTime endDate, int days) {
    return _calculateStartDate(endDate, days);
  }

  /// Legacy method - kept for backward compatibility
  // ignore: provide_deprecation_message
  @deprecated
  Query<Map<String, dynamic>> _buildCarbonEntriesQuery(
    String userId,
    Timestamp startTimestamp,
    Timestamp endTimestamp,
  ) {
    return _buildOptimizedCarbonQuery(
      userId,
      startTimestamp.toDate(),
      endTimestamp.toDate(),
    );
  }

  /// Executes a Firestore query with timeout and enhanced error handling
  ///
  /// This method wraps query execution with:
  /// - Configurable timeout to prevent hanging operations
  /// - Detailed error context for debugging
  /// - Performance monitoring capabilities
  /// - Graceful degradation on timeout
  ///
  /// Parameters:
  /// - [query]: The Firestore query to execute
  /// - [timeoutDuration]: Maximum time to wait for query completion (default: 30s)
  /// - [operationName]: Name of the operation for logging/debugging purposes
  ///
  /// Returns: QuerySnapshot with the query results
  /// Throws: [TimeoutException], [FirebaseException], or [Exception]
  Future<QuerySnapshot<Map<String, dynamic>>> _executeQueryWithTimeout(
    Query<Map<String, dynamic>> query, {
    Duration timeoutDuration = const Duration(seconds: 30),
    String operationName = 'firestore_query',
  }) async {
    try {
      // Execute query with timeout protection
      var timeout = query.get().timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Query timeout after ${timeoutDuration.inSeconds}s for operation: $operationName',
            timeoutDuration,
          );
        },
      );
      final result = await newMethod(timeout);

      // Optional: Log successful query execution for monitoring
      // Uncomment if logging framework is available
      // _logger.debug('Query executed successfully: $operationName, docs: ${result.docs.length}');

      return result;
    } on TimeoutException catch (e) {
      // Handle timeout with user-friendly message
      throw Exception(
        'Operation timed out: The request took longer than expected. '
        'Please check your internet connection and try again. '
        'Details: ${e.message}',
      );
    } on FirebaseException catch (e) {
      // Re-throw Firebase exceptions with additional context
      throw FirebaseException(
        plugin: e.plugin,
        code: e.code,
        message: 'Firestore query failed for $operationName: ${e.message}',
      );
    } catch (e) {
      // Handle unexpected errors with context
      throw Exception(
        'Unexpected error during $operationName query execution: $e',
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> newMethod(
    Future<QuerySnapshot<Map<String, dynamic>>> timeout,
  ) => timeout;

  /// Calculates optimal query limit based on expected data volume
  ///
  /// This method provides intelligent limiting to balance performance
  /// with data completeness based on the query date range.
  ///
  /// Parameters:
  /// - [days]: Number of days in the query range
  ///
  /// Returns: Optimal limit for the query
  int _calculateOptimalQueryLimit(int days) {
    // Base assumption: average 5 entries per day per user
    const int avgEntriesPerDay = 5;
    final int estimatedEntries = days * avgEntriesPerDay;

    // Apply reasonable bounds with safety margin
    const int minLimit = 50;
    const int maxLimit = _maxCarbonQueryResults;
    final int calculatedLimit =
        (estimatedEntries * 1.5).round(); // 50% safety margin

    return calculatedLimit.clamp(minLimit, maxLimit);
  }

  /// Validates if a date falls within the specified range
  ///
  /// Parameters:
  /// - [date]: Date to validate
  /// - [startDate]: Start of the valid range (inclusive)
  /// - [endDate]: End of the valid range (inclusive)
  ///
  /// Returns: true if date is within range, false otherwise
  bool _isDateInRange(DateTime date, DateTime startDate, DateTime endDate) {
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  /// Formats a DateTime to a consistent date key string
  ///
  /// Returns date in YYYY-MM-DD format for consistent grouping
  /// Enhanced with input validation and error handling
  String _formatDateKey(DateTime date) {
    try {
      return date.toIso8601String().split('T')[0];
    } catch (e) {
      // Fallback formatting in case of edge cases
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
  }

  // Update carbon entry
  Future<void> updateCarbonEntry(
    String entryId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('carbon_entries').doc(entryId).update(data);
  }

  // Delete carbon entry
  Future<void> deleteCarbonEntry(String entryId) async {
    await _firestore.collection('carbon_entries').doc(entryId).delete();
  }

  // ===== FORUM METHODS =====

  // Get all forum posts with StreamBuilder
  Stream<List<ForumPost>> getForumPosts() {
    return _firestore
        .collection('posts')
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ForumPost.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get forum posts by category
  Stream<List<ForumPost>> getForumPostsByCategory(String category) {
    if (category.isEmpty || category == 'All') {
      return getForumPosts();
    }

    return _firestore
        .collection('posts')
        .where('category', isEqualTo: category)
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ForumPost.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get forum post by ID
  Future<ForumPost?> getForumPostById(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();
    if (doc.exists) {
      return ForumPost.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }
    return null;
  }

  /// Creates a new forum post in Firestore.
  ///
  /// This method validates the input, adds the post to the 'posts' collection,
  /// and returns the generated document ID for reference.
  ///
  /// Parameters:
  /// - [post]: The forum post to create. Must not be null and should be properly initialized.
  ///
  /// Returns:
  /// The ID of the newly created document.
  ///
  /// Throws:
  /// - [ArgumentError] if the post is null or invalid.
  /// - [FirebaseException] for Firestore-specific errors (e.g., permission denied, network issues).
  /// - [Exception] for unexpected errors during the operation.
  Future<String> createForumPost(ForumPost post) async {
    // Input validation for edge cases
    if (post.title.isEmpty) {
      throw ArgumentError('ForumPost title cannot be null or empty');
    }

    try {
      final docRef = await _firestore
          .collection('posts')
          .add(post.toFirestore());
      // Optional: Log success for debugging/monitoring (uncomment if logging is available)
      // logger.info('Forum post created successfully with ID: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      // Handle specific Firestore errors with user-friendly messages
      switch (e.code) {
        case 'permission-denied':
          throw Exception(
            'Permission denied: Unable to create forum post. Please check your authentication.',
          );
        case 'unavailable':
          throw Exception(
            'Service unavailable: Please check your internet connection and try again.',
          );
        case 'resource-exhausted':
          throw Exception(
            'Rate limit exceeded: Please wait a moment before creating another post.',
          );
        default:
          throw Exception('Failed to create forum post: ${e.message}');
      }
    } catch (e) {
      // Handle unexpected errors
      throw Exception('Unexpected error creating forum post: $e');
    }
  }

  // Update a forum post
  Future<void> updateForumPost(String postId, Map<String, dynamic> data) async {
    await _firestore.collection('posts').doc(postId).update(data);
  }

  // Delete a forum post
  Future<void> deleteForumPost(String postId) async {
    // Delete the post
    await _firestore.collection('posts').doc(postId).delete();

    // Delete all comments for this post
    final commentsSnapshot =
        await _firestore
            .collection('comments')
            .where('postId', isEqualTo: postId)
            .get();

    for (final doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Vote on a forum post
  Future<void> voteOnPost(String postId, String userId, bool isUpvote) async {
    final postRef = _firestore.collection('posts').doc(postId);

    // Check if user already voted
    final voteRef = postRef.collection('votes').doc(userId);
    final voteDoc = await voteRef.get();

    if (voteDoc.exists) {
      final existingVote = voteDoc.data()?['isUpvote'] as bool?;
      if (existingVote == isUpvote) {
        // User is trying to vote the same way again - remove vote
        await voteRef.delete();
        if (isUpvote) {
          await postRef.update({'upvotes': FieldValue.increment(-1)});
        } else {
          await postRef.update({'downvotes': FieldValue.increment(-1)});
        }
      } else {
        // User is changing their vote
        await voteRef.update({'isUpvote': isUpvote});
        if (isUpvote) {
          await postRef.update({
            'upvotes': FieldValue.increment(1),
            'downvotes': FieldValue.increment(-1),
          });
        } else {
          await postRef.update({
            'upvotes': FieldValue.increment(-1),
            'downvotes': FieldValue.increment(1),
          });
        }
      }
    } else {
      // New vote
      await voteRef.set({
        'userId': userId,
        'isUpvote': isUpvote,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (isUpvote) {
        await postRef.update({'upvotes': FieldValue.increment(1)});
      } else {
        await postRef.update({'downvotes': FieldValue.increment(1)});
      }
    }
  }

  // ===== COMMENT METHODS =====

  // Get comments for a post
  Stream<List<Comment>> getCommentsForPost(String postId) {
    return _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Comment.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Add a comment to a post
  Future<String> addCommentToPost(Comment comment) async {
    final docRef = await _firestore
        .collection('comments')
        .add(comment.toFirestore());

    // Update comment count on the post
    await _firestore.collection('posts').doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  // Update a comment
  Future<void> updateComment(
    String commentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('comments').doc(commentId).update(data);
  }

  // Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    await _firestore.collection('comments').doc(commentId).delete();

    // Update comment count on the post
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // Vote on a comment
  Future<void> voteOnComment(
    String commentId,
    String userId,
    bool isUpvote,
  ) async {
    final commentRef = _firestore.collection('comments').doc(commentId);

    // Check if user already voted
    final voteRef = commentRef.collection('votes').doc(userId);
    final voteDoc = await voteRef.get();

    if (voteDoc.exists) {
      final existingVote = voteDoc.data()?['isUpvote'] as bool?;
      if (existingVote == isUpvote) {
        // User is trying to vote the same way again - remove vote
        await voteRef.delete();
        if (isUpvote) {
          await commentRef.update({'upvotes': FieldValue.increment(-1)});
        } else {
          await commentRef.update({'downvotes': FieldValue.increment(-1)});
        }
      } else {
        // User is changing their vote
        await voteRef.update({'isUpvote': isUpvote});
        if (isUpvote) {
          await commentRef.update({
            'upvotes': FieldValue.increment(1),
            'downvotes': FieldValue.increment(-1),
          });
        } else {
          await commentRef.update({
            'upvotes': FieldValue.increment(-1),
            'downvotes': FieldValue.increment(1),
          });
        }
      }
    } else {
      // New vote
      await voteRef.set({
        'userId': userId,
        'isUpvote': isUpvote,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (isUpvote) {
        await commentRef.update({'upvotes': FieldValue.increment(1)});
      } else {
        await commentRef.update({'downvotes': FieldValue.increment(1)});
      }
    }
  }

  // Get forum categories
  Future<List<String>> getForumCategories() async {
    final snapshot = await _firestore.collection('posts').get();
    final categories =
        snapshot.docs
            .map((doc) => doc.data()['category'] as String?)
            .where((category) => category != null && category.isNotEmpty)
            .map((category) => category!)
            .toSet()
            .toList();
    categories.sort();
    return categories;
  }

  // Search forum posts
  Stream<List<ForumPost>> searchForumPosts(String query) {
    if (query.isEmpty) {
      return getForumPosts();
    }

    // Note: Firestore doesn't support full-text search natively
    // This is a basic implementation - in production, you'd use Algolia or similar
    return _firestore
        .collection('posts')
        .where('title', isGreaterThanOrEqualTo: query)
        .where(
          'title',
          isLessThan:
              '$query'
              'z',
        )
        .orderBy('title')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ForumPost.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Add sample challenges for demo purposes
  Future<void> addSampleChallenges() async {
    final sampleChallenges = [
      Challenge(
        id: '',
        title: 'Zero Waste Week',
        description:
            'Go an entire week without producing any waste. Compost food scraps, reuse containers, and avoid single-use plastics.',
        category: 'Waste Reduction',
        durationDays: 7,
        targetValue: 7,
        unit: 'days',
        difficulty: 'Hard',
        points: 500,
        imageUrl: '',
        tips: [
          'Plan meals to minimize packaging',
          'Use reusable containers and bags',
          'Compost all food waste',
          'Buy products with minimal packaging',
        ],
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: '',
        title: 'Plant-Based Meals',
        description:
            'Try 10 plant-based meals this week. Discover new recipes and reduce your carbon footprint.',
        category: 'Food',
        durationDays: 7,
        targetValue: 10,
        unit: 'meals',
        difficulty: 'Medium',
        points: 300,
        imageUrl: '',
        tips: [
          'Start with familiar ingredients',
          'Try new vegetables and grains',
          'Use plant-based protein sources',
          'Experiment with herbs and spices',
        ],
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: '',
        title: 'Energy Saver',
        description:
            'Reduce your energy consumption by 20% this week through conscious usage habits.',
        category: 'Energy',
        durationDays: 7,
        targetValue: 20,
        unit: '%',
        difficulty: 'Easy',
        points: 200,
        imageUrl: '',
        tips: [
          'Unplug unused electronics',
          'Use LED bulbs',
          'Adjust thermostat by 2 degrees',
          'Wash clothes in cold water',
        ],
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: '',
        title: 'Sustainable Shopping',
        description:
            'Purchase only sustainable products for 5 days. Look for eco-friendly certifications and local products.',
        category: 'Shopping',
        durationDays: 5,
        targetValue: 5,
        unit: 'days',
        difficulty: 'Medium',
        points: 250,
        imageUrl: '',
        tips: [
          'Check for eco-certifications',
          'Buy from local producers',
          'Choose products with minimal packaging',
          'Research company sustainability practices',
        ],
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: '',
        title: 'Bicycle Commute',
        description: 'Replace car trips with bicycle rides for transportation.',
        category: 'Transportation',
        durationDays: 7,
        targetValue: 5,
        unit: 'trips',
        difficulty: 'Medium',
        points: 350,
        imageUrl: '',
        tips: [
          'Plan your route in advance',
          'Wear appropriate safety gear',
          'Start with shorter distances',
          'Combine with public transport when needed',
        ],
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: '',
        title: 'Water Conservation',
        description:
            'Reduce water usage by taking shorter showers and fixing leaks.',
        category: 'Water',
        durationDays: 7,
        targetValue: 15,
        unit: 'gallons',
        difficulty: 'Easy',
        points: 150,
        imageUrl: '',
        tips: [
          'Take 5-minute showers',
          'Fix leaky faucets',
          'Use water-efficient appliances',
          'Collect rainwater for plants',
        ],
        createdAt: DateTime.now(),
      ),
    ];

    for (final challenge in sampleChallenges) {
      await _firestore.collection('challenges').add(challenge.toFirestore());
    }
  }

  // Add sample recipes for demo purposes
  Future<void> addSampleRecipes() async {
    final sampleRecipes = [
      Recipe(
        id: '',
        title: 'Quinoa Buddha Bowl',
        description:
            'A nutritious and colorful plant-based bowl packed with protein-rich quinoa, fresh vegetables, and a tahini dressing.',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        ingredients: [
          '1 cup quinoa',
          '1 can chickpeas, drained and rinsed',
          '2 cups mixed greens (spinach, kale)',
          '1 avocado, sliced',
          '1 cup cherry tomatoes, halved',
          '1 cucumber, sliced',
          '1/4 cup red onion, thinly sliced',
          '2 tbsp tahini',
          '1 tbsp lemon juice',
          '1 tbsp olive oil',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Cook quinoa according to package instructions and let cool.',
          'While quinoa cooks, prepare the vegetables.',
          'In a small bowl, whisk together tahini, lemon juice, olive oil, salt, and pepper for the dressing.',
          'Arrange quinoa, chickpeas, and vegetables in bowls.',
          'Drizzle with tahini dressing and serve immediately.',
        ],
        prepTimeMinutes: 15,
        cookTimeMinutes: 15,
        servings: 4,
        dietaryTags: ['Vegan', 'Gluten-free', 'High-protein'],
        categories: ['Lunch', 'Dinner', 'Plant-based'],
        isPlantBased: true,
        isOrganic: true,
        isLocal: false,
        carbonFootprint: 1.2,
        caloriesPerServing: 450,
        difficulty: 'Easy',
        createdAt: DateTime.now(),
        authorId: 'demo_author',
      ),
      Recipe(
        id: '',
        title: 'Mediterranean Chickpea Salad',
        description:
            'A refreshing and healthy salad featuring chickpeas, fresh herbs, and a light lemon vinaigrette.',
        imageUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
        ingredients: [
          '2 cans chickpeas, drained and rinsed',
          '1 cup cherry tomatoes, halved',
          '1 cucumber, diced',
          '1/2 red onion, finely chopped',
          '1/4 cup fresh parsley, chopped',
          '1/4 cup fresh mint, chopped',
          '1/4 cup feta cheese, crumbled',
          '3 tbsp olive oil',
          '2 tbsp lemon juice',
          '1 garlic clove, minced',
          'Salt and pepper to taste',
        ],
        instructions: [
          'In a large bowl, combine chickpeas, tomatoes, cucumber, red onion, parsley, and mint.',
          'In a small bowl, whisk together olive oil, lemon juice, garlic, salt, and pepper.',
          'Pour dressing over the salad and toss to combine.',
          'Sprinkle with feta cheese and serve chilled.',
        ],
        prepTimeMinutes: 20,
        cookTimeMinutes: 0,
        servings: 6,
        dietaryTags: ['Vegetarian', 'Gluten-free', 'Mediterranean'],
        categories: ['Lunch', 'Side dish', 'Salad'],
        isPlantBased: false,
        isOrganic: true,
        isLocal: true,
        carbonFootprint: 0.8,
        caloriesPerServing: 280,
        difficulty: 'Easy',
        createdAt: DateTime.now(),
        authorId: 'demo_author',
      ),
      Recipe(
        id: '',
        title: 'Lentil Soup with Vegetables',
        description:
            'A hearty and warming soup made with lentils, seasonal vegetables, and aromatic spices.',
        imageUrl:
            'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=400',
        ingredients: [
          '1 cup green lentils, rinsed',
          '1 onion, diced',
          '2 carrots, diced',
          '2 celery stalks, diced',
          '2 garlic cloves, minced',
          '1 can diced tomatoes',
          '4 cups vegetable broth',
          '1 tsp cumin',
          '1 tsp paprika',
          '1/2 tsp turmeric',
          '2 tbsp olive oil',
          'Salt and pepper to taste',
          'Fresh parsley for garnish',
        ],
        instructions: [
          'Heat olive oil in a large pot over medium heat.',
          'Add onion, carrots, and celery. Cook for 5-7 minutes until softened.',
          'Add garlic, cumin, paprika, and turmeric. Cook for 1 minute.',
          'Add lentils, tomatoes, and vegetable broth. Bring to a boil.',
          'Reduce heat and simmer for 25-30 minutes until lentils are tender.',
          'Season with salt and pepper. Garnish with fresh parsley before serving.',
        ],
        prepTimeMinutes: 15,
        cookTimeMinutes: 35,
        servings: 6,
        dietaryTags: ['Vegan', 'Gluten-free', 'High-protein'],
        categories: ['Lunch', 'Dinner', 'Soup'],
        isPlantBased: true,
        isOrganic: true,
        isLocal: true,
        carbonFootprint: 0.9,
        caloriesPerServing: 220,
        difficulty: 'Medium',
        createdAt: DateTime.now(),
        authorId: 'demo_author',
      ),
      Recipe(
        id: '',
        title: 'Berry Smoothie Bowl',
        description:
            'A refreshing and nutritious breakfast bowl made with mixed berries, banana, and topped with granola.',
        imageUrl:
            'https://images.unsplash.com/photo-1571771019784-3ff35f4f4277?w=400',
        ingredients: [
          '1 cup mixed berries (strawberries, blueberries, raspberries)',
          '1 banana',
          '1/2 cup Greek yogurt',
          '1/4 cup almond milk',
          '1 tbsp honey',
          '1/4 cup granola',
          '1 tbsp chia seeds',
          'Fresh berries for topping',
        ],
        instructions: [
          'Add berries, banana, yogurt, almond milk, and honey to a blender.',
          'Blend until smooth and creamy.',
          'Pour into a bowl and top with granola, chia seeds, and fresh berries.',
          'Serve immediately for best texture.',
        ],
        prepTimeMinutes: 10,
        cookTimeMinutes: 0,
        servings: 2,
        dietaryTags: ['Vegetarian', 'Breakfast', 'Quick'],
        categories: ['Breakfast', 'Smoothie', 'Healthy'],
        isPlantBased: false,
        isOrganic: true,
        isLocal: true,
        carbonFootprint: 0.6,
        caloriesPerServing: 320,
        difficulty: 'Easy',
        createdAt: DateTime.now(),
        authorId: 'demo_author',
      ),
      Recipe(
        id: '',
        title: 'Stuffed Bell Peppers',
        description:
            'Colorful bell peppers stuffed with a savory mixture of quinoa, vegetables, and herbs.',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
        ingredients: [
          '4 large bell peppers',
          '1 cup quinoa, cooked',
          '1 onion, diced',
          '2 garlic cloves, minced',
          '1 zucchini, diced',
          '1 cup corn kernels',
          '1 can black beans, drained',
          '1 tsp cumin',
          '1 tsp chili powder',
          '1 cup shredded cheese',
          '2 tbsp olive oil',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Preheat oven to 375°F (190°C).',
          'Cut tops off bell peppers and remove seeds.',
          'Heat olive oil in a skillet and sauté onion and garlic for 3 minutes.',
          'Add zucchini, corn, and black beans. Cook for 5 minutes.',
          'Stir in cooked quinoa, cumin, chili powder, salt, and pepper.',
          'Stuff mixture into bell peppers and top with cheese.',
          'Bake for 25-30 minutes until peppers are tender and cheese is melted.',
        ],
        prepTimeMinutes: 20,
        cookTimeMinutes: 30,
        servings: 4,
        dietaryTags: ['Vegetarian', 'Gluten-free', 'High-protein'],
        categories: ['Dinner', 'Main course', 'Baked'],
        isPlantBased: false,
        isOrganic: true,
        isLocal: true,
        carbonFootprint: 1.5,
        caloriesPerServing: 380,
        difficulty: 'Medium',
        createdAt: DateTime.now(),
        authorId: 'demo_author',
      ),
    ];

    for (final recipe in sampleRecipes) {
      await _firestore.collection('recipes').add(recipe.toFirestore());
    }
  }

  // Add sample products for demo purposes
  Future<void> addSampleProducts() async {
    final sampleProducts = [
      Product(
        id: '',
        name: 'Organic Cotton Tote Bag',
        description:
            'Reusable tote bag made from 100% organic cotton. Perfect for grocery shopping and reducing plastic waste.',
        category: 'Bags',
        price: 15.99,
        ecoRating: 4.8,
        imageUrl:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        tags: ['organic', 'cotton', 'reusable', 'shopping'],
        createdAt: DateTime.now(),
      ),
      Product(
        id: '',
        name: 'Bamboo Toothbrush Set',
        description:
            'Biodegradable bamboo toothbrushes with replaceable heads. 4-pack for the whole family.',
        category: 'Personal Care',
        price: 12.99,
        ecoRating: 4.9,
        imageUrl:
            'https://images.unsplash.com/photo-1559599101-f09722fb4948?w=400',
        tags: ['bamboo', 'biodegradable', 'personal care', 'plastic-free'],
        createdAt: DateTime.now(),
      ),
      Product(
        id: '',
        name: 'Stainless Steel Water Bottle',
        description:
            'Insulated stainless steel water bottle that keeps drinks cold for 24 hours or hot for 12 hours.',
        category: 'Kitchen',
        price: 24.99,
        ecoRating: 4.7,
        imageUrl:
            'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400',
        tags: ['stainless steel', 'insulated', 'reusable', 'kitchen'],
        createdAt: DateTime.now(),
      ),
      Product(
        id: '',
        name: 'Organic Beeswax Food Wraps',
        description:
            'Set of 3 reusable beeswax wraps for food storage. Perfect replacement for plastic wrap.',
        category: 'Kitchen',
        price: 18.99,
        ecoRating: 4.6,
        imageUrl:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
        tags: ['beeswax', 'organic', 'food storage', 'plastic-free'],
        createdAt: DateTime.now(),
      ),
      Product(
        id: '',
        name: 'Recycled Glass Storage Jars',
        description:
            'Set of 6 recycled glass jars with bamboo lids. Perfect for storing dry goods and pantry organization.',
        category: 'Kitchen',
        price: 32.99,
        ecoRating: 4.5,
        imageUrl:
            'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=400',
        tags: ['recycled glass', 'bamboo', 'storage', 'kitchen'],
        createdAt: DateTime.now(),
      ),
      Product(
        id: '',
        name: 'Natural Loofah Sponge',
        description:
            '100% natural loofah sponge grown without pesticides. Biodegradable and perfect for bathing.',
        category: 'Personal Care',
        price: 8.99,
        ecoRating: 4.4,
        imageUrl:
            'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
        tags: ['natural', 'biodegradable', 'personal care', 'bath'],
        createdAt: DateTime.now(),
      ),
      Product(
        id: '',
        name: 'Compostable Trash Bags',
        description:
            'Box of 50 compostable trash bags made from plant-based materials. Certified compostable.',
        category: 'Cleaning',
        price: 16.99,
        ecoRating: 4.3,
        imageUrl:
            'https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?w=400',
        tags: ['compostable', 'plant-based', 'trash bags', 'cleaning'],
        createdAt: DateTime.now(),
      ),
      Product(
        id: '',
        name: 'Solar-Powered Phone Charger',
        description:
            'Portable solar charger that can charge your phone using sunlight. Perfect for outdoor activities.',
        category: 'Electronics',
        price: 39.99,
        ecoRating: 4.2,
        imageUrl:
            'https://images.unsplash.com/photo-1593941707882-a5bac6861d75?w=400',
        tags: ['solar', 'portable', 'charger', 'electronics'],
        createdAt: DateTime.now(),
      ),
    ];

    for (final product in sampleProducts) {
      await _firestore.collection('products').add(product.toFirestore());
    }
  }

  // Add sample data for dashboard charts
  Future<void> addSampleDashboardData(String userId) async {
    final now = DateTime.now();

    // Add sample carbon entries for the last 7 days
    final carbonEntries = <CarbonEntry>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      carbonEntries.addAll([
        CarbonEntry(
          id: '',
          userId: userId,
          activityType: 'Transportation',
          activityDescription: 'Car commute',
          quantity: 25.0 + (i * 2.0), // 25-39 km
          unit: 'km',
          carbonImpact: 2.5 + (i * 0.1), // Vary the impact slightly
          date: date,
          createdAt: date,
        ),
        CarbonEntry(
          id: '',
          userId: userId,
          activityType: 'Food',
          activityDescription: 'Meat consumption',
          quantity: 1.0, // 1 serving
          unit: 'servings',
          carbonImpact: 1.8 + (i * 0.05),
          date: date,
          createdAt: date,
        ),
        CarbonEntry(
          id: '',
          userId: userId,
          activityType: 'Energy',
          activityDescription: 'Home electricity',
          quantity: 15.0 + (i * 1.0), // 15-21 kWh
          unit: 'kWh',
          carbonImpact: 3.2 + (i * 0.08),
          date: date,
          createdAt: date,
        ),
      ]);
    }

    // Add carbon entries to Firestore
    for (final entry in carbonEntries) {
      await _firestore.collection('carbon_entries').add(entry.toFirestore());
    }

    // Add sample waste entries
    final wasteEntries = <WasteStats>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      wasteEntries.addAll([
        WasteStats(
          id: '',
          userId: userId,
          wasteType: 'Plastic',
          quantity: 0.5 + (i * 0.1),
          unit: 'kg',
          date: date,
          notes: 'Plastic bottles and packaging',
          createdAt: date,
        ),
        WasteStats(
          id: '',
          userId: userId,
          wasteType: 'Paper',
          quantity: 0.3 + (i * 0.05),
          unit: 'kg',
          date: date,
          notes: 'Newspapers and cardboard',
          createdAt: date,
        ),
        WasteStats(
          id: '',
          userId: userId,
          wasteType: 'Organic',
          quantity: 1.2 + (i * 0.15),
          unit: 'kg',
          date: date,
          notes: 'Food waste',
          createdAt: date,
        ),
      ]);
    }

    // Add waste entries to Firestore
    for (final entry in wasteEntries) {
      await _firestore.collection('waste_entries').add(entry.toFirestore());
    }

    // Add sample user challenges
    final challenges = [
      UserChallenge(
        id: '',
        userId: userId,
        challengeId: 'challenge_1',
        acceptedAt: now.subtract(const Duration(days: 5)),
        currentProgress: 3,
        isCompleted: false,
        progressEntries: [
          ProgressEntry(
            date: now.subtract(const Duration(days: 4)),
            value: 1,
            note: 'Started the challenge',
          ),
          ProgressEntry(
            date: now.subtract(const Duration(days: 2)),
            value: 2,
            note: 'Made good progress',
          ),
          ProgressEntry(date: now, value: 3, note: 'Continuing well'),
        ],
      ),
      UserChallenge(
        id: '',
        userId: userId,
        challengeId: 'challenge_2',
        acceptedAt: now.subtract(const Duration(days: 10)),
        currentProgress: 7,
        isCompleted: true,
        progressEntries: [
          ProgressEntry(
            date: now.subtract(const Duration(days: 9)),
            value: 2,
            note: 'Initial progress',
          ),
          ProgressEntry(
            date: now.subtract(const Duration(days: 7)),
            value: 5,
            note: 'Halfway there',
          ),
          ProgressEntry(
            date: now.subtract(const Duration(days: 3)),
            value: 7,
            note: 'Completed!',
          ),
        ],
      ),
    ];

    // Add challenges to Firestore
    for (final challenge in challenges) {
      await _firestore
          .collection('user_challenges')
          .add(challenge.toFirestore());
    }
  }
}
