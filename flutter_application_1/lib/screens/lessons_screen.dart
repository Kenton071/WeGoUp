import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'lesson_viewer_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

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
            itemCount: kLessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final lesson = kLessons[index];
              final completed = state.isCompleted(lesson.id);
              final locked = state.isLocked(index);
              return _LessonCard(
                lesson: lesson,
                completed: completed,
                locked: locked,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonData lesson;
  final bool completed;
  final bool locked;

  const _LessonCard({
    required this.lesson,
    required this.completed,
    required this.locked,
  });

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
    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: completed ? Colors.green.shade200 : Colors.grey.shade200,
          ),
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
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _tagColor(lesson.tag).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _tagColor(lesson.tag).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          lesson.tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: _tagColor(lesson.tag),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (completed)
                        Icon(Icons.check_circle,
                            color: Colors.green.shade500, size: 20)
                      else if (locked)
                        Icon(Icons.lock_outline,
                            color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lesson.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        lesson.duration,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 16),
                      const Text('📊', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        'Interactive Quiz Included',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (!locked)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonViewerScreen(lesson: lesson),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      completed ? Colors.white : Colors.blue.shade600,
                  foregroundColor:
                      completed ? Colors.grey.shade800 : Colors.white,
                  side: completed
                      ? BorderSide(color: Colors.grey.shade300)
                      : BorderSide.none,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(completed ? 'Review' : 'Start Lesson'),
              ),
          ],
        ),
      ),
    );
  }
}
