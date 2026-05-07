import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/core/services/local_storage_service.dart';

class SyncService {
  final _connectivity = Connectivity();
  StreamSubscription? _subscription;
  bool _isSyncing = false;

  void startSyncTimer() {
    _subscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _syncPendingData();
      }
    });

    // Periodic sync attempt
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncPendingData();
    });
  }

  Future<void> _syncPendingData() async {
    if (_isSyncing) return;
    
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return;

    final mealBox = Hive.box<Meal>(LocalStorageService.mealBoxName);
    final pendingMeals = mealBox.values.where((m) => m.syncStatus == 'pending').toList();

    if (pendingMeals.isEmpty) return;

    _isSyncing = true;
    if (kDebugMode) print('Syncing ${pendingMeals.length} pending operations to cloud...');

    try {
      // Simulate API calls for each pending meal
      for (var meal in pendingMeals) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Update local status to 'synced'
        final syncedMeal = meal.copyWith(syncStatus: 'synced');
        await mealBox.put(meal.id, syncedMeal);
      }
      
      if (kDebugMode) print('Sync complete!');
    } catch (e) {
      if (kDebugMode) print('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
