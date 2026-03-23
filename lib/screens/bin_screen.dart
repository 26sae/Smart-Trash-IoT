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

class _BinScreenState extends State<BinScreen> {
  bool _editing = false;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _wasteTypeCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final bin = context.read<AppProvider>().bin;
    _locationCtrl  = TextEditingController(text: bin?.location  ?? 'TIP QC Canteen');
    _wasteTypeCtrl = TextEditingController(text: bin?.wasteType ?? 'General');
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
      _locationCtrl.text.trim(),
      _wasteTypeCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() { _saving = false; _editing = false; });
  }

  @override
  Widget build(BuildContext context) {
    final p    = context.watch<AppProvider>();
    final fill = p.fillLevel;
    final col  = statusColor(fill);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Bin Management'),
        actions: [
          TextButton(
            onPressed: () {
              if (_editing) {
                _save();
              } else {
                setState(() => _editing = true);
              }
            },
            child: Text(
              _editing ? (_saving ? 'Saving...' : 'Save') : 'Edit',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _editing ? AppColors.green : AppColors.green,
              ),
            ),
          ),
          if (_editing)
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: Text('Cancel',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.inkLight)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Visual fill card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Bin vessel graphic
                          Column(children: [
                            SizedBox(
                              width: 48, height: 96,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border, width: 1.5),
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
                                    child: Text(
                                      '${fill.toInt()}%',
                                      style: GoogleFonts.dmMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: fill > 55 ? Colors.white : col,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('BIN-001',
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
                                          height: 1),
                                    ),
                                    TextSpan(
                                      text: '%',
                                      style: GoogleFonts.syne(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: col),
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: 6),
                                StatusPill(
                                    label: statusLabel(fill), color: col),
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
                      // Linear progress
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
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('0%',   style: GoogleFonts.dmMono(fontSize: 8, color: AppColors.inkLight)),
                        Text('100%', style: GoogleFonts.dmMono(fontSize: 8, color: AppColors.inkLight)),
                      ]),
                    ],
                  ),
                ),
              ),

              // ── Bin details (editable)
              const SectionLabel('Bin Details'),
              Card(
                child: Column(
                  children: [
                    InfoRow(k: 'Bin ID',          v: 'BIN-001'),
                    InfoRow(k: 'Microcontroller', v: 'Arduino UNO'),
                    InfoRow(k: 'Sensor',          v: 'HC-SR04 Ultrasonic'),
                    _EditableRow(
                      label: 'Location',
                      controller: _locationCtrl,
                      editing: _editing,
                    ),
                    _EditableRow(
                      label: 'Waste Type',
                      controller: _wasteTypeCtrl,
                      editing: _editing,
                      last: true,
                    ),
                  ],
                ),
              ),

              if (_editing) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  label: _saving ? 'Saving...' : 'Save Changes',
                  onPressed: _saving ? null : _save,
                ),
              ],

              // ── Live status
              const SectionLabel('Live Status'),
              Card(
                child: Column(children: [
                  InfoRow(k: 'Fill Level', v: '${fill.toInt()}%', vc: col),
                  InfoRow(k: 'Status',     v: statusLabel(fill),  vc: col),
                  if (p.bin != null)
                    InfoRow(
                      k: 'Last Collected',
                      v: _formatDate(p.bin!.lastCollected),
                    ),
                  InfoRow(
                    k: 'Sensor Signal',
                    v: p.bin?.sensorOnline == true ? 'Online' : 'Offline',
                    vc: p.bin?.sensorOnline == true
                        ? AppColors.green
                        : AppColors.red,
                    last: true,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
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
}

// ── Editable table row
class _EditableRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editing;
  final bool last;
  const _EditableRow({
    required this.label,
    required this.controller,
    required this.editing,
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
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.inkLight)),
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
                            color: AppColors.green.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: AppColors.green, width: 1.5),
                      ),
                      filled: true,
                      fillColor: AppColors.greenFaint,
                    ),
                  ),
                )
              : Text(
                  controller.text,
                  style: GoogleFonts.dmMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink),
                ),
        ],
      ),
    );
  }
}

// ── InfoRow without const (needs dynamic data)
class InfoRow extends StatelessWidget {
  final String k;
  final String v;
  final Color? vc;
  final bool last;
  const InfoRow({super.key, required this.k, required this.v, this.vc, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.inkLight)),
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
