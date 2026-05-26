import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _kApiKey = 'fPovQJbX1Z7XxKaBvBuhe1UgzwdUyL1W';
const _kBase = 'https://financialmodelingprep.com/api/v3';

// ─── Data models ──────────────────────────────────────────────

class _Stock {
  final String symbol;
  final String name;
  const _Stock(this.symbol, this.name);
}

class _Quote {
  final String symbol;
  final double price;
  final double change;
  final double changePct;
  final double open;
  final double high;
  final double low;
  final double volume;

  const _Quote({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePct,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
  });

  factory _Quote.fromJson(Map<String, dynamic> j) => _Quote(
        symbol: j['symbol'] ?? '',
        price: (j['price'] ?? 0).toDouble(),
        change: (j['change'] ?? 0).toDouble(),
        changePct: (j['changesPercentage'] ?? 0).toDouble(),
        open: (j['open'] ?? 0).toDouble(),
        high: (j['dayHigh'] ?? 0).toDouble(),
        low: (j['dayLow'] ?? 0).toDouble(),
        volume: (j['volume'] ?? 0).toDouble(),
      );
}

class _Candle {
  final String date;
  final double open;
  final double close;
  final double high;
  final double low;
  final double volume;

  const _Candle({
    required this.date,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.volume,
  });

  factory _Candle.fromJson(Map<String, dynamic> j) => _Candle(
        date: j['date'] ?? '',
        open: (j['open'] ?? 0).toDouble(),
        close: (j['close'] ?? 0).toDouble(),
        high: (j['high'] ?? 0).toDouble(),
        low: (j['low'] ?? 0).toDouble(),
        volume: (j['volume'] ?? 0).toDouble(),
      );
}

class _Position {
  final String symbol;
  final String name;
  double shares;
  double avgPrice;

  _Position({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.avgPrice,
  });
}

// ─── Technical indicators ─────────────────────────────────────

List<double?> _sma(List<_Candle> data, int period) {
  return List.generate(data.length, (i) {
    if (i < period - 1) return null;
    final slice = data.sublist(i - period + 1, i + 1);
    return slice.fold<double>(0, (s, c) => s + c.close) / period;
  });
}

List<double?> _ema(List<_Candle> data, int period) {
  final k = 2.0 / (period + 1);
  final result = List<double?>.filled(data.length, null);
  double? ema;
  for (int i = 0; i < data.length; i++) {
    if (i < period - 1) continue;
    if (ema == null) {
      final slice = data.sublist(0, period);
      ema = slice.fold<double>(0, (s, c) => s + c.close) / period;
    } else {
      ema = data[i].close * k + ema * (1 - k);
    }
    result[i] = ema;
  }
  return result;
}

class _BB {
  final double upper, mid, lower;
  const _BB(this.upper, this.mid, this.lower);
}

List<_BB?> _bollinger(List<_Candle> data, {int period = 20, double mult = 2}) {
  return List.generate(data.length, (i) {
    if (i < period - 1) return null;
    final slice =
        data.sublist(i - period + 1, i + 1).map((c) => c.close).toList();
    final mean = slice.fold<double>(0, (s, v) => s + v) / period;
    final variance =
        slice.fold<double>(0, (s, v) => s + (v - mean) * (v - mean)) / period;
    final std = math.sqrt(variance);
    return _BB(mean + mult * std, mean, mean - mult * std);
  });
}

List<double?> _rsi(List<_Candle> data, {int period = 14}) {
  final result = List<double?>.filled(data.length, null);
  if (data.length < period + 1) return result;
  double gains = 0, losses = 0;
  for (int i = 1; i <= period; i++) {
    final diff = data[i].close - data[i - 1].close;
    if (diff > 0)
      gains += diff;
    else
      losses -= diff;
  }
  double avgGain = gains / period;
  double avgLoss = losses / period;
  result[period] =
      100 - 100 / (1 + (avgLoss == 0 ? double.infinity : avgGain / avgLoss));
  for (int i = period + 1; i < data.length; i++) {
    final diff = data[i].close - data[i - 1].close;
    avgGain = (avgGain * (period - 1) + math.max(diff, 0)) / period;
    avgLoss = (avgLoss * (period - 1) + math.max(-diff, 0)) / period;
    result[i] =
        100 - 100 / (1 + (avgLoss == 0 ? double.infinity : avgGain / avgLoss));
  }
  return result;
}

