import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileEntity profile;
  final bool isCurrentUser;
  final VoidCallback onEditProfile;
  final VoidCallback onFollow;

  const ProfileHeader({
    Key? key,
    required this.profile,
    required this.isCurrentUser,
    required this.onEditProfile,
    required this.onFollow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryBlue.withOpacity(0.1),
            AppConstants.primaryIndigo.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // SizedBox(height: 60),
              SizedBox(height: 20),

              // Profile Picture
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppConstants.primaryBlue, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      profile.profilePicture != null &&
                          profile.profilePicture!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profile.profilePicture!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: AppConstants.primaryBlue.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: AppConstants.primaryBlue,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16),

              // Full Name
              Text(
                profile.fullName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4),

              // Username
              Text(
                '@${profile.username}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Email
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      profile.email,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              // Bio
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  profile.bio!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: isCurrentUser
                    ? ElevatedButton.icon(
                        onPressed: onEditProfile,
                        icon: Icon(Icons.edit_outlined, size: 20),
                        label: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: onFollow,
                        icon: Icon(
                          profile.isFollowing('')
                              ? Icons.person_remove_outlined
                              : Icons.person_add_outlined,
                          size: 20,
                        ),
                        label: Text(
                          profile.isFollowing('') ? 'Unfollow' : 'Follow',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: profile.isFollowing('')
                              ? Colors.grey[300]
                              : AppConstants.primaryBlue,
                          foregroundColor: profile.isFollowing('')
                              ? Colors.grey[800]
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
