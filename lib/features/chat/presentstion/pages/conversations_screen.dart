// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/features/post/presentation/providers/post_provider.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/network/dio_client.dart';
// import '../../../../core/services/socket_service.dart';
// import 'chat_screen.dart';

// class ConversationsScreen extends ConsumerStatefulWidget {
//   const ConversationsScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ConversationsScreen> createState() =>
//       _ConversationsScreenState();
// }

// class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
//   List<dynamic> _conversations = [];
//   bool _isLoading = true;
//   final SocketService _socketService = SocketService();

//   @override
//   void initState() {
//     super.initState();
//     _initializeSocket();
//     _loadConversations();
//   }

//   Future<void> _initializeSocket() async {
//     await _socketService.connect();

//     // Listen for new messages
//     _socketService.on('receive_message', (data) {
//       print('📨 New message received: $data');
//       _loadConversations(); // Refresh conversation list
//     });
//   }

//   Future<void> _loadConversations() async {
//     setState(() => _isLoading = true);

//     try {
//       final dioClient = ref.read(dioClientProvider);
//       final response = await dioClient.get('/api/messages/conversations');

//       if (response.data['success'] != false) {
//         setState(() {
//           _conversations = response.data as List? ?? [];
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading conversations: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _socketService.off('receive_message');
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppConstants.backgroundGray,
//       appBar: AppBar(
//         title: const Text(
//           'Messages',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit_square),
//             onPressed: () {
//               // TODO: Navigate to new chat
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation(AppConstants.primaryBlue),
//               ),
//             )
//           : _conversations.isEmpty
//           ? _buildEmptyState()
//           : RefreshIndicator(
//               onRefresh: _loadConversations,
//               child: ListView.builder(
//                 itemCount: _conversations.length,
//                 itemBuilder: (context, index) {
//                   final conv = _conversations[index];
//                   return _buildConversationTile(conv);
//                 },
//               ),
//             ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
//           const SizedBox(height: 16),
//           Text(
//             'No conversations yet',
//             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Start chatting with your friends!',
//             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildConversationTile(dynamic conv) {
//     final participant = conv['participant'];
//     final lastMessage = conv['lastMessage'];
//     final unreadCount = conv['unreadCount'] ?? 0;

//     String timeAgo = '';
//     if (conv['lastMessageTime'] != null) {
//       final date = DateTime.parse(conv['lastMessageTime']);
//       final now = DateTime.now();
//       final difference = now.difference(date);

//       if (difference.inDays == 0) {
//         timeAgo = DateFormat('HH:mm').format(date);
//       } else if (difference.inDays == 1) {
//         timeAgo = 'Yesterday';
//       } else {
//         timeAgo = DateFormat('dd/MM/yy').format(date);
//       }
//     }

