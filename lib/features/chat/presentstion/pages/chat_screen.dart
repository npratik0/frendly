// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/features/post/presentation/providers/post_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:hive/hive.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/network/dio_client.dart';
// import '../../../../core/services/socket_service.dart';
// import 'dart:async';

// class ChatScreen extends ConsumerStatefulWidget {
//   final String otherUserId;
//   final String otherUserName;
//   final String? otherUserAvatar;
//   final String conversationId;

//   const ChatScreen({
//     Key? key,
//     required this.otherUserId,
//     required this.otherUserName,
//     this.otherUserAvatar,
//     required this.conversationId,
//   }) : super(key: key);

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final SocketService _socketService = SocketService();

//   List<dynamic> _messages = [];
//   bool _isLoading = true;
//   bool _isTyping = false;
//   String? _currentUserId;
//   Timer? _typingTimer;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//     _loadMessages();
//     _setupSocketListeners();
//     _markAsRead();
//   }

//   void _loadCurrentUser() {
//     try {
//       final authBox = Hive.box('auth_box');
//       final userData = authBox.get('current_user');
//       _currentUserId = userData?['_id'] ?? userData?['id'];
//     } catch (e) {
//       print('Error loading current user: $e');
//     }
//   }

//   Future<void> _loadMessages() async {
//     try {
//       final dioClient = ref.read(dioClientProvider);
//       final response = await dioClient.get(
//         '/api/messages/user/${widget.otherUserId}',
//       );

//       setState(() {
//         _messages = response.data as List? ?? [];
//         _isLoading = false;
//       });

