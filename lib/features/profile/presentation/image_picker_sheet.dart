// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// Future<XFile?> showImagePickerSheet(BuildContext context) {
//   final picker = ImagePicker();

//   return showModalBottomSheet<XFile?>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) {
//       return SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text("Open Camera"),
//               onTap: () async {
//                 final image = await picker.pickImage(
//                   source: ImageSource.camera,
//                 );
//                 Navigator.pop(context, image);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo),
//               title: const Text("Open Gallery"),
//               onTap: () async {
//                 final image = await picker.pickImage(
//                   source: ImageSource.gallery,
//                 );
//                 Navigator.pop(context, image);
//               },
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickProfileImage(BuildContext context) {
  final picker = ImagePicker();

  return showModalBottomSheet<XFile?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Open Camera"),
              onTap: () async {
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                Navigator.pop(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Open Gallery"),
              onTap: () async {
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                Navigator.pop(context, image);
              },
            ),
          ],
        ),
      );
    },
  );
}
