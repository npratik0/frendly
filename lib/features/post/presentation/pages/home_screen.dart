import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/constants/hive_constants.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_bottom_sheet.dart';
import 'create_post_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // DEBUG: Check if token exists
    // _checkToken();

    // // Initial load
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(postFeedProvider.notifier).fetchFeed(refresh: true);
    // });

    // // Setup scroll listener for infinite scroll
    // _scrollController.addListener(_onScroll);

    // // Listen to connectivity changes
    // ref.listenManual(connectivityProvider, (previous, next) {
    //   next.whenData((isConnected) {
    //     if (isConnected && previous != null) {
    //       // Reconnected - sync offline actions
    //       ref.read(postFeedProvider.notifier).refresh();
    //       SnackBarUtils.showSuccess(
    //         context,
    //         'Back online! Syncing your actions...',
    //       );
    //     }
    //   });
    // });

    // Initial load - ONCE ONLY
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(postFeedProvider);
      // Only load if not already loaded
      if (currentState.posts.isEmpty && !currentState.isLoading) {
        ref.read(postFeedProvider.notifier).fetchFeed(refresh: true);
      }
    });

    _scrollController.addListener(_onScroll);

    ref.listenManual(connectivityProvider, (previous, next) {
      next.whenData((isConnected) {
        if (isConnected && previous != null) {
          ref.read(postFeedProvider.notifier).refresh();
          SnackBarUtils.showSuccess(context, 'Back online!');
        }
      });
    });
  }

  // Future<void> _checkToken() async {
  //   final authBox = await Hive.openBox(HiveConstants.authBox);
  //   final token = authBox.get(HiveConstants.tokenKey);

  //   print('🔍 DEBUG: Token check');
  //   print('Token exists: ${token != null}');
  //   if (token != null) {
  //     print('Token preview: ${token.toString().substring(0, 20)}...');
  //   } else {
  //     print('❌ NO TOKEN FOUND - This is why you get 401!');
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postFeedProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(postFeedProvider.notifier).refresh();
  }

  void _showCommentBottomSheet(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(postId: postId),
    );
  }

  // String? _getCurrentUserId() {
  //   // Get from your existing auth storage
  //   final authBox = Hive.box<AuthHiveModels>(
  //     'auth_box',
  //   ); // Adjust box name if needed
  //   // Return user ID from your auth model
  //   return authBox.get('current_user')?.authId; // Adjust based on your model
  // }

  String? _getCurrentUserId() {
    try {
      // Don't open the box again - it's already open!
      // Use Hive.box() instead of Hive.openBox()
      final authBox = Hive.box('auth_box');
      final userData = authBox.get('current_user');

      if (userData != null && userData is Map) {
        return userData['_id'] ?? userData['id'];
      }
      return null;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final postFeedState = ref.watch(postFeedProvider);
    final connectivity = ref.watch(connectivityProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Welcome Banner
          _buildWelcomeBanner(),

          // Offline Indicator
          connectivity.when(
            data: (isConnected) => !isConnected
                ? _buildOfflineIndicator()
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Feed Content
          Expanded(child: _buildFeedContent(postFeedState)),
        ],
      ),

      // Floating Create Post Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );

          if (result == true) {
            _onRefresh();
          }
        },
        backgroundColor: AppConstants.primaryBlue,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back! 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover what your friends are up to',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.trending_up, size: 40, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.orange.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Text(
            'You\'re offline. Changes will sync when reconnected.',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent(PostFeedState state) {
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
        ),
      );
    }

    if (state.error != null && state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load feed',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppConstants.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 50,
                color: AppConstants.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No posts yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something amazing!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );

                if (result == true) {
                  _onRefresh();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppConstants.primaryBlue,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppConstants.primaryBlue,
                  ),
                ),
              ),
            );
          }

          final post = state.posts[index];

          return PostCard(
            post: post,
            // currentUserId: 'current_user_id', // Get from auth provider
            currentUserId: _getCurrentUserId(),
            onLike: () {
              ref.read(postFeedProvider.notifier).likePost(post.id);
            },
            onComment: () {
              _showCommentBottomSheet(post.id);
            },
            onBookmark: () {
              ref
                  .read(postFeedProvider.notifier)
                  .bookmarkPost(post.id, post.isBookmarked);

              SnackBarUtils.showSuccess(
                context,
                post.isBookmarked ? 'Post removed from saved' : 'Post saved',
              );
            },
            onTap: () {
              // Navigate to post detail screen if needed
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/core/constants/hive_constants.dart';
// import 'package:hive/hive.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/utils/snackbar_utils.dart';
// import '../providers/post_provider.dart';
// import '../widgets/post_card.dart';
// import '../widgets/comment_bottom_sheet.dart';
// import 'create_post_screen.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();

//     // Initial load
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(postFeedProvider.notifier).fetchFeed(refresh: true);
//     });

//     // Setup scroll listener for infinite scroll
//     _scrollController.addListener(_onScroll);

//     // Listen to connectivity changes
//     ref.listenManual(connectivityProvider, (previous, next) {
//       next.whenData((isConnected) {
//         if (isConnected && previous != null) {
//           ref.read(postFeedProvider.notifier).refresh();
//           SnackBarUtils.showSuccess(
//             context,
//             'Back online! Syncing your actions...',
//           );
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       ref.read(postFeedProvider.notifier).loadMore();
//     }
//   }

//   Future<void> _onRefresh() async {
//     await ref.read(postFeedProvider.notifier).refresh();
//   }

//   void _showCommentBottomSheet(String postId) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => CommentBottomSheet(postId: postId),
//     );
//   }

//   String? _getCurrentUserId() {
//     try {
//       final authBox = Hive.box('auth_box');
//       final userData = authBox.get('current_user');
//       if (userData != null && userData is Map) {
//         return userData['_id'] ?? userData['id'];
//       }
//       return null;
//     } catch (e) {
//       print('Error getting current user ID: $e');
//       return null;
//     }
//   }

//   String? _getCurrentUserName() {
//     try {
//       final authBox = Hive.box('auth_box');
//       final userData = authBox.get('current_user');
//       if (userData != null && userData is Map) {
//         return userData['fullName'] ?? userData['username'];
//       }
//       return 'User';
//     } catch (e) {
//       return 'User';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final postFeedState = ref.watch(postFeedProvider);
//     final connectivity = ref.watch(connectivityProvider);

//     return Scaffold(
//       backgroundColor: AppConstants.backgroundGray,
//       body: Column(
//         children: [
//           // Modern App Bar
//           _buildModernAppBar(context),

//           // Offline Indicator
//           connectivity.when(
//             data: (isConnected) => !isConnected
//                 ? _buildOfflineIndicator()
//                 : const SizedBox.shrink(),
//             loading: () => const SizedBox.shrink(),
//             error: (_, __) => const SizedBox.shrink(),
//           ),

//           // Feed Content
//           Expanded(child: _buildFeedContent(postFeedState)),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernAppBar(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             children: [
//               // Menu Icon (Drawer)
//               IconButton(
//                 icon: const Icon(Icons.menu, size: 28),
//                 onPressed: () {
//                   Scaffold.of(context).openDrawer();
//                 },
//                 color: AppConstants.primaryBlue,
//               ),

//               const SizedBox(width: 8),

//               // Frendly Logo
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: AppConstants.primaryGradient,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.auto_awesome,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Frendly',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 16),

//               // Create Post Button
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     final result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const CreatePostScreen(),
//                       ),
//                     );

//                     if (result == true) {
//                       _onRefresh();
//                     }
//                   },
//                   child: Container(
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(22),
//                       border: Border.all(color: Colors.grey[300]!),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.add_circle_outline,
//                           color: Colors.grey[600],
//                           size: 22,
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           'What\'s on your mind, ${_getCurrentUserName()?.split(' ').first ?? 'there'}?',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 12),

//               // Notifications Icon
//               Stack(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.notifications_outlined, size: 28),
//                     onPressed: () {
//                       // Navigate to notifications
//                     },
//                     color: AppConstants.textPrimary,
//                   ),
//                   Positioned(
//                     right: 8,
//                     top: 8,
//                     child: Container(
//                       width: 8,
//                       height: 8,
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOfflineIndicator() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade100,
//         border: Border(
//           bottom: BorderSide(color: Colors.orange.shade200, width: 1),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade800),
//           const SizedBox(width: 8),
//           Text(
//             'You\'re offline. Changes will sync when reconnected.',
//             style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeedContent(PostFeedState state) {
//     if (state.isLoading && state.posts.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 gradient: AppConstants.primaryGradient,
//                 shape: BoxShape.circle,
//               ),
//               child: const Padding(
//                 padding: EdgeInsets.all(12),
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   strokeWidth: 3,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Loading your feed...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (state.error != null && state.posts.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.error_outline,
//                   size: 50,
//                   color: Colors.red.shade400,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Oops! Something went wrong',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'We couldn\'t load your feed',
//                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _onRefresh,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Try Again'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppConstants.primaryBlue,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 16,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (state.posts.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppConstants.primaryBlue.withOpacity(0.1),
//                       AppConstants.primaryIndigo.withOpacity(0.1),
//                     ],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.auto_awesome,
//                   size: 60,
//                   color: AppConstants.primaryBlue,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               const Text(
//                 'No posts yet',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Be the first to share something amazing!',
//                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const CreatePostScreen(),
//                     ),
//                   );

//                   if (result == true) {
//                     _onRefresh();
//                   }
//                 },
//                 icon: const Icon(Icons.add_photo_alternate, size: 24),
//                 label: const Text(
//                   'Create Your First Post',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppConstants.primaryBlue,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 18,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   elevation: 0,
//                   shadowColor: AppConstants.primaryBlue.withOpacity(0.3),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _onRefresh,
//       color: AppConstants.primaryBlue,
//       child: ListView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.only(top: 8, bottom: 80),
//         itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index >= state.posts.length) {
//             return Padding(
//               padding: const EdgeInsets.all(24),
//               child: Center(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: 32,
//                       height: 32,
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           AppConstants.primaryBlue,
//                         ),
//                         strokeWidth: 3,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Loading more posts...',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final post = state.posts[index];

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
//             child: PostCard(
//               post: post,
//               currentUserId: _getCurrentUserId(),
//               onLike: () {
//                 ref.read(postFeedProvider.notifier).likePost(post.id);
//               },
//               onComment: () {
//                 _showCommentBottomSheet(post.id);
//               },
//               onBookmark: () {
//                 ref
//                     .read(postFeedProvider.notifier)
//                     .bookmarkPost(post.id, post.isBookmarked);

//                 SnackBarUtils.showSuccess(
//                   context,
//                   post.isBookmarked
//                       ? 'Removed from saved'
//                       : 'Saved successfully',
//                 );
//               },
//               onTap: () {
//                 // Navigate to post detail screen if needed
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
