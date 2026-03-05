import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/entities/post_entity.dart';
import 'post_provider.dart';

// Create Post State
class CreatePostState {
  final XFile? selectedImage;
  final String caption;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  CreatePostState({
    this.selectedImage,
    this.caption = '',
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  CreatePostState copyWith({
    XFile? selectedImage,
    String? caption,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool clearImage = false,
  }) {
    return CreatePostState(
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      caption: caption ?? this.caption,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Create Post Notifier - UPDATED FOR RIVERPOD 3.x
class CreatePostNotifier extends Notifier<CreatePostState> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  CreatePostState build() {
    return CreatePostState();
  }

  CreatePostUseCase get _createPostUseCase =>
      CreatePostUseCase(ref.read(postRepositoryProvider));

  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        state = state.copyWith(selectedImage: image, error: null);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  void updateCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  void clearImage() {
    state = state.copyWith(clearImage: true);
  }

  Future<PostEntity?> createPost() async {
    if (state.selectedImage == null) {
      state = state.copyWith(error: 'Please select an image');
      return null;
    }

    if (state.caption.trim().isEmpty) {
      state = state.copyWith(error: 'Please add a caption');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _createPostUseCase(
      CreatePostParams(
        image: state.selectedImage!,
        caption: state.caption.trim(),
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (post) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return post;
      },
    );
  }

  void reset() {
    state = CreatePostState();
  }
}

// Provider - UPDATED FOR RIVERPOD 3.x
final createPostProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(() {
      return CreatePostNotifier();
    });
