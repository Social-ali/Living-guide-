// import 'package:flutter/material.dart';
// import '../../models/waste_stats_model.dart';
// import '../../services/firestore_service.dart';

// class WasteTrackerScreen extends StatefulWidget {
//   const WasteTrackerScreen({super.key});

//   @override
//   State<WasteTrackerScreen> createState() => _WasteTrackerScreenState();
// }

// class _WasteTrackerScreenState extends State<WasteTrackerScreen> {
//   final FirestoreService _firestoreService = FirestoreService();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();

//   String _selectedWasteType = 'plastic';
//   String _selectedUnit = 'kg';
//   DateTime _selectedDate = DateTime.now();

//   // For demo purposes, using a mock user ID
//   final String _currentUserId = 'demo_user_123';

//   final List<String> _wasteTypes = [
//     'plastic',
//     'paper',
//     'glass',
//     'metal',
//     'organic',
//     'electronic',
//   ];

//   final List<String> _units = ['kg', 'items', 'bottles', 'cans', 'bags'];

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     // Load any initial data if needed
//   }

//   Future<void> _addWasteEntry() async {
//     if (_quantityController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please enter a quantity')));
//       return;
//     }

//     final quantity = double.tryParse(_quantityController.text);
//     if (quantity == null || quantity <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid quantity')),
//       );
//       return;
//     }

//     try {
//       final wasteStats = WasteStats(
//         id: '',
//         userId: _currentUserId,
//         wasteType: _selectedWasteType,
//         quantity: quantity,
//         unit: _selectedUnit,
//         date: _selectedDate,
//         notes: _notesController.text.isNotEmpty ? _notesController.text : null,
//         createdAt: DateTime.now(),
//       );

//       await _firestoreService.addWasteEntry(wasteStats);

//       // Clear form
//       _quantityController.clear();
//       _notesController.clear();
//       setState(() {
//         _selectedDate = DateTime.now();
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Waste entry added successfully!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error adding waste entry: $e')));
//       }
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Waste Reduction Tracker'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.bar_chart),
//             onPressed: () {
//               // Navigate to dashboard (will be implemented)
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Dashboard coming soon!')),
//               );
//             },
//             tooltip: 'View Dashboard',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             const Text(
//               'Track Your Waste Reduction',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Log your waste reduction efforts to see your environmental impact over time.',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 24),

