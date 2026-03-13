import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────────────────────
//  Base class all interactive quiz widgets extend
// ─────────────────────────────────────────────────────────────

abstract class InteractiveQuiz extends StatefulWidget {
  final VoidCallback onComplete;
  final void Function(int score, int total) onScore;

  const InteractiveQuiz({
    super.key,
    required this.onComplete,
    required this.onScore,
  });
}

// ─────────────────────────────────────────────────────────────
//  LESSON 1 — Drag & Drop Matching
//  Match terms to definitions by dragging cards
// ─────────────────────────────────────────────────────────────

class DragMatchQuiz extends InteractiveQuiz {
  const DragMatchQuiz({
    super.key,
    required super.onComplete,
    required super.onScore,
  });

  @override
  State<DragMatchQuiz> createState() => _DragMatchQuizState();
}

class _DragMatchQuizState extends State<DragMatchQuiz> {
  final List<_MatchPair> _pairs = [
    const _MatchPair(
        term: 'Stock', definition: 'A share of ownership in a company'),
    const _MatchPair(
        term: 'Dividend', definition: 'Profit paid out to shareholders'),
    const _MatchPair(
      term: 'Market Cap',
      definition: 'Total value of outstanding shares',
    ),
    const _MatchPair(
      term: 'Bull Market',
      definition: 'A period of rising stock prices',
    ),
  ];

  late List<String> _shuffledDefs;
  final Map<String, String?> _matches = {}; // term → matched definition
  String? _dragging;
  bool _submitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _shuffledDefs = _pairs.map((p) => p.definition).toList()..shuffle();
    for (final p in _pairs) {
      _matches[p.term] = null;
    }
  }

  void _checkAnswers() {
    int s = 0;
    for (final p in _pairs) {
      if (_matches[p.term] == p.definition) s++;
    }
    setState(() {
      _score = s;
      _submitted = true;
    });
    widget.onScore(s, _pairs.length);
  }

  @override
  Widget build(BuildContext context) {
    final allMatched = _matches.values.every((v) => v != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _QuizHeader(
          icon: '🔗',
          title: 'Match the Terms',
          subtitle: 'Drag each definition to the correct term',
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terms column (drop targets)
            Expanded(
              child: Column(
                children: _pairs.map((pair) {
                  final matched = _matches[pair.term];
                  bool correct = _submitted && matched == pair.definition;
                  bool wrong = _submitted &&
                      matched != null &&
                      matched != pair.definition;

                  return DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      if (_submitted) return;
                      setState(() {
                        // Remove from previous slot
                        _matches.forEach((k, v) {
                          if (v == details.data) _matches[k] = null;
                        });
                        _matches[pair.term] = details.data;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovering = candidateData.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: correct
                              ? Colors.green.shade50
                              : wrong
                                  ? Colors.red.shade50
                                  : isHovering
                                      ? Colors.blue.shade50
                                      : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: correct
                                ? Colors.green.shade400
                                : wrong
                                    ? Colors.red.shade400
                                    : isHovering
                                        ? Colors.blue.shade400
                                        : Colors.grey.shade300,
                            width: isHovering ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  pair.term,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: correct
                                        ? Colors.green.shade800
                                        : wrong
                                            ? Colors.red.shade800
                                            : Colors.grey.shade800,
                                  ),
                                ),
                                const Spacer(),
                                if (correct)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 18,
                                  )
                                else if (wrong)
                                  const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                              ],
                            ),
                            if (matched != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: correct
                                      ? Colors.green.shade100
                                      : wrong
                                          ? Colors.red.shade100
                                          : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  matched,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: correct
                                        ? Colors.green.shade700
                                        : wrong
                                            ? Colors.red.shade700
                                            : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ] else
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    'Drop definition here',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 20),
            // Definitions column (draggable chips)
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEFINITIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._shuffledDefs.map((def) {
                    final isUsed = _matches.values.contains(def);
                    return Draggable<String>(
                      data: def,
                      onDragStarted: () => setState(() => _dragging = def),
                      onDragEnd: (_) => setState(() => _dragging = null),
                      feedback: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            def,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _DefChip(text: def, used: isUsed),
                      ),
                      child: _DefChip(text: def, used: isUsed),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_submitted)
          _ResultBanner(
            score: _score,
            total: _pairs.length,
            onContinue: widget.onComplete,
          )
        else
          ElevatedButton(
            onPressed: allMatched ? _checkAnswers : null,
            style: _primaryBtnStyle(),
            child: const Text('Check Answers'),
          ),
      ],
    );
  }
}

