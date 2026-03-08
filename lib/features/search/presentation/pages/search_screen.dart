import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/search_provider.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchProvider.notifier).searchUsers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(searchState),
            Expanded(
              child: searchState.currentQuery.isEmpty
                  ? _buildRecentSearches(searchState)
                  : searchState.isSearching
                  ? _buildLoading()
                  : searchState.searchResults.isEmpty
                  ? _buildEmptyState()
                  : _buildSearchResults(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: Icon(Icons.search, color: AppConstants.primaryBlue),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(SearchState state) {
    if (state.recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryBlue.withOpacity(0.1),
                    AppConstants.primaryIndigo.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 50,
                color: AppConstants.primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Search for users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Find friends by username or name',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                ref.read(searchProvider.notifier).clearRecentSearches();
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: AppConstants.primaryBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.recentSearches.map((search) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history,
                  color: AppConstants.primaryBlue,
                  size: 20,
                ),
              ),
              title: Text(
                search.query,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  ref
                      .read(searchProvider.notifier)
                      .deleteRecentSearch(search.query);
                },
              ),
              onTap: () {
                _searchController.text = search.query;
                ref.read(searchProvider.notifier).searchUsers(search.query);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppConstants.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_search, size: 50, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No users found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different term',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final user = state.searchResults[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: user.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
                backgroundImage:
                    user.profilePicture != null &&
                        user.profilePicture!.isNotEmpty
                    ? CachedNetworkImageProvider(user.profilePicture!)
                    : null,
                child:
                    user.profilePicture == null || user.profilePicture!.isEmpty
                    ? Icon(Icons.person, color: AppConstants.primaryBlue)
                    : null,
              ),
              const SizedBox(width: 12),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (user.followersCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${user.followersCount} followers',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              // Follow button indicator
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
