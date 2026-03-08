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

// lib/features/post/presentation/pages/home_screen.dart
// INTEGRATED VERSION - All 3 Sensors: Shake, Proximity, Tilt

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/core/constants/hive_constants.dart';
// import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
// import 'package:hive/hive.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/utils/snackbar_utils.dart';
// import '../../../../core/widgets/sensor_widgets.dart'; // ✅ ADD THIS
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

//     // Initial load - ONCE ONLY
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final currentState = ref.read(postFeedProvider);
//       // Only load if not already loaded
//       if (currentState.posts.isEmpty && !currentState.isLoading) {
//         ref.read(postFeedProvider.notifier).fetchFeed(refresh: true);
//       }
//     });

//     _scrollController.addListener(_onScroll);

//     ref.listenManual(connectivityProvider, (previous, next) {
//       next.whenData((isConnected) {
//         if (isConnected && previous != null) {
//           ref.read(postFeedProvider.notifier).refresh();
//           SnackBarUtils.showSuccess(context, 'Back online!');
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

//   // ✅ NEW: Shake handler
//   void _handleShake() {
//     print('🔄 Shake detected - Refreshing feed!');
//     _onRefresh();

//     // Optional: Show feedback
//     SnackBarUtils.showSuccess(context, 'Refreshing feed...');
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

//   @override
//   Widget build(BuildContext context) {
//     final postFeedState = ref.watch(postFeedProvider);
//     final connectivity = ref.watch(connectivityProvider);

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       // ✅ WRAP ENTIRE BODY WITH SENSORS
//       body: ShakeDetectorWidget(
//         onShake: _handleShake,
//         enabled: true, // Can toggle based on settings
//         child: TiltScrollWidget(
//           scrollController: _scrollController,
//           enabled: true, // Can toggle based on settings
//           child: ProximityDetectorWidget(
//             enabled: true, // Can toggle based on settings
//             child: Column(
//               children: [
//                 // Welcome Banner
//                 _buildWelcomeBanner(),

//                 // Offline Indicator
//                 connectivity.when(
//                   data: (isConnected) => !isConnected
//                       ? _buildOfflineIndicator()
//                       : const SizedBox.shrink(),
//                   loading: () => const SizedBox.shrink(),
//                   error: (_, __) => const SizedBox.shrink(),
//                 ),

//                 // Feed Content
//                 Expanded(child: _buildFeedContent(postFeedState)),
//               ],
//             ),
//           ),
//         ),
//       ),

//       // Floating Create Post Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const CreatePostScreen()),
//           );

//           if (result == true) {
//             _onRefresh();
//           }
//         },
//         backgroundColor: AppConstants.primaryBlue,
//         child: const Icon(Icons.add, size: 28),
//       ),
//     );
//   }

//   Widget _buildWelcomeBanner() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: AppConstants.primaryGradient,
//         borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: AppConstants.primaryBlue.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Welcome back! 👋',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Discover what your friends are up to',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.trending_up, size: 40, color: Colors.white70),
//         ],
//       ),
//     );
//   }

//   Widget _buildOfflineIndicator() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       color: Colors.orange.shade100,
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
//       return const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
//         ),
//       );
//     }

//     if (state.error != null && state.posts.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               'Failed to load feed',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _onRefresh,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppConstants.primaryBlue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (state.posts.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: AppConstants.primaryBlue.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.auto_awesome,
//                 size: 50,
//                 color: AppConstants.primaryBlue,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'No posts yet',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Be the first to share something amazing!',
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const CreatePostScreen(),
//                   ),
//                 );

//                 if (result == true) {
//                   _onRefresh();
//                 }
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Create Your First Post'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppConstants.primaryBlue,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 14,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _onRefresh,
//       color: AppConstants.primaryBlue,
//       child: ListView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index >= state.posts.length) {
//             return const Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     AppConstants.primaryBlue,
//                   ),
//                 ),
//               ),
//             );
//           }

//           final post = state.posts[index];

//           return PostCard(
//             post: post,
//             currentUserId: _getCurrentUserId(),
//             onLike: () {
//               ref.read(postFeedProvider.notifier).likePost(post.id);
//             },
//             onComment: () {
//               _showCommentBottomSheet(post.id);
//             },
//             onBookmark: () {
//               ref
//                   .read(postFeedProvider.notifier)
//                   .bookmarkPost(post.id, post.isBookmarked);

//               SnackBarUtils.showSuccess(
//                 context,
//                 post.isBookmarked ? 'Post removed from saved' : 'Post saved',
//               );
//             },
//             onTap: () {
//               // Navigate to post detail screen if needed
//             },
//           );
//         },
//       ),
//     );
//   }
// }
