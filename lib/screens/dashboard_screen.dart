import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p    = context.watch<AppProvider>();
    final fill = p.fillLevel;
    final col  = statusColor(fill);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.greenDark,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TIP QC — Canteen',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 4),
                    Text('Smart Trash',
                        style: GoogleFonts.syne(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                                color: AppColors.greenMid,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text('ARDUINO · LIVE',
                              style: GoogleFonts.dmMono(
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  letterSpacing: 0.8)),
                        ]),
                        StatusPill(
                            label: 'Administrator',
                            color: Colors.white.withValues(alpha: 0.45)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Body
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Gauge card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          FillGauge(fill: fill, size: 100),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StatusPill(label: statusLabel(fill), color: col),
                                const SizedBox(height: 8),
                                Text(statusMessage(fill),
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.inkMid,
                                        height: 1.5)),
                                const SizedBox(height: 8),
                                Text('BIN-001 · HC-SR04',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 9,
                                        color: AppColors.inkLight)),
                                if (p.bin != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last collected: ${DateFormat('MMM d · h:mm a').format(p.bin!.lastCollected)}',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 9,
                                        color: AppColors.inkLight),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overview grid
                  const SectionLabel('Overview'),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2,
                    children: [
                      MiniStatCard(
                          label: 'Remaining',
                          value: '${(100 - fill).toInt()}%',
                          valueColor: AppColors.green),
                      MiniStatCard(
                          label: 'Status',
                          value: statusLabel(fill),
                          valueColor: col),
                      const MiniStatCard(label: 'Sensor', value: 'HC-SR04'),
                      const MiniStatCard(
                          label: 'Controller', value: 'Arduino UNO'),
                    ],
                  ),

                  // Sensor log
                  const SectionLabel('Sensor Log'),
                  p.sensorLogs.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text('No sensor readings yet.',
                                  style: GoogleFonts.dmMono(
                                      fontSize: 10,
                                      color: AppColors.inkLight)),
                            ),
                          ),
                        )
                      : Card(
                          child: Column(
                            children: [
                              for (int i = 0; i < p.sensorLogs.length; i++) ...[
                                _LogTile(log: p.sensorLogs[i]),
                                if (i < p.sensorLogs.length - 1)
                                  const SlimDivider(),
                              ],
                            ],
                          ),
                        ),

                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final dynamic log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final fill = (log.fillLevel as double);
    final col  = statusColor(fill);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              fill.toInt().toString(),
              style: GoogleFonts.dmMono(
                  fontSize: 10, fontWeight: FontWeight.w500, color: col),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: fill / 100,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(col),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a · MMM d').format(log.timestamp as DateTime),
                  style: GoogleFonts.dmMono(
                      fontSize: 9, color: AppColors.inkLight),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${fill.toInt()}%',
            style: GoogleFonts.dmMono(
                fontSize: 10, fontWeight: FontWeight.w500, color: col),
          ),
        ],
      ),
    );
  }
}