class _DefChip extends StatelessWidget {
  final String text;
  final bool used;
  const _DefChip({required this.text, required this.used});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: used ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: used ? Colors.grey.shade300 : Colors.blue.shade200,
        ),
        boxShadow: used
            ? null
            : [BoxShadow(color: Colors.blue.shade50, blurRadius: 4)],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: used ? Colors.grey.shade400 : Colors.grey.shade800,
          decoration: used ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LESSON 2 — Order Builder (drag steps into correct sequence)
//  Sort order types into the right sequence for a trade
// ─────────────────────────────────────────────────────────────

class SequenceQuiz extends InteractiveQuiz {
  const SequenceQuiz({
    super.key,
    required super.onComplete,
    required super.onScore,
  });

  @override
  State<SequenceQuiz> createState() => _SequenceQuizState();
}

class _SequenceQuizState extends State<SequenceQuiz> {
  // Correct order for placing a limit order trade
  final List<String> _correctOrder = [
    'Analyze the stock chart',
    'Set your target entry price',
    'Place a limit buy order',
    'Set a stop-loss order',
    'Monitor the position',
    'Close the trade at target profit',
  ];

  late List<String> _currentOrder;
  bool _submitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _currentOrder = List.from(_correctOrder)..shuffle();
  }

  void _checkOrder() {
    int s = 0;
    for (int i = 0; i < _correctOrder.length; i++) {
      if (i < _currentOrder.length && _currentOrder[i] == _correctOrder[i]) s++;
    }
    setState(() {
      _score = s;
      _submitted = true;
    });
    widget.onScore(s, _correctOrder.length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _QuizHeader(
          icon: '📋',
          title: 'Put It In Order',
          subtitle:
              'Drag the steps into the correct order for placing a limit order trade',
        ),
        const SizedBox(height: 28),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: _submitted
              ? (_, __) {}
              : (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _currentOrder.removeAt(oldIndex);
                    _currentOrder.insert(newIndex, item);
                  });
                },
          children: List.generate(_currentOrder.length, (i) {
            final step = _currentOrder[i];
            final isCorrect = _submitted && step == _correctOrder[i];
            final isWrong = _submitted && step != _correctOrder[i];

            return AnimatedContainer(
              key: ValueKey(step),
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.shade50
                    : isWrong
                        ? Colors.red.shade50
                        : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.shade300
                      : isWrong
                          ? Colors.red.shade300
                          : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.shade100
                          : isWrong
                              ? Colors.red.shade100
                              : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCorrect
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.green,
                            )
                          : isWrong
                              ? const Icon(Icons.close,
                                  size: 16, color: Colors.red)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isCorrect
                            ? Colors.green.shade800
                            : isWrong
                                ? Colors.red.shade800
                                : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  if (!_submitted)
                    Icon(Icons.drag_handle, color: Colors.grey.shade400),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        if (_submitted)
          _ResultBanner(
            score: _score,
            total: _correctOrder.length,
            onContinue: widget.onComplete,
          )
        else
          ElevatedButton(
            onPressed: _checkOrder,
            style: _primaryBtnStyle(),
            child: const Text('Submit Order'),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LESSON 3 — Chart Pattern Spotter
//  Tap the correct candles / chart features to identify patterns
// ─────────────────────────────────────────────────────────────

class ChartSpotterQuiz extends InteractiveQuiz {
  const ChartSpotterQuiz({
    super.key,
    required super.onComplete,
    required super.onScore,
  });

  @override
  State<ChartSpotterQuiz> createState() => _ChartSpotterQuizState();
}

class _ChartSpotterQuizState extends State<ChartSpotterQuiz> {
  // 10 candles: index, isGreen, isBullishEngulfing, isDoji
  final List<_Candle> _candles = [
    const _Candle(open: 100, close: 105, high: 108, low: 98), // 0 green
    const _Candle(open: 106, close: 103, high: 109, low: 101), // 1 red
    const _Candle(open: 104, close: 102, high: 106, low: 100), // 2 red
    const _Candle(open: 103, close: 103.2, high: 107, low: 99), // 3 doji ✓
    const _Candle(
      open: 102,
      close: 108,
      high: 110,
      low: 100,
    ), // 4 green bullish engulfing ✓
    const _Candle(open: 107, close: 112, high: 114, low: 106), // 5 green
    const _Candle(open: 111, close: 109, high: 113, low: 107), // 6 red
    const _Candle(open: 110, close: 115, high: 117, low: 109), // 7 green
    const _Candle(open: 114, close: 113.8, high: 118, low: 112), // 8 doji ✓
    const _Candle(open: 114, close: 119, high: 121, low: 113), // 9 green
  ];

  final List<_QuizChallenge> _challenges = [
    const _QuizChallenge(
      question: 'Tap all DOJI candles (open ≈ close)',
      correctIndices: {3, 8},
      hint:
          'Doji candles have tiny bodies — price opened and closed at nearly the same level.',
    ),
    const _QuizChallenge(
      question: 'Tap the BULLISH ENGULFING candle',
      correctIndices: {4},
      hint:
          'A bullish engulfing candle is a large green candle that completely covers the previous red candle.',
    ),
    const _QuizChallenge(
      question: 'Tap all RED (bearish) candles',
      correctIndices: {1, 2, 6},
      hint: 'Red candles close lower than they open — sellers were in control.',
    ),
  ];

  int _challengeIndex = 0;
  final Set<int> _tapped = {};
  bool _checked = false;
  bool _correct = false;
  int _score = 0;

  void _tap(int index) {
    if (_checked) return;
    setState(() {
      if (_tapped.contains(index)) {
        _tapped.remove(index);
      } else {
        _tapped.add(index);
      }
    });
  }

  void _check() {
    final challenge = _challenges[_challengeIndex];
    final isCorrect = _tapped.length == challenge.correctIndices.length &&
        challenge.correctIndices.containsAll(_tapped);
    setState(() {
      _checked = true;
      _correct = isCorrect;
      if (isCorrect) _score++;
    });
  }

  void _next() {
    if (_challengeIndex < _challenges.length - 1) {
      setState(() {
        _challengeIndex++;
        _tapped.clear();
        _checked = false;
        _correct = false;
      });
    } else {
      widget.onScore(_score, _challenges.length);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_challengeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuizHeader(
          icon: '📈',
          title: 'Chart Pattern Spotter',
          subtitle: challenge.question,
        ),
        const SizedBox(height: 8),
        Text(
          'Question ${_challengeIndex + 1} of ${_challenges.length}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 24),

        // Mini candlestick chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Grid lines label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['120', '115', '110', '105', '100', '95']
                    .map(
                      (l) => Text(
                        l,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6E7681),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_candles.length, (i) {
                    return GestureDetector(
                      onTap: () => _tap(i),
                      child: _CandleWidget(
                        candle: _candles[i],
                        index: i,
                        tapped: _tapped.contains(i),
                        checked: _checked,
                        isCorrectAnswer: challenge.correctIndices.contains(i),
                        maxPrice: 121,
                        minPrice: 95,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _candles.length,
                  (i) => Text(
                    'C${i + 1}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6E7681),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        if (_checked)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _correct ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    _correct ? Colors.green.shade300 : Colors.orange.shade300,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _correct ? '✅' : '💡',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _correct ? 'Correct! Great eye!' : challenge.hint,
                    style: TextStyle(
                      fontSize: 13,
                      color: _correct
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),
        Row(
          children: [
            if (!_checked)
              ElevatedButton(
                onPressed: _tapped.isNotEmpty ? _check : null,
                style: _primaryBtnStyle(),
                child: const Text('Check Selection'),
              ),
            if (_checked)
              ElevatedButton(
                onPressed: _next,
                style: _primaryBtnStyle(),
                child: Text(
                  _challengeIndex < _challenges.length - 1
                      ? 'Next Pattern →'
                      : 'See Results',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CandleWidget extends StatelessWidget {
  final _Candle candle;
  final int index;
  final bool tapped;
  final bool checked;
  final bool isCorrectAnswer;
  final double maxPrice;
  final double minPrice;

  const _CandleWidget({
    required this.candle,
    required this.index,
    required this.tapped,
    required this.checked,
    required this.isCorrectAnswer,
    required this.maxPrice,
    required this.minPrice,
  });

  @override
  Widget build(BuildContext context) {
    final range = maxPrice - minPrice;
    final bodyTop = (maxPrice - math.max(candle.open, candle.close)) / range;
    final bodyBottom = (maxPrice - math.min(candle.open, candle.close)) / range;
    final wickTop = (maxPrice - candle.high) / range;
    final wickBottom = (maxPrice - candle.low) / range;
    final isGreen = candle.close >= candle.open;

    Color candleColor;
    if (checked) {
      if (isCorrectAnswer && tapped) {
        candleColor = Colors.green;
      } else if (isCorrectAnswer && !tapped) {
        candleColor = Colors.orange;
      } else if (!isCorrectAnswer && tapped) {
        candleColor = Colors.red;
      } else {
        candleColor =
            isGreen ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
      }
    } else if (tapped) {
      candleColor = Colors.blue;
    } else {
      candleColor = isGreen ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return SizedBox(
          width: 24,
          height: h,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Highlight overlay when tapped
              if (tapped)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade300, width: 1),
                    ),
                  ),
                ),
              // Wick
              Positioned(
                top: wickTop * h,
                child: Container(
                  width: 2,
                  height: (wickBottom - wickTop) * h,
                  color: candleColor,
                ),
              ),
              // Body
              Positioned(
                top: bodyTop * h,
                child: Container(
                  width: 16,
                  height: math.max(2.0, (bodyBottom - bodyTop) * h),
                  decoration: BoxDecoration(
                    color: candleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LESSON 4 — Risk Calculator Challenge
//  Fill in the blanks / sliders to solve risk scenarios
// ─────────────────────────────────────────────────────────────

class RiskCalculatorQuiz extends InteractiveQuiz {
  const RiskCalculatorQuiz({
    super.key,
    required super.onComplete,
    required super.onScore,
  });

  @override
  State<RiskCalculatorQuiz> createState() => _RiskCalculatorQuizState();
}

class _RiskCalculatorQuizState extends State<RiskCalculatorQuiz> {
  final List<_RiskScenario> _scenarios = [
    const _RiskScenario(
      question:
          'You have a \$10,000 account. Using the 1% rule, what is the maximum you should risk on one trade?',
      answer: 100,
      unit: '\$',
      min: 0,
      max: 500,
      hint: '1% of \$10,000 = \$100',
    ),
    const _RiskScenario(
      question:
          'A stock is at \$50 and you set a stop-loss at \$45. Your entry is \$50. What is your risk per share?',
      answer: 5,
      unit: '\$',
      min: 0,
      max: 20,
      hint: '\$50 - \$45 = \$5 risk per share',
    ),
    const _RiskScenario(
      question:
          'Using the answer above (\$5 risk/share) and max risk of \$100, how many shares should you buy?',
      answer: 20,
      unit: 'shares',
      min: 0,
      max: 50,
      hint: '\$100 ÷ \$5 per share = 20 shares',
    ),
  ];

  int _currentIndex = 0;
  double _sliderValue = 0;
  bool _checked = false;
  bool _correct = false;
  int _score = 0;

  void _check() {
    final correct = (_sliderValue - _scenarios[_currentIndex].answer).abs() < 1;
    setState(() {
      _checked = true;
      _correct = correct;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _scenarios.length - 1) {
      setState(() {
        _currentIndex++;
        _sliderValue = 0;
        _checked = false;
        _correct = false;
      });
    } else {
      widget.onScore(_score, _scenarios.length);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _scenarios[_currentIndex];
    final isExact = (_sliderValue - s.answer).abs() < 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _QuizHeader(
          icon: '🧮',
          title: 'Risk Calculator',
          subtitle: 'Slide to the correct answer for each scenario',
        ),
        const SizedBox(height: 8),
        Text(
          'Scenario ${_currentIndex + 1} of ${_scenarios.length}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Big answer display
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 130,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _checked
                        ? (_correct ? Colors.green.shade50 : Colors.red.shade50)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _checked
                          ? (_correct
                              ? Colors.green.shade300
                              : Colors.red.shade300)
                          : Colors.blue.shade200,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${s.unit == '\$' ? s.unit : ''}${_sliderValue.round()}${s.unit == 'shares' ? ' ${s.unit}' : ''}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _checked
                            ? (_correct
                                ? Colors.green.shade700
                                : Colors.red.shade700)
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: _checked
                      ? (_correct ? Colors.green.shade400 : Colors.red.shade400)
                      : Colors.blue.shade400,
                  inactiveTrackColor: Colors.grey.shade200,
                  thumbColor: _checked
                      ? (_correct ? Colors.green.shade600 : Colors.red.shade600)
                      : Colors.blue.shade600,
                  overlayColor: Colors.blue.withOpacity(0.1),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _sliderValue,
                  min: s.min.toDouble(),
                  max: s.max.toDouble(),
                  onChanged:
                      _checked ? null : (v) => setState(() => _sliderValue = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${s.unit == '\$' ? s.unit : ''}${s.min}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Text(
                    '${s.unit == '\$' ? s.unit : ''}${s.max}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_checked)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _correct ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    _correct ? Colors.green.shade300 : Colors.orange.shade300,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _correct ? '✅' : '💡',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _correct ? 'Correct! Great math!' : s.hint,
                    style: TextStyle(
                      fontSize: 13,
                      color: _correct
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (!_checked)
              ElevatedButton(
                onPressed: _check,
                style: _primaryBtnStyle(),
                child: const Text('Lock In Answer'),
              ),
            if (_checked)
              ElevatedButton(
                onPressed: _next,
                style: _primaryBtnStyle(),
                child: Text(
                  _currentIndex < _scenarios.length - 1
                      ? 'Next Scenario →'
                      : 'See Results',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LESSON 5 — Options Strategy Builder
//  Drag the right option components to build a strategy
// ─────────────────────────────────────────────────────────────

class StrategyBuilderQuiz extends InteractiveQuiz {
  const StrategyBuilderQuiz({
    super.key,
    required super.onComplete,
    required super.onScore,
  });

  @override
  State<StrategyBuilderQuiz> createState() => _StrategyBuilderQuizState();
}

class _StrategyBuilderQuizState extends State<StrategyBuilderQuiz> {
  final List<_StrategyChallenge> _challenges = [
    const _StrategyChallenge(
      scenario:
          'You believe stock XYZ will RISE significantly next month. Which option strategy fits best?',
      options: [
        'Buy a Call Option',
        'Buy a Put Option',
        'Sell a Call Option',
        'Short the Stock',
      ],
      correctIndex: 0,
      explanation:
          'Buying a call gives you the right to purchase shares at a set price. If the stock rises, your call becomes valuable.',
    ),
    const _StrategyChallenge(
      scenario:
          'You own 100 shares of ABC and want to protect against a potential DROP in price.',
      options: [
        'Sell a Call Option',
        'Buy a Put Option',
        'Buy more shares',
        'Buy a Call Option',
      ],
      correctIndex: 1,
      explanation:
          'Buying a put is like insurance on your shares. If the stock drops, your put gains value, offsetting the loss.',
    ),
    const _StrategyChallenge(
      scenario:
          'You think DEF stock will stay FLAT for the next month. You want to generate income from it.',
      options: [
        'Buy a Call Option',
        'Buy a Put Option',
        'Sell a Covered Call',
        'Buy a Straddle',
      ],
      correctIndex: 2,
      explanation:
          'Selling a covered call generates premium income. If the stock stays flat, you keep the premium as profit.',
    ),
  ];

  int _currentIndex = 0;
  int? _selected;
  bool _checked = false;
  int _score = 0;

  void _check() {
    if (_selected == null) return;
    final correct = _selected == _challenges[_currentIndex].correctIndex;
    setState(() {
      _checked = true;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _challenges.length - 1) {
      setState(() {
        _currentIndex++;
        _selected = null;
        _checked = false;
      });
    } else {
      widget.onScore(_score, _challenges.length);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _QuizHeader(
          icon: '🎯',
          title: 'Strategy Builder',
          subtitle: 'Pick the best options strategy for each scenario',
        ),
        const SizedBox(height: 8),
        Text(
          'Scenario ${_currentIndex + 1} of ${_challenges.length}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 24),

        // Scenario card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.shade100),
          ),
          child: Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  challenge.scenario,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'SELECT YOUR STRATEGY:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(challenge.options.length, (i) {
          final isSelected = _selected == i;
          final isCorrect = _checked && i == challenge.correctIndex;
          final isWrong = _checked && isSelected && i != challenge.correctIndex;

          return GestureDetector(
            onTap: _checked ? null : () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.shade50
                    : isWrong
                        ? Colors.red.shade50
                        : isSelected
                            ? Colors.blue.shade50
                            : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.shade400
                      : isWrong
                          ? Colors.red.shade400
                          : isSelected
                              ? Colors.blue.shade400
                              : Colors.grey.shade200,
                  width: isSelected || isCorrect ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect
                          ? Colors.green.shade100
                          : isWrong
                              ? Colors.red.shade100
                              : isSelected
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade100,
                    ),
                    child: Center(
                      child: isCorrect
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 18,
                            )
                          : isWrong
                              ? const Icon(Icons.close,
                                  color: Colors.red, size: 18)
                              : Text(
                                  ['A', 'B', 'C', 'D'][i],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      challenge.options[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected || isCorrect
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isCorrect
                            ? Colors.green.shade800
                            : isWrong
                                ? Colors.red.shade800
                                : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        if (_checked) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    challenge.explanation,
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        if (!_checked)
          ElevatedButton(
            onPressed: _selected != null ? _check : null,
            style: _primaryBtnStyle(),
            child: const Text('Confirm Strategy'),
          )
        else
          ElevatedButton(
            onPressed: _next,
            style: _primaryBtnStyle(),
            child: Text(
              _currentIndex < _challenges.length - 1
                  ? 'Next Scenario →'
                  : 'See Results',
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LESSON 6 — Algo Trading: Build the Rule
//  Drag conditions together to construct a valid trading rule
// ─────────────────────────────────────────────────────────────

class AlgoRuleBuilderQuiz extends InteractiveQuiz {
  const AlgoRuleBuilderQuiz({
    super.key,
    required super.onComplete,
    required super.onScore,
  });

  @override
  State<AlgoRuleBuilderQuiz> createState() => _AlgoRuleBuilderQuizState();
}

class _AlgoRuleBuilderQuizState extends State<AlgoRuleBuilderQuiz> {
  final List<_RuleChallenge> _challenges = [
    const _RuleChallenge(
      question: 'Build a valid BUY rule using the pieces below:',
      correctOrder: [
        'IF',
        'price > 50-day MA',
        'AND',
        'RSI < 70',
        'THEN',
        'BUY',
      ],
      hint:
          'A good buy signal: price is trending up (above moving average) but not yet overbought (RSI under 70).',
    ),
    const _RuleChallenge(
      question: 'Build a valid SELL rule to lock in profits:',
      correctOrder: [
        'IF',
        'price > entry × 1.10',
        'OR',
        'price < stop-loss',
        'THEN',
        'SELL',
      ],
      hint:
          'Sell when you\'ve made 10% profit OR hit your stop-loss to limit losses.',
    ),
  ];

  int _challengeIndex = 0;
  late List<String> _available;
  List<String> _built = [];
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _resetChallenge();
  }

  void _resetChallenge() {
    _available = List.from(_challenges[_challengeIndex].correctOrder)
      ..shuffle();
    _built = [];
    _submitted = false;
    _correct = false;
  }

  void _addPiece(String piece) {
    if (_submitted) return;
    setState(() {
      _available.remove(piece);
      _built.add(piece);
    });
  }

  void _removePiece(int index) {
    if (_submitted) return;
    setState(() {
      _available.add(_built.removeAt(index));
    });
  }

  void _submit() {
    final correct =
        _built.join(' ') == _challenges[_challengeIndex].correctOrder.join(' ');
    setState(() {
      _submitted = true;
      _correct = correct;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_challengeIndex < _challenges.length - 1) {
      setState(() {
        _challengeIndex++;
        _resetChallenge();
      });
    } else {
      widget.onScore(_score, _challenges.length);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_challengeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuizHeader(
          icon: '⚙️',
          title: 'Algo Rule Builder',
          subtitle: challenge.question,
        ),
        const SizedBox(height: 8),
        Text(
          'Challenge ${_challengeIndex + 1} of ${_challenges.length}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 28),

        // Build zone
        Text(
          'YOUR RULE:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 10),
        DragTarget<String>(
          onAcceptWithDetails: (details) => _addPiece(details.data),
          builder: (context, candidateData, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 70),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty
                    ? Colors.blue.shade50
                    : _submitted
                        ? (_correct ? Colors.green.shade50 : Colors.red.shade50)
                        : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: candidateData.isNotEmpty
                      ? Colors.blue.shade300
                      : _submitted
                          ? (_correct
                              ? Colors.green.shade300
                              : Colors.red.shade300)
                          : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _built.isEmpty
                  ? Center(
                      child: Text(
                        'Drag pieces here or tap them below →',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_built.length, (i) {
                        return GestureDetector(
                          onTap: () => _removePiece(i),
                          child: _RulePiece(
                            text: _built[i],
                            removable: !_submitted,
                            submitted: _submitted,
                            correct: _submitted &&
                                _built[i] == challenge.correctOrder[i],
                          ),
                        );
                      }),
                    ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Available pieces
        Text(
          'AVAILABLE PIECES (tap to add):',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _available.map((piece) {
            return Draggable<String>(
              data: piece,
              feedback: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: _RulePiece(text: piece, dragging: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _RulePiece(text: piece),
              ),
              child: GestureDetector(
                onTap: () => _addPiece(piece),
                child: _RulePiece(text: piece),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        if (_submitted)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _correct ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _correct
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _correct ? '✅' : '💡',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _correct ? 'Perfect rule!' : challenge.hint,
                            style: TextStyle(
                              fontSize: 13,
                              color: _correct
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                          if (!_correct) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Correct: ${challenge.correctOrder.join(' ')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _next,
                style: _primaryBtnStyle(),
                child: Text(
                  _challengeIndex < _challenges.length - 1
                      ? 'Next Challenge →'
                      : 'See Results',
                ),
              ),
            ],
          )
        else
          ElevatedButton(
            onPressed:
                _built.length == challenge.correctOrder.length ? _submit : null,
            style: _primaryBtnStyle(),
            child: const Text('Submit Rule'),
          ),
      ],
    );
  }
}

class _RulePiece extends StatelessWidget {
  final String text;
  final bool removable;
  final bool dragging;
  final bool submitted;
  final bool correct;

  const _RulePiece({
    required this.text,
    this.removable = false,
    this.dragging = false,
    this.submitted = false,
    this.correct = false,
  });

  Color get _bg {
    if (text == 'IF' || text == 'THEN') return Colors.purple.shade100;
    if (text == 'AND' || text == 'OR') return Colors.orange.shade100;
    if (text == 'BUY' || text == 'SELL') return Colors.green.shade100;
    return Colors.blue.shade100;
  }

  Color get _border {
    if (submitted) return correct ? Colors.green.shade400 : Colors.red.shade300;
    if (text == 'IF' || text == 'THEN') return Colors.purple.shade300;
    if (text == 'AND' || text == 'OR') return Colors.orange.shade300;
    if (text == 'BUY' || text == 'SELL') return Colors.green.shade300;
    return Colors.blue.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: dragging ? Colors.blue.shade600 : _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dragging ? Colors.blue.shade600 : _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dragging ? Colors.white : Colors.grey.shade800,
            ),
          ),
          if (removable) ...[
            const SizedBox(width: 6),
            Icon(Icons.close, size: 14, color: Colors.grey.shade500),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared UI helpers
// ─────────────────────────────────────────────────────────────

class _QuizHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _QuizHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onContinue;

  const _ResultBanner({
    required this.score,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final passed = score >= (total * 0.6).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: passed ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: passed ? Colors.green.shade300 : Colors.orange.shade300,
            ),
          ),
          child: Row(
            children: [
              Text(passed ? '🎉' : '💪', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passed
                          ? 'Great job! $score/$total correct'
                          : 'You got $score/$total — keep it up!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: passed
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onContinue,
          style: _primaryBtnStyle(),
          child: const Text('Continue →'),
        ),
      ],
    );
  }
}

ButtonStyle _primaryBtnStyle() => ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

// ─────────────────────────────────────────────────────────────
//  Data models (private to this file)
// ─────────────────────────────────────────────────────────────

class _MatchPair {
  final String term;
  final String definition;
  const _MatchPair({required this.term, required this.definition});
}

class _Candle {
  final double open, close, high, low;
  const _Candle({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });
}

class _QuizChallenge {
  final String question;
  final Set<int> correctIndices;
  final String hint;
  const _QuizChallenge({
    required this.question,
    required this.correctIndices,
    required this.hint,
  });
}

class _RiskScenario {
  final String question;
  final double answer;
  final String unit;
  final double min;
  final double max;
  final String hint;
  const _RiskScenario({
    required this.question,
    required this.answer,
    required this.unit,
    required this.min,
    required this.max,
    required this.hint,
  });
}

class _StrategyChallenge {
  final String scenario;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  const _StrategyChallenge({
    required this.scenario,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class _RuleChallenge {
  final String question;
  final List<String> correctOrder;
  final String hint;
  const _RuleChallenge({
    required this.question,
    required this.correctOrder,
    required this.hint,
  });
}
