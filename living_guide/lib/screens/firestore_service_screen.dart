// import 'package:flutter/material.dart';
// import '../services/firestore_service.dart';
// import '../models/product_model.dart';
// import '../models/challenge_model.dart';
// import '../models/waste_stats_model.dart';

// import '../models/carbon_entry_model.dart';
// import '../models/forum_post_model.dart';

// class FirestoreServiceScreen extends StatefulWidget {
//   const FirestoreServiceScreen({super.key});

//   @override
//   State<FirestoreServiceScreen> createState() => _FirestoreServiceScreenState();
// }

// class _FirestoreServiceScreenState extends State<FirestoreServiceScreen>
//     with SingleTickerProviderStateMixin {
//   final FirestoreService _firestoreService = FirestoreService();
//   final String _currentUserId = 'demo_user_123';
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 6, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Firestore Service Demo'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: const [
//             Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
//             Tab(text: 'Products', icon: Icon(Icons.shopping_cart)),
//             Tab(text: 'Challenges', icon: Icon(Icons.flag)),
//             Tab(text: 'Waste', icon: Icon(Icons.delete)),
//             Tab(text: 'Carbon', icon: Icon(Icons.eco)),
//             Tab(text: 'Forum', icon: Icon(Icons.forum)),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildOverviewTab(),
//           _buildProductsTab(),
//           _buildChallengesTab(),
//           _buildWasteTab(),
//           _buildCarbonTab(),
//           _buildForumTab(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addSampleData,
//         backgroundColor: Colors.green,
//         child: const Icon(Icons.add, color: Colors.white),
//         tooltip: 'Add Sample Data',
//       ),
//     );
//   }

//   Widget _buildOverviewTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Firestore Service Overview'),
//           const SizedBox(height: 16),

//           // Service Status Card
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.cloud_done, color: Colors.green, size: 32),
//                       const SizedBox(width: 16),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Service Status: Connected',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                             Text(
//                               'Firebase Firestore is properly configured and ready to use.',
//                               style: TextStyle(color: Colors.black54),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Available Collections
//           _buildSectionHeader('Available Collections'),
//           const SizedBox(height: 16),

//           GridView.count(
//             crossAxisCount: 2,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             children: [
//               _buildCollectionCard(
//                 'Products',
//                 Icons.shopping_bag,
//                 Colors.blue,
//                 'Store and manage sustainable products',
//               ),
//               _buildCollectionCard(
//                 'Challenges',
//                 Icons.flag,
//                 Colors.orange,
//                 'Environmental challenges and goals',
//               ),
//               _buildCollectionCard(
//                 'Waste Entries',
//                 Icons.delete,
//                 Colors.red,
//                 'Track waste reduction progress',
//               ),
//               _buildCollectionCard(
//                 'Carbon Entries',
//                 Icons.eco,
//                 Colors.green,
//                 'Monitor carbon footprint data',
//               ),
//               _buildCollectionCard(
//                 'Recipes',
//                 Icons.restaurant,
//                 Colors.purple,
//                 'Sustainable meal planning',
//               ),
//               _buildCollectionCard(
//                 'Forum Posts',
//                 Icons.forum,
//                 Colors.teal,
//                 'Community discussions',
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // Key Features
//           _buildSectionHeader('Key Features'),
//           const SizedBox(height: 16),

//           _buildFeatureCard(
//             'Real-time Data',
//             'All data streams update in real-time using Firestore listeners',
//             Icons.sync,
//             Colors.blue,
//           ),
//           const SizedBox(height: 12),
//           _buildFeatureCard(
//             'Offline Support',
//             'Data persists locally when offline and syncs when reconnected',
//             Icons.offline_bolt,
//             Colors.green,
//           ),
//           const SizedBox(height: 12),
//           _buildFeatureCard(
//             'Type Safety',
//             'All models use proper type definitions for data integrity',
//             Icons.security,
//             Colors.purple,
//           ),
//           const SizedBox(height: 12),
//           _buildFeatureCard(
//             'Error Handling',
//             'Comprehensive error handling with user-friendly messages',
//             Icons.error_outline,
//             Colors.orange,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Products Management'),
//           const SizedBox(height: 16),

