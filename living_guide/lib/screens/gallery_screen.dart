import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gallery'),
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
                'Health & Wellness Tips',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A collection of tips and tricks to help you improve your overall health and well-being.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              // Tips and tricks gallery section
              _buildCardSection(
                content: Column(
                  children: const [
                    _GalleryItem(
                      icon: Icons.local_drink,
                      title: 'Stay Hydrated',
                      subtitle:
                          'Drink at least 8 glasses of water a day to maintain energy levels and support bodily functions.',
                    ),
                    Divider(),
                    _GalleryItem(
                      icon: Icons.fastfood,
                      title: 'Eat a Balanced Diet',
                      subtitle:
                          'Focus on consuming whole foods, including fruits, vegetables, lean proteins, and whole grains.',
                    ),
                    Divider(),
                    _GalleryItem(
                      icon: Icons.self_improvement,
                      title: 'Prioritize Sleep',
                      subtitle:
                          'Aim for 7-9 hours of quality sleep per night to allow your body to repair and rejuvenate.',
                    ),
                    Divider(),
                    _GalleryItem(
                      icon: Icons.directions_run,
                      title: 'Get Regular Exercise',
                      subtitle:
                          'Incorporate physical activity into your daily routine, such as walking, jogging, or cycling.',
                    ),
                    Divider(),
                    _GalleryItem(
                      icon: Icons.wb_sunny,
                      title: 'Soak Up Some Sun',
                      subtitle:
                          'Spend at least 15-20 minutes in the sun to get your daily dose of Vitamin D.',
                    ),
                    Divider(),
                    _GalleryItem(
                      icon: Icons.phone_iphone,
                      title: 'Limit Screen Time',
                      subtitle:
                          'Take regular breaks from digital devices to reduce eye strain and improve mental clarity.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // New sections
              const Text(
                'Inspirational Stories',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Read inspiring stories from our community members who have achieved their health and wellness goals.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              _buildCardSection(
                content: Column(
                  children: const [
                    _GalleryItem(
                      icon: Icons.person_outline,
                      title: 'John\'s Journey to Fitness',
                      subtitle:
                          'John lost over 50 pounds by making small, consistent changes to his diet and exercise routine.',
                    ),
                    Divider(),
                    _GalleryItem(
                      icon: Icons.self_improvement,
                      title: 'Sarah\'s Meditation Habit',
                      subtitle:
                          'Sarah shares how daily meditation helped her manage stress and improve her mental health.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Healthy Recipes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Explore delicious and nutritious recipes that are easy to make and perfect for a healthy lifestyle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              _buildCardSection(
                content: Column(
                  children: const [
                    _GalleryItem(
                      icon: Icons.restaurant,
                      title: 'Avocado Toast with a Twist',
                      subtitle:
                          'A simple, healthy breakfast that is packed with healthy fats and fiber.',
                    ),
                    Divider(),
                    _GalleryItem(
                      icon: Icons.restaurant,
                      title: 'Quinoa Salad with Roasted Vegetables',
                      subtitle:
                          'A colorful and protein-rich salad that makes for a perfect lunch or dinner.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Motivational quote section
              _buildCardSection(
                content: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '"The greatest wealth is health."\n- Virgil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a card section
  Widget _buildCardSection({required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: content),
    );
  }
}

// Reusable widget for a gallery item
class _GalleryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _GalleryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            26,
            0,
            128,
            0,
          ), // Equivalent to green with 10% opacity
          borderRadius: BorderRadius.circular(12),
        ),

        child: Icon(icon, color: Colors.green, size: 28),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
    );
  }
}
