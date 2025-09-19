import 'package:flutter/material.dart';

// Local UI models for the challenges screen
class ChallengeUI {
  final String id;
  final String title;
  final String subtitle;
  final String difficulty;
  final int points;
  final IconData icon;
  final List<Task> tasks;
  final int? duration;
  final int? participants;
  final double? progress;
  final int? daysLeft;
  final String? completionDate;
  final String category;
  final String imageUrl;

  ChallengeUI({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.points,
    required this.icon,
    this.tasks = const [],
    this.duration,
    this.participants,
    this.progress,
    this.daysLeft,
    this.completionDate,
    this.category = 'General',
    this.imageUrl = '',
  });
}

class Task {
  final String description;
  bool isCompleted;

  Task({required this.description, this.isCompleted = false});
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  // State to track which challenges are expanded
  final Map<String, bool> _isExpanded = {};

  // State to track the currently selected tab
  String _selectedTab = 'Active';

  final List<ChallengeUI> _activeChallenges = [
    ChallengeUI(
      id: 'water_conservation',
      title: 'Water Conservation Challenge',
      subtitle: 'Reduce water usage by 20% this month',
      progress: 0.75,
      daysLeft: 5,
      participants: 2156,
      points: 300,
      difficulty: 'Medium',
      icon: Icons.water_drop,
      category: 'Water',
    ),
    ChallengeUI(
      id: 'biodiversity_boost',
      title: 'Biodiversity Boost',
      subtitle: 'Plant 5 native plants in your garden',
      progress: 0.40,
      daysLeft: 10,
      participants: 987,
      points: 200,
      difficulty: 'Easy',
      icon: Icons.nature,
      category: 'Biodiversity',
    ),
    ChallengeUI(
      id: 'eco_transport',
      title: 'Eco-Friendly Transport Challenge',
      subtitle: 'Use public transport or bike for all trips this week',
      progress: 0.60,
      daysLeft: 3,
      participants: 1842,
      points: 250,
      difficulty: 'Medium',
      icon: Icons.directions_bike,
      category: 'Transport',
      tasks: [
        Task(description: 'Plan your route using public transport'),
        Task(description: 'Use bike for short trips under 5km'),
        Task(description: 'Track your carbon savings'),
        Task(description: 'Share your experience with others'),
      ],
    ),
  ];

  final List<ChallengeUI> _availableChallenges = [
    ChallengeUI(
      id: 'community_clean',
      title: 'Community Clean-Up',
      subtitle: 'Organize or join a neighborhood clean-up event',
      duration: 7,
      participants: 1456,
      points: 250,
      difficulty: 'Easy',
      icon: Icons.cleaning_services,
      category: 'Community',
      tasks: [
        Task(description: 'Find or organize a clean-up event'),
        Task(description: 'Gather cleaning supplies'),
        Task(description: 'Participate for at least 2 hours'),
        Task(description: 'Share photos of the event'),
      ],
    ),
    ChallengeUI(
      id: 'sustainable_shopping',
      title: 'Sustainable Shopping Week',
      subtitle: 'Buy only second-hand or eco-friendly items for a week',
      duration: 7,
      participants: 892,
      points: 400,
      difficulty: 'Medium',
      icon: Icons.shopping_bag,
      category: 'Consumption',
      tasks: [
        Task(description: 'Shop at thrift stores or online marketplaces'),
        Task(description: 'Choose products with eco-certifications'),
        Task(description: 'Avoid fast fashion brands'),
        Task(description: 'Track your purchases and savings'),
      ],
    ),
    ChallengeUI(
      id: 'carbon_tracker',
      title: 'Carbon Footprint Tracker',
      subtitle: 'Track and reduce your weekly carbon emissions',
      duration: 14,
      participants: 2341,
      points: 350,
      difficulty: 'Hard',
      icon: Icons.cloud,
      category: 'Climate',
      tasks: [
        Task(description: 'Download a carbon tracking app'),
        Task(description: 'Log daily activities and emissions'),
        Task(description: 'Identify high-emission activities'),
        Task(description: 'Implement reduction strategies'),
      ],
    ),
  ];

