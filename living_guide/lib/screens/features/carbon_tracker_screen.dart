// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/carbon_entry_model.dart';
import '../../services/firestore_service.dart';

class CarbonTrackerPage extends StatefulWidget {
  const CarbonTrackerPage({super.key});

  @override
  State<CarbonTrackerPage> createState() => _CarbonTrackerPageState();
}

class _CarbonTrackerPageState extends State<CarbonTrackerPage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  // Form controllers
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form state
  String _selectedActivityType = 'Transportation';
  String _selectedActivityOption = '';
  DateTime _selectedDate = DateTime.now();

  // For demo purposes, using a mock user ID
  final String _currentUserId = 'demo_user_123';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Set default activity option
    if (CarbonCalculator.activityTypes.isNotEmpty) {
      final firstType = CarbonCalculator.activityTypes.first;
      _selectedActivityOption = firstType.options.first.name;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addCarbonEntry() async {
    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a quantity')));
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    // Calculate carbon impact
    final carbonImpact = CarbonCalculator.calculateCarbonImpact(
      _selectedActivityType,
      _selectedActivityOption,
      quantity,
    );

    final activityType = CarbonCalculator.getActivityType(
      _selectedActivityType,
    );
    final activityOption = CarbonCalculator.getActivityOption(
      _selectedActivityType,
      _selectedActivityOption,
    );

    if (activityType == null || activityOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid activity selection')),
      );
      return;
    }

    final entry = CarbonEntry(
      id: '',
      userId: _currentUserId,
      activityType: _selectedActivityType,
      activityDescription: _selectedActivityOption,
      quantity: quantity,
      unit: activityOption.unit,
      carbonImpact: carbonImpact,
      date: _selectedDate,
      createdAt: DateTime.now(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      await _firestoreService.addCarbonEntry(entry);

      // Clear form
      _quantityController.clear();
      _notesController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Activity logged! ${carbonImpact.toStringAsFixed(2)} kg CO₂',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging activity: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint Tracker'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Log Activity'),
            Tab(text: 'History'),
            Tab(text: 'Charts'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityForm(),
          _buildHistoryView(),
          _buildChartsView(),
        ],
      ),
    );
  }

  Widget _buildActivityForm() {
    final selectedType = CarbonCalculator.getActivityType(
      _selectedActivityType,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Log Your Daily Activities',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your carbon footprint by logging your daily activities.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Activity Type Selection
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        CarbonCalculator.activityTypes.map((type) {
                          final isSelected = type.name == _selectedActivityType;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type.icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : type.color,
                                ),
                                const SizedBox(width: 4),
                                Text(type.name),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedActivityType = type.name;
                                  _selectedActivityOption =
                                      type.options.first.name;
                                });
                              }
                            },
                            selectedColor: type.color,
                            backgroundColor: type.color.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Activity Details
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedType Activity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity Option Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedActivityOption,
                    decoration: const InputDecoration(
                      labelText: 'Specific Activity',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        selectedType?.options.map((option) {
                          return DropdownMenuItem(
                            value: option.name,
                            child: Text(option.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityOption = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Quantity Input
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter amount',
                      border: const OutlineInputBorder(),
                      suffixText:
                          selectedType?.options
                              .firstWhere(
                                (opt) => opt.name == _selectedActivityOption,
                              )
                              .unit ??
                          '',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date Picker
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Add any additional notes...',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Carbon Impact Preview
                  if (_quantityController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Estimated CO₂ Impact: ${CarbonCalculator.calculateCarbonImpact(_selectedActivityType, _selectedActivityOption, double.tryParse(_quantityController.text) ?? 0).toStringAsFixed(2)} kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Log Activity Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addCarbonEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Log Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Column(
      children: [
        // Summary Cards
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.withOpacity(0.1),
          child: FutureBuilder<Map<String, double>>(
            future: _firestoreService.getCarbonImpactByActivityType(
              _currentUserId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final impactByType = snapshot.data ?? {};
              final totalImpact = impactByType.values.fold(
                0.0,
                (sum, value) => sum + value,
              );

              return Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total CO₂',
                      '${totalImpact.toStringAsFixed(1)} kg',
                      Icons.eco,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Activities',
                      '${impactByType.length}',
                      Icons.track_changes,
                      Colors.blue,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Activity History
        Expanded(
          child: StreamBuilder<List<CarbonEntry>>(
            stream: _firestoreService.getUserCarbonEntries(_currentUserId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = snapshot.data ?? [];

              if (entries.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No activities logged yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start tracking your carbon footprint!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: entry.activityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          entry.activityIcon,
                          color: entry.activityColor,
                        ),
                      ),
                      title: Text(
                        '${entry.activityDescription} - ${entry.quantity} ${entry.unit}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                          ),
                          Text(
                            '${entry.carbonImpact.toStringAsFixed(2)} kg CO₂',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing:
                          entry.notes != null
                              ? const Icon(Icons.note, color: Colors.grey)
                              : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Carbon Footprint Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visualize your environmental impact over time.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Daily Impact Chart
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Carbon Impact (Last 7 Days)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _firestoreService.getDailyCarbonImpact(
                        _currentUserId,
                        days: 7,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final data = snapshot.data ?? [];
                        if (data.isEmpty) {
                          return const Center(
                            child: Text('No data available for chart'),
                          );
                        }

                        return LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < data.length) {
                                      final date =
                                          data[value.toInt()]['date']
                                              as DateTime;
                                      return Text(
                                        '${date.month}/${date.day}',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots:
                                    data.asMap().entries.map((entry) {
                                      return FlSpot(
                                        entry.key.toDouble(),
                                        entry.value['impact'] as double,
                                      );
                                    }).toList(),
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withOpacity(0.1),
                                ),
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Activity Type Breakdown
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carbon Impact by Activity Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, double>>(
                    future: _firestoreService.getCarbonImpactByActivityType(
                      _currentUserId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data ?? {};
                      if (data.isEmpty) {
                        return const Center(
                          child: Text('No activity data available'),
                        );
                      }

                      final total = data.values.fold(
                        0.0,
                        (sum, value) => sum + value,
                      );

                      return Column(
                        children:
                            data.entries.map((entry) {
                              final percentage =
                                  total > 0 ? (entry.value / total * 100) : 0.0;
                              final activityType =
                                  CarbonCalculator.getActivityType(entry.key);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              activityType?.icon ?? Icons.eco,
                                              color:
                                                  activityType?.color ??
                                                  Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              entry.key,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${entry.value.toStringAsFixed(1)} kg',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        activityType?.color ?? Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Summary
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _firestoreService.getDailyCarbonImpact(
                      _currentUserId,
                      days: 7,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data ?? [];
                      final totalWeekly = data.fold(
                        0.0,
                        (sum, day) => sum + (day['impact'] as double),
                      );
                      final averageDaily =
                          data.isNotEmpty ? totalWeekly / data.length : 0.0;

                      return Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Total This Week',
                              '${totalWeekly.toStringAsFixed(1)} kg',
                              Icons.eco,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              'Daily Average',
                              '${averageDaily.toStringAsFixed(1)} kg',
                              Icons.trending_up,
                              Colors.blue,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
