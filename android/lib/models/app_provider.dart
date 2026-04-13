import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models.dart';

class AppProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance;

  AppUser?    _user;

  // BIN-001 — Biodegradable
  TrashBin?   _bin1;
  double      _fillLevel1 = 0;
  bool        _wetWaste1 = false;
  int         _moistureRaw1 = 0;
  List<SensorLog> _sensorLogs1 = [];
  DateTime?   _lastLoggedAt1;
  double?     _lastLoggedFill1;

  // BIN-002 — Non-Biodegradable
  TrashBin?   _bin2;
  double      _fillLevel2 = 0;
  bool        _wetWaste2 = false;
  int         _moistureRaw2 = 0;
  List<SensorLog> _sensorLogs2 = [];
  DateTime?   _lastLoggedAt2;
  double?     _lastLoggedFill2;

  List<Report> _reports = [];
  bool _isLoading = true;
  String? _error;

  // Subscriptions
  StreamSubscription? _authSub;
  StreamSubscription? _rtdbSub1;
  StreamSubscription? _rtdbSub1Wet;
  StreamSubscription? _rtdbSub1Moisture;
  StreamSubscription? _rtdbSub2;
  StreamSubscription? _rtdbSub2Wet;
  StreamSubscription? _rtdbSub2Moisture;
  StreamSubscription? _binSub1;
  StreamSubscription? _binSub2;
  StreamSubscription? _logsSub1;
  StreamSubscription? _logsSub2;
  StreamSubscription? _reportsSub;

  AppUser?         get user         => _user;
  TrashBin?        get bin1         => _bin1;
  TrashBin?        get bin2         => _bin2;
  double           get fillLevel1   => _fillLevel1;
  bool             get wetWaste1    => _wetWaste1;
  int              get moistureRaw1 => _moistureRaw1;
  double           get fillLevel2   => _fillLevel2;
  bool             get wetWaste2    => _wetWaste2;
  int              get moistureRaw2 => _moistureRaw2;
  List<SensorLog>  get sensorLogs1  => _sensorLogs1;
  List<SensorLog>  get sensorLogs2  => _sensorLogs2;
  List<Report>     get reports      => _reports;
  bool             get isLoading    => _isLoading;
  String?          get error        => _error;
  bool             get isAdmin      => _user?.isAdmin ?? false;
  int get pendingReports => _reports.where((r) => r.status == ReportStatus.pending).length;

  // Keep these for backward compat in existing screens
  double    get fillLevel  => _fillLevel1;
  TrashBin? get bin        => _bin1;
  List<SensorLog> get sensorLogs => _sensorLogs1;

  AppProvider() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _cancelDataStreams();
      _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = AppUser.fromFirestore(firebaseUser.uid, doc.data()!);
        _startDataStreams();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _startDataStreams() {
    // BIN-001 RTDB stream
    _rtdbSub1 = _rtdb.ref('/bins/BIN-001/fillLevel').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null) {
        _fillLevel1 = (val as num).toDouble();
        _bin1 = _bin1?.copyWith(fillLevel: _fillLevel1);
        _maybeAppendSensorLog(binId: 'BIN-001', fillLevel: _fillLevel1);
        notifyListeners();
      }
    });

    _rtdbSub1Wet = _rtdb.ref('/bins/BIN-001/wetWaste').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null) {
        _wetWaste1 = val == true || val.toString().toLowerCase() == 'true';
        _bin1 = _bin1?.copyWith(wetWaste: _wetWaste1);
        notifyListeners();
      }
    });

    _rtdbSub1Moisture = _rtdb.ref('/bins/BIN-001/moistureRaw').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null) {
        _moistureRaw1 = (val as num).toInt();
        _bin1 = _bin1?.copyWith(moistureRaw: _moistureRaw1);
        notifyListeners();
      }
    });

    // BIN-002 RTDB stream
    _rtdbSub2 = _rtdb.ref('/bins/BIN-002/fillLevel').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null) {
        _fillLevel2 = (val as num).toDouble();
        _bin2 = _bin2?.copyWith(fillLevel: _fillLevel2);
        _maybeAppendSensorLog(binId: 'BIN-002', fillLevel: _fillLevel2);
        notifyListeners();
      }
    });

    _rtdbSub2Wet = _rtdb.ref('/bins/BIN-002/wetWaste').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null) {
        _wetWaste2 = val == true || val.toString().toLowerCase() == 'true';
        _bin2 = _bin2?.copyWith(wetWaste: _wetWaste2);
        notifyListeners();
      }
    });

    _rtdbSub2Moisture = _rtdb.ref('/bins/BIN-002/moistureRaw').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null) {
        _moistureRaw2 = (val as num).toInt();
        _bin2 = _bin2?.copyWith(moistureRaw: _moistureRaw2);
        notifyListeners();
      }
    });

    // BIN-001 Firestore metadata
    _binSub1 = _db.collection('bins').doc('BIN-001').snapshots().listen((snap) {
      if (snap.exists) {
        _bin1 = TrashBin.fromFirestore(snap.data()!);
        notifyListeners();
      }
    });

    // BIN-002 Firestore metadata
    _binSub2 = _db.collection('bins').doc('BIN-002').snapshots().listen((snap) {
      if (snap.exists) {
        _bin2 = TrashBin.fromFirestore(snap.data()!);
        notifyListeners();
      }
    });

    // BIN-001 sensor logs
    _logsSub1 = _db
        .collection('bins').doc('BIN-001').collection('sensorLogs')
        .orderBy('timestamp', descending: true).limit(20)
        .snapshots().listen((snap) {
      _sensorLogs1 = snap.docs
          .map((d) => SensorLog.fromFirestore(d.id, d.data()))
          .where((log) => log.fillLevel > 0 && log.fillLevel <= 100)
          .toList();
      notifyListeners();
    });

    // BIN-002 sensor logs
    _logsSub2 = _db
        .collection('bins').doc('BIN-002').collection('sensorLogs')
        .orderBy('timestamp', descending: true).limit(20)
        .snapshots().listen((snap) {
      _sensorLogs2 = snap.docs
          .map((d) => SensorLog.fromFirestore(d.id, d.data()))
          .where((log) => log.fillLevel > 0 && log.fillLevel <= 100)
          .toList();
      notifyListeners();
    });

    // Reports
    _reportsSub = _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      _reports = snap.docs.map((d) => Report.fromFirestore(d.id, d.data())).toList();
      notifyListeners();
    });
  }

  void _maybeAppendSensorLog({required String binId, required double fillLevel}) {
    // Ignore reset/noise values so manual empty actions do not pollute trend history.
    if (fillLevel <= 0 || fillLevel > 100) return;

    final now = DateTime.now();
    final isBin1 = binId == 'BIN-001';
    final lastAt = isBin1 ? _lastLoggedAt1 : _lastLoggedAt2;
    final lastFill = isBin1 ? _lastLoggedFill1 : _lastLoggedFill2;

    final enoughTime = lastAt == null || now.difference(lastAt).inMinutes >= 5;
    final enoughChange = lastFill == null || (fillLevel - lastFill).abs() >= 2;

    if (!enoughTime && !enoughChange) return;

    if (isBin1) {
      _lastLoggedAt1 = now;
      _lastLoggedFill1 = fillLevel;
    } else {
      _lastLoggedAt2 = now;
      _lastLoggedFill2 = fillLevel;
    }

    unawaited(
      _db.collection('bins').doc(binId).collection('sensorLogs').add({
        'fillLevel': fillLevel,
        'timestamp': Timestamp.fromDate(now),
      }).catchError((e) {
        debugPrint('Failed to append sensor log for $binId: $e');
        throw e;
      }),
    );
  }

  void _cancelDataStreams() {
    _rtdbSub1?.cancel(); _rtdbSub1Wet?.cancel(); _rtdbSub1Moisture?.cancel();
    _rtdbSub2?.cancel(); _rtdbSub2Wet?.cancel(); _rtdbSub2Moisture?.cancel();
    _binSub1?.cancel();  _binSub2?.cancel();
    _logsSub1?.cancel(); _logsSub2?.cancel();
    _reportsSub?.cancel();
    _bin1 = null; _bin2 = null;
    _wetWaste1 = false; _moistureRaw1 = 0;
    _wetWaste2 = false; _moistureRaw2 = 0;
    _lastLoggedAt1 = null; _lastLoggedFill1 = null;
    _lastLoggedAt2 = null; _lastLoggedFill2 = null;
    _sensorLogs1 = []; _sensorLogs2 = [];
    _reports = [];
  }

  // ── Actions

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign-in failed';
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> markCollected(String binId) async {
    final now = DateTime.now();
    await Future.wait([
      _rtdb.ref('/bins/$binId/fillLevel').set(0),
      _rtdb.ref('/bins/$binId/wetWaste').set(false),
      _rtdb.ref('/bins/$binId/moistureRaw').set(0),
      _rtdb.ref('/bins/$binId/sensorOnline').set(true),
      _db.collection('bins').doc(binId).update({
        'fillLevel': 0,
        'wetWaste': false,
        'moistureRaw': 0,
        'lastCollected': Timestamp.fromDate(now),
      }),
    ]);
  }

  Future<void> fileReport(String issue) async {
    if (_user == null) return;
    await _db.collection('reports').add({
      'filedBy': _user!.name,
      'filedByUid': _user!.uid,
      'issue': issue,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    await _db.collection('reports').doc(reportId).update({'status': status});
  }

  Future<void> deleteReport(String reportId) async {
    await _db.collection('reports').doc(reportId).delete();
  }

  Future<void> updateBinDetails(String binId, String location, String wasteType) async {
    await _db.collection('bins').doc(binId).update({
      'location': location,
      'wasteType': wasteType,
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cancelDataStreams();
    super.dispose();
  }
}
