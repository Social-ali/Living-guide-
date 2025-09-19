import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contact Us'),
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
                'Contact Us',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'d love to hear from you. Send us a message and we\'ll respond as soon as possible.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              // Contact details section
              _buildCardSection(
                content: Column(
                  children: const [
                    _ContactDetail(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: 'support@ecoguide.app',
                      description: 'Send us an email anytime',
                    ),
                    Divider(),
                    _ContactDetail(
                      icon: Icons.phone,
                      title: 'Phone',
                      subtitle:
                          '+92 (21) 123-4567', // Karachi-specific phone number
                      description: 'Call us during business hours',
                    ),
                    Divider(),
                    _ContactDetail(
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: 'Karachi, Sindh, Pakistan',
                      description: 'Our headquarters',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Send us a message form
              const Text(
                'Send us a Message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              _buildCardSection(
                content: Column(
                  children: [
                    _buildTextField(
                      label: 'Full Name *',
                      hint: 'Enter your full name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email Address *',
                      hint: 'Enter your email',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Category',
                      items: [
                        'General Inquiry',
                        'Report Bug',
                        'Feature Request',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Subject *',
                      hint: 'Brief description of your inquiry',
                    ),
                    const SizedBox(height: 16),
                    _buildMultiLineTextField(
                      label: 'Message *',
                      hint: 'Please provide details about your inquiry...',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle form submission
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Quick help section
              _buildCardSection(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Quick Help',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    _QuickHelpItem(
                      icon: Icons.help_outline,
                      title: 'General Questions',
                      subtitle:
                          'Learn about EcoGuide features and how to get started',
                    ),
                    Divider(),
                    _QuickHelpItem(
                      icon: Icons.bug_report,
                      title: 'Report Bug',
                      subtitle: 'Found a problem? Let us know so we can fix it',
                    ),
                    Divider(),
                    _QuickHelpItem(
                      icon: Icons.lightbulb_outline,
                      title: 'Feature Request',
                      subtitle:
                          'Suggest new features to improve your experience',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Response Time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We typically respond to all inquiries within 24 hours during business days. For urgent technical issues, please include "URGENT" in your subject line.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
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

  // Helper method to build a standard text field
  Widget _buildTextField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Helper method for a multiline text field
  Widget _buildMultiLineTextField({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Helper method for a dropdown field
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: (String? newValue) {
            // Handle dropdown change
          },
        ),
      ],
    );
  }
}

// Reusable widget for a contact detail item
class _ContactDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _ContactDetail({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
 return ListTile(
  leading: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color.fromARGB(26, 0, 128, 0), // Replaces Colors.green.withOpacity(0.1)
      borderRadius: BorderRadius.circular(12),
    ),
        child: Icon(icon, color: Colors.green, size: 28),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: const TextStyle(color: Colors.black87)),
          Text(description, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

// Reusable widget for a quick help item
class _QuickHelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickHelpItem({
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
