import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.green,
          unselectedLabelColor: AppColors.inkLight,
          indicatorColor: AppColors.green,
          labelStyle:
              GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
          tabs: const [
            Tab(text: 'Biodegradable'),
            Tab(text: 'Non-Biodegradable'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _StatsTab(
            fill: p.fillLevel2,
            logs: p.sensorLogs2,
            accentColor: AppColors.green,
            binLabel: 'BIN-001',
          ),
          _StatsTab(
            fill: p.fillLevel1,
            logs: p.sensorLogs1,
            accentColor: const Color(0xFF1565C0),
            binLabel: 'BIN-002',
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final double fill;
  final List<dynamic> logs;
  final Color accentColor;
  final String binLabel;

  // static const List<double> _hourly = [];
  // static const List<double> _weekly = [];
  static const List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  const _StatsTab({
    required this.fill,
    required this.logs,
    required this.accentColor,
    required this.binLabel,
  });

  DateTime? _timestampOf(dynamic log) {
    final ts = log.timestamp;
    return ts is DateTime ? ts : null;
  }

  double _fillOf(dynamic log) {
    final raw = log.fillLevel;
    return raw is num ? raw.toDouble() : 0;
  }

  List<double> _hourlyAverages(List<dynamic> entries) {
    final bucket = <int, List<double>>{};
    for (final log in entries) {
      final ts = _timestampOf(log);
      if (ts == null) continue;
      bucket.putIfAbsent(ts.hour, () => <double>[]).add(_fillOf(log));
    }

    return List<double>.generate(24, (h) {
      final vals = bucket[h];
      if (vals == null || vals.isEmpty) return 0;
      final sum = vals.reduce((a, b) => a + b);
      return sum / vals.length;
    });
  }

  List<double> _hourlyCounts(List<dynamic> entries) {
    final counts = List<double>.filled(24, 0);
    for (final log in entries) {
      final ts = _timestampOf(log);
      if (ts == null) continue;
      counts[ts.hour] = counts[ts.hour] + 1;
    }
    return counts;
  }

  List<double> _weeklyAverages(List<dynamic> entries) {
    final bucket = <int, List<double>>{};
    for (final log in entries) {
      final ts = _timestampOf(log);
      if (ts == null) continue;
      if (ts.weekday == DateTime.sunday) continue;
      if (ts.weekday < DateTime.monday || ts.weekday > DateTime.saturday) {
        continue;
      }
      final idx = ts.weekday - DateTime.monday;
      bucket.putIfAbsent(idx, () => <double>[]).add(_fillOf(log));
    }

    return List<double>.generate(6, (i) {
      final vals = bucket[i];
      if (vals == null || vals.isEmpty) return 0;
      final sum = vals.reduce((a, b) => a + b);
      return sum / vals.length;
    });
  }

  List<double> _weeklyCounts(List<dynamic> entries) {
    final counts = List<double>.filled(6, 0);
    for (final log in entries) {
      final ts = _timestampOf(log);
      if (ts == null || ts.weekday == DateTime.sunday) continue;
      if (ts.weekday < DateTime.monday || ts.weekday > DateTime.saturday) {
        continue;
      }
      final idx = ts.weekday - DateTime.monday;
      counts[idx] = counts[idx] + 1;
    }
    return counts;
  }

  int _maxIndex(List<double> values) {
    var idx = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[idx]) idx = i;
    }
    return idx;
  }

  // Color _barColor(double v, double max) {
  //   final pct = (v / max) * 100;
  //   if (pct >= 80) return AppColors.red;
  //   if (pct >= 60) return AppColors.amber;
  //   if (pct >= 40) return AppColors.yellow;
  //   return AppColors.green;
  // }

  @override
  Widget build(BuildContext context) {
    double avgRate = 0;
    if (logs.length >= 2) {
      final rates = <double>[];
      for (int i = 0; i < logs.length - 1; i++) {
        final diff = logs[i].fillLevel - logs[i + 1].fillLevel;
        final mins =
            logs[i].timestamp.difference(logs[i + 1].timestamp).inMinutes.abs();
        if (diff > 0 && mins > 0) rates.add(diff / mins);
      }
      if (rates.isNotEmpty) {
        avgRate = rates.reduce((a, b) => a + b) / rates.length;
      }
    }

    final remaining = 100 - fill;
    final minsLeft = avgRate > 0 ? remaining / avgRate : null;
    final hrsLeft = minsLeft != null ? minsLeft / 60 : null;
    final projColor =
        hrsLeft != null && hrsLeft < 2 ? AppColors.red : accentColor;

    String projValue = '—';
    String projUnit = 'no data';
    if (hrsLeft != null) {
      projValue = hrsLeft < 1
          ? minsLeft!.round().toString()
          : hrsLeft.toStringAsFixed(1);
      projUnit = hrsLeft < 1 ? 'min until full' : 'hrs until full';
    }

    String? projTime;
    if (minsLeft != null) {
      final fullAt = DateTime.now().add(Duration(minutes: minsLeft.round()));
      final h = fullAt.hour % 12 == 0 ? 12 : fullAt.hour % 12;
      final m = fullAt.minute.toString().padLeft(2, '0');
      final ap = fullAt.hour >= 12 ? 'PM' : 'AM';
      projTime = '$h:$m $ap';
    }

    final hourlyAvg = _hourlyAverages(logs);
    final weeklyAvg = _weeklyAverages(logs);
    final hourlyActivity = _hourlyCounts(logs);
    final weeklyActivity = _weeklyCounts(logs);

    final hasHourlyFillData = hourlyAvg.any((v) => v > 0);
    final hasWeeklyFillData = weeklyAvg.any((v) => v > 0);
    final hasHourlyData = hourlyActivity.any((v) => v > 0);
    final hasWeeklyData = weeklyActivity.any((v) => v > 0);

    final hourly = hasHourlyFillData ? hourlyAvg : hourlyActivity;
    final weekly = hasWeeklyFillData ? weeklyAvg : weeklyActivity;
    final hourlyMax =
        hasHourlyData ? hourly.reduce((a, b) => a > b ? a : b) : 1.0;
    final weeklyMax =
        hasWeeklyData ? weekly.reduce((a, b) => a > b ? a : b) : 1.0;

    String peakWindow = '—';
    if (hasHourlyData) {
      final idx = _maxIndex(hourly);
      final next = (idx + 1) % 24;
      peakWindow =
          '${idx.toString().padLeft(2, '0')}:00-${next.toString().padLeft(2, '0')}:00';
    }

    String busiestDay = '—';
    if (hasWeeklyData) {
      final idx = _maxIndex(weekly);
      busiestDay = _dayNames[idx];
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bin label
            Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Text('$binLabel Statistics',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(height: 12),

            // Fill projection
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: projColor.withValues(alpha: 0.5)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: projColor, width: 3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FILL PROJECTION',
                        style: GoogleFonts.dmMono(
                            fontSize: 9,
                            color: AppColors.inkLight,
                            letterSpacing: 1.0)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(projValue,
                            style: GoogleFonts.syne(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: projColor,
                                height: 1)),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(projUnit,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13, color: AppColors.inkLight)),
                        ),
                      ],
                    ),
                    if (projTime != null) ...[
                      const SizedBox(height: 4),
                      Text('Full at approx. $projTime',
                          style: GoogleFonts.dmMono(
                              fontSize: 10, color: AppColors.inkMid)),
                      const SizedBox(height: 14),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text('Connect Arduino to generate projection',
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.inkLight,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 14),
                    ],
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: fill / 100,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(statusColor(fill)),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('NOW ${fill.toInt()}%',
                              style: GoogleFonts.dmMono(
                                  fontSize: 8, color: AppColors.inkLight)),
                          Text('FULL 100%',
                              style: GoogleFonts.dmMono(
                                  fontSize: 8, color: AppColors.inkLight)),
                        ]),
                  ],
                ),
              ),
            ),

            // Fill rate grid
            const SectionLabel('Fill Rate'),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                MiniStatCard(
                    label: 'Per Minute',
                    value:
                        avgRate > 0 ? '${avgRate.toStringAsFixed(2)}%' : '—'),
                MiniStatCard(
                    label: 'Per Hour',
                    value: avgRate > 0
                        ? '${(avgRate * 60).toStringAsFixed(1)}%'
                        : '—'),
                MiniStatCard(label: 'Peak Window', value: peakWindow),
                MiniStatCard(
                    label: 'Est/Week',
                    value: avgRate > 0
                        ? '${((6 * 24 * 60 * avgRate) / 100).toStringAsFixed(1)}×'
                        : '—'),
              ],
            ),

            // Hourly pattern
            const SectionLabel('Hourly Pattern'),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVG FILL BY HOUR OF DAY',
                        style: GoogleFonts.dmMono(
                            fontSize: 9, color: AppColors.inkLight)),
                    const SizedBox(height: 10),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.greenFaint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: hasHourlyData
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(24, (h) {
                                  final val = hourly[h];
                                  final barHeight = val <= 0
                                      ? 2.0
                                      : ((val / hourlyMax) * 40)
                                          .clamp(2.0, 40.0);
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0.6),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: barHeight,
                                          decoration: BoxDecoration(
                                            color: val <= 0
                                                ? AppColors.border
                                                : accentColor.withValues(
                                                    alpha: 0.8),
                                            borderRadius:
                                                BorderRadius.circular(1.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            )
                          : Center(
                              child: Text('No data yet for hourly trend',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: AppColors.inkLight,
                                      fontStyle: FontStyle.italic)),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [0, 6, 12, 18, 23]
                            .map((h) => Text('${h}h',
                                style: GoogleFonts.dmMono(
                                    fontSize: 8, color: AppColors.inkLight)))
                            .toList()),
                  ],
                ),
              ),
            ),

            // Weekly pattern
            const SectionLabel('Weekly Pattern'),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVG FILL BY DAY OF WEEK',
                        style: GoogleFonts.dmMono(
                            fontSize: 9, color: AppColors.inkLight)),
                    const SizedBox(height: 10),
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.greenFaint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: hasWeeklyData
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(6, (i) {
                                  final val = weekly[i];
                                  final barHeight = val <= 0
                                      ? 3.0
                                      : ((val / weeklyMax) * 62)
                                          .clamp(3.0, 62.0);
                                  return Container(
                                    width: 18,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: val <= 0
                                          ? AppColors.border
                                          : accentColor.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            )
                          : Center(
                              child: Text('No data yet for weekly trend',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: AppColors.inkLight,
                                      fontStyle: FontStyle.italic)),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _days
                            .map((d) => Text(d,
                                style: GoogleFonts.dmMono(
                                    fontSize: 9, color: AppColors.inkLight)))
                            .toList()),
                    const SizedBox(height: 10),
                    const SlimDivider(),
                    const SizedBox(height: 10),
                    Text(
                        'Sunday excluded — canteen closed. Trends are computed from Firestore sensor logs.',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.inkMid,
                            height: 1.5)),
                  ],
                ),
              ),
            ),

            // Summary
            const SectionLabel('Summary'),
            Card(
              child: Column(children: [
                _SumRow(k: 'Sensor Readings', v: '${logs.length}'),
                _SumRow(
                    k: 'Fill Rate',
                    v: avgRate > 0
                        ? '${avgRate.toStringAsFixed(3)}% / min'
                        : 'Insufficient data'),
                _SumRow(k: 'Peak Window', v: peakWindow),
                _SumRow(k: 'Busiest Day', v: busiestDay),
                _SumRow(
                    k: 'Est. Collections/Week',
                    v: avgRate > 0
                        ? '${((6 * 24 * 60 * avgRate) / 100).toStringAsFixed(1)}×'
                        : '—',
                    last: true),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  final String k;
  final String v;
  final bool last;
  const _SumRow({required this.k, required this.v, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom: last
                ? BorderSide.none
                : const BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style:
                  GoogleFonts.dmSans(fontSize: 12, color: AppColors.inkLight)),
          Text(v,
              style: GoogleFonts.dmMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink)),
        ],
      ),
    );
  }
}