//     return Container(
//       color: Colors.white,
//       margin: const EdgeInsets.only(bottom: 1),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: CircleAvatar(
//           radius: 28,
//           backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
//           backgroundImage:
//               participant['profilePicture'] != null &&
//                   participant['profilePicture'].isNotEmpty
//               ? NetworkImage(participant['profilePicture'])
//               : null,
//           child:
//               participant['profilePicture'] == null ||
//                   participant['profilePicture'].isEmpty
//               ? Icon(Icons.person, color: AppConstants.primaryBlue)
//               : null,
//         ),
//         title: Text(
//           participant['fullName'] ?? participant['username'],
//           style: TextStyle(
//             fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Text(
//           lastMessage?['content'] ?? 'No messages yet',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
//             fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
//           ),
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               timeAgo,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: unreadCount > 0 ? AppConstants.primaryBlue : Colors.grey,
//               ),
//             ),
//             if (unreadCount > 0) ...[
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppConstants.primaryBlue,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text(
//                   unreadCount > 9 ? '9+' : unreadCount.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatScreen(
//                 otherUserId: participant['_id'],
//                 otherUserName:
//                     participant['fullName'] ?? participant['username'],
//                 otherUserAvatar: participant['profilePicture'],
//                 conversationId: conv['_id'],
//               ),
//             ),
//           ).then((_) => _loadConversations());
//         },
//       ),
//     );
//   }
// }

// // lib/features/chat/presentation/pages/conversations_screen.dart
// // FIXED VERSION - Proper API response handling

// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:frendly/features/post/presentation/providers/post_provider.dart';
// // import 'package:intl/intl.dart';
// // import '../../../../core/constants/app_constants.dart';
// // import '../../../../core/network/dio_client.dart';
// // import '../../../../core/services/socket_service.dart';
// // import 'chat_screen.dart';

// // class ConversationsScreen extends ConsumerStatefulWidget {
// //   const ConversationsScreen({Key? key}) : super(key: key);

// //   @override
// //   ConsumerState<ConversationsScreen> createState() =>
// //       _ConversationsScreenState();
// // }

// // class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
// //   List<dynamic> _conversations = [];
// //   bool _isLoading = true;
// //   String? _error;
// //   final SocketService _socketService = SocketService();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeSocket();
// //     _loadConversations();
// //   }

// //   Future<void> _initializeSocket() async {
// //     await _socketService.connect();

// //     // Listen for new messages
// //     _socketService.on('receive_message', (data) {
// //       print('📨 New message received in conversations: $data');
// //       _loadConversations(); // Refresh conversation list
// //     });

// //     // Listen for message sent confirmation
// //     _socketService.on('message_sent', (data) {
// //       print('✅ Message sent confirmation in conversations');
// //       _loadConversations(); // Refresh conversation list
// //     });
// //   }

// //   Future<void> _loadConversations() async {
// //     setState(() {
// //       _isLoading = true;
// //       _error = null;
// //     });

// //     try {
// //       final dioClient = ref.read(dioClientProvider);
// //       final response = await dioClient.get('/api/messages/conversations');

// //       print('📱 Conversations API Response: ${response.data}');

// //       // ✅ FIXED: Check for success field properly
// //       if (response.data is Map && response.data['success'] == true) {
// //         setState(() {
// //           _conversations = response.data['data'] as List? ?? [];
// //           _isLoading = false;
// //         });
// //         print('✅ Loaded ${_conversations.length} conversations');
// //       } else {
// //         setState(() {
// //           _error = response.data['message'] ?? 'Failed to load conversations';
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       print('❌ Error loading conversations: $e');
// //       setState(() {
// //         _error = 'Failed to load conversations: ${e.toString()}';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _socketService.off('receive_message');
// //     _socketService.off('message_sent');
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppConstants.backgroundGray,
// //       appBar: AppBar(
// //         title: const Text(
// //           'Messages',
// //           style: TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         actions: [
// //           // Socket connection status indicator
// //           Padding(
// //             padding: const EdgeInsets.only(right: 8),
// //             child: Center(
// //               child: Container(
// //                 width: 8,
// //                 height: 8,
// //                 decoration: BoxDecoration(
// //                   color: _socketService.isConnected ? Colors.green : Colors.red,
// //                   shape: BoxShape.circle,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.edit_square),
// //             onPressed: () {
// //               // TODO: Navigate to new chat (user search)
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Go to Search tab to find users')),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //       body: _isLoading
// //           ? Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   CircularProgressIndicator(
// //                     valueColor: AlwaysStoppedAnimation(
// //                       AppConstants.primaryBlue,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   const Text('Loading conversations...'),
// //                 ],
// //               ),
// //             )
// //           : _error != null
// //           ? _buildErrorState()
// //           : _conversations.isEmpty
// //           ? _buildEmptyState()
// //           : RefreshIndicator(
// //               onRefresh: _loadConversations,
// //               child: ListView.builder(
// //                 itemCount: _conversations.length,
// //                 itemBuilder: (context, index) {
// //                   final conv = _conversations[index];
// //                   return _buildConversationTile(conv);
// //                 },
// //               ),
// //             ),
// //     );
// //   }

// //   Widget _buildErrorState() {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'Failed to load',
// //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               _error ?? 'Unknown error',
// //               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 24),
// //             ElevatedButton.icon(
// //               onPressed: _loadConversations,
// //               icon: const Icon(Icons.refresh),
// //               label: const Text('Try Again'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: AppConstants.primaryBlue,
// //                 foregroundColor: Colors.white,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
// //           const SizedBox(height: 16),
// //           Text(
// //             'No conversations yet',
// //             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'Start chatting with your friends!',
// //             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
// //           ),
// //           const SizedBox(height: 24),
// //           ElevatedButton.icon(
// //             onPressed: () {
// //               // Navigate to search tab
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Go to Search tab to find users')),
// //               );
// //             },
// //             icon: const Icon(Icons.search),
// //             label: const Text('Find Friends'),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: AppConstants.primaryBlue,
// //               foregroundColor: Colors.white,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildConversationTile(dynamic conv) {
// //     final participant = conv['participant'];
// //     final lastMessage = conv['lastMessage'];
// //     final unreadCount = conv['unreadCount'] ?? 0;

// //     String timeAgo = '';
// //     if (conv['lastMessageTime'] != null) {
// //       try {
// //         final date = DateTime.parse(conv['lastMessageTime']);
// //         final now = DateTime.now();
// //         final difference = now.difference(date);

// //         if (difference.inDays == 0) {
// //           timeAgo = DateFormat('HH:mm').format(date);
// //         } else if (difference.inDays == 1) {
// //           timeAgo = 'Yesterday';
// //         } else {
// //           timeAgo = DateFormat('dd/MM/yy').format(date);
// //         }
// //       } catch (e) {
// //         timeAgo = '';
// //       }
// //     }

// //     return Container(
// //       color: Colors.white,
// //       margin: const EdgeInsets.only(bottom: 1),
// //       child: ListTile(
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //         leading: CircleAvatar(
// //           radius: 28,
// //           backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
// //           backgroundImage:
// //               participant['profilePicture'] != null &&
// //                   participant['profilePicture'].toString().isNotEmpty
// //               ? NetworkImage(participant['profilePicture'])
// //               : null,
// //           child:
// //               participant['profilePicture'] == null ||
// //                   participant['profilePicture'].toString().isEmpty
// //               ? Icon(Icons.person, color: AppConstants.primaryBlue)
// //               : null,
// //         ),
// //         title: Text(
// //           participant['fullName']?.toString() ??
// //               participant['username']?.toString() ??
// //               'Unknown',
// //           style: TextStyle(
// //             fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
// //             fontSize: 16,
// //           ),
// //         ),
// //         subtitle: Text(
// //           lastMessage?['content']?.toString() ?? 'No messages yet',
// //           maxLines: 1,
// //           overflow: TextOverflow.ellipsis,
// //           style: TextStyle(
// //             color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
// //             fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
// //           ),
// //         ),
// //         trailing: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           children: [
// //             Text(
// //               timeAgo,
// //               style: TextStyle(
// //                 fontSize: 12,
// //                 color: unreadCount > 0 ? AppConstants.primaryBlue : Colors.grey,
// //               ),
// //             ),
// //             if (unreadCount > 0) ...[
// //               const SizedBox(height: 4),
// //               Container(
// //                 padding: const EdgeInsets.all(6),
// //                 decoration: BoxDecoration(
// //                   color: AppConstants.primaryBlue,
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: Text(
// //                   unreadCount > 9 ? '9+' : unreadCount.toString(),
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //         onTap: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => ChatScreen(
// //                 otherUserId: participant['_id']?.toString() ?? '',
// //                 otherUserName:
// //                     participant['fullName']?.toString() ??
// //                     participant['username']?.toString() ??
// //                     'Unknown',
// //                 otherUserAvatar: participant['profilePicture']?.toString(),
// //                 conversationId: conv['_id']?.toString() ?? '',
// //               ),
// //             ),
// //           ).then((_) => _loadConversations());
// //         },
// //       ),
// //     );
// //   }
// // }

// lib/features/chat/presentation/pages/conversations_screen.dart
// COMPLETE STANDALONE VERSION - With built-in user search

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/post/presentation/providers/post_provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/socket_service.dart';
import 'chat_screen.dart';
import 'dart:async';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  List<dynamic> _conversations = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _showSearch = false;
  String? _error;
  final SocketService _socketService = SocketService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _loadConversations();
  }

  Future<void> _initializeSocket() async {
    await _socketService.connect();

    // Listen for new messages
    _socketService.on('receive_message', (data) {
      print('📨 New message received in conversations');
      _loadConversations();
    });

    _socketService.on('message_sent', (data) {
      print('✅ Message sent confirmation in conversations');
      _loadConversations();
    });
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.get('/api/messages/conversations');

      if (response.data is Map && response.data['success'] == true) {
        setState(() {
          _conversations = response.data['data'] as List? ?? [];
          _isLoading = false;
        });
        print('✅ Loaded ${_conversations.length} conversations');
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Failed to load conversations';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading conversations: $e');
      setState(() {
        _error = 'Failed to load conversations';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Clear results if query is too short
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Debounce search - wait 300ms after user stops typing
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchUsers(query.trim());
    });
  }

  Future<void> _searchUsers(String query) async {
    // Only search if query has 2 or more characters
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final dioClient = ref.read(dioClientProvider);

      // ✅ FIXED: Use 'q' parameter to match backend
      final response = await dioClient.get(
        '/api/auth/search',
        queryParameters: {'q': query.trim()},
      );

      print('🔍 Search API Response: ${response.data}');

      if (response.data is Map && response.data['success'] == true) {
        final users = response.data['data'] as List? ?? [];
        print('✅ Found ${users.length} users');

        setState(() {
          _searchResults = users;
          _isSearching = false;
        });
      } else {
        print('⚠️ Search returned no success');
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('❌ Error searching users: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchResults = [];
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _socketService.off('receive_message');
    _socketService.off('message_sent');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundGray,
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: const TextStyle(fontSize: 16),
              )
            : const Text(
                'Messages',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Socket connection indicator
          if (!_showSearch)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _socketService.isConnected
                        ? Colors.green
                        : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          // Search toggle button
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.person_add),
            onPressed: _toggleSearch,
            tooltip: _showSearch ? 'Close' : 'New Chat',
          ),
        ],
      ),
      body: _showSearch ? _buildSearchView() : _buildConversationsView(),
    );
  }

  Widget _buildSearchView() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppConstants.primaryBlue),
            ),
            const SizedBox(height: 16),
            const Text('Searching...'),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryBlue.withOpacity(0.1),
                    AppConstants.primaryIndigo.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 50,
                color: AppConstants.primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Search for users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Find friends to start chatting',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // ✅ ADDED: Show message if query is too short
    if (_searchController.text.trim().length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_fields, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Keep typing...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Type at least 2 characters to search',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No users found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserSearchTile(user);
      },
    );
  }

  Widget _buildUserSearchTile(dynamic user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
          backgroundImage:
              user['profilePicture'] != null &&
                  user['profilePicture'].toString().isNotEmpty
              ? NetworkImage(user['profilePicture'])
              : null,
          child:
              user['profilePicture'] == null ||
                  user['profilePicture'].toString().isEmpty
              ? Icon(Icons.person, color: AppConstants.primaryBlue)
              : null,
        ),
        title: Text(
          user['fullName']?.toString() ??
              user['username']?.toString() ??
              'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user['username']?.toString() ?? 'unknown'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            if (user['followersCount'] != null && user['followersCount'] > 0)
              Text(
                '${user['followersCount']} followers',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Start new conversation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      otherUserId: user['_id']?.toString() ?? '',
                      otherUserName:
                          user['fullName']?.toString() ??
                          user['username']?.toString() ??
                          'Unknown',
                      otherUserAvatar: user['profilePicture']?.toString(),
                      conversationId: '', // Empty for new conversation
                    ),
                  ),
                ).then((_) {
                  // Refresh conversations and close search
                  _loadConversations();
                  _toggleSearch();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.message, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsView() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppConstants.primaryBlue),
            ),
            const SizedBox(height: 16),
            const Text('Loading conversations...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conv = _conversations[index];
          return _buildConversationTile(conv);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadConversations,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with your friends!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _toggleSearch,
            icon: const Icon(Icons.person_add),
            label: const Text('Find Friends'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(dynamic conv) {
    final participant = conv['participant'];
    final lastMessage = conv['lastMessage'];
    final unreadCount = conv['unreadCount'] ?? 0;

    String timeAgo = '';
    if (conv['lastMessageTime'] != null) {
      try {
        final date = DateTime.parse(conv['lastMessageTime']);
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inDays == 0) {
          timeAgo = DateFormat('HH:mm').format(date);
        } else if (difference.inDays == 1) {
          timeAgo = 'Yesterday';
        } else {
          timeAgo = DateFormat('dd/MM/yy').format(date);
        }
      } catch (e) {
        timeAgo = '';
      }
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
          backgroundImage:
              participant['profilePicture'] != null &&
                  participant['profilePicture'].toString().isNotEmpty
              ? NetworkImage(participant['profilePicture'])
              : null,
          child:
              participant['profilePicture'] == null ||
                  participant['profilePicture'].toString().isEmpty
              ? Icon(Icons.person, color: AppConstants.primaryBlue)
              : null,
        ),
        title: Text(
          participant['fullName']?.toString() ??
              participant['username']?.toString() ??
              'Unknown',
          style: TextStyle(
            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          lastMessage?['content']?.toString() ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0 ? AppConstants.primaryBlue : Colors.grey,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                otherUserId: participant['_id']?.toString() ?? '',
                otherUserName:
                    participant['fullName']?.toString() ??
                    participant['username']?.toString() ??
                    'Unknown',
                otherUserAvatar: participant['profilePicture']?.toString(),
                conversationId: conv['_id']?.toString() ?? '',
              ),
            ),
          ).then((_) => _loadConversations());
        },
      ),
    );
  }
}
