import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/post/presentation/providers/post_provider.dart';
import 'dart:async';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/search_local_datasource.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/recent_search_entity.dart';
import '../../domain/entities/search_user_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/clear_recent_searches_usecase.dart';
import '../../domain/usecases/get_recent_searches_usecase.dart';
import '../../domain/usecases/save_recent_search_usecase.dart';
import '../../domain/usecases/search_users_usecase.dart';

// ================= Dependency Providers =================

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSourceImpl(dioClient: ref.read(dioClientProvider));
});

final searchLocalDataSourceProvider = Provider<SearchLocalDataSource>((ref) {
  return SearchLocalDataSourceImpl();
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(
    remoteDataSource: ref.read(searchRemoteDataSourceProvider),
    localDataSource: ref.read(searchLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Cases
final searchUsersUseCaseProvider = Provider<SearchUsersUseCase>((ref) {
  return SearchUsersUseCase(ref.read(searchRepositoryProvider));
});

final getRecentSearchesUseCaseProvider = Provider<GetRecentSearchesUseCase>((
  ref,
) {
  return GetRecentSearchesUseCase(ref.read(searchRepositoryProvider));
});

final saveRecentSearchUseCaseProvider = Provider<SaveRecentSearchUseCase>((
  ref,
) {
  return SaveRecentSearchUseCase(ref.read(searchRepositoryProvider));
});

final clearRecentSearchesUseCaseProvider = Provider<ClearRecentSearchesUseCase>(
  (ref) {
    return ClearRecentSearchesUseCase(ref.read(searchRepositoryProvider));
  },
);

// ================= State =================

class SearchState {
  final List<SearchUserEntity> searchResults;
  final List<RecentSearchEntity> recentSearches;
  final bool isSearching;
  final bool isLoadingRecent;
  final String? error;
  final String currentQuery;

  SearchState({
    this.searchResults = const [],
    this.recentSearches = const [],
    this.isSearching = false,
    this.isLoadingRecent = false,
    this.error,
    this.currentQuery = '',
  });

  SearchState copyWith({
    List<SearchUserEntity>? searchResults,
    List<RecentSearchEntity>? recentSearches,
    bool? isSearching,
    bool? isLoadingRecent,
    String? error,
    String? currentQuery,
    bool clearError = false,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      recentSearches: recentSearches ?? this.recentSearches,
      isSearching: isSearching ?? this.isSearching,
      isLoadingRecent: isLoadingRecent ?? this.isLoadingRecent,
      error: clearError ? null : (error ?? this.error),
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

// ================= Notifier =================

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    // Load recent searches on init
    loadRecentSearches();
    return SearchState();
  }

  SearchUsersUseCase get _searchUsersUseCase =>
      ref.read(searchUsersUseCaseProvider);
  GetRecentSearchesUseCase get _getRecentSearchesUseCase =>
      ref.read(getRecentSearchesUseCaseProvider);
  SaveRecentSearchUseCase get _saveRecentSearchUseCase =>
      ref.read(saveRecentSearchUseCaseProvider);
  ClearRecentSearchesUseCase get _clearRecentSearchesUseCase =>
      ref.read(clearRecentSearchesUseCaseProvider);

  // Load recent searches
  Future<void> loadRecentSearches() async {
    state = state.copyWith(isLoadingRecent: true);

    final result = await _getRecentSearchesUseCase(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingRecent: false, error: failure.message);
      },
      (searches) {
        state = state.copyWith(
          isLoadingRecent: false,
          recentSearches: searches,
          clearError: true,
        );
      },
    );
  }

  // Search users with debounce
  void searchUsers(String query) {
    // Cancel previous debounce
    _debounce?.cancel();

    // Update current query immediately
    state = state.copyWith(currentQuery: query, clearError: true);

    // If query is empty, clear results
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], isSearching: false);
      return;
    }

    // Set loading state
    state = state.copyWith(isSearching: true);

    // Debounce search
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  // Perform actual search
  Future<void> _performSearch(String query) async {
    final result = await _searchUsersUseCase(query);

    result.fold(
      (failure) {
        state = state.copyWith(isSearching: false, error: failure.message);
      },
      (users) {
        state = state.copyWith(
          isSearching: false,
          searchResults: users,
          clearError: true,
        );

        // Save to recent searches (don't await)
        _saveRecentSearchUseCase(query);
        // Reload recent searches to update UI
        loadRecentSearches();
      },
    );
  }

  // Clear search
  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(
      currentQuery: '',
      searchResults: [],
      isSearching: false,
      clearError: true,
    );
  }

  // Delete a recent search
  Future<void> deleteRecentSearch(String query) async {
    final repository = ref.read(searchRepositoryProvider);
    await repository.deleteRecentSearch(query);
    await loadRecentSearches();
  }

  // Clear all recent searches
  Future<void> clearRecentSearches() async {
    final result = await _clearRecentSearchesUseCase(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        state = state.copyWith(recentSearches: [], clearError: true);
      },
    );
  }

  // @override
  // void dispose() {
  //   _debounce?.cancel();
  //   super.dispose();
  // }
}

// ================= Provider =================

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
