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
  TrashBin?   _bin;
  double      _fillLevel = 0;
  List<SensorLog> _sensorLogs = [];
  List<Report>    _reports    = [];
  bool _isLoading = true;
  String? _error;

  // Subscriptions
  StreamSubscription? _authSub;
  StreamSubscription? _rtdbSub;
  StreamSubscription? _binSub;
  StreamSubscription? _logsSub;
  StreamSubscription? _reportsSub;

  AppUser?         get user        => _user;
  TrashBin?        get bin         => _bin;
  double           get fillLevel   => _fillLevel;
  List<SensorLog>  get sensorLogs  => _sensorLogs;
  List<Report>     get reports     => _reports;
  bool             get isLoading   => _isLoading;
  String?          get error       => _error;
  bool             get isAdmin     => _user?.isAdmin ?? false;
  int get pendingReports => _reports.where((r) => r.status == ReportStatus.pending).length;

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
    // Live fill level from Realtime Database (Arduino writes here)
    _rtdbSub = _rtdb.ref('/bins/BIN-001/fillLevel').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null) {
        _fillLevel = (val as num).toDouble();
        _bin = _bin?.copyWith(fillLevel: _fillLevel);
        notifyListeners();
      }
    });

    // Bin metadata from Firestore
    _binSub = _db.collection('bins').doc('BIN-001').snapshots().listen((snap) {
      if (snap.exists) {
        _bin = TrashBin.fromFirestore(snap.data()!);
        notifyListeners();
      }
    });

    // Sensor logs — latest 20
    _logsSub = _db
        .collection('bins')
        .doc('BIN-001')
        .collection('sensorLogs')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snap) {
      _sensorLogs = snap.docs
          .map((d) => SensorLog.fromFirestore(d.id, d.data()))
          .toList();
      notifyListeners();
    });

    // Reports — latest 50
    _reportsSub = _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      _reports = snap.docs
          .map((d) => Report.fromFirestore(d.id, d.data()))
          .toList();
      notifyListeners();
    });
  }

  void _cancelDataStreams() {
    _rtdbSub?.cancel();
    _binSub?.cancel();
    _logsSub?.cancel();
    _reportsSub?.cancel();
    _bin = null;
    _sensorLogs = [];
    _reports = [];
  }

  // ── Actions

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign-in failed';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> markCollected() async {
    final now = DateTime.now();
    await Future.wait([
      _rtdb.ref('/bins/BIN-001/fillLevel').set(0),
      _db.collection('bins').doc('BIN-001').update({
        'fillLevel': 0,
        'lastCollected': Timestamp.fromDate(now),
      }),
      _db
          .collection('bins')
          .doc('BIN-001')
          .collection('sensorLogs')
          .add({'fillLevel': 0, 'timestamp': Timestamp.fromDate(now)}),
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

  Future<void> updateBinDetails(String location, String wasteType) async {
    await _db.collection('bins').doc('BIN-001').update({
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
