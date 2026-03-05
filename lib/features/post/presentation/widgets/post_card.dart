import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback onTap;
  final String? currentUserId;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
    required this.onTap,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header
          _buildUserHeader(context),
          
          // Post Image
          _buildPostImage(context),
          
          // Action Buttons
          _buildActionButtons(),
          
          // Likes Count
          if (post.likes.isNotEmpty) _buildLikesCount(),
          
          // Caption
          if (post.caption.isNotEmpty) _buildCaption(),
          
          // Comments Preview
          if (post.comments.isNotEmpty) _buildCommentsPreview(context),
          
          // Timestamp
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.primaryBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: post.user.profilePicture ??
                    AppConstants.defaultProfilePicture,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Username and Full Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '@${post.user.username}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // More Options
          if (currentUserId == post.user.id)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options menu
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPostImage(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
          imageUrl: post.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryBlue,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Like Button
          IconButton(
            icon: Icon(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: post.isLiked ? Colors.red : Colors.grey[700],
            ),
            onPressed: onLike,
            iconSize: 28,
          ),
          const SizedBox(width: 8),
          // Comment Button
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey[700],
            ),
            onPressed: onComment,
            iconSize: 26,
          ),
          const Spacer(),
          // Bookmark Button
          IconButton(
            icon: Icon(
              post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: post.isBookmarked
                  ? AppConstants.primaryBlue
                  : Colors.grey[700],
            ),
            onPressed: onBookmark,
            iconSize: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildLikesCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '${post.likes.length} ${post.likes.length == 1 ? 'like' : 'likes'}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '${post.user.username} ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: post.caption),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCommentsPreview(BuildContext context) {
    final commentsCount = post.comments.length;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: onComment,
        child: Text(
          'View all $commentsCount ${commentsCount == 1 ? 'comment' : 'comments'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        app_date_utils.DateUtils.timeAgo(post.createdAt),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}
