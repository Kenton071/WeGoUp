import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────────────────────

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class LessonData {
  final String id;
  final String title;
  final String tag;
  final String description;
  final String duration;
  final String youtubeUrl; // ← Swap in your real URLs here
  final List<QuizQuestion> quiz;

  const LessonData({
    required this.id,
    required this.title,
    required this.tag,
    required this.description,
    required this.duration,
    required this.youtubeUrl,
    required this.quiz,
  });
}

class Achievement {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;

  const Achievement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}

// ─────────────────────────────────────────────────────────────
//  All lesson content — edit youtubeUrl values with your links
// ─────────────────────────────────────────────────────────────

const List<LessonData> kLessons = [
  LessonData(
    id: 'lesson_1',
    title: 'Introduction to Stock Market',
    tag: 'Basics',
    description: 'Learn the fundamentals of how the stock market works',
    duration: '15 min',
    youtubeUrl: 'https://www.youtube.com/watch?v=p7HKvqRI_Bo',
    quiz: [
      QuizQuestion(
        question: 'What is a stock?',
        options: [
          'A type of bond issued by the government',
          'A share of ownership in a company',
          'A fixed-interest loan to a corporation',
          'A currency used in trading',
        ],
        correctIndex: 1,
        explanation:
            'A stock represents a share of ownership in a company. When you buy stock, you become a partial owner (shareholder) of that company.',
      ),
      QuizQuestion(
        question: 'What does a stock exchange do?',
        options: [
          'It prints money for the government',
          'It provides a marketplace where buyers and sellers trade stocks',
          'It sets the price of all goods and services',
          'It manages company payroll',
        ],
        correctIndex: 1,
        explanation:
            'A stock exchange is an organized marketplace where buyers and sellers come together to trade shares of publicly listed companies.',
      ),
      QuizQuestion(
        question: 'What is market capitalization?',
        options: [
          'The total debt of a company',
          'The number of employees in a company',
          'The total value of a company\'s outstanding shares',
          'The company\'s annual revenue',
        ],
        correctIndex: 2,
        explanation:
            'Market cap = share price × total shares outstanding. It\'s used to gauge a company\'s size.',
      ),
    ],
  ),
  LessonData(
    id: 'lesson_2',
    title: 'Understanding Market Orders',
    tag: 'Basics',
    description: 'Different types of orders and when to use them',
    duration: '20 min',
    youtubeUrl: 'https://www.youtube.com/watch?v=p7HKvqRI_Bo',
    quiz: [
      QuizQuestion(
        question: 'What is a market order?',
        options: [
          'An order that executes only at a specific price',
          'An order that executes immediately at the best available price',
          'An order that expires at the end of the day',
          'An order placed after market hours',
        ],
        correctIndex: 1,
        explanation:
            'A market order executes immediately at the best available current price, prioritizing speed over price.',
      ),
      QuizQuestion(
        question: 'When would you use a limit order?',
        options: [
          'When you want to buy or sell immediately at any price',
          'When you want to set a specific price you\'re willing to pay or accept',
          'When you want to short-sell a stock',
          'When you want to buy stocks after hours',
        ],
        correctIndex: 1,
        explanation:
            'A limit order lets you set the maximum price you\'ll pay (buy limit) or minimum price you\'ll accept (sell limit).',
      ),
      QuizQuestion(
        question: 'What is a stop-loss order?',
        options: [
          'An order to buy more stock when prices fall',
          'An order that automatically sells when a stock hits a set price to limit losses',
          'An order only available to institutional investors',
          'An order that freezes your account',
        ],
        correctIndex: 1,
        explanation:
            'A stop-loss triggers a sell order automatically when the stock reaches a specified price, helping cap your downside.',
      ),
    ],
  ),
  LessonData(
    id: 'lesson_3',
    title: 'Reading Stock Charts',
    tag: 'Technical Analysis',
    description: 'Candlesticks, trends, and technical indicators',
    duration: '25 min',
    youtubeUrl: 'https://www.youtube.com/watch?v=p7HKvqRI_Bo',
    quiz: [
      QuizQuestion(
        question: 'What does a green candlestick indicate?',
        options: [
          'The stock price fell during that period',
          'The stock price rose during that period',
          'The stock had no movement',
          'The stock was halted',
        ],
        correctIndex: 1,
        explanation:
            'A green (bullish) candle means the closing price was higher than the opening price — the stock went up that period.',
      ),
      QuizQuestion(
        question: 'What is a moving average used for?',
        options: [
          'To predict exact future prices',
          'To smooth out price data and identify trends',
          'To calculate dividends',
          'To measure company earnings',
        ],
        correctIndex: 1,
        explanation:
            'Moving averages smooth out short-term noise, making it easier to spot the underlying trend direction.',
      ),
      QuizQuestion(
        question: 'What does RSI stand for?',
        options: [
          'Relative Stock Index',
          'Rate of Stock Increase',
          'Relative Strength Index',
          'Revenue Stability Indicator',
        ],
        correctIndex: 2,
        explanation:
            'RSI (Relative Strength Index) measures momentum and whether a stock is overbought (>70) or oversold (<30).',
      ),
    ],
  ),
  LessonData(
    id: 'lesson_4',
    title: 'Risk Management Essentials',
    tag: 'Risk Management',
    description: 'Protect your capital and manage position sizes',
    duration: '18 min',
    youtubeUrl: 'https://www.youtube.com/watch?v=p7HKvqRI_Bo',
    quiz: [
      QuizQuestion(
        question: 'What is the "1% rule" in trading?',
        options: [
          'Never invest more than 1% of your savings',
          'Never risk more than 1% of your total capital on a single trade',
          'Always aim for 1% daily returns',
          'Limit trades to 1 per day',
        ],
        correctIndex: 1,
        explanation:
            'The 1% rule means you should never risk more than 1% of your account on any single trade, protecting your capital from large losses.',
      ),
      QuizQuestion(
        question: 'What is diversification?',
        options: [
          'Putting all money into the best-performing stock',
          'Spreading investments across different assets to reduce risk',
          'Trading as many stocks as possible in one day',
          'Keeping all funds in cash',
        ],
        correctIndex: 1,
        explanation:
            'Diversification spreads your risk so that poor performance in one investment doesn\'t wipe out your whole portfolio.',
      ),
      QuizQuestion(
        question: 'What is a risk-reward ratio?',
        options: [
          'The percentage of winning trades',
          'The comparison of potential profit vs. potential loss on a trade',
          'The volatility of a stock',
          'Your broker\'s commission rate',
        ],
        correctIndex: 1,
        explanation:
            'A risk-reward ratio compares how much you stand to gain versus how much you could lose. A 1:3 ratio means risking \$1 to potentially make \$3.',
      ),
    ],
  ),
  LessonData(
    id: 'lesson_5',
    title: 'Options Trading Basics',
    tag: 'Advanced',
    description: 'Introduction to calls, puts, and options strategies',
    duration: '30 min',
    youtubeUrl: 'https://www.youtube.com/watch?v=p7HKvqRI_Bo',
    quiz: [
      QuizQuestion(
        question: 'What does a "call option" give you the right to do?',
        options: [
          'Sell a stock at a set price before expiration',
          'Buy a stock at a set price before expiration',
          'Short a stock immediately',
          'Receive dividends from a company',
        ],
        correctIndex: 1,
        explanation:
            'A call option gives the buyer the right (not obligation) to buy 100 shares at the strike price before expiration.',
      ),
      QuizQuestion(
        question: 'What is the "premium" in options trading?',
        options: [
          'The profit from the option',
          'The price you pay to buy the option contract',
          'The stock\'s price at expiration',
          'The broker\'s annual fee',
        ],
        correctIndex: 1,
        explanation:
            'The premium is the cost of the option contract itself — what the buyer pays to the seller for the right granted by the option.',
      ),
      QuizQuestion(
        question: 'What happens if an option expires "out of the money"?',
        options: [
          'It automatically exercises and you buy the stock',
          'The option expires worthless and you lose the premium paid',
          'You receive a refund of the premium',
          'The expiration is extended by 30 days',
        ],
        correctIndex: 1,
        explanation:
            'If an option expires out of the money (e.g., a call where stock price < strike price), it expires worthless and the buyer loses their premium.',
      ),
    ],
  ),
  LessonData(
    id: 'lesson_6',
    title: 'Algorithmic Trading Fundamentals',
    tag: 'Advanced',
    description: 'Understanding automated trading strategies',
    duration: '35 min',
    youtubeUrl: 'https://www.youtube.com/watch?v=p7HKvqRI_Bo',
    quiz: [
      QuizQuestion(
        question: 'What is algorithmic trading?',
        options: [
          'Trading using tips from social media',
          'Using computer programs to execute trades based on predefined rules',
          'Manual trading with a calculator',
          'Trading only during after-hours sessions',
        ],
        correctIndex: 1,
        explanation:
            'Algorithmic trading uses automated programs that execute trades when specific conditions are met, removing emotion from the process.',
      ),
      QuizQuestion(
        question: 'What is backtesting?',
        options: [
          'Testing a strategy on live markets with real money',
          'Testing a trading strategy on historical data to see how it would have performed',
          'Reviewing trades made last month',
          'A risk assessment done by your broker',
        ],
        correctIndex: 1,
        explanation:
            'Backtesting runs your strategy against historical price data to evaluate its performance before risking real capital.',
      ),
      QuizQuestion(
        question: 'What is "overfitting" in algorithmic trading?',
        options: [
          'Placing too many orders at once',
          'A strategy so tuned to past data it fails on new data',
          'Using too many stocks in a portfolio',
          'Trading with excessive leverage',
        ],
        correctIndex: 1,
        explanation:
            'Overfitting happens when you optimize a strategy so heavily on historical data that it loses predictive power on future, unseen data.',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────
//  All possible achievements
// ─────────────────────────────────────────────────────────────

const List<Achievement> kAllAchievements = [
  Achievement(
    id: 'first_lesson',
    title: 'First Step',
    subtitle: 'Completed your first lesson',
    emoji: '🎯',
  ),
  Achievement(
    id: 'first_quiz',
    title: 'Quiz Whiz',
    subtitle: 'Passed your first quiz',
    emoji: '🧠',
  ),
  Achievement(
    id: 'basics_done',
    title: 'Basics Master',
    subtitle: 'Completed all Basics lessons',
    emoji: '📘',
  ),
  Achievement(
    id: 'halfway',
    title: 'Halfway There',
    subtitle: 'Completed 50% of lessons',
    emoji: '🏅',
  ),
  Achievement(
    id: 'all_done',
    title: 'Trading Scholar',
    subtitle: 'Completed all lessons',
    emoji: '🏆',
  ),
  Achievement(
    id: 'perfect_quiz',
    title: 'Perfect Score',
    subtitle: 'Got 100% on a quiz',
    emoji: '⭐',
  ),
  Achievement(
    id: 'knowledge_seeker',
    title: 'Knowledge Seeker',
    subtitle: 'Completed 3 lessons',
    emoji: '📚',
  ),
];

// ─────────────────────────────────────────────────────────────
//  AppState — ChangeNotifier drives all UI reactivity
// ─────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  // Which lessons are fully completed (video watched + quiz passed)
  final Set<String> _completedLessons = {};

  // Achievements the user has earned
  final Set<String> _earnedAchievementIds = {};

  // Quizzes passed count
  int _quizzesPassed = 0;

  // Simulation hours (static for now, can wire up later)
  double simulationHours = 24.5;

  // Trading win rate (static for now)
  double tradingWinRate = 0.62;

  // ── Getters ──────────────────────────────────────────────

  Set<String> get completedLessons => _completedLessons;
  int get quizzesPassed => _quizzesPassed;

  bool isCompleted(String lessonId) => _completedLessons.contains(lessonId);

  bool isLocked(int index) {
    if (index == 0) return false;
    // Each lesson unlocks only after the previous one is complete
    return !isCompleted(kLessons[index - 1].id);
  }

  double get overallProgress =>
      kLessons.isEmpty ? 0 : _completedLessons.length / kLessons.length;

  String get lessonsProgress =>
      '${_completedLessons.length}/${kLessons.length}';

  String get winRateDisplay => '${(tradingWinRate * 100).toStringAsFixed(0)}%';

  List<Achievement> get earnedAchievements => kAllAchievements
      .where((a) => _earnedAchievementIds.contains(a.id))
      .toList();

  // ── Actions ──────────────────────────────────────────────

  /// Call this when a user passes a quiz for a lesson.
  void completeLesson(String lessonId, {required bool perfectScore}) {
    if (_completedLessons.contains(lessonId)) return;
    _completedLessons.add(lessonId);
    _quizzesPassed++;
    _checkAchievements(lessonId: lessonId, perfectScore: perfectScore);
    notifyListeners();
  }

  void _checkAchievements({
    required String lessonId,
    required bool perfectScore,
  }) {
    final count = _completedLessons.length;

    if (count >= 1) _earn('first_lesson');
    if (_quizzesPassed >= 1) _earn('first_quiz');
    if (count >= 3) _earn('knowledge_seeker');
    if (overallProgress >= 0.5) _earn('halfway');
    if (count == kLessons.length) _earn('all_done');
    if (perfectScore) _earn('perfect_quiz');

    // Basics master: lessons 1 and 2 both completed
    final basicsIds =
        kLessons.where((l) => l.tag == 'Basics').map((l) => l.id).toSet();
    if (_completedLessons.containsAll(basicsIds)) _earn('basics_done');
  }

  void _earn(String id) => _earnedAchievementIds.add(id);
}
