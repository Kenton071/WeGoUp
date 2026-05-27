import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'interactive_quizzes.dart';

class LessonViewerScreen extends StatefulWidget {
  final LessonData lesson;
  const LessonViewerScreen({super.key, required this.lesson});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  bool _showQuiz = false;
  bool _quizDone = false;
  int _quizScore = 0;
  int _quizTotal = 0;

  void _handleQuizScore(int score, int total) {
    _quizScore = score;
    _quizTotal = total;
  }

  void _handleQuizComplete() {
    final perfectScore = _quizScore == _quizTotal;
    context.read<AppState>().completeLesson(
          widget.lesson.id,
          perfectScore: perfectScore,
        );
    setState(() => _quizDone = true);
  }

  int get _currentStep => _quizDone
      ? 3
      : _showQuiz
          ? 2
          : 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.lesson.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _currentStep / 3,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade500),
          ),
        ),
      ),
      body: _quizDone
          ? _ResultsScreen(
              lesson: widget.lesson,
              score: _quizScore,
              total: _quizTotal,
              onBack: () => Navigator.of(context).pop(),
            )
          : _showQuiz
              ? _QuizWrapper(
                  lesson: widget.lesson,
                  onScore: _handleQuizScore,
                  onComplete: _handleQuizComplete,
                )
              : _VideoSection(
                  lesson: widget.lesson,
                  onStartQuiz: () => setState(() => _showQuiz = true),
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Video Section — thumbnail + copy link
// ─────────────────────────────────────────────────────────────

class _VideoSection extends StatefulWidget {
  final LessonData lesson;
  final VoidCallback onStartQuiz;

  const _VideoSection({required this.lesson, required this.onStartQuiz});

  @override
  State<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<_VideoSection> {
  bool _copied = false;

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

  String _thumbnailUrl() {
    final uri = Uri.tryParse(widget.lesson.youtubeUrl);
    final id = uri?.queryParameters['v'] ?? '';
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  void _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.lesson.youtubeUrl));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepRow(currentStep: 1),
              const SizedBox(height: 28),

              // Tag + duration
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          _tagColor(widget.lesson.tag).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _tagColor(widget.lesson.tag)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      widget.lesson.tag,
                      style: TextStyle(
                          fontSize: 12,
                          color: _tagColor(widget.lesson.tag),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(widget.lesson.duration,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 12),

              Text(widget.lesson.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(widget.lesson.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),

              // Video card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              _thumbnailUrl(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF1C2128),
                                child: const Center(
                                  child: Icon(Icons.play_circle_outline,
                                      color: Colors.white54, size: 80),
                                ),
                              ),
                            ),
                            Container(
                                color: Colors.black.withValues(alpha: 0.3)),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 40),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Link + copy button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Open this link in your browser to watch the lesson, then come back to take the challenge.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14),
                          ),
                          const SizedBox(height: 16),

                          // URL box with copy button
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2128),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.lesson.youtubeUrl,
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: _copyLink,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _copied
                                          ? Colors.green.shade700
                                          : Colors.grey.shade700,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _copied ? Icons.check : Icons.copy,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _copied ? 'Copied!' : 'Copy',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Challenge CTA
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🎮', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ready for the interactive challenge?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Watched the video? Test what you learned with hands-on exercises.',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: widget.onStartQuiz,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start Challenge'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Quiz Wrapper
// ─────────────────────────────────────────────────────────────

class _QuizWrapper extends StatelessWidget {
  final LessonData lesson;
  final void Function(int score, int total) onScore;
  final VoidCallback onComplete;

  const _QuizWrapper(
      {required this.lesson, required this.onScore, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepRow(currentStep: 2),
              const SizedBox(height: 28),
              _buildQuiz(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    switch (lesson.id) {
      case 'lesson_1':
        return DragMatchQuiz(onComplete: onComplete, onScore: onScore);
      case 'lesson_2':
        return SequenceQuiz(onComplete: onComplete, onScore: onScore);
      case 'lesson_3':
        return ChartSpotterQuiz(onComplete: onComplete, onScore: onScore);
      case 'lesson_4':
        return RiskCalculatorQuiz(onComplete: onComplete, onScore: onScore);
      case 'lesson_5':
        return StrategyBuilderQuiz(onComplete: onComplete, onScore: onScore);
      case 'lesson_6':
        return AlgoRuleBuilderQuiz(onComplete: onComplete, onScore: onScore);
      default:
        return DragMatchQuiz(onComplete: onComplete, onScore: onScore);
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Results Screen
// ─────────────────────────────────────────────────────────────

class _ResultsScreen extends StatelessWidget {
  final LessonData lesson;
  final int score;
  final int total;
  final VoidCallback onBack;

  const _ResultsScreen(
      {required this.lesson,
      required this.score,
      required this.total,
      required this.onBack});

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? score / total : 0.0;
    final passed = percentage >= 0.6;
    final earnedAchievements = context.watch<AppState>().earnedAchievements;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _StepRow(currentStep: 3),
              const SizedBox(height: 36),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percentage),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          passed ? Colors.green.shade50 : Colors.orange.shade50,
                      border: Border.all(
                        color: passed
                            ? Colors.green.shade300
                            : Colors.orange.shade300,
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$score/$total',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: passed
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700)),
                        Text('${(value * 100).toInt()}%',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(passed ? '🎉 Lesson Complete!' : '💪 Keep Going!',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'You\'ve mastered "${lesson.title}"'
                    : 'Watch the video again and try the challenge once more.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              if (earnedAchievements.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text('ACHIEVEMENTS UNLOCKED',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.grey.shade500)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: earnedAchievements
                      .map((a) => _AchievementBadge(achievement: a))
                      .toList(),
                ),
              ],
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Back to Lessons'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(achievement.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(achievement.title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(achievement.subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Step indicator
// ─────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final int currentStep;
  const _StepRow({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Step(
            number: 1,
            label: 'Watch',
            active: currentStep == 1,
            done: currentStep > 1),
        _StepLine(done: currentStep > 1),
        _Step(
            number: 2,
            label: 'Practice',
            active: currentStep == 2,
            done: currentStep > 2),
        _StepLine(done: currentStep > 2),
        _Step(
            number: 3, label: 'Results', active: currentStep == 3, done: false),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String label;
  final bool active;
  final bool done;

  const _Step(
      {required this.number,
      required this.label,
      required this.active,
      required this.done});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? Colors.green.shade500
                : active
                    ? Colors.blue.shade600
                    : Colors.grey.shade200,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('$number',
                    style: TextStyle(
                        color: active ? Colors.white : Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: active ? Colors.blue.shade700 : Colors.grey.shade500,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool done;
  const _StepLine({required this.done});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
        color: done ? Colors.green.shade400 : Colors.grey.shade200,
      ),
    );
  }
}
