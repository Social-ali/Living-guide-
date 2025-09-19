import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';
import '../../services/firestore_service.dart';
import 'recipes_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _selectedDate = DateTime.now();

  // For demo purposes, using a mock user ID
  final String _currentUserId = 'demo_user_123';

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    _formatDate(_selectedDate),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Meal Plan
          Expanded(
            child: StreamBuilder<MealPlan?>(
              stream: Stream.fromFuture(
                _firestoreService.getMealPlan(_currentUserId, _selectedDate),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mealPlan = snapshot.data;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children:
                      _mealTypes.map((mealType) {
                        final mealItems =
                            mealPlan?.meals
                                .where((meal) => meal.mealType == mealType)
                                .toList() ??
                            [];

                        return _buildMealSection(mealType, mealItems);
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipeDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealSection(String mealType, List<MealPlanItem> mealItems) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Type Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  onPressed: () => _addRecipeToMeal(mealType),
                  icon: const Icon(Icons.add),
                  color: Colors.green,
                  tooltip: 'Add recipe',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Meal Items
            if (mealItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No meals planned yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...mealItems.map((item) => _buildMealItem(item, mealType)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(MealPlanItem item, String mealType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Recipe Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.recipeTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.servings} serving${item.servings > 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                onPressed: () => _editMealItem(item, mealType),
                icon: const Icon(Icons.edit),
                iconSize: 20,
                color: Colors.blue,
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _removeMealItem(item, mealType),
                icon: const Icon(Icons.delete),
                iconSize: 20,
                color: Colors.red,
                tooltip: 'Remove',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addRecipeToMeal(String mealType) async {
    // Navigate to recipes screen to select a recipe
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecipesScreen()),
    );

    // If a recipe was selected, add it to the meal plan
    if (result != null && result is Recipe) {
      final mealItem = MealPlanItem(
        mealType: mealType,
        recipeId: result.id,
        recipeTitle: result.title,
        servings: 1,
      );

      try {
        await _firestoreService.addRecipeToMealPlan(
          _currentUserId,
          _selectedDate,
          mealItem,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.title} added to $mealType!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding recipe: $e')));
        }
      }
    }
  }

  Future<void> _showAddRecipeDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecipesScreen()),
    );

    if (result != null && result is Recipe) {
      _showMealTypeSelectionDialog(result);
    }
  }

  void _showMealTypeSelectionDialog(Recipe recipe) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Meal Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _mealTypes.map((mealType) {
                    return ListTile(
                      title: Text(mealType.toUpperCase()),
                      onTap: () async {
                        Navigator.of(context).pop();

                        final mealItem = MealPlanItem(
                          mealType: mealType,
                          recipeId: recipe.id,
                          recipeTitle: recipe.title,
                          servings: 1,
                        );

                        try {
                          await _firestoreService.addRecipeToMealPlan(
                            _currentUserId,
                            _selectedDate,
                            mealItem,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${recipe.title} added to $mealType!',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error adding recipe: $e'),
                              ),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Future<void> _editMealItem(MealPlanItem item, String mealType) async {
    final TextEditingController servingsController = TextEditingController(
      text: item.servings.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Meal'),
            content: TextField(
              controller: servingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of servings',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final servings = int.tryParse(servingsController.text) ?? 1;
                  Navigator.of(context).pop(servings);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (result != null && result != item.servings) {
      // Remove old item and add new one with updated servings
      await _removeMealItem(item, mealType);

      final updatedItem = MealPlanItem(
        mealType: mealType,
        recipeId: item.recipeId,
        recipeTitle: item.recipeTitle,
        servings: result,
      );

      await _firestoreService.addRecipeToMealPlan(
        _currentUserId,
        _selectedDate,
        updatedItem,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Meal updated!')));
      }
    }
  }

  Future<void> _removeMealItem(MealPlanItem item, String mealType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Meal'),
            content: Text('Remove "${item.recipeTitle}" from your meal plan?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        // Get the current meal plan to find the mealPlanId
        final mealPlan = await _firestoreService.getMealPlan(
          _currentUserId,
          _selectedDate,
        );
        if (mealPlan != null) {
          await _firestoreService.removeRecipeFromMealPlan(
            mealPlan.id,
            mealType,
            item.recipeId,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meal removed from plan')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meal plan not found')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error removing meal: $e')));
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