//           // Products Stream
//           StreamBuilder<List<Product>>(
//             stream: _firestoreService.getProducts(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return _buildErrorCard(snapshot.error.toString());
//               }

//               final products = snapshot.data ?? [];

//               return Column(
//                 children: [
//                   _buildStatsCard(
//                     'Total Products',
//                     products.length.toString(),
//                     Icons.shopping_cart,
//                     Colors.blue,
//                   ),
//                   const SizedBox(height: 16),

//                   if (products.isEmpty)
//                     _buildEmptyState(
//                       'No products available',
//                       'Add some products to get started',
//                     )
//                   else
//                     ...products.map((product) => _buildProductCard(product)),
//                 ],
//               );
//             },
//           ),

//           const SizedBox(height: 24),

//           // Categories
//           _buildSectionHeader('Product Categories'),
//           const SizedBox(height: 16),

//           FutureBuilder<List<String>>(
//             future: _firestoreService.getCategories(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final categories = snapshot.data ?? [];

//               return Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children:
//                     categories.map((category) {
//                       return Chip(
//                         label: Text(category),
//                         backgroundColor: Colors.blue.withOpacity(0.1),
//                         labelStyle: const TextStyle(color: Colors.blue),
//                       );
//                     }).toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChallengesTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Challenges Management'),
//           const SizedBox(height: 16),

//           // Challenges Stream
//           StreamBuilder<List<Challenge>>(
//             stream: _firestoreService.getChallenges(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return _buildErrorCard(snapshot.error.toString());
//               }

//               final challenges = snapshot.data ?? [];

//               return Column(
//                 children: [
//                   _buildStatsCard(
//                     'Total Challenges',
//                     challenges.length.toString(),
//                     Icons.flag,
//                     Colors.orange,
//                   ),
//                   const SizedBox(height: 16),

//                   if (challenges.isEmpty)
//                     _buildEmptyState(
//                       'No challenges available',
//                       'Create challenges to engage users',
//                     )
//                   else
//                     ...challenges.map(
//                       (challenge) => _buildChallengeCard(challenge),
//                     ),
//                 ],
//               );
//             },
//           ),

//           const SizedBox(height: 24),

//           // User Challenges
//           _buildSectionHeader('User Challenges'),
//           const SizedBox(height: 16),

//           StreamBuilder<List<UserChallenge>>(
//             stream: _firestoreService.getUserChallenges(_currentUserId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final userChallenges = snapshot.data ?? [];

//               return Column(
//                 children: [
//                   _buildStatsCard(
//                     'Your Challenges',
//                     userChallenges.length.toString(),
//                     Icons.person,
//                     Colors.green,
//                   ),
//                   const SizedBox(height: 16),

//                   if (userChallenges.isEmpty)
//                     _buildEmptyState(
//                       'No active challenges',
//                       'Accept a challenge to get started',
//                     )
//                   else
//                     ...userChallenges.map(
//                       (challenge) => _buildUserChallengeCard(challenge),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWasteTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Waste Tracking'),
//           const SizedBox(height: 16),

//           // Waste Entries Stream
//           StreamBuilder<List<WasteStats>>(
//             stream: _firestoreService.getUserWasteEntries(_currentUserId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return _buildErrorCard(snapshot.error.toString());
//               }

//               final wasteEntries = snapshot.data ?? [];

//               return Column(
//                 children: [
//                   FutureBuilder<double>(
//                     future: _firestoreService.getTotalWasteReduced(
//                       _currentUserId,
//                     ),
//                     builder: (context, totalSnapshot) {
//                       final total = totalSnapshot.data ?? 0.0;
//                       return _buildStatsCard(
//                         'Total Waste Reduced',
//                         '${total.toStringAsFixed(1)} kg',
//                         Icons.delete,
//                         Colors.red,
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   if (wasteEntries.isEmpty)
//                     _buildEmptyState(
//                       'No waste entries',
//                       'Start tracking your waste reduction',
//                     )
//                   else
//                     ...wasteEntries.map((entry) => _buildWasteCard(entry)),
//                 ],
//               );
//             },
//           ),