//       // Scroll to bottom
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     } catch (e) {
//       print('Error loading messages: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   void _setupSocketListeners() {
//     // Listen for new messages
//     _socketService.on('receive_message', (data) {
//       if (data['message']['sender']['_id'] == widget.otherUserId) {
//         setState(() {
//           _messages.add(data['message']);
//         });
//         _scrollToBottom();
//         _markAsRead();
//       }
//     });

//     // Listen for message sent confirmation
//     _socketService.on('message_sent', (data) {
//       setState(() {
//         _messages.add(data['message']);
//       });
//       _scrollToBottom();
//     });

//     // Listen for typing indicator
//     _socketService.on('user_typing', (data) {
//       if (data['userId'] == widget.otherUserId) {
//         setState(() => _isTyping = true);
//       }
//     });

//     _socketService.on('user_stopped_typing', (data) {
//       if (data['userId'] == widget.otherUserId) {
//         setState(() => _isTyping = false);
//       }
//     });
//   }

//   Future<void> _markAsRead() async {
//     try {
//       _socketService.emit('mark_as_read', {
//         'conversationId': widget.conversationId,
//       });
//     } catch (e) {
//       print('Error marking as read: $e');
//     }
//   }

//   void _sendMessage() {
//     final text = _messageController.text.trim();
//     if (text.isEmpty) return;

//     _socketService.emit('send_message', {
//       'receiverId': widget.otherUserId,
//       'content': text,
//       'messageType': 'text',
//     });

//     _messageController.clear();
//     _stopTyping();
//   }

//   void _onTypingChanged(String text) {
//     if (text.isNotEmpty) {
//       _socketService.emit('typing_start', {'receiverId': widget.otherUserId});

//       // Cancel previous timer
//       _typingTimer?.cancel();

//       // Set new timer to stop typing after 2 seconds of inactivity
//       _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
//     }
//   }

//   void _stopTyping() {
//     _socketService.emit('typing_stop', {'receiverId': widget.otherUserId});
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _typingTimer?.cancel();
//     _socketService.off('receive_message');
//     _socketService.off('message_sent');
//     _socketService.off('user_typing');
//     _socketService.off('user_stopped_typing');
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppConstants.backgroundGray,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 18,
//               backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
//               backgroundImage:
//                   widget.otherUserAvatar != null &&
//                       widget.otherUserAvatar!.isNotEmpty
//                   ? NetworkImage(widget.otherUserAvatar!)
//                   : null,
//               child:
//                   widget.otherUserAvatar == null ||
//                       widget.otherUserAvatar!.isEmpty
//                   ? Icon(
//                       Icons.person,
//                       color: AppConstants.primaryBlue,
//                       size: 20,
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.otherUserName,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (_isTyping)
//                     const Text(
//                       'typing...',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppConstants.primaryBlue,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _isLoading
//                 ? Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation(
//                         AppConstants.primaryBlue,
//                       ),
//                     ),
//                   )
//                 : _messages.isEmpty
//                 ? _buildEmptyState()
//                 : ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       final message = _messages[index];
//                       final isMe = message['sender']['_id'] == _currentUserId;
//                       return _buildMessageBubble(message, isMe);
//                     },
//                   ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.chat_outlined, size: 80, color: Colors.grey[300]),
//           const SizedBox(height: 16),
//           Text(
//             'No messages yet',
//             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Send a message to start chatting!',
//             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(dynamic message, bool isMe) {
//     final time = DateFormat(
//       'HH:mm',
//     ).format(DateTime.parse(message['createdAt']));

//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.7,
//         ),
//         decoration: BoxDecoration(
//           color: isMe ? AppConstants.primaryBlue : Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(16),
//             topRight: const Radius.circular(16),
//             bottomLeft: Radius.circular(isMe ? 16 : 4),
//             bottomRight: Radius.circular(isMe ? 4 : 16),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               message['content'],
//               style: TextStyle(
//                 color: isMe ? Colors.white : Colors.black87,
//                 fontSize: 15,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   time,
//                   style: TextStyle(
//                     color: isMe ? Colors.white70 : Colors.grey,
//                     fontSize: 11,
//                   ),
//                 ),
//                 if (isMe) ...[
//                   const SizedBox(width: 4),
//                   Icon(
//                     message['isRead'] == true
//                         ? Icons.done_all
//                         : message['isDelivered'] == true
//                         ? Icons.done_all
//                         : Icons.done,
//                     size: 14,
//                     color: message['isRead'] == true
//                         ? Colors.blue[200]
//                         : Colors.white70,
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               onChanged: _onTypingChanged,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//               ),
//               maxLines: null,
//               textCapitalization: TextCapitalization.sentences,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             decoration: BoxDecoration(
//               gradient: AppConstants.primaryGradient,
//               shape: BoxShape.circle,
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white),
//               onPressed: _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // lib/features/chat/presentation/pages/chat_screen.dart
// // FIXED VERSION - Proper API response handling + debugging

// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:frendly/features/post/presentation/providers/post_provider.dart';
// // import 'package:intl/intl.dart';
// // import 'package:hive/hive.dart';
// // import '../../../../core/constants/app_constants.dart';
// // import '../../../../core/network/dio_client.dart';
// // import '../../../../core/services/socket_service.dart';
// // import 'dart:async';

// // class ChatScreen extends ConsumerStatefulWidget {
// //   final String otherUserId;
// //   final String otherUserName;
// //   final String? otherUserAvatar;
// //   final String conversationId;

// //   const ChatScreen({
// //     Key? key,
// //     required this.otherUserId,
// //     required this.otherUserName,
// //     this.otherUserAvatar,
// //     required this.conversationId,
// //   }) : super(key: key);

// //   @override
// //   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// // }

// // class _ChatScreenState extends ConsumerState<ChatScreen> {
// //   final TextEditingController _messageController = TextEditingController();
// //   final ScrollController _scrollController = ScrollController();
// //   final SocketService _socketService = SocketService();

// //   List<dynamic> _messages = [];
// //   bool _isLoading = true;
// //   bool _isTyping = false;
// //   bool _isSending = false;
// //   String? _currentUserId;
// //   String? _error;
// //   Timer? _typingTimer;

// //   @override
// //   void initState() {
// //     super.initState();
// //     print('\n🔵 ChatScreen initialized');
// //     print('   Other User ID: ${widget.otherUserId}');
// //     print('   Conversation ID: ${widget.conversationId}');

