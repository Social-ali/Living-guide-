import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('About'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'About EcoGuide',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Empowering individuals to make a positive environmental impact through sustainable living practices.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              _buildCardSection(
                title: 'Our Mission',
                content: const Text(
                  'To make sustainable living accessible, engaging, and rewarding for everyone. We believe that small individual actions, when multiplied across our community, can create significant positive environmental change.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              _buildCardSection(
                title: 'What We Offer',
                content: Column(
                  children: const [
                    _AboutListItem(
                      icon: Icons.trending_up,
                      title: 'Carbon Footprint Tracking',
                      subtitle:
                          'Monitor your daily environmental impact with detailed analytics and insights.',
                    ),
                    Divider(),
                    _AboutListItem(
                      icon: Icons.emoji_events,
                      title: 'Sustainable Challenges',
                      subtitle:
                          'Join fun challenges to build eco-friendly habits and compete with the community.',
                    ),
                    Divider(),
                    _AboutListItem(
                      icon: Icons.delete_outline,
                      title: 'Waste Reduction',
                      subtitle:
                          'Track and reduce your waste with personalized tips and recycling guidance.',
                    ),
                    Divider(),
                    _AboutListItem(
                      icon: Icons.shopping_cart,
                      title: 'Eco-Friendly Products',
                      subtitle:
                          'Discover sustainable alternatives for your everyday products and purchases.',
                    ),
                    Divider(),
                    _AboutListItem(
                      icon: Icons.group,
                      title: 'Community Support',
                      subtitle:
                          'Connect with like-minded individuals on their sustainability journey.',
                    ),
                    Divider(),
                    _AboutListItem(
                      icon: Icons.lightbulb_outline,
                      title: 'Energy Conservation',
                      subtitle:
                          'Get personalized tips to reduce your home energy consumption.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCardSection(
                title: 'Our Values',
                content: Column(
                  children: const [
                    _AboutListItem(
                      icon: Icons.public,
                      title: 'Environmental Impact',
                      subtitle:
                          'We\'re committed to helping reduce global carbon emissions through individual action.',
                    ),
                    Divider(),
                    _AboutListItem(
                      icon: Icons.favorite_border,
                      title: 'Community First',
                      subtitle:
                          'Building a supportive community that encourages sustainable living practices.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCardSection(
                title: 'Community Impact',
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatDisplay(value: '50,000+', label: 'Active Users'),
                          _StatDisplay(value: '2.5M kg', label: 'CO2 Saved'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatDisplay(
                            value: '100,000+',
                            label: 'Challenges Completed',
                          ),
                          _StatDisplay(value: '25,000', label: 'Trees Planted'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCardSection(
                title: 'Data Privacy',
                content: const _AboutListItem(
                  icon: Icons.security,
                  title: 'Data Privacy',
                  subtitle:
                      'Your personal data and environmental tracking information is secure and private.',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'EcoStride Mobile App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Version 2.1.0 • Built with sustainability in mind',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Chip(label: 'Carbon Neutral', color: Colors.green),
                  _Chip(label: 'Privacy First', color: Colors.blue),
                  _Chip(label: 'Community Driven', color: Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a section with a title and content
  Widget _buildCardSection({required String title, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Divider(height: 24, color: Colors.green),
            content,
          ],
        ),
      ),
    );
  }
}

// Reusable widget for an item in the About section
class _AboutListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AboutListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}

// Reusable widget for displaying a statistic
class _StatDisplay extends StatelessWidget {
  final String value;
  final String label;

  const _StatDisplay({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

// Reusable widget for a colored chip
class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: color,
      ),
    );
  }
}
