import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/posts_grid.dart';
import '../widgets/empty_posts_view.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // null = current user

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
  }

  // void _loadCurrentUser() {
  //   try {
  //     final authBox = Hive.box('auth_box');
  //     final userData = authBox.get('current_user');
  //     _currentUserId = userData?['_id'] ?? userData?['id'];

  //     // Load profile
  //     final targetUserId = widget.userId ?? _currentUserId;
  //     if (targetUserId != null) {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         ref
  //             .read(profileProvider.notifier)
  //             .loadProfile(targetUserId, _currentUserId);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading current user: $e');
  //   }
  // }

  void _loadCurrentUser() {
    try {
      final authBox = Hive.box('auth_box');
      final userData = authBox.get('current_user');
      _currentUserId = userData?['_id'] ?? userData?['id'];

      // ✅ Load profile ONCE in initState, not in build
      final targetUserId = widget.userId ?? _currentUserId;
      if (targetUserId != null) {
        // Use addPostFrameCallback to avoid calling during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ✅ Only load if not already loading
          final currentState = ref.read(profileProvider);
          if (currentState.profile == null && !currentState.isLoading) {
            ref
                .read(profileProvider.notifier)
                .loadProfile(targetUserId, _currentUserId);
          }
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final targetUserId = widget.userId ?? _currentUserId;
    if (targetUserId != null) {
      await ref
          .read(profileProvider.notifier)
          .refresh(targetUserId, _currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading && profileState.profile == null) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppConstants.primaryBlue),
              ),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (profileState.error != null && profileState.profile == null) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                profileState.error!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = profileState.profile;
    if (profile == null) {
      return Scaffold(body: Center(child: Text('Profile not found')));
    }

    // Determine if this is current user's profile
    final isCurrentUser = profileState.isCurrentUser;

    // Update tab length based on user
    if (isCurrentUser && _tabController.length != 2) {
      _tabController = TabController(length: 2, vsync: this);
    } else if (!isCurrentUser && _tabController.length != 1) {
      _tabController = TabController(length: 1, vsync: this);
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundGray,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppConstants.primaryBlue,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Navigator.canPop(context)
                    ? IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
                actions: [
                  if (isCurrentUser)
                    IconButton(
                      icon: Icon(Icons.settings_outlined),
                      onPressed: () {
                        // Navigate to settings
                      },
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      ProfileHeader(
                        profile: profile,
                        isCurrentUser: isCurrentUser,
                        onEditProfile: () {
                          // Navigate to edit profile
                        },
                        onFollow: () {
                          final targetUserId = widget.userId ?? _currentUserId;
                          if (targetUserId != null) {
                            ref
                                .read(profileProvider.notifier)
                                .toggleFollow(targetUserId);
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      ProfileStats(profile: profile),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppConstants.primaryBlue,
                      indicatorWeight: 3,
                      labelColor: AppConstants.primaryBlue,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(icon: Icon(Icons.grid_on, size: 24), text: 'Posts'),
                        if (isCurrentUser)
                          Tab(
                            icon: Icon(Icons.bookmark_border, size: 24),
                            text: 'Saved',
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          // body: TabBarView(
          //   controller: _tabController,
          //   children: [
          //     // Posts Tab
          //     profileState.isLoadingPosts
          //         ? Center(
          //             child: CircularProgressIndicator(
          //               valueColor: AlwaysStoppedAnimation(
          //                 AppConstants.primaryBlue,
          //               ),
          //             ),
          //           )
          //         : profileState.userPosts.isEmpty
          //         ? EmptyPostsView(
          //             icon: Icons.photo_library_outlined,
          //             title: 'No posts yet',
          //             subtitle: isCurrentUser
          //                 ? 'Share your first post!'
          //                 : 'No posts to show',
          //             onAction: isCurrentUser
          //                 ? () {
          //                     // Navigate to create post
          //                   }
          //                 : null,
          //             actionLabel: 'Create Post',
          //           )
          //         : PostsGrid(
          //             posts: profileState.userPosts,
          //             onPostTap: (post) {
          //               // Navigate to post detail or show modal
          //             },
          //           ),

          //     // Saved Tab (only for current user)
          //     if (isCurrentUser)
          //       profileState.isLoadingSaved
          //           ? Center(
          //               child: CircularProgressIndicator(
          //                 valueColor: AlwaysStoppedAnimation(
          //                   AppConstants.primaryBlue,
          //                 ),
          //               ),
          //             )
          //           : profileState.savedPosts.isEmpty
          //           ? EmptyPostsView(
          //               icon: Icons.bookmark_border,
          //               title: 'No saved posts',
          //               subtitle: 'Posts you save will appear here',
          //             )
          //           : PostsGrid(
          //               posts: profileState.savedPosts,
          //               onPostTap: (post) {
          //                 // Navigate to post detail
          //               },
          //             ),
          //   ],
          // ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Posts Tab
              profileState.isLoadingPosts
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          AppConstants.primaryBlue,
                        ),
                      ),
                    )
                  : profileState.userPosts.isEmpty
                  ? EmptyPostsView(
                      icon: Icons.photo_library_outlined,
                      title: 'No posts yet',
                      subtitle: isCurrentUser
                          ? 'Share your first post!'
                          : 'No posts to show',
                      onAction: isCurrentUser
                          ? () {
                              // Navigate to create post
                            }
                          : null,
                      actionLabel: 'Create Post',
                    )
                  : PostsGrid(
                      posts: profileState.userPosts,
                      // ✅ That's it! No onPostTap needed
                    ),

              // Saved Tab (only for current user)
              if (isCurrentUser)
                profileState.isLoadingSaved
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            AppConstants.primaryBlue,
                          ),
                        ),
                      )
                    : profileState.savedPosts.isEmpty
                    ? EmptyPostsView(
                        icon: Icons.bookmark_border,
                        title: 'No saved posts',
                        subtitle: 'Posts you save will appear here',
                      )
                    : PostsGrid(
                        posts: profileState.savedPosts,
                        // ✅ Automatic navigation here too!
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
