import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/challenge_model.dart';
import '../models/waste_stats_model.dart';
import '../models/recipe_model.dart';
import '../models/carbon_entry_model.dart';
import '../models/forum_post_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        .where('name', isLessThan: query + 'z')
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
        (sum, entry) => sum + entry.quantity,
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
            .where('title', isLessThan: query + '\uf8ff')
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

  // Get daily carbon impact for the last N days
  Future<List<Map<String, dynamic>>> getDailyCarbonImpact(
    String userId, {
    int days = 7,
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

    final dailyImpact = <String, double>{};
    for (final doc in snapshot.docs) {
      final entry = CarbonEntry.fromFirestore(doc.data(), doc.id);
      final dateKey =
          entry.date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      dailyImpact[dateKey] = (dailyImpact[dateKey] ?? 0) + entry.carbonImpact;
    }

    // Convert to list of maps for chart data
    final result = <Map<String, dynamic>>[];
    final currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final dateKey = currentDate.toIso8601String().split('T')[0];
      result.add({'date': currentDate, 'impact': dailyImpact[dateKey] ?? 0.0});
      currentDate.add(const Duration(days: 1));
    }

    return result;
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

  // Create a new forum post
  Future<String> createForumPost(ForumPost post) async {
    final docRef = await _firestore.collection('posts').add(post.toFirestore());
    return docRef.id;
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
        .where('title', isLessThan: query + 'z')
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
}