//           const SizedBox(height: 24),

//           // Waste Summary
//           _buildSectionHeader('Waste Summary by Type'),
//           const SizedBox(height: 16),

//           FutureBuilder<List<WasteSummary>>(
//             future: _firestoreService.getWasteSummaryByType(_currentUserId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final summaries = snapshot.data ?? [];

//               if (summaries.isEmpty) {
//                 return _buildEmptyState(
//                   'No waste summary data',
//                   'Add waste entries to see summary',
//                 );
//               }

//               return Column(
//                 children:
//                     summaries
//                         .map((summary) => _buildWasteSummaryCard(summary))
//                         .toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCarbonTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Carbon Tracking'),
//           const SizedBox(height: 16),

//           // Carbon Entries Stream
//           StreamBuilder<List<CarbonEntry>>(
//             stream: _firestoreService.getUserCarbonEntries(_currentUserId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return _buildErrorCard(snapshot.error.toString());
//               }

//               final carbonEntries = snapshot.data ?? [];

//               return Column(
//                 children: [
//                   FutureBuilder<double>(
//                     future: _firestoreService.getTotalCarbonImpact(
//                       _currentUserId,
//                     ),
//                     builder: (context, totalSnapshot) {
//                       final total = totalSnapshot.data ?? 0.0;
//                       return _buildStatsCard(
//                         'Total Carbon Impact',
//                         '${total.toStringAsFixed(1)} kg CO₂',
//                         Icons.eco,
//                         Colors.green,
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   if (carbonEntries.isEmpty)
//                     _buildEmptyState(
//                       'No carbon entries',
//                       'Start tracking your carbon footprint',
//                     )
//                   else
//                     ...carbonEntries.map((entry) => _buildCarbonCard(entry)),
//                 ],
//               );
//             },
//           ),

//           const SizedBox(height: 24),

//           // Daily Carbon Impact
//           _buildSectionHeader('Daily Carbon Impact (Last 7 Days)'),
//           const SizedBox(height: 16),

//           FutureBuilder<List<Map<String, dynamic>>>(
//             future: _firestoreService.getDailyCarbonImpact(
//               _currentUserId,
//               days: 7,
//             ),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return _buildErrorCard(snapshot.error.toString());
//               }

//               final data = snapshot.data ?? [];

//               if (data.isEmpty) {
//                 return _buildEmptyState(
//                   'No daily data',
//                   'Add carbon entries to see trends',
//                 );
//               }

//               return Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children:
//                         data.map((entry) {
//                           final date = entry['date'] as DateTime;
//                           final impact = entry['impact'] as double;
//                           return ListTile(
//                             leading: Icon(
//                               Icons.calendar_today,
//                               color: Colors.green,
//                             ),
//                             title: Text(
//                               '${date.month}/${date.day}/${date.year}',
//                             ),
//                             trailing: Text(
//                               '${impact.toStringAsFixed(1)} kg',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//               );
//             },
//           ),

//           const SizedBox(height: 24),

//           // Activity Breakdown
//           _buildSectionHeader('Carbon Impact by Activity'),
//           const SizedBox(height: 16),

//           FutureBuilder<Map<String, double>>(
//             future: _firestoreService.getCarbonImpactByActivityType(
//               _currentUserId,
//             ),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final data = snapshot.data ?? {};

//               if (data.isEmpty) {
//                 return _buildEmptyState(
//                   'No activity data',
//                   'Add carbon entries to see breakdown',
//                 );
//               }

//               return Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children:
//                         data.entries.map((entry) {
//                           return ListTile(
//                             leading: Icon(Icons.category, color: Colors.blue),
//                             title: Text(entry.key),
//                             trailing: Text(
//                               '${entry.value.toStringAsFixed(1)} kg CO₂',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildForumTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Forum Management'),
//           const SizedBox(height: 16),

//           // Forum Posts Stream
//           StreamBuilder<List<ForumPost>>(
//             stream: _firestoreService.getForumPosts(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return _buildErrorCard(snapshot.error.toString());
//               }