//             // Add Waste Entry Form
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Add Waste Entry',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Waste Type Dropdown
//                     DropdownButtonFormField<String>(
//                       initialValue: _selectedWasteType,
//                       decoration: const InputDecoration(
//                         labelText: 'Waste Type',
//                         border: OutlineInputBorder(),
//                       ),
//                       items:
//                           _wasteTypes.map((type) {
//                             return DropdownMenuItem(
//                               value: type,
//                               child: Text(type.toUpperCase()),
//                             );
//                           }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedWasteType = value!;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     // Quantity and Unit Row
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: TextFormField(
//                             controller: _quantityController,
//                             keyboardType: TextInputType.number,
//                             decoration: const InputDecoration(
//                               labelText: 'Quantity',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           flex: 1,
//                           child: DropdownButtonFormField<String>(
//                             initialValue: _selectedUnit,
//                             decoration: const InputDecoration(
//                               labelText: 'Unit',
//                               border: OutlineInputBorder(),
//                             ),
//                             items:
//                                 _units.map((unit) {
//                                   return DropdownMenuItem(
//                                     value: unit,
//                                     child: Text(unit),
//                                   );
//                                 }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _selectedUnit = value!;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Date Picker
//                     InkWell(
//                       onTap: () => _selectDate(context),
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           labelText: 'Date',
//                           border: OutlineInputBorder(),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             const Icon(Icons.calendar_today),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Notes
//                     TextFormField(
//                       controller: _notesController,
//                       maxLines: 3,
//                       decoration: const InputDecoration(
//                         labelText: 'Notes (optional)',
//                         border: OutlineInputBorder(),
//                         hintText: 'Add any additional notes...',
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Add Entry Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _addWasteEntry,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'Add Waste Entry',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Recent Entries
//             const Text(
//               'Recent Entries',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             // Waste Entries List
//             StreamBuilder<List<WasteStats>>(
//               stream: _firestoreService.getUserWasteEntries(_currentUserId),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final entries = snapshot.data ?? [];

//                 if (entries.isEmpty) {
//                   return const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.recycling, size: 64, color: Colors.grey),
//                         SizedBox(height: 16),
//                         Text(
//                           'No waste entries yet',
//                           style: TextStyle(fontSize: 18, color: Colors.grey),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Start tracking your waste reduction!',
//                           style: TextStyle(fontSize: 14, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: entries.length,
//                   itemBuilder: (context, index) {
//                     final entry = entries[index];
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       child: ListTile(
//                         leading: Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Color(
//                               WasteStats.wasteTypeColors[entry.wasteType] ??
//                                   0xFF2196F3,
//                             ).withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.recycling,
//                             color: Colors.green,
//                           ),
//                         ),
//                         title: Text(
//                           '${entry.wasteTypeDisplayName} - ${entry.quantity} ${entry.unit}',
//                           style: const TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         subtitle: Text(
//                           '${entry.date.day}/${entry.date.month}/${entry.date.year}',
//                         ),
//                         trailing:
//                             entry.notes != null && entry.notes!.isNotEmpty
//                                 ? const Icon(Icons.note, color: Colors.grey)
//                                 : null,
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _quantityController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
// }

// lib/screens/features/waste_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WasteTrackerScreen extends StatefulWidget {
  const WasteTrackerScreen({super.key});

  @override
  State<WasteTrackerScreen> createState() => _WasteTrackerScreenState();
}

class _WasteTrackerScreenState extends State<WasteTrackerScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedWasteType = 'plastic';
  String _selectedUnit = 'kg';
  DateTime _selectedDate = DateTime.now();

  // Replace with real logged in user id in your app.
  final String _currentUserId = 'demo_user_123';

  final List<String> _wasteTypes = [
    'plastic',
    'paper',
    'glass',
    'metal',
    'organic',
    'electronic',
  ];

  final List<String> _units = ['kg', 'items', 'bottles', 'cans', 'bags'];

  bool _isSaving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addWasteEntry() async {
    // Validation
    if (_quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a quantity')));
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('waste_entries').doc();

      // Save with server timestamp for createdAt and a Timestamp for date
      await docRef.set({
        'userId': _currentUserId,
        'wasteType': _selectedWasteType,
        'quantity': quantity,
        'unit': _selectedUnit,
        // store date as Timestamp (keeps proper date type)
        'date': Timestamp.fromDate(_selectedDate),
        'notes':
            _notesController.text.isNotEmpty ? _notesController.text : null,
        // server timestamp ensures consistent ordering and prevents missing fields
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear fields
      _quantityController.clear();
      _notesController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waste entry added successfully!')),
        );
      }
    } catch (e, st) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding waste entry: $e')));
      }
      // Optionally print to console for debugging
      // ignore: avoid_print
      print('Error in _addWasteEntry: $e\n$st');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  DateTime _parseCreatedAt(dynamic value) {
    // Handle Timestamp, String (ISO) or null
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime _parseDateField(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Reduction Tracker'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Your Waste Reduction',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log your waste reduction efforts to see your impact over time.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Add Waste Entry Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Waste Type
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWasteType,
                      decoration: const InputDecoration(
                        labelText: 'Waste Type',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _wasteTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedWasteType = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantity + Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                _units
                                    .map(
                                      (unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedUnit = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date picker
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
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _addWasteEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Add Waste Entry',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent Entries',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Realtime list from Firestore (no server-side orderBy to avoid errors if some docs lack createdAt)
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('waste_entries')
                      .where('userId', isEqualTo: _currentUserId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                // Map docs to local objects and sort client-side by createdAt (descending)
                final items =
                    docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final createdAtParsed = _parseCreatedAt(
                        data['createdAt'],
                      );
                      final dateParsed = _parseDateField(data['date']);
                      return {
                        'id': doc.id,
                        'wasteType': data['wasteType'] ?? '',
                        'quantity': data['quantity'] ?? 0,
                        'unit': data['unit'] ?? '',
                        'notes': data['notes'],
                        'createdAt': createdAtParsed,
                        'date': dateParsed,
                      };
                    }).toList();

                // sort: newest first. Documents without createdAt will go to the end.
                items.sort(
                  (a, b) => (b['createdAt'] as DateTime).compareTo(
                    a['createdAt'] as DateTime,
                  ),
                );

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.recycling, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No waste entries yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start tracking your waste reduction!',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final DateTime createdAt = item['createdAt'] as DateTime;
                    final DateTime entryDate = item['date'] as DateTime;

                    // Nice display string (use createdAt if available otherwise entryDate)
                    final displayDate =
                        createdAt.millisecondsSinceEpoch > 0
                            ? createdAt
                            : entryDate;

                    return Card(
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.recycling,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          '${(item['wasteType'] ?? '').toString().toUpperCase()} - ${item['quantity']} ${item['unit']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${displayDate.day}/${displayDate.month}/${displayDate.year}',
                            ),
                            if (item['notes'] != null &&
                                (item['notes'] as String).isNotEmpty)
                              Text(
                                'Notes: ${item['notes']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              // delete doc
                              try {
                                await FirebaseFirestore.instance
                                    .collection('waste_entries')
                                    .doc(item['id'])
                                    .delete();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Entry deleted'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Delete failed: $e'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder:
                              (_) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
