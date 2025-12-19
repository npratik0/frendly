import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Stories data
    final List<Map<String, String>> stories = [
      {"name": "You", "image": ""},
      {"name": "Sanjay", "image": "https://i.pravatar.cc/150?img=11"},
      {"name": "Aayush", "image": "https://i.pravatar.cc/150?img=12"},
      {"name": "Bibek", "image": "https://i.pravatar.cc/150?img=13"},
      {"name": "Ram", "image": "https://i.pravatar.cc/150?img=14"},
      {"name": "Karan", "image": "https://i.pravatar.cc/150?img=15"},
    ];

    // Feed data
    final List<Map<String, String>> posts = [
      {
        "name": "Nirjal Adhikari",
        "username": "@NirjalAD15",
        "profile": "https://i.pravatar.cc/150?img=6",
        "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
        "likes": "122",
        "comments": "10",
      },
      {
        "name": "Ankit Sharma",
        "username": "@Ankittt",
        "profile": "https://i.pravatar.cc/150?img=7",
        "image": "https://images.unsplash.com/photo-1511765224389-37f0e77cf0eb",
        "likes": "98",
        "comments": "6",
      },
    ];

    return Column(
      children: [
        // 🔵 Stories
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: index == 0 ? Colors.blue : Colors.blue,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: story["image"]!.isNotEmpty
                            ? NetworkImage(story["image"]!)
                            : null,
                        child: story["image"]!.isEmpty
                            ? const Icon(Icons.add, size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story["name"]!,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // 📰 Feed
        Expanded(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👤 User Info
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(post["profile"]!),
                      ),
                      title: Text(
                        post["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(post["username"]!),
                      trailing: const Icon(Icons.more_vert),
                    ),

                    // 🖼 Post Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        post["image"]!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // ❤️ Actions
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_border),
                          const SizedBox(width: 6),
                          Text(post["likes"]!),
                          const SizedBox(width: 16),
                          const Icon(Icons.mode_comment_outlined),
                          const SizedBox(width: 6),
                          Text(post["comments"]!),
                          const Spacer(),
                          const Icon(Icons.send),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
