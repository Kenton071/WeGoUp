import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  final List<Map<String, dynamic>> lessons = const [
    {
      'title': 'Introduction to Stock Market',
      'tag': 'Basics',
      'description': 'Learn the fundamentals of how the stock market works',
      'duration': '15 min',
      'completed': true,
      'locked': false,
    },
    {
      'title': 'Understanding Market Orders',
      'tag': 'Basics',
      'description': 'Different types of orders and when to use them',
      'duration': '20 min',
      'completed': true,
      'locked': false,
    },
    {
      'title': 'Reading Stock Charts',
      'tag': 'Technical Analysis',
      'description': 'Candlesticks, trends, and technical indicators',
      'duration': '25 min',
      'completed': false,
      'locked': false,
    },
    {
      'title': 'Risk Management Essentials',
      'tag': 'Risk Management',
      'description': 'Protect your capital and manage position sizes',
      'duration': '18 min',
      'completed': false,
      'locked': false,
    },
    {
      'title': 'Options Trading Basics',
      'tag': 'Advanced',
      'description': 'Introduction to calls, puts, and options strategies',
      'duration': '30 min',
      'completed': false,
      'locked': false,
    },
    {
      'title': 'Algorithmic Trading Fundamentals',
      'tag': 'Advanced',
      'description': 'Understanding automated trading strategies',
      'duration': '35 min',
      'completed': false,
      'locked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Path',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Master trading through structured lessons and hands-on simulations',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return _LessonCard(lesson: lesson);
            },
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;
  const _LessonCard({required this.lesson});

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Basics':
        return Colors.blue;
      case 'Technical Analysis':
        return Colors.purple;
      case 'Risk Management':
        return Colors.orange;
      case 'Advanced':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool completed = lesson['completed'];
    final bool locked = lesson['locked'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Tag + Status Icon
                Row(
                  children: [
                    Text(
                      lesson['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _tagColor(lesson['tag']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _tagColor(lesson['tag']).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        lesson['tag'],
                        style: TextStyle(
                          fontSize: 12,
                          color: _tagColor(lesson['tag']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (completed)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade500,
                        size: 20,
                      )
                    else if (locked)
                      Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Description
                Text(
                  lesson['description'],
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                // Duration + Simulation badge
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lesson['duration'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('📊', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      'Interactive Simulation Included',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Action Button
          if (!locked)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: completed
                    ? Colors.white
                    : Colors.blue.shade600,
                foregroundColor: completed
                    ? Colors.grey.shade800
                    : Colors.white,
                side: completed
                    ? BorderSide(color: Colors.grey.shade300)
                    : BorderSide.none,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(completed ? 'Review' : 'Start Lesson'),
            ),
        ],
      ),
    );
  }
}
