// lib/features/post/presentation/pages/post_detail_screen.dart
// Beautiful full-screen post detail view

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../domain/entities/post_entity.dart';
import '../providers/post_provider.dart';
import '../widgets/comment_bottom_sheet.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostEntity post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late PostEntity _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  void _showCommentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(postId: _currentPost.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates to this specific post from the feed
    final feedState = ref.watch(postFeedProvider);
    final updatedPost = feedState.posts.firstWhere(
      (p) => p.id == _currentPost.id,
      orElse: () => _currentPost,
    );

    if (updatedPost != _currentPost) {
      _currentPost = updatedPost;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Image
                    _buildPostImage(),

                    // Post Content (on white background)
                    Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Action Buttons
                          _buildActionButtons(),

                          // Likes Count
                          _buildLikesSection(),

                          // Caption
                          _buildCaptionSection(),

                          // Comments Preview
                          _buildCommentsSection(),

                          // Timestamp
                          _buildTimestamp(),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          // User Info
          CircleAvatar(
            radius: 16,
            backgroundImage:
                _currentPost.user.profilePicture != null &&
                    _currentPost.user.profilePicture!.isNotEmpty
                ? CachedNetworkImageProvider(_currentPost.user.profilePicture!)
                : null,
            backgroundColor: Colors.grey[800],
            child:
                _currentPost.user.profilePicture == null ||
                    _currentPost.user.profilePicture!.isEmpty
                ? Icon(Icons.person, size: 18, color: Colors.white)
                : null,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentPost.user.fullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${_currentPost.user.username}',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // More Options
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        ref.read(postFeedProvider.notifier).likePost(_currentPost.id);
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        color: Colors.black,
        child: CachedNetworkImage(
          imageUrl: _currentPost.imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppConstants.primaryBlue),
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(Icons.error_outline, color: Colors.white, size: 48),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Like Button
          IconButton(
            icon: Icon(
              _currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
              color: _currentPost.isLiked ? Colors.red : Colors.grey[800],
              size: 28,
            ),
            onPressed: () {
              ref.read(postFeedProvider.notifier).likePost(_currentPost.id);
            },
          ),

          SizedBox(width: 8),

          // Comment Button
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey[800],
              size: 26,
            ),
            onPressed: _showCommentBottomSheet,
          ),

          SizedBox(width: 8),

          // Share Button
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.grey[800], size: 26),
            onPressed: () {
              // TODO: Implement share
            },
          ),

          Spacer(),

          // Bookmark Button
          IconButton(
            icon: Icon(
              _currentPost.isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: _currentPost.isBookmarked
                  ? AppConstants.primaryBlue
                  : Colors.grey[800],
              size: 26,
            ),
            onPressed: () {
              ref
                  .read(postFeedProvider.notifier)
                  .bookmarkPost(_currentPost.id, _currentPost.isBookmarked);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLikesSection() {
    if (_currentPost.likes.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _currentPost.likes.length == 1
            ? '1 like'
            : '${_currentPost.likes.length} likes',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildCaptionSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: _currentPost.user.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: '  '),
            TextSpan(text: _currentPost.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    if (_currentPost.comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: GestureDetector(
          onTap: _showCommentBottomSheet,
          child: Text(
            'Add a comment...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentPost.comments.length > 2)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: _showCommentBottomSheet,
              child: Text(
                'View all ${_currentPost.comments.length} comments',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ),

        // Show first 2 comments
        ...(_currentPost.comments.take(2).map((comment) {
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: comment.user.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '  '),
                  TextSpan(text: comment.text),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        app_date.DateUtils.timeAgo(_currentPost.createdAt),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share
                },
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement copy link
                },
              ),
              if (_currentPost.isBookmarked)
                ListTile(
                  leading: Icon(Icons.bookmark_remove),
                  title: Text('Remove from Saved'),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(postFeedProvider.notifier)
                        .bookmarkPost(
                          _currentPost.id,
                          _currentPost.isBookmarked,
                        );
                  },
                )
              else
                ListTile(
                  leading: Icon(Icons.bookmark_add),
                  title: Text('Save Post'),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(postFeedProvider.notifier)
                        .bookmarkPost(
                          _currentPost.id,
                          _currentPost.isBookmarked,
                        );
                  },
                ),
              Divider(),
              ListTile(
                leading: Icon(Icons.report, color: Colors.red),
                title: Text('Report', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement report
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
