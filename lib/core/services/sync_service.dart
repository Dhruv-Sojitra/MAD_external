import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final _connectivity = Connectivity();
  StreamSubscription? _subscription;
  bool _isSyncing = false;

  void startSyncTimer() {
    _subscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _syncData();
      }
    });

    // Periodic sync attempt every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncData();
    });
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return;

    _isSyncing = true;
    if (kDebugMode) print('Syncing local data to cloud...');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (kDebugMode) print('Sync complete!');
    _isSyncing = false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