// //     _loadCurrentUser();
// //     _loadMessages();
// //     _setupSocketListeners();

// //     if (widget.conversationId.isNotEmpty) {
// //       _markAsRead();
// //     }
// //   }

// //   void _loadCurrentUser() {
// //     try {
// //       final authBox = Hive.box('auth_box');
// //       final userData = authBox.get('current_user');
// //       _currentUserId = userData?['_id'] ?? userData?['id'];
// //       print('✅ Current User ID: $_currentUserId');
// //     } catch (e) {
// //       print('❌ Error loading current user: $e');
// //     }
// //   }

// //   Future<void> _loadMessages() async {
// //     if (widget.otherUserId.isEmpty) {
// //       print('❌ Cannot load messages: otherUserId is empty');
// //       setState(() {
// //         _error = 'Invalid user ID';
// //         _isLoading = false;
// //       });
// //       return;
// //     }

// //     print('\n📥 Loading messages with user: ${widget.otherUserId}');

// //     try {
// //       final dioClient = ref.read(dioClientProvider);
// //       final response = await dioClient.get(
// //         '/api/messages/user/${widget.otherUserId}',
// //       );

// //       print('📱 Messages API Response: ${response.data}');

// //       // ✅ FIXED: Proper success check
// //       if (response.data is Map && response.data['success'] == true) {
// //         final messagesList = response.data['data'] as List? ?? [];
// //         print('✅ Loaded ${messagesList.length} messages');

// //         setState(() {
// //           _messages = messagesList;
// //           _isLoading = false;
// //           _error = null;
// //         });

