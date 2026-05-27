import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/lessons_screen.dart';
import 'screens/simulator_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
    _NavigationItem(icon: Icons.book_outlined, label: 'Lessons'),
    _NavigationItem(icon: Icons.trending_up, label: 'Simulator'),
    _NavigationItem(icon: Icons.bar_chart, label: 'Progress'),
    _NavigationItem(icon: Icons.quiz_outlined, label: 'Quizzes'),
    _NavigationItem(icon: Icons.forum_outlined, label: 'Community'),
    _NavigationItem(icon: Icons.code, label: 'Backtesting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────
          Container(
            width: 240,
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.purple]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'TradeLearn',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _selectedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _selectedIndex = index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade50
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(item.icon,
                                      size: 20,
                                      color: isSelected
                                          ? Colors.blue.shade700
                                          : Colors.grey.shade600),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.blue.shade700
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ──────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.dark_mode_outlined,
                            color: Colors.grey.shade600),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(Icons.person_outline,
                            color: Colors.grey.shade600),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      // 0 - Dashboard
                      const _DashboardTab(),

                      // 1 - Lessons
                      const LessonsScreen(),

                      // 2 - Simulator ← ADDED
                      const SimulatorScreen(),

                      // 3–6 Placeholders
                      ...[
                        'Progress',
                        'Quizzes',
                        'Community',
                        'Backtesting',
                      ].map(
                        (label) => Center(
                          child: Text(
                            '$label — Coming Soon',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Dashboard Tab — fully reactive via AppState
// ─────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Continue your trading education journey',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Overall Progress
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overall Progress',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(state.overallProgress * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.overallProgress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Lessons Completed', state.lessonsProgress,
                  Icons.emoji_events_outlined, Colors.blue),
              _buildStatCard('Quizzes Passed', '${state.quizzesPassed}',
                  Icons.check_circle_outline, Colors.green),
              _buildStatCard(
                  'Simulation Hours',
                  state.simulationHours.toString(),
                  Icons.flash_on_outlined,
                  Colors.purple),
              _buildStatCard('Trading Win Rate', state.winRateDisplay,
                  Icons.trending_up, Colors.orange),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Achievements
              Expanded(
                child: _AchievementsCard(state: state),
              ),
              const SizedBox(width: 24),
              // Next Steps
              Expanded(
                child: _NextStepsCard(state: state),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Achievements Card — shows earned achievements dynamically
// ─────────────────────────────────────────────────────────────

class _AchievementsCard extends StatelessWidget {
  final AppState state;
  const _AchievementsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final earned = state.earnedAchievements;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '${earned.length}/${kAllAchievements.length}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (earned.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complete your first lesson to earn achievements!',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            )
          else
            ...earned.take(3).map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementRow(achievement: a),
                  ),
                ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final Achievement achievement;
  const _AchievementRow({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child:
                  Text(achievement.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(achievement.subtitle,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Next Steps Card — shows what to do based on current progress
// ─────────────────────────────────────────────────────────────

class _NextStepsCard extends StatelessWidget {
  final AppState state;
  const _NextStepsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    // Find next incomplete lesson
    final nextLesson = kLessons.firstWhere(
      (l) => !state.isCompleted(l.id),
      orElse: () => kLessons.last,
    );
    final allDone = state.completedLessons.length == kLessons.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Next Steps',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          if (allDone) ...[
            const _NextStep(
              title: '🏆 All Lessons Complete!',
              subtitle: 'You\'ve finished the full curriculum',
            ),
            const SizedBox(height: 12),
            const _NextStep(
              title: 'Try the Simulator',
              subtitle: 'Put your skills to the test',
            ),
          ] else ...[
            _NextStep(
              title: 'Continue: ${nextLesson.title}',
              subtitle: nextLesson.tag,
            ),
            const SizedBox(height: 12),
            const _NextStep(
              title: 'Try: Advanced Simulator',
              subtitle: 'Test your skills in market volatility',
            ),
            const SizedBox(height: 12),
            _NextStep(
              title: 'Earn Achievements',
              subtitle:
                  '${kAllAchievements.length - state.earnedAchievements.length} still to unlock',
            ),
          ],
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String title;
  final String subtitle;
  const _NextStep({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  _NavigationItem({required this.icon, required this.label});
}
