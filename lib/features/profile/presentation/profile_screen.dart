import 'dart:io';

import 'package:flutter/material.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 🔷 Profile Header
//             Container(
//               padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.blue.shade700, Colors.blue.shade500],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(24),
//                   bottomRight: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Profile Image
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const CircleAvatar(
//                       radius: 48,
//                       backgroundColor: Colors.grey,
//                       child: Icon(Icons.person, size: 48, color: Colors.white),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // Name
//                   const Text(
//                     "Pratik Neupane",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   // Username
//                   const Text(
//                     "@pratik.dev",
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),

//                   const SizedBox(height: 12),

//                   // Bio
//                   const Text(
//                     "Flutter Developer • UI Enthusiast • Building Frendly 🚀",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.white, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             //  Stats
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: const [
//                 ProfileStat(title: "Posts", value: "0"),
//                 ProfileStat(title: "Followers", value: "2.5K"),
//                 ProfileStat(title: "Friends", value: "180"),
//               ],
//             ),

//             const SizedBox(height: 24),

//             //  Buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {},
//                       child: const Text(
//                         "Edit Profile",
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         side: const BorderSide(color: Colors.blue),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {},
//                       child: const Text(
//                         "Share",
//                         style: TextStyle(fontSize: 16, color: Colors.blue),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),

//             //  User Posts (Preview Grid)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Posts",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // GridView.builder(
//             //   shrinkWrap: true,
//             //   physics: const NeverScrollableScrollPhysics(),
//             //   padding: const EdgeInsets.symmetric(horizontal: 16),
//             //   itemCount: 9,
//             //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             //     crossAxisCount: 3,
//             //     crossAxisSpacing: 8,
//             //     mainAxisSpacing: 8,
//             //   ),
//             //   itemBuilder: (context, index) {
//             //     return Container(
//             //       decoration: BoxDecoration(
//             //         color: Colors.grey.shade300,
//             //         borderRadius: BorderRadius.circular(12),
//             //       ),
//             //       child: const Icon(
//             //         Icons.image,
//             //         color: Colors.white70,
//             //         size: 36,
//             //       ),
//             //     );
//             //   },
//             // ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.photo_library_outlined,
//                     size: 64,
//                     color: Colors.grey.shade700,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "No posts yet",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     "When you share photos, they’ll appear here.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 📊 Stat Widget
// class ProfileStat extends StatelessWidget {
//   final String title;
//   final String value;

//   const ProfileStat({super.key, required this.title, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 4),
//         Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
//       ],
//     );
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/profile/presentation/profile_view_model.dart';
import './image_picker_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final user = state.user;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // 🔹 PROFILE IMAGE (logic added, UI same)
                  GestureDetector(
                    onTap: () async {
                      final picked = await pickProfileImage(context);
                      if (picked != null) {
                        ref
                            .read(profileViewModelProvider.notifier)
                            .uploadProfileImage(File(picked.path));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey,
                        backgroundImage: user?.imageUrl != null
                            ? NetworkImage(
                                "http://10.0.2.2:5000${user!.imageUrl}",
                              )
                            : null,
                        child: user?.imageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Pratik Neupane",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "@pratik.dev",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Flutter Developer • UI Enthusiast • Building Frendly 🚀",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // EVERYTHING BELOW UNCHANGED
          ],
        ),
      ),
    );
  }
}