// //         // Scroll to bottom after loading
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           if (_scrollController.hasClients) {
// //             _scrollController.jumpTo(
// //               _scrollController.position.maxScrollExtent,
// //             );
// //           }
// //         });
// //       } else {
// //         setState(() {
// //           _error = response.data['message'] ?? 'Failed to load messages';
// //           _isLoading = false;
// //         });
// //         print('❌ API returned error: $_error');
// //       }
// //     } catch (e) {
// //       print('❌ Error loading messages: $e');
// //       setState(() {
// //         _error = 'Failed to load messages: ${e.toString()}';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   void _setupSocketListeners() {
// //     print('🔌 Setting up socket listeners');

// //     // Listen for new messages
// //     _socketService.on('receive_message', (data) {
// //       print('\n📨 RECEIVE_MESSAGE event');
// //       print('   Data: $data');

// //       try {
// //         final message = data['message'];
// //         final senderId = message['sender']['_id'] ?? message['sender'];

// //         if (senderId == widget.otherUserId) {
// //           print('✅ Message is from current chat partner, adding to list');
// //           setState(() {
// //             _messages.add(message);
// //           });
// //           _scrollToBottom();
// //           _markAsRead();
// //         } else {
// //           print('⚠️ Message is from different user: $senderId');
// //         }
// //       } catch (e) {
// //         print('❌ Error processing received message: $e');
// //       }
// //     });

// //     // Listen for message sent confirmation
// //     _socketService.on('message_sent', (data) {
// //       print('\n✅ MESSAGE_SENT confirmation');
// //       print('   Data: $data');

// //       try {
// //         final message = data['message'];
// //         setState(() {
// //           // Check if message already exists (avoid duplicates)
// //           final exists = _messages.any((m) => m['_id'] == message['_id']);

// //           if (!exists) {
// //             _messages.add(message);
// //             print('✅ Message added to list');
// //           } else {
// //             print('⚠️ Message already in list, skipping');
// //           }

// //           _isSending = false;
// //         });
// //         _scrollToBottom();
// //       } catch (e) {
// //         print('❌ Error processing sent confirmation: $e');
// //         setState(() => _isSending = false);
// //       }
// //     });

// //     // Listen for message errors
// //     _socketService.on('message_error', (data) {
// //       print('❌ MESSAGE_ERROR: $data');
// //       setState(() => _isSending = false);

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Failed to send message: ${data['error']}'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     });

// //     // Listen for typing indicator
// //     _socketService.on('user_typing', (data) {
// //       if (data['userId'] == widget.otherUserId) {
// //         setState(() => _isTyping = true);
// //       }
// //     });

// //     _socketService.on('user_stopped_typing', (data) {
// //       if (data['userId'] == widget.otherUserId) {
// //         setState(() => _isTyping = false);
// //       }
// //     });
// //   }

// //   Future<void> _markAsRead() async {
// //     if (widget.conversationId.isEmpty) return;

// //     try {
// //       print('📖 Marking messages as read');
// //       _socketService.emit('mark_as_read', {
// //         'conversationId': widget.conversationId,
// //       });
// //     } catch (e) {
// //       print('❌ Error marking as read: $e');
// //     }
// //   }

// //   void _sendMessage() {
// //     final text = _messageController.text.trim();
// //     if (text.isEmpty || _isSending) {
// //       print('⚠️ Cannot send: text empty or already sending');
// //       return;
// //     }

// //     if (!_socketService.isConnected) {
// //       print('❌ Socket not connected!');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Not connected. Please check your connection.'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }

// //     setState(() => _isSending = true);

// //     print('\n📤 SENDING MESSAGE');
// //     print('   To: ${widget.otherUserId}');
// //     print('   Content: $text');
// //     print('   Socket connected: ${_socketService.isConnected}');

// //     _socketService.emit('send_message', {
// //       'receiverId': widget.otherUserId,
// //       'content': text,
// //       'messageType': 'text',
// //     });

// //     _messageController.clear();
// //     _stopTyping();

// //     // Auto-cancel sending state after 5 seconds if no response
// //     Future.delayed(const Duration(seconds: 5), () {
// //       if (_isSending) {
// //         print('⚠️ Message send timeout, resetting state');
// //         setState(() => _isSending = false);
// //       }
// //     });
// //   }

// //   void _onTypingChanged(String text) {
// //     if (text.isNotEmpty) {
// //       _socketService.emit('typing_start', {'receiverId': widget.otherUserId});

// //       _typingTimer?.cancel();
// //       _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
// //     }
// //   }

// //   void _stopTyping() {
// //     _socketService.emit('typing_stop', {'receiverId': widget.otherUserId});
// //   }

// //   void _scrollToBottom() {
// //     if (_scrollController.hasClients) {
// //       _scrollController.animateTo(
// //         _scrollController.position.maxScrollExtent,
// //         duration: const Duration(milliseconds: 300),
// //         curve: Curves.easeOut,
// //       );
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     print('🔴 ChatScreen disposing');
// //     _messageController.dispose();
// //     _scrollController.dispose();
// //     _typingTimer?.cancel();
// //     _socketService.off('receive_message');
// //     _socketService.off('message_sent');
// //     _socketService.off('message_error');
// //     _socketService.off('user_typing');
// //     _socketService.off('user_stopped_typing');
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppConstants.backgroundGray,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: Row(
// //           children: [
// //             Stack(
// //               children: [
// //                 CircleAvatar(
// //                   radius: 18,
// //                   backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
// //                   backgroundImage:
// //                       widget.otherUserAvatar != null &&
// //                           widget.otherUserAvatar!.isNotEmpty
// //                       ? NetworkImage(widget.otherUserAvatar!)
// //                       : null,
// //                   child:
// //                       widget.otherUserAvatar == null ||
// //                           widget.otherUserAvatar!.isEmpty
// //                       ? Icon(
// //                           Icons.person,
// //                           color: AppConstants.primaryBlue,
// //                           size: 20,
// //                         )
// //                       : null,
// //                 ),
// //                 // Socket connection indicator
// //                 Positioned(
// //                   right: 0,
// //                   bottom: 0,
// //                   child: Container(
// //                     width: 12,
// //                     height: 12,
// //                     decoration: BoxDecoration(
// //                       color: _socketService.isConnected
// //                           ? Colors.green
// //                           : Colors.red,
// //                       shape: BoxShape.circle,
// //                       border: Border.all(color: Colors.white, width: 2),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     widget.otherUserName,
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   if (_isTyping)
// //                     const Text(
// //                       'typing...',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: AppConstants.primaryBlue,
// //                         fontStyle: FontStyle.italic,
// //                       ),
// //                     )
// //                   else if (!_socketService.isConnected)
// //                     const Text(
// //                       'Disconnected',
// //                       style: TextStyle(fontSize: 12, color: Colors.red),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           if (_error != null)
// //             Container(
// //               padding: const EdgeInsets.all(8),
// //               color: Colors.red[100],
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.error, size: 16, color: Colors.red[900]),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: Text(
// //                       _error!,
// //                       style: TextStyle(color: Colors.red[900], fontSize: 12),
// //                     ),
// //                   ),
// //                   IconButton(
// //                     icon: Icon(Icons.refresh, size: 16, color: Colors.red[900]),
// //                     onPressed: _loadMessages,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           Expanded(
// //             child: _isLoading
// //                 ? Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         CircularProgressIndicator(
// //                           valueColor: AlwaysStoppedAnimation(
// //                             AppConstants.primaryBlue,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 16),
// //                         const Text('Loading messages...'),
// //                       ],
// //                     ),
// //                   )
// //                 : _messages.isEmpty
// //                 ? _buildEmptyState()
// //                 : ListView.builder(
// //                     controller: _scrollController,
// //                     padding: const EdgeInsets.all(16),
// //                     itemCount: _messages.length,
// //                     itemBuilder: (context, index) {
// //                       final message = _messages[index];
// //                       final senderId = message['sender'] is Map
// //                           ? message['sender']['_id']
// //                           : message['sender'];
// //                       final isMe = senderId == _currentUserId;
// //                       return _buildMessageBubble(message, isMe);
// //                     },
// //                   ),
// //           ),
// //           _buildMessageInput(),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.chat_outlined, size: 80, color: Colors.grey[300]),
// //           const SizedBox(height: 16),
// //           Text(
// //             'No messages yet',
// //             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'Send a message to start chatting!',
// //             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildMessageBubble(dynamic message, bool isMe) {
// //     final time = DateFormat(
// //       'HH:mm',
// //     ).format(DateTime.parse(message['createdAt']));

// //     return Align(
// //       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 8),
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //         constraints: BoxConstraints(
// //           maxWidth: MediaQuery.of(context).size.width * 0.7,
// //         ),
// //         decoration: BoxDecoration(
// //           color: isMe ? AppConstants.primaryBlue : Colors.white,
// //           borderRadius: BorderRadius.only(
// //             topLeft: const Radius.circular(16),
// //             topRight: const Radius.circular(16),
// //             bottomLeft: Radius.circular(isMe ? 16 : 4),
// //             bottomRight: Radius.circular(isMe ? 4 : 16),
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 5,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               message['content'],
// //               style: TextStyle(
// //                 color: isMe ? Colors.white : Colors.black87,
// //                 fontSize: 15,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   time,
// //                   style: TextStyle(
// //                     color: isMe ? Colors.white70 : Colors.grey,
// //                     fontSize: 11,
// //                   ),
// //                 ),
// //                 if (isMe) ...[
// //                   const SizedBox(width: 4),
// //                   Icon(
// //                     message['isRead'] == true
// //                         ? Icons.done_all
// //                         : message['isDelivered'] == true
// //                         ? Icons.done_all
// //                         : Icons.done,
// //                     size: 14,
// //                     color: message['isRead'] == true
// //                         ? Colors.blue[200]
// //                         : Colors.white70,
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMessageInput() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, -2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextField(
// //               controller: _messageController,
// //               onChanged: _onTypingChanged,
// //               enabled: !_isSending,
// //               decoration: InputDecoration(
// //                 hintText: _isSending ? 'Sending...' : 'Type a message...',
// //                 filled: true,
// //                 fillColor: Colors.grey[100],
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(24),
// //                   borderSide: BorderSide.none,
// //                 ),
// //                 contentPadding: const EdgeInsets.symmetric(
// //                   horizontal: 20,
// //                   vertical: 10,
// //                 ),
// //               ),
// //               maxLines: null,
// //               textCapitalization: TextCapitalization.sentences,
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           Container(
// //             decoration: BoxDecoration(
// //               gradient: _isSending
// //                   ? LinearGradient(colors: [Colors.grey, Colors.grey[400]!])
// //                   : AppConstants.primaryGradient,
// //               shape: BoxShape.circle,
// //             ),
// //             child: IconButton(
// //               icon: _isSending
// //                   ? const SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         valueColor: AlwaysStoppedAnimation(Colors.white),
// //                       ),
// //                     )
// //                   : const Icon(Icons.send, color: Colors.white),
// //               onPressed: _isSending ? null : _sendMessage,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// lib/features/chat/presentation/pages/chat_screen.dart
// FIXED VERSION - Proper API response handling + debugging

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/post/presentation/providers/post_provider.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/socket_service.dart';
import 'dart:async';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String conversationId;

  const ChatScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.conversationId,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService();

  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isSending = false;
  String? _currentUserId;
  String? _error;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    print('\n🔵 ChatScreen initialized');
    print('   Other User ID: ${widget.otherUserId}');
    print('   Conversation ID: ${widget.conversationId}');

    _loadCurrentUser();
    _loadMessages();
    _setupSocketListeners();

    if (widget.conversationId.isNotEmpty) {
      _markAsRead();
    }
  }

  void _loadCurrentUser() {
    try {
      final authBox = Hive.box('auth_box');
      final userData = authBox.get('current_user');
      _currentUserId = userData?['_id'] ?? userData?['id'];
      print('✅ Current User ID: $_currentUserId');
    } catch (e) {
      print('❌ Error loading current user: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (widget.otherUserId.isEmpty) {
      print('❌ Cannot load messages: otherUserId is empty');
      setState(() {
        _error = 'Invalid user ID';
        _isLoading = false;
      });
      return;
    }

    print('\n📥 Loading messages with user: ${widget.otherUserId}');

    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.get(
        '/api/messages/user/${widget.otherUserId}',
      );

      print('📱 Messages API Response: ${response.data}');

      // ✅ FIXED: Proper success check
      if (response.data is Map && response.data['success'] == true) {
        final messagesList = response.data['data'] as List? ?? [];
        print('✅ Loaded ${messagesList.length} messages');

        setState(() {
          _messages = messagesList;
          _isLoading = false;
          _error = null;
        });

        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Failed to load messages';
          _isLoading = false;
        });
        print('❌ API returned error: $_error');
      }
    } catch (e) {
      print('❌ Error loading messages: $e');
      setState(() {
        _error = 'Failed to load messages: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _setupSocketListeners() {
    print('🔌 Setting up socket listeners');

    // Listen for new messages
    _socketService.on('receive_message', (data) {
      print('\n📨 RECEIVE_MESSAGE event');
      print('   Data: $data');

      try {
        final message = data['message'];
        final senderId = message['sender']['_id'] ?? message['sender'];

        if (senderId == widget.otherUserId) {
          print('✅ Message is from current chat partner, adding to list');
          setState(() {
            _messages.add(message);
          });
          _scrollToBottom();
          _markAsRead();
        } else {
          print('⚠️ Message is from different user: $senderId');
        }
      } catch (e) {
        print('❌ Error processing received message: $e');
      }
    });

    // Listen for message sent confirmation
    _socketService.on('message_sent', (data) {
      print('\n✅ MESSAGE_SENT confirmation');
      print('   Data: $data');

      try {
        final message = data['message'];
        setState(() {
          // Check if message already exists (avoid duplicates)
          final exists = _messages.any((m) => m['_id'] == message['_id']);

          if (!exists) {
            _messages.add(message);
            print('✅ Message added to list');
          } else {
            print('⚠️ Message already in list, skipping');
          }

          _isSending = false;
        });
        _scrollToBottom();
      } catch (e) {
        print('❌ Error processing sent confirmation: $e');
        setState(() => _isSending = false);
      }
    });

    // Listen for message errors
    _socketService.on('message_error', (data) {
      print('❌ MESSAGE_ERROR: $data');
      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${data['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Listen for typing indicator
    _socketService.on('user_typing', (data) {
      if (data['userId'] == widget.otherUserId) {
        setState(() => _isTyping = true);
      }
    });

    _socketService.on('user_stopped_typing', (data) {
      if (data['userId'] == widget.otherUserId) {
        setState(() => _isTyping = false);
      }
    });
  }

  Future<void> _markAsRead() async {
    if (widget.conversationId.isEmpty) return;

    try {
      print('📖 Marking messages as read');
      _socketService.emit('mark_as_read', {
        'conversationId': widget.conversationId,
      });
    } catch (e) {
      print('❌ Error marking as read: $e');
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) {
      print('⚠️ Cannot send: text empty or already sending');
      return;
    }

    if (!_socketService.isConnected) {
      print('❌ Socket not connected!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    print('\n📤 SENDING MESSAGE');
    print('   To: ${widget.otherUserId}');
    print('   Content: $text');
    print('   Socket connected: ${_socketService.isConnected}');

    _socketService.emit('send_message', {
      'receiverId': widget.otherUserId,
      'content': text,
      'messageType': 'text',
    });

    _messageController.clear();
    _stopTyping();

    // Auto-cancel sending state after 5 seconds if no response
    Future.delayed(const Duration(seconds: 5), () {
      if (_isSending) {
        print('⚠️ Message send timeout, resetting state');
        setState(() => _isSending = false);
      }
    });
  }

  void _onTypingChanged(String text) {
    if (text.isNotEmpty) {
      _socketService.emit('typing_start', {'receiverId': widget.otherUserId});

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
    }
  }

  void _stopTyping() {
    _socketService.emit('typing_stop', {'receiverId': widget.otherUserId});
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    print('🔴 ChatScreen disposing');
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _socketService.off('receive_message');
    _socketService.off('message_sent');
    _socketService.off('message_error');
    _socketService.off('user_typing');
    _socketService.off('user_stopped_typing');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
                  backgroundImage:
                      widget.otherUserAvatar != null &&
                          widget.otherUserAvatar!.isNotEmpty
                      ? NetworkImage(widget.otherUserAvatar!)
                      : null,
                  child:
                      widget.otherUserAvatar == null ||
                          widget.otherUserAvatar!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppConstants.primaryBlue,
                          size: 20,
                        )
                      : null,
                ),
                // Socket connection indicator
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _socketService.isConnected
                          ? Colors.green
                          : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isTyping)
                    const Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.primaryBlue,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else if (!_socketService.isConnected)
                    const Text(
                      'Disconnected',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.error, size: 16, color: Colors.red[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[900], fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 16, color: Colors.red[900]),
                    onPressed: _loadMessages,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            AppConstants.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Loading messages...'),
                      ],
                    ),
                  )
                : _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final senderId = message['sender'] is Map
                          ? message['sender']['_id']
                          : message['sender'];
                      final isMe = senderId == _currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start chatting!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isMe) {
    final time = DateFormat(
      'HH:mm',
    ).format(DateTime.parse(message['createdAt']));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppConstants.primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['content'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message['isRead'] == true
                        ? Icons.done_all
                        : message['isDelivered'] == true
                        ? Icons.done_all
                        : Icons.done,
                    size: 14,
                    color: message['isRead'] == true
                        ? Colors.blue[200]
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: _onTypingChanged,
              enabled: !_isSending,
              decoration: InputDecoration(
                hintText: _isSending ? 'Sending...' : 'Type a message...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: _isSending
                  ? LinearGradient(colors: [Colors.grey, Colors.grey[400]!])
                  : AppConstants.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
