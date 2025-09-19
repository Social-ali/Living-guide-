import 'package:flutter/material.dart';

// Challenge data models to make the code more manageable
class Challenge {
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

  Challenge({
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

  final List<Challenge> _activeChallenges = [
    Challenge(
      id: 'plastic_free',
      title: 'Plastic-Free Week',
      subtitle: 'Avoid single-use plastics for 7 consecutive days',
      progress: 0.65,
      daysLeft: 3,
      participants: 1247,
      points: 250,
      difficulty: 'Medium',
      icon: Icons.recycling,
    ),
    Challenge(
      id: 'walk_to_work',
      title: 'Walk to Work',
      subtitle: 'Walk or cycle to work for 5 days this week',
      progress: 0.80,
      daysLeft: 2,
      participants: 892,
      points: 150,
      difficulty: 'Easy',
      icon: Icons.directions_walk,
    ),
  ];

  final List<Challenge> _availableChallenges = [
    Challenge(
      id: 'energy_saver',
      title: 'Energy Saver Challenge',
      subtitle: 'Reduce home energy consumption by 20% this month',
      duration: 30,
      participants: 756,
      points: 300,
      difficulty: 'Medium',
      icon: Icons.lightbulb_outline,
      tasks: [
        Task(description: 'Unplug electronics when not in use'),
        Task(description: 'Use energy-efficient light bulbs'),
        Task(description: 'Turn off lights when leaving a room'),
        Task(description: 'Wash clothes with cold water'),
      ],
    ),
    Challenge(
      id: 'zero_waste',
      title: 'Zero Waste Weekend',
      subtitle: 'Produce zero waste for an entire weekend',
      duration: 2,
      participants: 234,
      points: 500,
      difficulty: 'Hard',
      icon: Icons.delete_sweep_outlined,
      tasks: [
        Task(description: 'Use reusable containers for food'),
        Task(description: 'Bring a reusable coffee cup'),
        Task(description: 'Refuse single-use cutlery'),
      ],
    ),
  ];

  final List<Challenge> _completedChallenges = [
    Challenge(
      id: 'meatless_monday',
      title: 'Meatless Monday',
      subtitle: 'No meat on Mondays for 4 weeks',
      points: 180,
      completionDate: '2/15/2024',
      difficulty: 'Easy',
      icon: Icons.restaurant,
      tasks: [
        Task(description: 'Cook a meatless meal for dinner'),
        Task(description: 'Pack a vegetarian lunch'),
        Task(description: 'Share a meatless recipe with a friend'),
        Task(description: 'Try a new plant-based protein source'),
      ],
    ),
    Challenge(
      id: 'bike_to_work',
      title: 'Bike to Work Week',
      subtitle: 'Cycle to work every day for a week',
      points: 220,
      completionDate: '2/8/2024',
      difficulty: 'Medium',
      icon: Icons.directions_bike,
      tasks: [
        Task(description: 'Cycle to work on Monday'),
        Task(description: 'Cycle to work on Tuesday'),
        Task(description: 'Cycle to work on Wednesday'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: Colors.green,
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
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Build sustainable habits through fun challenges',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
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
                    color: Colors.black87,
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ..._availableChallenges.map(
                  (challenge) => _buildExpandableChallenge(challenge),
                ),
              ] else if (_selectedTab == 'Completed') ...[
                const Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
    );
  }

  Widget _buildStatsBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.workspace_premium_outlined,
          text: '1,250 points earned',
          color: Colors.green,
        ),
        _StatItem(
          icon: Icons.check_circle_outline,
          text: '5 challenges completed',
          color: Colors.green,
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

  Widget _buildActiveChallenge(Challenge challenge) {
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

  Widget _buildExpandableChallenge(Challenge challenge) {
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
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
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
        color: color.withAlpha((255 * 0.1).round()),
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