// ─── Stock list ───────────────────────────────────────────────

const _kStocks = [
  _Stock('AAPL', 'Apple Inc.'),
  _Stock('GOOGL', 'Alphabet Inc.'),
  _Stock('MSFT', 'Microsoft Corp.'),
  _Stock('TSLA', 'Tesla Inc.'),
  _Stock('AMZN', 'Amazon.com Inc.'),
  _Stock('NVDA', 'NVIDIA Corp.'),
  _Stock('META', 'Meta Platforms'),
  _Stock('NFLX', 'Netflix Inc.'),
];

// ─── Indicator config ─────────────────────────────────────────

class _Indicator {
  final String id;
  final String label;
  final String desc;
  final String level;
  final Color color;

  const _Indicator({
    required this.id,
    required this.label,
    required this.desc,
    required this.level,
    required this.color,
  });
}

const _kIndicators = [
  _Indicator(
      id: 'sma20',
      label: 'SMA 20',
      desc: 'Simple Moving Average (20)',
      level: 'Beginner',
      color: Color(0xFFD97706)),
  _Indicator(
      id: 'sma50',
      label: 'SMA 50',
      desc: 'Simple Moving Average (50)',
      level: 'Beginner',
      color: Color(0xFF2563EB)),
  _Indicator(
      id: 'ema20',
      label: 'EMA 20',
      desc: 'Exponential Moving Average (20)',
      level: 'Beginner',
      color: Color(0xFF7C3AED)),
  _Indicator(
      id: 'bb',
      label: 'Bollinger',
      desc: 'Bollinger Bands (20, 2σ)',
      level: 'Intermediate',
      color: Color(0xFF059669)),
  _Indicator(
      id: 'rsi',
      label: 'RSI',
      desc: 'Relative Strength Index (14)',
      level: 'Advanced',
      color: Color(0xFFDC2626)),
];

// ─── Light theme palette ──────────────────────────────────────

const _bg = Color(0xFFF3F4F6); // cool light grey page bg
const _surface = Color(0xFFFFFFFF); // white sidebar/header
const _card = Color(0xFFFFFFFF); // white cards
const _cardAlt = Color(0xFFF9FAFB); // subtle card bg
const _border = Color(0xFFE5E7EB);
const _textPrimary = Color(0xFF111827);
const _textMuted = Color(0xFF9CA3AF);
const _accent = Color(0xFF4F46E5);
const _accentLight = Color(0xFFEEF2FF);
const _green = Color(0xFF059669);
const _greenLight = Color(0xFFD1FAE5);
const _red = Color(0xFFDC2626);
const _redLight = Color(0xFFFEE2E2);