//               final posts = snapshot.data ?? [];

//               return Column(
//                 children: [
//                   _buildStatsCard(
//                     'Total Posts',
//                     posts.length.toString(),
//                     Icons.forum,
//                     Colors.teal,
//                   ),
//                   const SizedBox(height: 16),

//                   if (posts.isEmpty)
//                     _buildEmptyState(
//                       'No forum posts',
//                       'Create the first discussion',
//                     )
//                   else
//                     ...posts.take(5).map((post) => _buildForumPostCard(post)),

//                   if (posts.length > 5)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 16),
//                       child: Text(
//                         'Showing first 5 posts (${posts.length - 5} more...)',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),

//           const SizedBox(height: 24),

//           // Forum Categories
//           _buildSectionHeader('Forum Categories'),
//           const SizedBox(height: 16),

//           FutureBuilder<List<String>>(
//             future: _firestoreService.getForumCategories(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final categories = snapshot.data ?? [];

//               return Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children:
//                     categories.map((category) {
//                       return Chip(
//                         label: Text(category),
//                         backgroundColor: Colors.teal.withOpacity(0.1),
//                         labelStyle: const TextStyle(color: Colors.teal),
//                       );
//                     }).toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Widgets

//   Widget _buildSectionHeader(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         color: Colors.black87,
//       ),
//     );
//   }

//   Widget _buildCollectionCard(
//     String title,
//     IconData icon,
//     Color color,
//     String description,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 48, color: color),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               description,
//               style: const TextStyle(fontSize: 12, color: Colors.black54),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(
//     String title,
//     String description,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     description,
//                     style: const TextStyle(fontSize: 14, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(fontSize: 16, color: Colors.black54),
//                   ),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: color,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(Product product) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.shopping_cart, color: Colors.blue),
//         title: Text(product.name),
//         subtitle: Text('${product.category} • \$${product.price}'),
//         trailing: Icon(Icons.arrow_forward_ios, size: 16),
//       ),
//     );
//   }

//   Widget _buildChallengeCard(Challenge challenge) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.flag, color: Colors.orange),
//         title: Text(challenge.title),
//         subtitle: Text('${challenge.category} • ${challenge.difficulty}'),
//         trailing: Text('${challenge.points} pts'),
//       ),
//     );
//   }

//   Widget _buildUserChallengeCard(UserChallenge challenge) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(
//           challenge.isCompleted ? Icons.check_circle : Icons.pending,
//           color: challenge.isCompleted ? Colors.green : Colors.orange,
//         ),
//         title: Text('Challenge Progress'),
//         subtitle: Text(
//           'Progress: ${challenge.currentProgress} • ${challenge.isCompleted ? 'Completed' : 'In Progress'}',
//         ),
//       ),
//     );
//   }

//   Widget _buildWasteCard(WasteStats waste) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.delete, color: Colors.red),
//         title: Text(waste.wasteType),
//         subtitle: Text('${waste.date.toString().split(' ')[0]}'),
//         trailing: Text('${waste.quantity} ${waste.unit}'),
//       ),
//     );
//   }

//   Widget _buildWasteSummaryCard(WasteSummary summary) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.analytics, color: Colors.red),
//         title: Text(summary.wasteTypeDisplayName),
//         subtitle: Text(
//           'Last entry: ${summary.lastEntryDate.toString().split(' ')[0]}',
//         ),
//         trailing: Text('${summary.totalQuantity.toStringAsFixed(1)} kg'),
//       ),
//     );
//   }

//   Widget _buildCarbonCard(CarbonEntry entry) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.eco, color: Colors.green),
//         title: Text(entry.activityType),
//         subtitle: Text(
//           '${entry.date.toString().split(' ')[0]} • ${entry.activityDescription}',
//         ),
//         trailing: Text('${entry.carbonImpact.toStringAsFixed(1)} kg'),
//       ),
//     );
//   }

//   Widget _buildForumPostCard(ForumPost post) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.forum, color: Colors.teal),
//         title: Text(post.title),
//         subtitle: Text(
//           '${post.userId} • ${post.createdAt.toString().split(' ')[0]}',
//         ),
//         trailing: Text('${post.commentCount} comments'),
//       ),
//     );
//   }

