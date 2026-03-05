import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../providers/create_post_provider.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createPostState = ref.watch(createPostProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (createPostState.selectedImage != null)
            TextButton(
              onPressed: createPostState.isLoading
                  ? null
                  : () async {
                      final post = await ref
                          .read(createPostProvider.notifier)
                          .createPost();

                      if (post != null) {
                        // Add post to feed
                        ref.read(postFeedProvider.notifier).addNewPost(post);

                        SnackBarUtils.showSuccess(
                          context,
                          'Post created successfully!',
                        );

                        Navigator.pop(context, true);
                      } else if (createPostState.error != null) {
                        SnackBarUtils.showError(
                          context,
                          createPostState.error!,
                        );
                      }
                    },
              child: createPostState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.primaryBlue,
                        ),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: AppConstants.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            if (createPostState.selectedImage == null)
              _buildImagePicker(context, ref)
            else
              _buildSelectedImage(createPostState.selectedImage!, ref),

            // Caption Input
            _buildCaptionInput(createPostState, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.width,
      color: Colors.grey[100],
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
              Icons.add_photo_alternate,
              size: 50,
              color: AppConstants.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select a photo to share',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(createPostProvider.notifier)
                      .pickImage(source: ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
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
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(createPostProvider.notifier)
                      .pickImage(source: ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryBlue,
                  side: const BorderSide(
                    color: AppConstants.primaryBlue,
                    width: 2,
                  ),
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
        ],
      ),
    );
  }

  Widget _buildSelectedImage(XFile image, WidgetRef ref) {
    return Stack(
      children: [
        Image.file(
          File(image.path),
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white),
            ),
            onPressed: () {
              ref.read(createPostProvider.notifier).clearImage();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCaptionInput(CreatePostState state, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Caption',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 5,
            maxLength: 2200,
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppConstants.primaryBlue,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              ref.read(createPostProvider.notifier).updateCaption(value);
            },
          ),
        ],
      ),
    );
  }
}
