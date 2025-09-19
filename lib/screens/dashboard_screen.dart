import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/waste_stats_model.dart';
import '../models/challenge_model.dart';
import '../models/carbon_entry_model.dart';
import '../models/forum_post_model.dart';
import '../services/firestore_service.dart';
import 'features/carbon_tracker_screen.dart';
import 'features/challenges_screen.dart';
import 'features/forum_screen.dart';
import 'features/waste_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = 'demo_user_123';

  // Method to add sample data for testing
  Future<void> _addSampleData() async {
    try {
      await _firestoreService.addSampleDashboardData(_currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample data added successfully!')),
        );
        // Refresh the UI
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding sample data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleData,
        backgroundColor: Colors.green,
        tooltip: 'Add Sample Data',
        child: const Icon(Icons.add_chart, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              // Dashboard Title
              Text(
                'Your Impact Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track your progress, monitor your environmental impact, and celebrate your achievements.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 32),
              // Stats Grid
              _StatsGrid(),
              SizedBox(height: 32),
              // Active Challenges Section
              _SectionTitle(title: 'Active Challenges'),
              _ActiveChallenges(),
              SizedBox(height: 32),
              // Recent Actions Section
              _SectionTitle(
                title: 'Recent Actions',
                actionText: 'Add Action',
                onActionPressed: null, // You can add a function here later
              ),
              _RecentActions(),
              const SizedBox(height: 32),
              // Charts Section
              _SectionTitle(title: 'Your Environmental Impact'),
              _ChartsSection(),
              SizedBox(height: 32),

              // Waste Tracking Section
              _SectionTitle(
                title: 'Waste Reduction Progress',
                actionText: 'Track Waste',
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WasteTrackerScreen(),
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WasteTrackerScreen(),
                    ),
                  );
                },
                child: _WasteTrackingSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable widget for section titles with optional action text
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const _SectionTitle({
    required this.title,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Grid for displaying key statistics with real data
class _StatsGrid extends StatefulWidget {
  const _StatsGrid();

  @override
  State<_StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends State<_StatsGrid> {
  final FirestoreService _firestoreService = FirestoreService();
  // Get userId from parent widget
  String get _currentUserId =>
      (context.findAncestorStateOfType<_DashboardScreenState>())!
          ._currentUserId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCombinedStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? {};

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              icon: Icons.eco,
              value: '${stats['totalCarbon']?.toStringAsFixed(1) ?? '0.0'} kg',
              label: 'Carbon Footprint',
              change: stats['carbonChange'] ?? '0%',
              iconColor: Colors.green,
              changeColor:
                  stats['carbonChange']?.startsWith('-') == true
                      ? Colors.green
                      : Colors.red,
            ),
            _StatCard(
              icon: Icons.local_activity,
              value: '${stats['totalActions'] ?? 0}',
              label: 'Eco Actions',
              change: '+${stats['actionsChange'] ?? 0}',
              iconColor: Colors.blue,
              changeColor: Colors.green,
            ),
            _StatCard(
              icon: Icons.person,
              value: '${stats['totalPoints'] ?? 0}',
              label: 'Points Earned',
              change: '+${stats['pointsChange'] ?? 0}',
              iconColor: Colors.purple,
              changeColor: Colors.green,
            ),
            _StatCard(
              icon: Icons.calendar_today,
              value: '${stats['daysActive'] ?? 0}',
              label: 'Days Active',
              change: '+${stats['daysChange'] ?? 0}',
              iconColor: Colors.orange,
              changeColor: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getCombinedStats() async {
    try {
      // Get carbon data
      final carbonData = await _firestoreService.getDailyCarbonImpact(
        _currentUserId,
        days: 30,
      );
      final totalCarbon = carbonData.fold<double>(
        0,
        (sum, entry) => sum + (entry['impact'] as double),
      );

      // Get waste data
      await _firestoreService.getTotalWasteReduced(_currentUserId);

      // Get challenge data
      final userChallenges =
          await _firestoreService.getUserChallenges(_currentUserId).first;
      final completedChallenges =
          userChallenges.where((c) => c.isCompleted).length;
      final totalPoints = userChallenges.fold<int>(
        0,
        (sum, c) => sum + (c.isCompleted ? 100 : 50),
      );

      // Get forum data
      final forumPosts = await _firestoreService.getForumPosts().first;
      final userPosts =
          forumPosts.where((post) => post.userId == _currentUserId).length;

      return {
        'totalCarbon': totalCarbon,
        'carbonChange': '-12%', // Mock change calculation
        'totalActions': completedChallenges + userPosts,
        'actionsChange': 5,
        'totalPoints': totalPoints,
        'pointsChange': 120,
        'daysActive': 28,
        'daysChange': 3,
      };
    } catch (e) {
      return {};
    }
  }
}

// Reusable widget for a single statistic card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String change;
  final Color iconColor;
  final Color changeColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.change,
    required this.iconColor,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// Comprehensive Charts Section
class _ChartsSection extends StatefulWidget {
  const _ChartsSection();

  @override
  State<_ChartsSection> createState() => _ChartsSectionState();
}

class _ChartsSectionState extends State<_ChartsSection> {
  final FirestoreService _firestoreService = FirestoreService();
  // Get userId from parent widget
  String get _currentUserId =>
      (context.findAncestorStateOfType<_DashboardScreenState>())!
          ._currentUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carbon Footprint Chart
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Carbon Footprint Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CarbonTrackerPage(),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: SizedBox(
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
                              child: Text('No carbon data available'),
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
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Activity Breakdown Pie Chart
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: FutureBuilder<Map<String, double>>(
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

                      final sections =
                          data.entries.map((entry) {
                            final activityType =
                                CarbonCalculator.getActivityType(entry.key);
                            final color = activityType?.color ?? Colors.grey;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${entry.value.toStringAsFixed(1)}kg',
                              color: color,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList();

                      return PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                FutureBuilder<Map<String, double>>(
                  future: _firestoreService.getCarbonImpactByActivityType(
                    _currentUserId,
                  ),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {};
                    return Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children:
                          data.entries.map((entry) {
                            final activityType =
                                CarbonCalculator.getActivityType(entry.key);
                            final color = activityType?.color ?? Colors.grey;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Combined Environmental Impact Overview
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Environmental Impact Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: _getCombinedImpactData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data ?? {};
                    final carbonData =
                        data['carbon'] as List<Map<String, dynamic>>? ?? [];
                    final wasteData =
                        data['waste'] as List<Map<String, dynamic>>? ?? [];
                    final challengeData =
                        data['challenges'] as List<Map<String, dynamic>>? ?? [];

                    if (carbonData.isEmpty &&
                        wasteData.isEmpty &&
                        challengeData.isEmpty) {
                      return const Center(
                        child: Text('No environmental data available'),
                      );
                    }

                    return SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < 7) {
                                    final days = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    return Text(
                                      days[value.toInt()],
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
                                reservedSize: 50,
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
                            // Carbon Footprint Line
                            if (carbonData.isNotEmpty)
                              LineChartBarData(
                                spots:
                                    carbonData.asMap().entries.map((entry) {
                                      return FlSpot(
                                        entry.key.toDouble(),
                                        entry.value['value'] as double,
                                      );
                                    }).toList(),
                                isCurved: true,
                                color: Colors.red,
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.red.withOpacity(0.1),
                                ),
                                dotData: FlDotData(show: true),
                              ),
                            // Waste Reduction Line
                            if (wasteData.isNotEmpty)
                              LineChartBarData(
                                spots:
                                    wasteData.asMap().entries.map((entry) {
                                      return FlSpot(
                                        entry.key.toDouble(),
                                        entry.value['value'] as double,
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
                            // Challenge Progress Line
                            if (challengeData.isNotEmpty)
                              LineChartBarData(
                                spots:
                                    challengeData.asMap().entries.map((entry) {
                                      return FlSpot(
                                        entry.key.toDouble(),
                                        entry.value['value'] as double,
                                      );
                                    }).toList(),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.1),
                                ),
                                dotData: FlDotData(show: true),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Carbon (kg)', Colors.red),
                    const SizedBox(width: 16),
                    _buildLegendItem('Waste (kg)', Colors.green),
                    const SizedBox(width: 16),
                    _buildLegendItem('Challenges', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Challenge Progress Chart
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Challenge Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<UserChallenge>>(
                  stream: _firestoreService.getUserChallenges(_currentUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final userChallenges = snapshot.data ?? [];
                    if (userChallenges.isEmpty) {
                      return const Center(child: Text('No active challenges'));
                    }

                    final completed =
                        userChallenges.where((c) => c.isCompleted).length;
                    final active = userChallenges.length - completed;

                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ChallengesScreen(),
                                ),
                              );
                            },
                            child: _buildChallengeMetricCard(
                              'Active',
                              active.toString(),
                              Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ChallengesScreen(),
                                ),
                              );
                            },
                            child: _buildChallengeMetricCard(
                              'Completed',
                              completed.toString(),
                              Colors.green,
                            ),
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

        const SizedBox(height: 16),

        // Progress Tracking Over Time
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress Tracking (30 Days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, List<FlSpot>>>(
                  future: _getProgressTrackingData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data ?? {};
                    final carbonSpots = data['carbon'] ?? [];
                    final wasteSpots = data['waste'] ?? [];
                    final pointsSpots = data['points'] ?? [];

                    if (carbonSpots.isEmpty &&
                        wasteSpots.isEmpty &&
                        pointsSpots.isEmpty) {
                      return const Center(
                        child: Text('No progress data available'),
                      );
                    }

                    return SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() % 7 == 0) {
                                    return Text(
                                      'Day ${value.toInt() + 1}',
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
                                reservedSize: 50,
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
                            // Carbon emissions over time
                            if (carbonSpots.isNotEmpty)
                              LineChartBarData(
                                spots: carbonSpots,
                                isCurved: true,
                                color: Colors.red,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.red.withOpacity(0.1),
                                ),
                              ),
                            // Waste reduction over time
                            if (wasteSpots.isNotEmpty)
                              LineChartBarData(
                                spots: wasteSpots,
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withOpacity(0.1),
                                ),
                              ),
                            // Points earned over time
                            if (pointsSpots.isNotEmpty)
                              LineChartBarData(
                                spots: pointsSpots,
                                isCurved: true,
                                color: Colors.purple,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.purple.withOpacity(0.1),
                                ),
                              ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  String label;
                                  if (spot.barIndex == 0) {
                                    label =
                                        'Carbon: ${spot.y.toStringAsFixed(1)}kg';
                                  } else if (spot.barIndex == 1) {
                                    label =
                                        'Waste: ${spot.y.toStringAsFixed(1)}kg';
                                  } else {
                                    label = 'Points: ${spot.y.toInt()}';
                                  }
                                  return LineTooltipItem(
                                    label,
                                    const TextStyle(color: Colors.white),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Progress Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Carbon (kg)', Colors.red),
                    const SizedBox(width: 20),
                    _buildLegendItem('Waste Saved (kg)', Colors.green),
                    const SizedBox(width: 20),
                    _buildLegendItem('Points Earned', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Forum Engagement
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Engagement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<ForumPost>>(
                  stream: _firestoreService.getForumPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data ?? [];
                    final userPosts =
                        posts
                            .where((post) => post.userId == _currentUserId)
                            .length;
                    final totalComments = posts.fold(
                      0,
                      (sum, post) => sum + post.commentCount,
                    );

                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForumScreen(),
                                ),
                              );
                            },
                            child: _buildEngagementCard(
                              'Your Posts',
                              userPosts.toString(),
                              Icons.post_add,
                              Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForumScreen(),
                                ),
                              );
                            },
                            child: _buildEngagementCard(
                              'Comments',
                              totalComments.toString(),
                              Icons.comment,
                              Colors.purple,
                            ),
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
    );
  }

  Widget _buildChallengeMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getCombinedImpactData() async {
    try {
      // Get carbon data for the last 7 days
      final carbonData = await _firestoreService.getDailyCarbonImpact(
        _currentUserId,
        days: 7,
      );

      // Get waste data (mock data for now)
      final wasteData = List.generate(
        7,
        (index) => {
          'value': (index + 1) * 0.5, // Mock waste reduction data
        },
      );

      // Get challenge progress data
      final userChallenges =
          await _firestoreService.getUserChallenges(_currentUserId).first;
      final challengeData = List.generate(
        7,
        (index) => {
          'value':
              userChallenges.isNotEmpty
                  ? userChallenges.length * (index + 1) * 0.1
                  : 0.0,
        },
      );

      return {
        'carbon': carbonData,
        'waste': wasteData,
        'challenges': challengeData,
      };
    } catch (e) {
      return {};
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<Map<String, List<FlSpot>>> _getProgressTrackingData() async {
    try {
      // Get carbon data for the last 30 days
      final carbonData = await _firestoreService.getDailyCarbonImpact(
        _currentUserId,
        days: 30,
      );

      // Get waste data (mock data for now - in real app, you'd track this over time)
      final wasteSpots = List.generate(
        30,
        (index) => FlSpot(
          index.toDouble(),
          (index + 1) * 0.3, // Mock cumulative waste reduction
        ),
      );

      // Get points earned over time (mock data)
      final pointsSpots = List.generate(
        30,
        (index) => FlSpot(
          index.toDouble(),
          (index + 1) * 8.5, // Mock cumulative points
        ),
      );

      // Convert carbon data to FlSpot format
      final carbonSpots =
          carbonData.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value['impact'] as double,
            );
          }).toList();

      return {
        'carbon': carbonSpots,
        'waste': wasteSpots,
        'points': pointsSpots,
      };
    } catch (e) {
      return {};
    }
  }
}

// Waste tracking section with statistics and charts
class _WasteTrackingSection extends StatefulWidget {
  const _WasteTrackingSection();

  @override
  State<_WasteTrackingSection> createState() => _WasteTrackingSectionState();
}

class _WasteTrackingSectionState extends State<_WasteTrackingSection> {
  final FirestoreService _firestoreService = FirestoreService();
  // Get userId from parent widget
  String get _currentUserId =>
      (context.findAncestorStateOfType<_DashboardScreenState>())!
          ._currentUserId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Waste Summary Stats
            FutureBuilder<List<WasteSummary>>(
              future: _firestoreService.getWasteSummaryByType(_currentUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading waste data');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final summaries = snapshot.data ?? [];

                if (summaries.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No waste data yet. Start tracking your waste reduction!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Total Waste Reduced
                    FutureBuilder<double>(
                      future: _firestoreService.getTotalWasteReduced(
                        _currentUserId,
                      ),
                      builder: (context, totalSnapshot) {
                        final total = totalSnapshot.data ?? 0.0;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Waste Reduced',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Keep up the great work!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${total.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Waste Type Breakdown
                    const Text(
                      'Waste by Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...summaries.map((summary) {
                      final color = Color(
                        WasteStats.wasteTypeColors[summary.wasteType] ??
                            0xFF2196F3,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                summary.wasteTypeDisplayName,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${summary.totalQuantity.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Waste Type Bar Chart
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              summaries.isNotEmpty
                                  ? summaries
                                          .map((s) => s.totalQuantity)
                                          .reduce((a, b) => a > b ? a : b) *
                                      1.2
                                  : 10,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                final summary = summaries[groupIndex];
                                return BarTooltipItem(
                                  '${summary.wasteTypeDisplayName}\n${rod.toY.toStringAsFixed(1)} kg',
                                  const TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < summaries.length) {
                                    final summary = summaries[value.toInt()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        summary.wasteTypeDisplayName.length > 6
                                            ? '${summary.wasteTypeDisplayName.substring(0, 6)}...'
                                            : summary.wasteTypeDisplayName,
                                        style: const TextStyle(fontSize: 10),
                                      ),
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
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          barGroups:
                              summaries.asMap().entries.map((entry) {
                                final index = entry.key;
                                final summary = entry.value;
                                final color = Color(
                                  WasteStats.wasteTypeColors[summary
                                          .wasteType] ??
                                      0xFF2196F3,
                                );

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: summary.totalQuantity,
                                      color: color,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Section for active challenges
class _ActiveChallenges extends StatelessWidget {
  const _ActiveChallenges();

  @override
  Widget build(BuildContext context) {
    // Active challenges data matching the challenges screen
    final activeChallenges = [
      {
        'title': 'Water Conservation Challenge',
        'progress': 0.75,
        'level': 'Medium',
        'daysLeft': '5 days left',
        'category': 'Water',
        'icon': Icons.water_drop,
      },
      {
        'title': 'Biodiversity Boost',
        'progress': 0.40,
        'level': 'Easy',
        'daysLeft': '10 days left',
        'category': 'Biodiversity',
        'icon': Icons.nature,
      },
      {
        'title': 'Eco-Friendly Transport Challenge',
        'progress': 0.60,
        'level': 'Medium',
        'daysLeft': '3 days left',
        'category': 'Transport',
        'icon': Icons.directions_bike,
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Active Challenges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...activeChallenges.map((challenge) {
              return Column(
                children: [
                  _ChallengeItem(
                    title: challenge['title'] as String,
                    progress: challenge['progress'] as double,
                    level: challenge['level'] as String,
                    daysLeft: challenge['daysLeft'] as String,
                    category: challenge['category'] as String,
                    icon: challenge['icon'] as IconData,
                  ),
                  if (challenge != activeChallenges.last) const Divider(),
                ],
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChallengesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('View All Challenges'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for a single challenge item
class _ChallengeItem extends StatelessWidget {
  final String title;
  final double progress;
  final String level;
  final String daysLeft;
  final String? category;
  final IconData? icon;

  const _ChallengeItem({
    required this.title,
    required this.progress,
    required this.level,
    required this.daysLeft,
    this.category,
    this.icon,
  });

  Color _getLevelColor() {
    switch (level) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: _getLevelColor(), size: 20),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: _getLevelColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (category != null) ...[
            const SizedBox(height: 4),
            Text(
              category!,
              style: TextStyle(
                fontSize: 12,
                color: _getLevelColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor()),
          ),
          const SizedBox(height: 8),
          Text(
            daysLeft,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// Section for recent actions
class _RecentActions extends StatelessWidget {
  const _RecentActions();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ActionItem(
              icon: Icons.water_drop,
              text: 'Used reusable water bottle',
              time: '2 hours ago',
              points: '+15 pts',
            ),
            Divider(),
            _ActionItem(
              icon: Icons.directions_walk,
              text: 'Walked instead of driving',
              time: '5 hours ago',
              points: '+25 pts',
            ),
            Divider(),
            _ActionItem(
              icon: Icons.eco,
              text: 'Bought organic vegetables',
              time: '1 day ago',
              points: '+20 pts',
            ),
            Divider(),
            _ActionItem(
              icon: Icons.shower,
              text: 'Reduced shower time',
              time: '1 day ago',
              points: '+10 pts',
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for a single action item
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;
  final String points;

  const _ActionItem({
    required this.icon,
    required this.text,
    required this.time,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