//   Widget _buildErrorCard(String error) {
//     return Card(
//       color: Colors.red.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(Icons.error, color: Colors.red),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 'Error: $error',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(String title, String subtitle) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           children: [
//             Icon(Icons.inbox, size: 48, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               subtitle,
//               style: const TextStyle(color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _addSampleData() async {
//     try {
//       await _firestoreService.addSampleDashboardData(_currentUserId);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Sample data added successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error adding sample data: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

import '../models/forum_post_model.dart';

class FirestoreServiceScreen extends StatefulWidget {
  const FirestoreServiceScreen({super.key});

  @override
  State<FirestoreServiceScreen> createState() => _FirestoreServiceScreenState();
}

class _FirestoreServiceScreenState extends State<FirestoreServiceScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = 'demo_user_123';
  late TabController _tabController;

  late final Stream<List<ForumPost>> _forumPostsStream;
  late final Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // ✅ FIX: streams aur futures ek hi dafa init
    _forumPostsStream = _firestoreService.getForumPosts();
    _categoriesFuture = _firestoreService.getForumCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Service Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Products', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Challenges', icon: Icon(Icons.flag)),
            Tab(text: 'Waste', icon: Icon(Icons.delete)),
            Tab(text: 'Carbon', icon: Icon(Icons.eco)),
            Tab(text: 'Forum', icon: Icon(Icons.forum)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildProductsTab(),
          _buildChallengesTab(),
          _buildWasteTab(),
          _buildCarbonTab(),
          _buildForumTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleData,
        backgroundColor: Colors.green,
        tooltip: 'Add Sample Data',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// ==========================
  /// Forum Management Tab
  /// ==========================
  Widget _buildForumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Forum Management'),
          const SizedBox(height: 16),

          // Forum Posts Stream
          StreamBuilder<List<ForumPost>>(
            stream: _forumPostsStream, // ✅ FIXED
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _buildErrorCard(snapshot.error.toString());
              }
              final posts = snapshot.data ?? [];

              return Column(
                children: [
                  _buildStatsCard(
                    'Total Posts',
                    posts.length.toString(),
                    Icons.forum,
                    Colors.teal,
                  ),
                  const SizedBox(height: 16),

                  if (posts.isEmpty)
                    _buildEmptyState(
                      'No forum posts',
                      'Create the first discussion',
                    )
                  else
                    ...posts.take(5).map((post) => _buildForumPostCard(post)),

                  if (posts.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Showing first 5 posts (${posts.length - 5} more...)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Forum Categories
          _buildSectionHeader('Forum Categories'),
          const SizedBox(height: 16),

          FutureBuilder<List<String>>(
            future: _categoriesFuture, // ✅ FIXED
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return _buildEmptyState(
                  'No forum categories',
                  'Add categories in Firestore to organize posts',
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    categories
                        .map(
                          (category) => Chip(
                            label: Text(category),
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            labelStyle: const TextStyle(color: Colors.teal),
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ========================== Dummy Tabs ==========================
  Widget _buildOverviewTab() => const Center(child: Text("Overview working ✅"));
  Widget _buildProductsTab() => const Center(child: Text("Products working ✅"));
  Widget _buildChallengesTab() =>
      const Center(child: Text("Challenges working ✅"));
  Widget _buildWasteTab() => const Center(child: Text("Waste working ✅"));
  Widget _buildCarbonTab() => const Center(child: Text("Carbon working ✅"));

  // ========================== Helpers ==========================
  Widget _buildSectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumPostCard(ForumPost post) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.forum, color: Colors.teal),
        title: Text(post.title),
        subtitle: Text(
          '${post.userId} • ${post.createdAt.toString().split(' ')[0]}',
        ),
        trailing: Text('${post.commentCount} comments'),
      ),
    );
  }

  Widget _buildErrorCard(String error) => Card(
    color: Colors.red.withOpacity(0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState(String title, String subtitle) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.inbox, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Future<void> _addSampleData() async {
    try {
      await _firestoreService.addSampleDashboardData(_currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
