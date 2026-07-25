import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';

class UsbService {
  UsbPort? _port;
  final StreamController<String> dataController = StreamController.broadcast();
  bool connected = false;

  Future<List<UsbDevice>> getDevices() => UsbSerial.listDevices();

  Future<bool> connect(UsbDevice device) async {
    try {
      _port = await device.create();
      if (await _port!.open()) {
        _port!.setDTR(true);
        _port!.setRTS(true);
        _port!.write(Uint8List.fromList('INIT\n'.codeUnits));
        _port!.inputStream!.listen((data) {
          dataController.add(String.fromCharCodes(data));
        });
        connected = true;
        return true;
      }
    } catch (_) {}
    return false;
  }

  void sendCommand(String cmd) {
    if (_port != null && connected) {
      _port!.write(Uint8List.fromList('$cmd\n'.codeUnits));
    }
  }

  void disconnect() {
    _port?.close();
    connected = false;
  }

  void dispose() {
    disconnect();
    dataController.close();
  }
}
