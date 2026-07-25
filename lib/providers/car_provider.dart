import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import '../models/car_data.dart';
import '../services/usb_service.dart';

class CarProvider extends ChangeNotifier {
  final UsbService _usbService = UsbService();
  CarData carData = CarData();
  StreamSubscription? _dataSub;

  // Settings
  int showRunTime = 5;
  int policeFreqMs = 300;
  int raceBurstThreshold = 6500;
  int sportBurstThreshold = 5000;
  int showBurstThreshold = 4500;
  bool welcomeEnabled = true;
  bool farewellEnabled = true;

  void init() {
    _dataSub = _usbService.dataController.stream.listen(_parseData);
  }

  void _parseData(String raw) {
    for (var part in raw.split(',')) {
      final kv = part.split(':');
      if (kv.length != 2) continue;
      final key = kv[0];
      final value = kv[1];
      switch (key) {
        case 'RPM':
          carData.rpm = int.tryParse(value) ?? 0;
          break;
        case 'TEMP':
          carData.temp = int.tryParse(value) ?? 0;
          break;
        case 'SPEED':
          carData.speed = int.tryParse(value) ?? 0;
          break;
        case 'VOLT':
          carData.voltage = double.tryParse(value) ?? 0.0;
          break;
        case 'LIGHT':
          carData.lightsOn = value == 'ON';
          break;
        case 'MODE':
          carData.currentMode = value;
          break;
        case 'BACKFIRE':
          carData.backfireActive = value == 'ACTIVE';
          break;
      }
    }
    notifyListeners();
  }

  Future<bool> connectToDevice(UsbDevice device) => _usbService.connect(device);

  void changeMode(String mode) => _usbService.sendCommand('MODE $mode');
  void toggleUnderlight() => _usbService.sendCommand('TOGGLE_UNDERLIGHT');
  void sendSetting(String setting) => _usbService.sendCommand('SET $setting');

  @override
  void dispose() {
    _dataSub?.cancel();
    _usbService.dispose();
    super.dispose();
  }
}
