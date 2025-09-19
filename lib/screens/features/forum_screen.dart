// import 'package:flutter/material.dart';
// import '../../models/forum_post_model.dart';
// import '../../services/firestore_service.dart';

// class ForumScreen extends StatefulWidget {
//   const ForumScreen({super.key});

//   @override
//   State<ForumScreen> createState() => _ForumScreenState();
// }

// class _ForumScreenState extends State<ForumScreen>
//     with SingleTickerProviderStateMixin {
//   final FirestoreService _firestoreService = FirestoreService();
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();

//   String _selectedCategory = 'All';
//   String _selectedPostCategory = 'General';
//   String _searchQuery = '';
//   List<String> _categories = ['All'];

//   // For demo purposes, using a mock user ID
//   final String _currentUserId = 'demo_user_123';

//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final categories = await _firestoreService.getForumCategories();
//       setState(() {
//         _categories = ['All', ...categories];
//       });
//     } catch (e) {
//       // Handle error
//     }
//   }

//   Stream<List<ForumPost>> _getFilteredPosts() {
//     if (_searchQuery.isNotEmpty) {
//       return _firestoreService.searchForumPosts(_searchQuery);
//     } else {
//       return _firestoreService.getForumPostsByCategory(_selectedCategory);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Community Forum',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.green, Colors.teal],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         foregroundColor: Colors.white,
//         elevation: 4,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: _showCreatePostDialog,
//             tooltip: 'Create Post',
//           ),
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: _showSearchDialog,
//             tooltip: 'Search',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Category Filter
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.grey[50]!, Colors.grey[100]!],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             margin: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Browse Categories',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children:
//                         _categories.map((category) {
//                           final isSelected = category == _selectedCategory;
//                           return Container(
//                             margin: const EdgeInsets.only(right: 8),
//                             child: FilterChip(
//                               label: Text(
//                                 category,
//                                 style: TextStyle(
//                                   fontWeight:
//                                       isSelected
//                                           ? FontWeight.bold
//                                           : FontWeight.normal,
//                                 ),
//                               ),
//                               selected: isSelected,
//                               onSelected: (selected) {
//                                 setState(() {
//                                   _selectedCategory = category;
//                                 });
//                               },
//                               selectedColor: Colors.green.withOpacity(0.2),
//                               checkmarkColor: Colors.green,
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Posts List with StreamBuilder
//           Expanded(
//             child: StreamBuilder<List<ForumPost>>(
//               stream: _getFilteredPosts(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           size: 64,
//                           color: Colors.grey,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Error loading posts: ${snapshot.error}',
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final posts = snapshot.data ?? [];

//                 if (posts.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(24),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Colors.grey[200]!, Colors.grey[300]!],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             _searchQuery.isNotEmpty
//                                 ? Icons.search_off
//                                 : Icons.forum,
//                             size: 48,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           _searchQuery.isNotEmpty
//                               ? 'No posts found for "$_searchQuery"'
//                               : 'No posts in this category yet',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[700],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         if (_searchQuery.isEmpty)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 12,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Text(
//                               'Be the first to start a discussion!',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: posts.length,
//                   itemBuilder: (context, index) {
//                     final post = posts[index];
//                     return _buildPostCard(post);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPostCard(ForumPost post) {
//     final category = ForumCategories.getCategory(post.category);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Card(
//         margin: EdgeInsets.zero,
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: InkWell(
//           onTap: () => _navigateToPostDetail(post),
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.grey[50]!],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Post Header
//                 Row(
//                   children: [
//                     // Category Badge
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             category?.color.withOpacity(0.1) ??
//                             Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color:
//                               category?.color.withOpacity(0.3) ??
//                               Colors.grey.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             category?.icon ?? Icons.forum,
//                             size: 16,
//                             color: category?.color ?? Colors.grey,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             post.category,
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: category?.color ?? Colors.grey,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const Spacer(),

//                     // Time and Pinned
//                     Row(
//                       children: [
//                         if (post.isPinned)
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.push_pin,
//                               size: 16,
//                               color: Colors.orange,
//                             ),
//                           ),
//                         const SizedBox(width: 8),
//                         Text(
//                           post.timeAgo,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // Post Title
//                 Text(
//                   post.title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     height: 1.3,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 const SizedBox(height: 10),

//                 // Post Content Preview
//                 Text(
//                   post.content,
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.grey[700],
//                     height: 1.5,
//                   ),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 const SizedBox(height: 16),

//                 // Post Footer
//                 Row(
//                   children: [
//                     // Author
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 12,
//                           backgroundColor: Colors.grey[200],
//                           child: const Icon(
//                             Icons.person,
//                             size: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           post.authorName,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const Spacer(),