// ─── Main screen ─────────────────────────────────────────────

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  _Stock _selected = _kStocks[0];
  Map<String, _Quote> _quotes = {};
  List<_Candle> _history = [];
  bool _loadingQuotes = true;
  bool _loadingHistory = false;
  String _timeframe = '1month';
  String? _apiError;

  double _balance = 100000;
  final Map<String, _Position> _positions = {};

  final TextEditingController _sharesCtrl = TextEditingController();
  bool _isBuy = true;

  final Set<String> _activeIndicators = {'sma20'};

  Timer? _refreshTimer;
  OverlayEntry? _toastEntry;

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
    _fetchHistory();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _fetchQuotes());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _sharesCtrl.dispose();
    super.dispose();
  }

  // ── API calls ──────────────────────────────────────────────

  Future<void> _fetchQuotes() async {
    try {
      final symbols = _kStocks.map((s) => s.symbol).join(',');
      final uri = Uri.parse('$_kBase/quote/$symbols?apikey=$_kApiKey');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // FMP returns an error map when limit exceeded or key invalid
        if (body is Map && body.containsKey('Error Message')) {
          if (mounted)
            setState(() {
              _apiError = body['Error Message'] as String?;
              _loadingQuotes = false;
            });
          return;
        }
        final List data = body is List ? body : [];
        if (data.isEmpty) {
          if (mounted)
            setState(() {
              _apiError = 'No data returned. Check API key / plan limits.';
              _loadingQuotes = false;
            });
          return;
        }
        final map = <String, _Quote>{};
        for (final item in data) {
          final q = _Quote.fromJson(item as Map<String, dynamic>);
          map[q.symbol] = q;
        }
        if (mounted)
          setState(() {
            _quotes = map;
            _loadingQuotes = false;
            _apiError = null;
          });
      } else {
        if (mounted)
          setState(() {
            _apiError = 'HTTP ${res.statusCode} — check API key.';
            _loadingQuotes = false;
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _apiError = 'Network error: $e';
          _loadingQuotes = false;
        });
    }
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _loadingHistory = true;
      _history = [];
    });
    try {
      final limits = {'1week': 7, '1month': 30, '3months': 90, '1year': 365};
      final limit = limits[_timeframe] ?? 30;
      final uri = Uri.parse(
          '$_kBase/historical-price-full/${_selected.symbol}?timeseries=$limit&apikey=$_kApiKey');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('Error Message')) {
          if (mounted)
            setState(() {
              _apiError = data['Error Message'] as String?;
              _loadingHistory = false;
            });
          return;
        }
        final historical =
            (data is Map ? data['historical'] : null) as List? ?? [];
        final candles = historical
            .map((j) => _Candle.fromJson(j as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
        if (mounted)
          setState(() {
            _history = candles;
            _loadingHistory = false;
          });
      } else {
        if (mounted) setState(() => _loadingHistory = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  // ── Trading logic ─────────────────────────────────────────

  void _placeOrder() {
    final shares = double.tryParse(_sharesCtrl.text) ?? 0;
    if (shares <= 0) {
      _showToast('Enter a valid share count', isError: true);
      return;
    }
    final quote = _quotes[_selected.symbol];
    if (quote == null) {
      _showToast('Price unavailable — API data not loaded', isError: true);
      return;
    }
    final cost = shares * quote.price;

    if (_isBuy) {
      if (cost > _balance) {
        _showToast('Insufficient funds', isError: true);
        return;
      }
      setState(() {
        _balance -= cost;
        final existing = _positions[_selected.symbol];
        if (existing != null) {
          final total = existing.shares + shares;
          existing.avgPrice =
              (existing.shares * existing.avgPrice + cost) / total;
          existing.shares = total;
        } else {
          _positions[_selected.symbol] = _Position(
            symbol: _selected.symbol,
            name: _selected.name,
            shares: shares,
            avgPrice: quote.price,
          );
        }
        _sharesCtrl.clear();
      });
      _showToast(
          'Bought $shares ${_selected.symbol} @ \$${quote.price.toStringAsFixed(2)}');
    } else {
      final pos = _positions[_selected.symbol];
      if (pos == null || pos.shares < shares) {
        _showToast('Insufficient shares', isError: true);
        return;
      }
      setState(() {
        _balance += cost;
        pos.shares -= shares;
        if (pos.shares <= 0) _positions.remove(_selected.symbol);
        _sharesCtrl.clear();
      });
      _showToast(
          'Sold $shares ${_selected.symbol} @ \$${quote.price.toStringAsFixed(2)}');
    }
  }

  double get _portfolioValue {
    double total = _balance;
    for (final pos in _positions.values) {
      final price = _quotes[pos.symbol]?.price ?? pos.avgPrice;
      total += pos.shares * price;
    }
    return total;
  }

  // ── Toast ─────────────────────────────────────────────────

  void _showToast(String msg, {bool isError = false}) {
    _toastEntry?.remove();
    _toastEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 32,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isError ? const Color(0xFF7F1D1D) : const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: isError ? _red : const Color(0xFF059669)),
              ),
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'monospace')),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_toastEntry!);
    Future.delayed(const Duration(seconds: 3), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[_selected.symbol];
    final price = quote?.price ?? 0.0;
    final change = quote?.change ?? 0.0;
    final changePct = quote?.changePct ?? 0.0;
    final isUp = change >= 0;

    final sharesNum = double.tryParse(_sharesCtrl.text) ?? 0;
    final estCost = sharesNum * price;

    return Container(
      color: _bg,
      child: Row(
        children: [
          // ── Centre pane ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: _surface,
                    border:
                        Border(bottom: BorderSide(color: _border, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Paper Trading Simulator',
                              style: TextStyle(
                                  color: _textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          const Text('Practice with virtual money · Live data',
                              style:
                                  TextStyle(color: _textMuted, fontSize: 11)),
                        ],
                      ),
                      const Spacer(),
                      // API error badge
                      if (_apiError != null)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _redLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: _red, size: 14),
                              const SizedBox(width: 6),
                              const Text('API error — check key/plan',
                                  style: TextStyle(
                                      color: _red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      _statPill('PORTFOLIO',
                          '\$${_portfolioValue.toStringAsFixed(2)}', _accent),
                      const SizedBox(width: 10),
                      _statPill(
                          'CASH', '\$${_balance.toStringAsFixed(2)}', _green),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stock header row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(_selected.symbol,
                                        style: const TextStyle(
                                            color: _textPrimary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 10),
                                    Text(_selected.name,
                                        style: const TextStyle(
                                            color: _textMuted, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                        _loadingQuotes
                                            ? '—'
                                            : _apiError != null
                                                ? 'No data'
                                                : '\$${price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            color: _textPrimary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 10),
                                    if (!_loadingQuotes && _apiError == null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isUp ? _greenLight : _redLight,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${isUp ? '▲' : '▼'} ${change.abs().toStringAsFixed(2)} (${changePct.abs().toStringAsFixed(2)}%)',
                                          style: TextStyle(
                                              color: isUp ? _green : _red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            _TimeframeBar(
                              selected: _timeframe,
                              onChanged: (tf) {
                                setState(() => _timeframe = tf);
                                _fetchHistory();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Indicator toolbar
                        _IndicatorToolbar(
                          active: _activeIndicators,
                          onToggle: (id) => setState(() {
                            if (_activeIndicators.contains(id))
                              _activeIndicators.remove(id);
                            else
                              _activeIndicators.add(id);
                          }),
                        ),
                        const SizedBox(height: 12),

                        // Chart
                        Container(
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: _loadingHistory
                              ? const SizedBox(
                                  height: 300,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: _accent, strokeWidth: 2)),
                                )
                              : _history.isEmpty
                                  ? SizedBox(
                                      height: 300,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.bar_chart_outlined,
                                                color: _textMuted, size: 36),
                                            const SizedBox(height: 10),
                                            Text(
                                                _apiError != null
                                                    ? 'API error — no chart data'
                                                    : 'No historical data',
                                                style: const TextStyle(
                                                    color: _textMuted,
                                                    fontSize: 13)),
                                            if (_apiError != null) ...[
                                              const SizedBox(height: 6),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32),
                                                child: Text(_apiError!,
                                                    style: const TextStyle(
                                                        color: _red,
                                                        fontSize: 11),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    )
                                  : _ChartView(
                                      candles: _history,
                                      activeIndicators: _activeIndicators,
                                    ),
                        ),
                        const SizedBox(height: 16),

                        // Order panel
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Place Order · ${_selected.symbol}',
                                  style: const TextStyle(
                                      color: _textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 12),

                              // Buy/Sell toggle
                              Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _border),
                                ),
                                child: Row(
                                  children: [
                                    _OrderToggleBtn(
                                        label: 'BUY',
                                        active: _isBuy,
                                        isGreen: true,
                                        onTap: () =>
                                            setState(() => _isBuy = true)),
                                    _OrderToggleBtn(
                                        label: 'SELL',
                                        active: !_isBuy,
                                        isGreen: false,
                                        onTap: () =>
                                            setState(() => _isBuy = false)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('SHARES',
                                            style: TextStyle(
                                                color: _textMuted,
                                                fontSize: 10,
                                                letterSpacing: 0.8)),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: _sharesCtrl,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                              color: _textPrimary,
                                              fontSize: 14),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: const TextStyle(
                                                color: _textMuted),
                                            filled: true,
                                            fillColor: _bg,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                  color: _border),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                  color: _border),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                  color: _accent),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                          ),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('EST. COST',
                                            style: TextStyle(
                                                color: _textMuted,
                                                fontSize: 10,
                                                letterSpacing: 0.8)),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 44,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: _accentLight,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: const Color(0xFFC7D2FE)),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '\$${estCost.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                color: _accent,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'monospace'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'BUY',
                                      bgColor: _green,
                                      onPressed: _isBuy ? _placeOrder : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'SELL',
                                      bgColor: _red,
                                      onPressed: !_isBuy ? _placeOrder : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right sidebar ────────────────────────────────
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: _surface,
              border: Border(left: BorderSide(color: _border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                  child: Text('MARKET OVERVIEW',
                      style: TextStyle(
                          color: _textMuted,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600)),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _kStocks.length,
                    itemBuilder: (context, i) {
                      final stock = _kStocks[i];
                      final q = _quotes[stock.symbol];
                      final isActive = stock.symbol == _selected.symbol;
                      final up = (q?.changePct ?? 0) >= 0;
                      return _TickerRow(
                        stock: stock,
                        quote: q,
                        isActive: isActive,
                        isUp: up,
                        onTap: () {
                          setState(() => _selected = stock);
                          _fetchHistory();
                        },
                      );
                    },
                  ),
                ),

                // Positions panel
                Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: _border)),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR POSITIONS',
                          style: TextStyle(
                              color: _textMuted,
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      if (_positions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('No open positions',
                              style: const TextStyle(
                                  color: _textMuted, fontSize: 12)),
                        )
                      else
                        ..._positions.values.map((pos) {
                          final curPrice =
                              _quotes[pos.symbol]?.price ?? pos.avgPrice;
                          final pnl = (curPrice - pos.avgPrice) * pos.shares;
                          final pnlPct =
                              ((curPrice - pos.avgPrice) / pos.avgPrice) * 100;
                          final posUp = pnl >= 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(pos.symbol,
                                          style: const TextStyle(
                                              color: _textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          '${pos.shares.toStringAsFixed(0)} shares',
                                          style: const TextStyle(
                                              color: _textMuted, fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        '${posUp ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: posUp ? _green : _red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        '${posUp ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                            color: posUp ? _green : _red,
                                            fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
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

  Widget _statPill(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _cardAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: const TextStyle(
                  color: _textMuted, fontSize: 9, letterSpacing: 0.8)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ─── Chart widget ─────────────────────────────────────────────

class _ChartView extends StatelessWidget {
  final List<_Candle> candles;
  final Set<String> activeIndicators;

  const _ChartView({required this.candles, required this.activeIndicators});

  @override
  Widget build(BuildContext context) {
    final showRSI = activeIndicators.contains('rsi');
    return Column(
      children: [
        SizedBox(
          height: showRSI ? 240 : 300,
          child: CustomPaint(
            painter:
                _PricePainter(candles: candles, indicators: activeIndicators),
            size: Size.infinite,
          ),
        ),
        if (showRSI) ...[
          const Divider(color: _border, height: 1),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _RSIPainter(candles: candles),
              size: Size.infinite,
            ),
          ),
        ],
      ],
    );
  }
}

class _PricePainter extends CustomPainter {
  final List<_Candle> candles;
  final Set<String> indicators;

  _PricePainter({required this.candles, required this.indicators});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    const pad = EdgeInsets.fromLTRB(8, 16, 64, 28);
    final chartRect = Rect.fromLTRB(
        pad.left, pad.top, size.width - pad.right, size.height - pad.bottom);

    List<double> allVals = candles.map((c) => c.close).toList();

    final sma20 = indicators.contains('sma20') ? _sma(candles, 20) : null;
    final sma50 = indicators.contains('sma50') ? _sma(candles, 50) : null;
    final ema20 = indicators.contains('ema20') ? _ema(candles, 20) : null;
    final bbs = indicators.contains('bb') ? _bollinger(candles) : null;

    if (sma20 != null) allVals.addAll(sma20.whereType<double>());
    if (sma50 != null) allVals.addAll(sma50.whereType<double>());
    if (ema20 != null) allVals.addAll(ema20.whereType<double>());
    if (bbs != null) {
      for (final b in bbs) {
        if (b != null) allVals.addAll([b.upper, b.lower]);
      }
    }

    final minP = allVals.reduce(math.min) * 0.999;
    final maxP = allVals.reduce(math.max) * 1.001;
    final range = maxP - minP;

    double xOf(int i) =>
        chartRect.left + (i / (candles.length - 1)) * chartRect.width;
    double yOf(double v) =>
        chartRect.bottom - ((v - minP) / range) * chartRect.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.5;
    const labelStyle = TextStyle(
        color: Color(0xFF9CA3AF), fontSize: 10, fontFamily: 'monospace');

    for (int i = 0; i <= 4; i++) {
      final y = chartRect.top + (i / 4) * chartRect.height;
      canvas.drawLine(
          Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
      final v = maxP - (i / 4) * range;
      _drawText(canvas, '\$${v.toStringAsFixed(1)}',
          Offset(chartRect.right + 4, y - 6), labelStyle);
    }

    final step = math.max(1, (candles.length / 6).floor());
    for (int i = 0; i < candles.length; i += step) {
      final x = xOf(i);
      canvas.drawLine(
          Offset(x, chartRect.top), Offset(x, chartRect.bottom), gridPaint);
      final label =
          candles[i].date.length >= 7 ? candles[i].date.substring(5) : '$i';
      _drawText(
          canvas, label, Offset(x - 14, chartRect.bottom + 4), labelStyle);
    }

    // Bollinger bands
    if (bbs != null) {
      final validBBs =
          bbs.asMap().entries.where((e) => e.value != null).toList();
      if (validBBs.length >= 2) {
        final fillPath = Path();
        fillPath.moveTo(
            xOf(validBBs.first.key), yOf(validBBs.first.value!.upper));
        for (final e in validBBs) {
          fillPath.lineTo(xOf(e.key), yOf(e.value!.upper));
        }
        for (final e in validBBs.reversed) {
          fillPath.lineTo(xOf(e.key), yOf(e.value!.lower));
        }
        fillPath.close();
        canvas.drawPath(
            fillPath,
            Paint()
              ..color = const Color(0xFF059669).withOpacity(0.06)
              ..style = PaintingStyle.fill);

        for (final which in ['upper', 'mid', 'lower']) {
          final p = Paint()
            ..color =
                const Color(0xFF059669).withOpacity(which == 'mid' ? 0.5 : 0.35)
            ..strokeWidth = which == 'mid' ? 1.0 : 0.8
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round;
          final path = Path();
          bool started = false;
          for (final e in validBBs) {
            final y = which == 'upper'
                ? e.value!.upper
                : which == 'mid'
                    ? e.value!.mid
                    : e.value!.lower;
            if (!started) {
              path.moveTo(xOf(e.key), yOf(y));
              started = true;
            } else
              path.lineTo(xOf(e.key), yOf(y));
          }
          canvas.drawPath(path, p);
        }
      }
    }

    void drawLine(List<double?> vals, Color color, double width) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      bool started = false;
      for (int i = 0; i < vals.length; i++) {
        if (vals[i] == null) continue;
        if (!started) {
          path.moveTo(xOf(i), yOf(vals[i]!));
          started = true;
        } else
          path.lineTo(xOf(i), yOf(vals[i]!));
      }
      canvas.drawPath(path, paint);
    }

    if (sma20 != null) drawLine(sma20, const Color(0xFFD97706), 1.5);
    if (sma50 != null) drawLine(sma50, const Color(0xFF2563EB), 1.5);
    if (ema20 != null) drawLine(ema20, const Color(0xFF7C3AED), 1.5);

    // Price area + line
    final prices = candles.map((c) => c.close).toList();
    final isUp = prices.last >= prices.first;
    final lineColor = isUp ? const Color(0xFF059669) : const Color(0xFFDC2626);

    final fillPath = Path();
    fillPath.moveTo(xOf(0), yOf(prices[0]));
    for (int i = 1; i < prices.length; i++) {
      fillPath.lineTo(xOf(i), yOf(prices[i]));
    }
    fillPath.lineTo(xOf(prices.length - 1), chartRect.bottom);
    fillPath.lineTo(xOf(0), chartRect.bottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = lineColor.withOpacity(0.07)
        ..style = PaintingStyle.fill,
    );

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final linePath = Path();
    linePath.moveTo(xOf(0), yOf(prices[0]));
    for (int i = 1; i < prices.length; i++) {
      linePath.lineTo(xOf(i), yOf(prices[i]));
    }
    canvas.drawPath(linePath, linePaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _PricePainter old) =>
      old.candles != candles || old.indicators != indicators;
}

class _RSIPainter extends CustomPainter {
  final List<_Candle> candles;
  _RSIPainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.length < 15) return;
    final rsiVals = _rsi(candles);

    const pad = EdgeInsets.fromLTRB(8, 8, 64, 20);
    final chartRect = Rect.fromLTRB(
        pad.left, pad.top, size.width - pad.right, size.height - pad.bottom);

    double xOf(int i) =>
        chartRect.left + (i / (candles.length - 1)) * chartRect.width;
    double yOf(double v) => chartRect.bottom - (v / 100) * chartRect.height;

    for (final lvl in [30.0, 50.0, 70.0]) {
      final y = yOf(lvl);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()
          ..color = const Color(0xFFE5E7EB)
          ..strokeWidth = 0.5,
      );
      _drawText(
          canvas,
          '${lvl.toInt()}',
          Offset(chartRect.right + 4, y - 5),
          TextStyle(
            color: lvl == 70
                ? const Color(0xFFDC2626)
                : lvl == 30
                    ? const Color(0xFF059669)
                    : const Color(0xFF9CA3AF),
            fontSize: 9,
            fontFamily: 'monospace',
          ));
    }

    _drawText(canvas, 'RSI(14)', const Offset(12, 4),
        const TextStyle(color: Color(0xFF9CA3AF), fontSize: 9));

    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    bool started = false;
    for (int i = 0; i < rsiVals.length; i++) {
      if (rsiVals[i] == null) continue;
      if (!started) {
        path.moveTo(xOf(i), yOf(rsiVals[i]!));
        started = true;
      } else
        path.lineTo(xOf(i), yOf(rsiVals[i]!));
    }
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _RSIPainter old) => old.candles != candles;
}

// ─── Sub-widgets ──────────────────────────────────────────────

class _TimeframeBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  _TimeframeBar({required this.selected, required this.onChanged});

  static const _options = [
    ('1week', '1W'),
    ('1month', '1M'),
    ('3months', '3M'),
    ('1year', '1Y'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final isActive = selected == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? _accentLight : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isActive ? _accent : _border,
              ),
            ),
            child: Text(opt.$2,
                style: TextStyle(
                  color: isActive ? _accent : _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
          ),
        );
      }).toList(),
    );
  }
}

class _IndicatorToolbar extends StatelessWidget {
  final Set<String> active;
  final ValueChanged<String> onToggle;

  _IndicatorToolbar({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _cardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Text('INDICATORS',
              style: TextStyle(
                  color: _textMuted, fontSize: 9, letterSpacing: 1.2)),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _kIndicators.map((ind) {
                final isActive = active.contains(ind.id);
                return Tooltip(
                  message: '${ind.desc}\n${ind.level}',
                  child: GestureDetector(
                    onTap: () => onToggle(ind.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? ind.color.withOpacity(0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isActive ? ind.color : _border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(ind.label,
                              style: TextStyle(
                                color: isActive ? ind.color : _textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              )),
                          const SizedBox(height: 1),
                          Text(ind.level,
                              style: const TextStyle(
                                  color: _textMuted,
                                  fontSize: 8,
                                  letterSpacing: 0.3)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TickerRow extends StatelessWidget {
  final _Stock stock;
  final _Quote? quote;
  final bool isActive;
  final bool isUp;
  final VoidCallback onTap;

  _TickerRow({
    required this.stock,
    required this.quote,
    required this.isActive,
    required this.isUp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _accentLight : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? _accent : Colors.transparent,
              width: 2,
            ),
            bottom: const BorderSide(color: _border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stock.symbol,
                      style: TextStyle(
                          color: isActive ? _accent : _textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(stock.name,
                      style: const TextStyle(color: _textMuted, fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    quote != null
                        ? '\$${quote!.price.toStringAsFixed(2)}'
                        : '—',
                    style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace')),
                if (quote != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isUp ? _greenLight : _redLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${isUp ? '+' : ''}${quote!.changePct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isUp ? _green : _red,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final bool isGreen;
  final VoidCallback onTap;

  _OrderToggleBtn({
    required this.label,
    required this.active,
    required this.isGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isGreen ? _green : _red;
    final activeBg = isGreen ? _greenLight : _redLight;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: double.infinity,
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                color: active ? activeColor : _textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              )),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final VoidCallback? onPressed;

  _ActionButton({
    required this.label,
    required this.bgColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        decoration: BoxDecoration(
          color: onPressed != null ? bgColor : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
              color: onPressed != null ? Colors.white : _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            )),
      ),
    );
  }
}
