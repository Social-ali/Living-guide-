import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/firestore_service.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isPlantBased = false;
  bool _isOrganic = false;
  bool _isLocal = false;
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  List<String> _categories = ['All'];

  // For demo purposes, using a mock user ID
  final String _currentUserId = 'demo_user_123';

  // Favorites state
  Set<String> _favoriteRecipeIds = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFavorites();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _firestoreService.getRecipeCategories();
      setState(() {
        _categories = ['All', ...categories];
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _firestoreService.getFavoriteRecipeIds(
        _currentUserId,
      );
      setState(() {
        _favoriteRecipeIds = favorites.toSet();
      });
    } catch (e) {
      // Handle error
    }
  }

  bool _isFavorite(String recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final isCurrentlyFavorite = _isFavorite(recipe.id);

    try {
      if (isCurrentlyFavorite) {
        await _firestoreService.removeRecipeFromFavorites(
          _currentUserId,
          recipe.id,
        );
        setState(() {
          _favoriteRecipeIds.remove(recipe.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${recipe.title} removed from favorites')),
          );
        }
      } else {
        await _firestoreService.addRecipeToFavorites(_currentUserId, recipe.id);
        setState(() {
          _favoriteRecipeIds.add(recipe.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${recipe.title} added to favorites')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));
      }
    }
  }

  Future<void> _addSampleRecipes() async {
    try {
      await _firestoreService.addSampleRecipes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample recipes added successfully!')),
        );
      }
      // Refresh the recipes list
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding sample recipes: $e')),
        );
      }
    }
  }

  Stream<List<Recipe>> _getFilteredRecipes() {
    if (_searchQuery.isNotEmpty) {
      // For search, we'll use a different approach since Firestore search is limited
      return _firestoreService.getRecipes();
    }

    return _firestoreService.getFilteredRecipes(
      isPlantBased: _isPlantBased ? true : null,
      isOrganic: _isOrganic ? true : null,
      isLocal: _isLocal ? true : null,
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      difficulty: _selectedDifficulty != 'All' ? _selectedDifficulty : null,
    );
  }

  List<Recipe> _filterRecipesBySearch(List<Recipe> recipes) {
    if (_searchQuery.isEmpty) return recipes;

    final query = _searchQuery.toLowerCase();
    return recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(query) ||
          recipe.description.toLowerCase().contains(query) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(query),
          ) ||
          recipe.dietaryTags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _addToMealPlan(Recipe recipe, String mealType) async {
    final mealItem = MealPlanItem(
      mealType: mealType,
      recipeId: recipe.id,
      recipeTitle: recipe.title,
      servings: 1,
    );

    try {
      await _firestoreService.addRecipeToMealPlan(
        _currentUserId,
        DateTime.now(),
        mealItem,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${recipe.title} added to $mealType!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to meal plan: $e')),
        );
      }
    }
  }

  void _showMealTypeDialog(Recipe recipe) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add to Meal Plan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Breakfast'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addToMealPlan(recipe, 'breakfast');
                  },
                ),
                ListTile(
                  title: const Text('Lunch'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addToMealPlan(recipe, 'lunch');
                  },
                ),
                ListTile(
                  title: const Text('Dinner'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addToMealPlan(recipe, 'dinner');
                  },
                ),
                ListTile(
                  title: const Text('Snack'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addToMealPlan(recipe, 'snack');
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes & Meal Planner'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSampleRecipes,
            tooltip: 'Add Sample Recipes',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active Filters
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_isPlantBased)
                    Chip(
                      label: const Text('Plant-based'),
                      onDeleted: () => setState(() => _isPlantBased = false),
                    ),
                  if (_isOrganic)
                    Chip(
                      label: const Text('Organic'),
                      onDeleted: () => setState(() => _isOrganic = false),
                    ),
                  if (_isLocal)
                    Chip(
                      label: const Text('Local'),
                      onDeleted: () => setState(() => _isLocal = false),
                    ),
                  if (_selectedCategory != 'All')
                    Chip(
                      label: Text(_selectedCategory),
                      onDeleted:
                          () => setState(() => _selectedCategory = 'All'),
                    ),
                  if (_selectedDifficulty != 'All')
                    Chip(
                      label: Text(_selectedDifficulty),
                      onDeleted:
                          () => setState(() => _selectedDifficulty = 'All'),
                    ),
                ],
              ),
            ),

          // Recipes List
          Expanded(
            child: StreamBuilder<List<Recipe>>(
              stream: _getFilteredRecipes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recipes = _filterRecipesBySearch(snapshot.data ?? []);

                if (recipes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No recipes found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return _buildRecipeCard(recipe);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.grey[300],
            ),
            child:
                recipe.imageUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                    : const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.grey,
                    ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Difficulty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: recipe.difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe.difficulty,
                        style: TextStyle(
                          color: recipe.difficultyColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  recipe.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Recipe Info
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      recipe.totalTimeFormatted,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.servings} servings',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.eco, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.carbonFootprint.toStringAsFixed(1)} kg CO₂',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filter Tags
                Wrap(
                  spacing: 6,
                  children:
                      recipe.filterTags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.green[50],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showMealTypeDialog(recipe),
                        icon: const Icon(Icons.add),
                        label: const Text('Add to Meal Plan'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _toggleFavorite(recipe),
                      icon: Icon(
                        _isFavorite(recipe.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: _isFavorite(recipe.id) ? Colors.red : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _isPlantBased ||
        _isOrganic ||
        _isLocal ||
        _selectedCategory != 'All' ||
        _selectedDifficulty != 'All';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Filter Recipes'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dietary Filters
                        const Text(
                          'Dietary Preferences',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        CheckboxListTile(
                          title: const Text('Plant-based'),
                          value: _isPlantBased,
                          onChanged: (value) {
                            setState(() => _isPlantBased = value ?? false);
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Organic'),
                          value: _isOrganic,
                          onChanged: (value) {
                            setState(() => _isOrganic = value ?? false);
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Local'),
                          value: _isLocal,
                          onChanged: (value) {
                            setState(() => _isLocal = value ?? false);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Category Filter
                        const Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items:
                              _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategory = value!);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Difficulty Filter
                        const Text(
                          'Difficulty',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedDifficulty,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All')),
                            DropdownMenuItem(
                              value: 'Easy',
                              child: Text('Easy'),
                            ),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'Hard',
                              child: Text('Hard'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedDifficulty = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isPlantBased = false;
                          _isOrganic = false;
                          _isLocal = false;
                          _selectedCategory = 'All';
                          _selectedDifficulty = 'All';
                        });
                        this.setState(() {});
                      },
                      child: const Text('Clear All'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        this.setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