//                     // Voting
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: () => _voteOnPost(post.id, true),
//                             icon: const Icon(Icons.arrow_upward, size: 16),
//                             color: Colors.grey[600],
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             post.netVotes.toString(),
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           IconButton(
//                             onPressed: () => _voteOnPost(post.id, false),
//                             icon: const Icon(Icons.arrow_downward, size: 16),
//                             color: Colors.grey[600],
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     // Comments
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.comment,
//                             size: 16,
//                             color: Colors.blue[600],
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             post.commentCount.toString(),
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.blue[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Tags
//                 if (post.tags.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children:
//                         post.tags.map((tag) {
//                           return Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.purple.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: Colors.purple.withOpacity(0.3),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Text(
//                               '#$tag',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.purple,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _voteOnPost(String postId, bool isUpvote) async {
//     try {
//       await _firestoreService.voteOnPost(postId, _currentUserId, isUpvote);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
//       }
//     }
//   }

//   void _showSearchDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Search Posts'),
//             content: TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(
//                 hintText: 'Search by title...',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _searchQuery = '';
//                     _searchController.clear();
//                   });
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Clear'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Close'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showCreatePostDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder:
//                 (context, setState) => AlertDialog(
//                   title: const Text('Create New Post'),
//                   content: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         TextField(
//                           controller: _titleController,
//                           decoration: const InputDecoration(
//                             labelText: 'Title',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonFormField<String>(
//                           value: _selectedPostCategory,
//                           decoration: const InputDecoration(
//                             labelText: 'Category',
//                             border: OutlineInputBorder(),
//                           ),
//                           items:
//                               ForumCategories.categories.map((category) {
//                                 return DropdownMenuItem(
//                                   value: category.name,
//                                   child: Text(category.name),
//                                 );
//                               }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedPostCategory = value!;
//                             });
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: _contentController,
//                           decoration: const InputDecoration(
//                             labelText: 'Content',
//                             border: OutlineInputBorder(),
//                           ),
//                           maxLines: 5,
//                         ),
//                       ],
//                     ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         _titleController.clear();
//                         _contentController.clear();
//                         _selectedPostCategory = 'General';
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: _createPost,
//                       child: const Text('Create'),
//                     ),
//                   ],
//                 ),
//           ),
//     );
//   }

//   Future<void> _createPost() async {
//     if (_titleController.text.trim().isEmpty ||
//         _contentController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }

//     final post = ForumPost(
//       id: '',
//       userId: _currentUserId,
//       authorName: 'Demo User',
//       title: _titleController.text.trim(),
//       content: _contentController.text.trim(),
//       category: _selectedPostCategory,
//       tags: [],
//       upvotes: 0,
//       downvotes: 0,
//       commentCount: 0,
//       createdAt: DateTime.now(),
//       isPinned: false,
//     );

//     try {
//       await _firestoreService.createForumPost(post);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Post created successfully!')),
//       );
//       Navigator.of(context).pop();
//       _titleController.clear();
//       _contentController.clear();
//       _selectedPostCategory = 'General';
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
//     }
//   }

//   void _navigateToPostDetail(ForumPost post) {
//     // Navigate to post detail screen with comments
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => _PostDetailScreen(post: post)),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }
// }

// // Post Detail Screen
// class _PostDetailScreen extends StatefulWidget {
//   final ForumPost post;

//   const _PostDetailScreen({required this.post});

//   @override
//   State<_PostDetailScreen> createState() => _PostDetailScreenState();
// }

// class _PostDetailScreenState extends State<_PostDetailScreen> {
//   final FirestoreService _firestoreService = FirestoreService();
//   final TextEditingController _commentController = TextEditingController();
//   final String _currentUserId = 'demo_user_123';

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   Future<void> _addComment() async {
//     if (_commentController.text.trim().isEmpty) return;

//     final comment = Comment(
//       id: '',
//       postId: widget.post.id,
//       userId: _currentUserId,
//       authorName: 'Demo User',
//       content: _commentController.text.trim(),
//       createdAt: DateTime.now(),
//       upvotes: 0,
//       downvotes: 0,
//     );

//     try {
//       await _firestoreService.addCommentToPost(comment);
//       _commentController.clear();
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Comment added!')));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error adding comment: $e')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final category = ForumCategories.getCategory(widget.post.category);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Post Details',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.green, Colors.teal],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         foregroundColor: Colors.white,
//         elevation: 4,
//       ),
//       body: Column(
//         children: [
//           // Post Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Post Header
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color:
//                               category?.color.withOpacity(0.1) ??
//                               Colors.grey.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color:
//                                 category?.color.withOpacity(0.3) ??
//                                 Colors.grey.withOpacity(0.3),
//                             width: 1,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               category?.icon ?? Icons.forum,
//                               size: 16,
//                               color: category?.color ?? Colors.grey,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               widget.post.category,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: category?.color ?? Colors.grey,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Spacer(),
//                       Text(
//                         widget.post.timeAgo,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   // Post Title
//                   Text(
//                     widget.post.title,
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                       height: 1.3,
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Author
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 16,
//                         backgroundColor: Colors.grey[200],
//                         child: const Icon(
//                           Icons.person,
//                           size: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         widget.post.authorName,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 24),

