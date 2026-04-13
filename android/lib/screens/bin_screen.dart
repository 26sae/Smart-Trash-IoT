import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class BinScreen extends StatefulWidget {
  const BinScreen({super.key});
  @override
  State<BinScreen> createState() => _BinScreenState();
}

class _BinScreenState extends State<BinScreen>
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Bin Management'),
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
          _BinDetailTab(
            binId: 'BIN-002',
            displayBinId: 'BIN-001',
            accentColor: AppColors.green,
            defaultLocation: 'TIP QC Canteen',
            defaultWasteType: 'Biodegradable',
          ),
          _BinDetailTab(
            binId: 'BIN-001',
            displayBinId: 'BIN-002',
            accentColor: const Color(0xFF1565C0),
            defaultLocation: 'TIP QC Canteen',
            defaultWasteType: 'Non-Biodegradable',
          ),
        ],
      ),
    );
  }
}

class _BinDetailTab extends StatefulWidget {
  final String binId;
  final String displayBinId;
  final Color accentColor;
  final String defaultLocation;
  final String defaultWasteType;

  const _BinDetailTab({
    required this.binId,
    required this.displayBinId,
    required this.accentColor,
    required this.defaultLocation,
    required this.defaultWasteType,
  });

  @override
  State<_BinDetailTab> createState() => _BinDetailTabState();
}

class _BinDetailTabState extends State<_BinDetailTab> {
  bool _editing = false;
  bool _saving = false;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _wasteTypeCtrl;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>();
    final bin = widget.binId == 'BIN-001' ? p.bin1 : p.bin2;
    _locationCtrl =
        TextEditingController(text: bin?.location ?? widget.defaultLocation);
    _wasteTypeCtrl =
        TextEditingController(text: bin?.wasteType ?? widget.defaultWasteType);
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _wasteTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AppProvider>().updateBinDetails(
          widget.binId,
          _locationCtrl.text.trim(),
          _wasteTypeCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _editing = false;
    });
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today · ${_timeStr(dt)}';
    }
    return '${dt.month}/${dt.day} · ${_timeStr(dt)}';
  }

  String _timeStr(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final bin = widget.binId == 'BIN-001' ? p.bin1 : p.bin2;
    final fill = widget.binId == 'BIN-001' ? p.fillLevel1 : p.fillLevel2;
    final col = statusColor(fill);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bin label banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${widget.displayBinId} — ${widget.defaultWasteType}',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: widget.accentColor,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 12),

            // Visual fill card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(children: [
                          SizedBox(
                            width: 48,
                            height: 96,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.border, width: 1.5),
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColors.bg,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedFractionallySizedBox(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOut,
                                    heightFactor: fill / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: col.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text('${fill.toInt()}%',
                                      style: GoogleFonts.dmMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              fill > 55 ? Colors.white : col)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                            Text(widget.displayBinId,
                              style: GoogleFonts.dmMono(
                                  fontSize: 8, color: AppColors.inkLight)),
                        ]),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: '${fill.toInt()}',
                                      style: GoogleFonts.syne(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: col,
                                          height: 1)),
                                  TextSpan(
                                      text: '%',
                                      style: GoogleFonts.syne(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: col)),
                                ]),
                              ),
                              const SizedBox(height: 6),
                              StatusPill(label: statusLabel(fill), color: col),
                              const SizedBox(height: 8),
                              Text(statusMessage(fill),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.inkMid,
                                      height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: fill / 100,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(col),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0%',
                              style: GoogleFonts.dmMono(
                                  fontSize: 8, color: AppColors.inkLight)),
                          Text('100%',
                              style: GoogleFonts.dmMono(
                                  fontSize: 8, color: AppColors.inkLight)),
                        ]),
                  ],
                ),
              ),
            ),

            // Bin details (editable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('Bin Details'),
                Row(children: [
                  if (_editing)
                    TextButton(
                      onPressed: () => setState(() => _editing = false),
                      child: Text('Cancel',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppColors.inkLight)),
                    ),
                  TextButton(
                    onPressed: _editing
                        ? _save
                        : () => setState(() => _editing = true),
                    child: Text(
                      _editing ? (_saving ? 'Saving...' : 'Save') : 'Edit',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green),
                    ),
                  ),
                ]),
              ],
            ),
            Card(
              child: Column(children: [
                InfoRow(k: 'Bin ID', v: widget.displayBinId),
                InfoRow(k: 'Microcontroller', v: 'ESP32'),
                InfoRow(k: 'Sensors', v: 'HC-SR04 Ultrasonic'),
                _EditableRow(
                    label: 'Location',
                    controller: _locationCtrl,
                    editing: _editing,
                    accentColor: widget.accentColor),
                _EditableRow(
                    label: 'Waste Type',
                    controller: _wasteTypeCtrl,
                    editing: _editing,
                    accentColor: widget.accentColor,
                    last: true),
              ]),
            ),

            if (_editing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(_saving ? 'Saving...' : 'Save Changes',
                      style: GoogleFonts.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            // Live status
            const SectionLabel('Live Status'),
            Card(
              child: Column(children: [
                InfoRow(k: 'Fill Level', v: '${fill.toInt()}%', vc: col),
                InfoRow(k: 'Status', v: statusLabel(fill), vc: col),
                if (bin != null)
                  InfoRow(
                      k: 'Last Collected', v: _formatDate(bin.lastCollected)),
                InfoRow(
                  k: 'Sensor Signal',
                  v: bin?.sensorOnline == true ? 'Online' : 'Offline',
                  vc: bin?.sensorOnline == true
                      ? AppColors.green
                      : AppColors.red,
                  last: true,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Editable row
class _EditableRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editing;
  final bool last;
  final Color accentColor;
  const _EditableRow({
    required this.label,
    required this.controller,
    required this.editing,
    required this.accentColor,
    this.last = false,
  });

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
          Text(label,
              style:
                  GoogleFonts.dmSans(fontSize: 12, color: AppColors.inkLight)),
          editing
              ? SizedBox(
                  width: 160,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.dmMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                            color: accentColor.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: accentColor, width: 1.5),
                      ),
                      filled: true,
                      fillColor: AppColors.greenFaint,
                    ),
                  ),
                )
              : Text(controller.text,
                  style: GoogleFonts.dmMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink)),
        ],
      ),
    );
  }
}

// ── Info row
class InfoRow extends StatelessWidget {
  final String k;
  final String v;
  final Color? vc;
  final bool last;
  const InfoRow(
      {super.key,
      required this.k,
      required this.v,
      this.vc,
      this.last = false});

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
                  color: vc ?? AppColors.ink)),
        ],
      ),
    );
  }
}
