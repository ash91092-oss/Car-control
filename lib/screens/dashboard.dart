import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../providers/car_provider.dart';
import '../services/usb_service.dart';
import 'settings.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<void> _connect() async {
    final devices = await UsbSerial.listDevices();
    if (!mounted) return;
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ دستگاهی پیدا نشد')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('انتخاب دستگاه USB'),
        children: devices.map((d) => SimpleDialogOption(
          onPressed: () {
            Navigator.pop(ctx);
            _connectTo(d);
          },
          child: Text(d.productName ?? 'ESP32'),
        )).toList(),
      ),
    );
  }

  Future<void> _connectTo(UsbDevice device) async {
    final ok = await context.read<CarProvider>().connectToDevice(device);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'اتصال موفق' : 'اتصال ناموفق')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('۲۰۷i Challenger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.usb),
            onPressed: _connect,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // RPM Gauge
            SizedBox(
              height: 250,
              child: SfRadialGauge(
                axes: [
                  RadialAxis(
                    minimum: 0,
                    maximum: 8000,
                    ranges: const [
                      GaugeRange(start: 0, end: 6000, color: Colors.green),
                      GaugeRange(start: 6000, end: 7000, color: Colors.orange),
                      GaugeRange(start: 7000, end: 8000, color: Colors.red),
                    ],
                    pointers: [
                      NeedlePointer(value: provider.carData.rpm.toDouble()),
                    ],
                    annotations: [
                      GaugeAnnotation(
                        widget: Text(
                          '${provider.carData.rpm} RPM',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Digital readouts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard('دما', '${provider.carData.temp}°C', Icons.thermostat),
                _infoCard('سرعت', '${provider.carData.speed}', Icons.speed),
                _infoCard('ولتاژ', provider.carData.voltage.toStringAsFixed(1), Icons.battery_std),
              ],
            ),
            const SizedBox(height: 20),
            // Mode buttons
            const Text('حالت رانندگی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _modeButton('NORMAL', 'معمولی', Icons.eco, provider),
                _modeButton('SHOW', 'نمایشی', Icons.star, provider),
                _modeButton('SPORT', 'اسپرت', Icons.speed, provider),
                _modeButton('RACE', 'مسابقه', Icons.flag, provider),
                _modeButton('AUTO', 'خودکار', Icons.auto_mode, provider),
                _modeButton('PARTY', 'مهمانی', Icons.music_note, provider),
              ],
            ),
            const SizedBox(height: 20),
            // Underlight toggle (only in RACE)
            if (provider.carData.currentMode == 'RACE')
              ElevatedButton.icon(
                onPressed: provider.toggleUnderlight,
                icon: const Icon(Icons.lightbulb),
                label: const Text('خاموش/روشن زیر ماشین'),
              ),
            if (provider.carData.backfireActive)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 10),
                color: Colors.red,
                child: const Text('بک‌فایر فعال', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.redAccent),
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _modeButton(String mode, String label, IconData icon, CarProvider provider) {
    final isActive = provider.carData.currentMode == mode;
    return ElevatedButton.icon(
      onPressed: () => provider.changeMode(mode),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.redAccent : Colors.grey[800],
      ),
    );
  }
}