//                   // Post Content
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.grey[200]!, width: 1),
//                     ),
//                     child: Text(
//                       widget.post.content,
//                       style: TextStyle(
//                         fontSize: 16,
//                         height: 1.6,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                   ),

//                   // Tags
//                   if (widget.post.tags.isNotEmpty) ...[
//                     const SizedBox(height: 24),
//                     Wrap(
//                       spacing: 10,
//                       runSpacing: 10,
//                       children:
//                           widget.post.tags.map((tag) {
//                             return Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.purple.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                   color: Colors.purple.withOpacity(0.3),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Text(
//                                 '#$tag',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.purple,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                     ),
//                   ],

//                   const SizedBox(height: 32),

//                   // Comments Section
//                   Container(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         top: BorderSide(color: Colors.grey[300]!, width: 1),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.comment, size: 24, color: Colors.grey[700]),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Comments',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Comments List
//                   StreamBuilder<List<Comment>>(
//                     stream: _firestoreService.getCommentsForPost(
//                       widget.post.id,
//                     ),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       }

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       final comments = snapshot.data ?? [];

//                       if (comments.isEmpty) {
//                         return Center(
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Colors.grey[200]!,
//                                       Colors.grey[300]!,
//                                     ],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.chat_bubble_outline,
//                                   size: 32,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No comments yet. Be the first to comment!',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }

//                       return ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: comments.length,
//                         itemBuilder: (context, index) {
//                           final comment = comments[index];
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Card(
//                               margin: EdgeInsets.zero,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 14,
//                                           backgroundColor: Colors.grey[200],
//                                           child: const Icon(
//                                             Icons.person,
//                                             size: 14,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Text(
//                                           comment.authorName,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                         const Spacer(),
//                                         Text(
//                                           comment.timeAgo,
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 12),
//                                     Text(
//                                       comment.content,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         height: 1.5,
//                                         color: Colors.grey[800],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Comment Input
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 top: BorderSide(color: Colors.grey[300]!, width: 1),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.grey[300]!, width: 1),
//                     ),
//                     child: TextField(
//                       controller: _commentController,
//                       decoration: InputDecoration(
//                         hintText: 'Add a comment...',
//                         hintStyle: TextStyle(color: Colors.grey[500]),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       maxLines: null,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: _addComment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Post',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/forum_post_model.dart';
import '../../services/firestore_service.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = 'All';
  String _selectedPostCategory = 'General';
  String _searchQuery = '';
  List<String> _categories = ['All'];

  final String _currentUserId = 'demo_user_123';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _firestoreService.getForumCategories();
      setState(() {
        _categories = ['All', ...categories];
      });
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community Forum',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePostDialog,
            tooltip: 'Create Post',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: Colors.green.withOpacity(0.2),
                          checkmarkColor: Colors.green,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          // Posts List with StreamBuilder
          Expanded(
            child: StreamBuilder<List<ForumPost>>(
              stream: _firestoreService.getForumPosts(), // single stream
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var posts = snapshot.data ?? [];

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  posts =
                      posts
                          .where(
                            (post) => post.title.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();
                }

                // Apply category filter
                if (_selectedCategory != 'All') {
                  posts =
                      posts
                          .where((post) => post.category == _selectedCategory)
                          .toList();
                }

                if (posts.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No posts found for "$_searchQuery"'
                          : 'No posts in this category yet',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostCard(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // Helpers
  // ================================

  Widget _buildPostCard(ForumPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => _navigateToPostDetail(post),
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          post.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(post.timeAgo),
      ),
    );
  }

  // ignore: unused_element
  Future<void> _voteOnPost(String postId, bool isUpvote) async {
    try {
      await _firestoreService.voteOnPost(postId, _currentUserId, isUpvote);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Posts'),
            content: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Create New Post'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedPostCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              ForumCategories.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.name,
                                  child: Text(category.name),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPostCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _titleController.clear();
                        _contentController.clear();
                        _selectedPostCategory = 'General';
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: _createPost,
                      child: const Text('Create'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _createPost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final post = ForumPost(
      id: '',
      userId: _currentUserId,
      authorName: 'Demo User',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedPostCategory,
      tags: [],
      upvotes: 0,
      downvotes: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      isPinned: false,
    );

    try {
      await _firestoreService.createForumPost(post);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
      Navigator.of(context).pop();
      _titleController.clear();
      _contentController.clear();
      _selectedPostCategory = 'General';
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    }
  }

  void _navigateToPostDetail(ForumPost post) {
    // same as before
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
