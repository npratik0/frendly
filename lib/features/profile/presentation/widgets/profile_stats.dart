import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileStats extends StatelessWidget {
  final UserProfileEntity profile;

  const ProfileStats({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.grid_on,
              count: profile.postsCount.toString(),
              label: 'Posts',
              gradient: LinearGradient(
                colors: [AppConstants.primaryBlue, AppConstants.primaryIndigo],
              ),
              onTap: () {
                // Scroll to posts or show posts
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.people_outline,
              count: profile.followersCount.toString(),
              label: 'Followers',
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              onTap: () {
                // Navigate to followers list
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.person_outline,
              count: profile.followingCount.toString(),
              label: 'Following',
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.pinkAccent],
              ),
              onTap: () {
                // Navigate to following list
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String count,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(height: 10),
              Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
