import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const List<double> _hourly = [
    4, 2, 2, 2, 3, 5, 10, 18, 28, 42, 75, 92,
    95, 88, 65, 40, 28, 20, 14, 10, 7, 5, 4, 3,
  ];

  // Sunday excluded — canteen closed
  static const List<double> _weekly = [62, 75, 68, 80, 91, 45];
  static const List<String> _days   = ['M', 'T', 'W', 'T', 'F', 'S'];

  Color _barColor(double v, double max) {
    final pct = (v / max) * 100;
    if (pct >= 80) return AppColors.red;
    if (pct >= 60) return AppColors.amber;
    if (pct >= 40) return AppColors.yellow;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final p    = context.watch<AppProvider>();
    final fill = p.fillLevel;
    final logs = p.sensorLogs;

    double avgRate = 0;
    if (logs.length >= 2) {
      final rates = <double>[];
      for (int i = 0; i < logs.length - 1; i++) {
        final diff = logs[i].fillLevel - logs[i + 1].fillLevel;
        final mins = logs[i].timestamp.difference(logs[i + 1].timestamp).inMinutes.abs();
        if (diff > 0 && mins > 0) rates.add(diff / mins);
      }
      if (rates.isNotEmpty) avgRate = rates.reduce((a, b) => a + b) / rates.length;
    }

    final remaining = 100 - fill;
    final minsLeft  = avgRate > 0 ? remaining / avgRate : null;
    final hrsLeft   = minsLeft != null ? minsLeft / 60 : null;
    final projColor = hrsLeft != null && hrsLeft < 2 ? AppColors.red : AppColors.amber;

    String projValue = '—';
    String projUnit  = 'no data';
    if (hrsLeft != null) {
      projValue = hrsLeft < 1 ? minsLeft!.round().toString() : hrsLeft.toStringAsFixed(1);
      projUnit  = hrsLeft < 1 ? 'min until full' : 'hrs until full';
    }

    String? projTime;
    if (minsLeft != null) {
      final fullAt = DateTime.now().add(Duration(minutes: minsLeft.round()));
      final h  = fullAt.hour % 12 == 0 ? 12 : fullAt.hour % 12;
      final m  = fullAt.minute.toString().padLeft(2, '0');
      final ap = fullAt.hour >= 12 ? 'PM' : 'AM';
      projTime = '$h:$m $ap';
    }

    final maxH = _hourly.reduce((a, b) => a > b ? a : b);
    final maxW = _weekly.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

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
                              fontSize: 9, color: AppColors.inkLight, letterSpacing: 1.0)),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(projValue,
                              style: GoogleFonts.syne(
                                  fontSize: 44, fontWeight: FontWeight.w800,
                                  color: projColor, height: 1)),
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
                            style: GoogleFonts.dmMono(fontSize: 10, color: AppColors.inkMid)),
                        const SizedBox(height: 14),
                      ] else
                        const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: fill / 100, backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(statusColor(fill)), minHeight: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('NOW ${fill.toInt()}%',
                            style: GoogleFonts.dmMono(fontSize: 8, color: AppColors.inkLight)),
                        Text('FULL 100%',
                            style: GoogleFonts.dmMono(fontSize: 8, color: AppColors.inkLight)),
                      ]),
                    ],
                  ),
                ),
              ),

              // Fill rate grid
              const SectionLabel('Fill Rate'),
              GridView.count(
                crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.2,
                children: [
                  MiniStatCard(label: 'Per Minute',
                      value: avgRate > 0 ? '${avgRate.toStringAsFixed(2)}%' : '—'),
                  MiniStatCard(label: 'Per Hour',
                      value: avgRate > 0 ? '${(avgRate * 60).toStringAsFixed(1)}%' : '—'),
                  const MiniStatCard(label: 'Peak Window', value: '12–1 PM',
                      valueColor: AppColors.green),
                  MiniStatCard(label: 'Est/Week',
                      value: avgRate > 0
                          ? '${((6 * 24 * 60 * avgRate) / 100).toStringAsFixed(1)}×' : '—'),
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
                          style: GoogleFonts.dmMono(fontSize: 9, color: AppColors.inkLight)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 56,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _hourly.asMap().entries.map((e) {
                            final isLunch = e.key >= 11 && e.key <= 13;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  height: (e.value / maxH) * 50,
                                  decoration: BoxDecoration(
                                    color: (isLunch ? AppColors.red : _barColor(e.value, maxH))
                                        .withValues(alpha: 0.88),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [0, 6, 12, 18, 23].map((h) => Text('${h}h',
                            style: GoogleFonts.dmMono(
                                fontSize: 8,
                                color: h == 12 ? AppColors.green : AppColors.inkLight))).toList(),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.greenFaint,
                          border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Peak at 12:00–1:00 PM (lunch rush). Mild 2–5 PM. Quiet evenings.',
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.green, height: 1.5)),
                      ),
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
                          style: GoogleFonts.dmMono(fontSize: 9, color: AppColors.inkLight)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 90,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _weekly.asMap().entries.map((e) {
                            final isFri = e.key == 4;
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    height: (e.value / maxW) * 56,
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: _barColor(e.value, maxW).withValues(alpha: 0.88),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_days[e.key],
                                      style: GoogleFonts.dmMono(
                                          fontSize: 9,
                                          color: isFri ? AppColors.green : AppColors.inkLight,
                                          fontWeight: isFri ? FontWeight.w500 : FontWeight.w400)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SlimDivider(),
                      const SizedBox(height: 10),
                      Text(
                        'Fridays are the busiest — consider an extra collection run before lunch. (Sunday excluded — canteen closed)',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.inkMid, height: 1.5)),
                    ],
                  ),
                ),
              ),

              // Summary
              const SectionLabel('Summary'),
              Card(
                child: Column(children: [
                  _SumRow(k: 'Sensor Readings', v: '${logs.length}'),
                  _SumRow(k: 'Fill Rate',
                      v: avgRate > 0 ? '${avgRate.toStringAsFixed(3)}% / min' : 'Insufficient data'),
                  const _SumRow(k: 'Peak Window', v: '12:00 – 1:00 PM'),
                  const _SumRow(k: 'Busiest Day', v: 'Friday'),
                  _SumRow(k: 'Est. Collections/Week',
                      v: avgRate > 0
                          ? '${((6 * 24 * 60 * avgRate) / 100).toStringAsFixed(1)}×' : '—',
                      last: true),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  final String k; final String v; final bool last;
  const _SumRow({required this.k, required this.v, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: last ? BorderSide.none : const BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.inkLight)),
          Text(v, style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.ink)),
        ],
      ),
    );
  }
}