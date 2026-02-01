import 'dart:async';
import 'dart:developer';
import 'package:battery_plus/battery_plus.dart';
import 'package:remindus/services/local_notification_service.dart';

class BatteryService {
  final Battery _battery = Battery();
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  bool _hasNotifiedLowBattery = false;

  void startMonitoring() {
    log("Battery monitoring started");
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) async {
      final int level = await _battery.batteryLevel;
      _checkBatteryLevel(level);
    });

    // Also check periodically or on start
    _checkInitialLevel();
  }

  Future<void> _checkInitialLevel() async {
    final int level = await _battery.batteryLevel;
    _checkBatteryLevel(level);
  }

  void _checkBatteryLevel(int level) {
    log("Current battery level: $level%");
    if (level <= 20) {
      if (!_hasNotifiedLowBattery) {
        _sendLowBatteryNotification(level);
        _hasNotifiedLowBattery = true;
      }
    } else {
      // Reset the flag if battery goes above 20%
      _hasNotifiedLowBattery = false;
    }
  }

  Future<void> _sendLowBatteryNotification(int level) async {
    await _notificationService.showInstantNotification(
      id: 999,
      title: 'Low Battery Alert',
      body: 'Your battery is at $level%. Please plug in your charger.',
      payload: {
        'type': 'battery_alert',
        'message': 'Your battery is low ($level%).',
      },
    );
  }

  void dispose() {
    _batteryStateSubscription?.cancel();
  }
}
