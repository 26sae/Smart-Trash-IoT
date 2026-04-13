import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

// Responsive breakpoints
enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return DeviceType.mobile;
  if (width < 1024) return DeviceType.tablet;
  return DeviceType.desktop;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final device = getDeviceType(context);
    final isDesktop = device == DeviceType.desktop;
    final isTablet = device == DeviceType.tablet;
    final shellPadding = isDesktop ? 32.0 : (isTablet ? 20.0 : 14.0);
    final contentMaxWidth =
        isDesktop ? 1180.0 : (isTablet ? 920.0 : double.infinity);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.greenDark,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          isDesktop ? 1244 : (isTablet ? 960 : double.infinity),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(shellPadding, 0, shellPadding, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TIP QC — Canteen',
                              style: GoogleFonts.dmSans(
                                  fontSize: isDesktop ? 13 : 11,
                                  color: Colors.white.withValues(alpha: 0.5))),
                          const SizedBox(height: 4),
                          Text('Smart Trash',
                              style: GoogleFonts.syne(
                                  fontSize: isDesktop ? 28 : 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.4)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                        color: AppColors.greenMid,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text('ESP · LIVE',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 9,
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
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
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                shellPadding,
                14,
                shellPadding,
                24,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: _DashboardContent(
                          device: device, provider: p, isDesktop: isDesktop),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DeviceType device;
  final AppProvider provider;
  final bool isDesktop;

  const _DashboardContent({
    required this.device,
    required this.provider,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      // Desktop: Two-column layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Two bins side by side
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: _BinGaugeCard(
                    label: 'Biodegradable',
                    binId: 'BIN-001',
                    fill: provider.fillLevel2,
                    bin: provider.bin2,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _BinGaugeCard(
                    label: 'Non-Biodegradable',
                    binId: 'BIN-002',
                    fill: provider.fillLevel1,
                    bin: provider.bin1,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Overview stats in 4 columns
          const SectionLabel('Overview'),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: [
              MiniStatCard(
                label: 'BIO Remaining',
                value: '${(100 - provider.fillLevel1).toInt()}%',
                valueColor: AppColors.green,
              ),
              MiniStatCard(
                label: 'NON-BIO Remaining',
                value: '${(100 - provider.fillLevel2).toInt()}%',
                valueColor: const Color(0xFF1565C0),
              ),
              MiniStatCard(
                label: 'BIO Status',
                value: statusLabel(provider.fillLevel1),
                valueColor: statusColor(provider.fillLevel1),
              ),
              MiniStatCard(
                label: 'NON-BIO Status',
                value: statusLabel(provider.fillLevel2),
                valueColor: statusColor(provider.fillLevel2),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logs side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Biodegradable — Sensor Log'),
                    _LogCard(logs: provider.sensorLogs2),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Non-Biodegradable — Sensor Log'),
                    _LogCard(logs: provider.sensorLogs1),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Mobile/Tablet: Stacked layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Two gauges side by side
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _BinGaugeCard(
                    label: 'Biodegradable',
                    binId: 'BIN-001',
                    fill: provider.fillLevel2,
                    bin: provider.bin2,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(width: device == DeviceType.mobile ? 8 : 10),
                Expanded(
                  child: _BinGaugeCard(
                    label: 'Non-Biodegradable',
                    binId: 'BIN-002',
                    fill: provider.fillLevel1,
                    bin: provider.bin1,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const SectionLabel('Overview'),
          GridView.count(
            crossAxisCount: device == DeviceType.mobile ? 2 : 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: [
              MiniStatCard(
                label: 'BIO Remaining',
                value: '${(100 - provider.fillLevel1).toInt()}%',
                valueColor: AppColors.green,
              ),
              MiniStatCard(
                label: 'NON-BIO Remaining',
                value: '${(100 - provider.fillLevel2).toInt()}%',
                valueColor: const Color(0xFF1565C0),
              ),
              MiniStatCard(
                label: 'BIO Status',
                value: statusLabel(provider.fillLevel1),
                valueColor: statusColor(provider.fillLevel1),
              ),
              MiniStatCard(
                label: 'NON-BIO Status',
                value: statusLabel(provider.fillLevel2),
                valueColor: statusColor(provider.fillLevel2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // BIN-001 Sensor Log
          const SectionLabel('Biodegradable — Sensor Log'),
          _LogCard(logs: provider.sensorLogs1),

          const SizedBox(height: 12),

          // BIN-002 Sensor Log
          const SectionLabel('Non-Biodegradable — Sensor Log'),
          _LogCard(logs: provider.sensorLogs2),

          const SizedBox(height: 8),
        ],
      );
    }
  }
}

class _BinGaugeCard extends StatelessWidget {
  final String label;
  final String binId;
  final double fill;
  final TrashBin? bin;
  final Color color;

  const _BinGaugeCard({
    required this.label,
    required this.binId,
    required this.fill,
    required this.bin,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final col = statusColor(fill);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmMono(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6)),
            const SizedBox(height: 10),
            FillGauge(fill: fill, size: 88),
            const SizedBox(height: 10),
            StatusPill(label: statusLabel(fill), color: col),
            const SizedBox(height: 6),
            Text(statusMessage(fill),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: AppColors.inkMid, height: 1.4)),
            const SizedBox(height: 6),
            Text(
              'Wet waste: ${bin?.wetWaste == true ? 'YES' : 'NO'}',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmMono(
                fontSize: 8,
                color:
                    bin?.wetWaste == true ? AppColors.red : AppColors.inkLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Moisture: ${bin?.moistureRaw ?? 0}',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmMono(fontSize: 8, color: AppColors.inkLight),
            ),
            const SizedBox(height: 6),
            Text(binId,
                style:
                    GoogleFonts.dmMono(fontSize: 8, color: AppColors.inkLight)),
            if (bin != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last: ${DateFormat('MMM d · h:mm a').format(bin!.lastCollected)}',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.dmMono(fontSize: 8, color: AppColors.inkLight),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final List<dynamic> logs;
  const _LogCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text('No sensor readings yet.',
                style: GoogleFonts.dmMono(
                    fontSize: 10, color: AppColors.inkLight)),
          ),
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < logs.length; i++) ...[
            _LogTile(log: logs[i]),
            if (i < logs.length - 1) const SlimDivider(),
          ],
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final dynamic log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final fill = log.fillLevel as double;
    final col = statusColor(fill);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(fill.toInt().toString(),
                style: GoogleFonts.dmMono(
                    fontSize: 10, fontWeight: FontWeight.w500, color: col)),
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
                    DateFormat('h:mm a · MMM d')
                        .format(log.timestamp as DateTime),
                    style: GoogleFonts.dmMono(
                        fontSize: 9, color: AppColors.inkLight)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${fill.toInt()}%',
              style: GoogleFonts.dmMono(
                  fontSize: 10, fontWeight: FontWeight.w500, color: col)),
        ],
      ),
    );
  }
}
