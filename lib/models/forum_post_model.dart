import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String userId;
  final String authorName;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final String? imageUrl;

  ForumPost({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.createdAt,
    this.updatedAt,
    required this.isPinned,
    this.imageUrl,
  });

  factory ForumPost.fromFirestore(Map<String, dynamic> data, String id) {
    return ForumPost(
      id: id,
      userId: data['userId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      tags: List<String>.from(data['tags'] ?? []),
      upvotes: (data['upvotes'] ?? 0).toInt(),
      downvotes: (data['downvotes'] ?? 0).toInt(),
      commentCount: (data['commentCount'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isPinned: data['isPinned'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isPinned': isPinned,
      'imageUrl': imageUrl,
    };
  }

  int get netVotes => upvotes - downvotes;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String content;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentCommentId; // For nested replies

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
    this.updatedAt,
    this.parentCommentId,
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      content: data['content'] ?? '',
      upvotes: (data['upvotes'] ?? 0).toInt(),
      downvotes: (data['downvotes'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      parentCommentId: data['parentCommentId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'parentCommentId': parentCommentId,
    };
  }

  int get netVotes => upvotes - downvotes;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ForumCategory {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const ForumCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ForumCategories {
  static const List<ForumCategory> categories = [
    ForumCategory(
      name: 'General',
      description: 'General discussions about sustainability',
      icon: Icons.forum,
      color: Colors.blue,
    ),
    ForumCategory(
      name: 'Tips & Advice',
      description: 'Share your eco-friendly tips and advice',
      icon: Icons.lightbulb,
      color: Colors.amber,
    ),
    ForumCategory(
      name: 'Success Stories',
      description: 'Share your sustainability achievements',
      icon: Icons.emoji_events,
      color: Colors.green,
    ),
    ForumCategory(
      name: 'Questions',
      description: 'Ask questions about sustainable living',
      icon: Icons.help,
      color: Colors.purple,
    ),
    ForumCategory(
      name: 'Challenges',
      description: 'Discuss sustainability challenges',
      icon: Icons.warning,
      color: Colors.orange,
    ),
    ForumCategory(
      name: 'Products',
      description: 'Discuss eco-friendly products',
      icon: Icons.shopping_bag,
      color: Colors.teal,
    ),
    ForumCategory(
      name: 'Recipes',
      description: 'Share sustainable recipes',
      icon: Icons.restaurant,
      color: Colors.red,
    ),
    ForumCategory(
      name: 'Events',
      description: 'Local sustainability events and meetups',
      icon: Icons.event,
      color: Colors.indigo,
    ),
  ];

  static ForumCategory? getCategory(String name) {
    try {
      return categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }
}
