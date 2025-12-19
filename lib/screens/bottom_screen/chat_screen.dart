import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy chat data
    final List<Map<String, dynamic>> chats = [
      {
        "name": "Aayush Sharma",
        "message": "Bro, are we meeting today?",
        "time": "3:45 PM",
        "unread": 2,
        "icon": Icons.person,
      },
      {
        "name": "Sneha Karki",
        "message": "Loved your last post ❤️",
        "time": "2:18 PM",
        "unread": 0,
        "icon": Icons.person_outline,
      },
      {
        "name": "Rahul Gupta",
        "message": "Send me the notes please",
        "time": "1:02 PM",
        "unread": 1,
        "icon": Icons.person,
      },
      {
        "name": "Family Group",
        "message": "Dinner at 8 PM 🍽️",
        "time": "Yesterday",
        "unread": 5,
        "icon": Icons.group,
      },
      {
        "name": "Project Team",
        "message": "Meeting rescheduled to tomorrow",
        "time": "Yesterday",
        "unread": 0,
        "icon": Icons.work,
      },
      {
        "name": "Suman Rai",
        "message": "😂😂😂",
        "time": "Mon",
        "unread": 0,
        "icon": Icons.person,
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          //  Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search chats",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          //  Chat List
          Expanded(
            child: ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.shade300, height: 1),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final bool hasUnread = chat["unread"] > 0;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      chat["icon"],
                      color: Colors.blue.shade700,
                      size: 26,
                    ),
                  ),
                  title: Text(
                    chat["name"],
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    chat["message"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasUnread ? Colors.black : Colors.grey,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chat["time"],
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread ? Colors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat["unread"].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