  final List<ChallengeUI> _completedChallenges = [
    ChallengeUI(
      id: 'plant_tree',
      title: 'Plant a Tree Month',
      subtitle: 'Plant and care for a tree in your community',
      points: 300,
      completionDate: '8/15/2024',
      difficulty: 'Medium',
      icon: Icons.park,
      category: 'Biodiversity',
      tasks: [
        Task(description: 'Choose a suitable tree species'),
        Task(description: 'Prepare the planting site'),
        Task(description: 'Plant the tree properly'),
        Task(description: 'Water and maintain for 30 days'),
      ],
    ),
    ChallengeUI(
      id: 'recycle_master',
      title: 'Recycle Master Challenge',
      subtitle: 'Achieve 100% recycling rate for a month',
      points: 250,
      completionDate: '7/30/2024',
      difficulty: 'Easy',
      icon: Icons.recycling,
      category: 'Waste',
      tasks: [
        Task(description: 'Sort all recyclables correctly'),
        Task(description: 'Research local recycling guidelines'),
        Task(description: 'Track recycling habits'),
        Task(description: 'Educate family members'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.lightGreen, Colors.white],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Challenges'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Eco Challenges',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Build sustainable habits through fun challenges',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  _buildStatsBar(),
                  const SizedBox(height: 24),
                  _buildChallengeTabs(),
                  const SizedBox(height: 24),
                  if (_selectedTab == 'Active') ...[
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._activeChallenges.map(
                      (challenge) => _buildActiveChallenge(challenge),
                    ),
                  ] else if (_selectedTab == 'Available') ...[
                    const Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAvailableChallengesGrid(),
                  ] else if (_selectedTab == 'Completed') ...[
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._completedChallenges.map(
                      (challenge) => _buildExpandableChallenge(challenge),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.workspace_premium_outlined,
          text: '2,100 points earned',
          color: Colors.white,
        ),
        _StatItem(
          icon: Icons.check_circle_outline,
          text: '7 challenges completed',
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildChallengeTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TabItem(
          title: 'Active',
          isSelected: _selectedTab == 'Active',
          onTap: () {
            setState(() {
              _selectedTab = 'Active';
            });
          },
        ),
        _TabItem(
          title: 'Available',
          isSelected: _selectedTab == 'Available',
          onTap: () {
            setState(() {
              _selectedTab = 'Available';
            });
          },
        ),
        _TabItem(
          title: 'Completed',
          isSelected: _selectedTab == 'Completed',
          onTap: () {
            setState(() {
              _selectedTab = 'Completed';
            });
          },
        ),
      ],
    );
  }

  // --- Widgets to build each challenge card ---

  Widget _buildActiveChallenge(ChallengeUI challenge) {
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
                Flexible(
                  // Wrap the content in a Flexible widget to prevent overflow
                  child: Row(
                    children: [
                      Icon(challenge.icon, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              challenge.subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              challenge.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDifficultyPill(challenge.difficulty),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Progress',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: challenge.progress!,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(challenge.progress! * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  '${challenge.daysLeft} days left',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.participants} participants',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  '${challenge.points} points',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableChallenge(ChallengeUI challenge) {
    final bool isExpanded = _isExpanded[challenge.id] ?? false;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded[challenge.id] = !isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(challenge.icon, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenge.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                challenge.subtitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                challenge.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDifficultyPill(challenge.difficulty),
                ],
              ),
              if (challenge.completionDate == null) ...[
                // For Available challenges
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.duration} days',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.people, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.participants} participants',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle join challenge logic
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Join Challenge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ] else ...[
                // For Completed challenges
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed on ${challenge.completionDate}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child:
                    isExpanded
                        ? _buildTaskList(challenge.tasks)
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(
                    task.isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
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

  Widget _buildDifficultyPill(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAvailableChallengesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _availableChallenges.length,
      itemBuilder: (context, index) {
        final challenge = _availableChallenges[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded[challenge.id] = !_isExpanded[challenge.id]!;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(challenge.icon, color: Colors.green, size: 24),
                      _buildDifficultyPill(challenge.difficulty),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${challenge.points} pts',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${challenge.participants}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  if (_isExpanded[challenge.id] ?? false) ...[
                    const SizedBox(height: 8),
                    ...challenge.tasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Icon(
                              task.isCompleted
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                task.description,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// StatelessWidget for reusable components
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }
}
