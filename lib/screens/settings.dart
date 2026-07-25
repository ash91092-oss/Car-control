import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('خوش‌آمدگویی (Welcome)'),
              value: provider.welcomeEnabled,
              onChanged: (v) {
                provider.welcomeEnabled = v;
                provider.sendSetting('WELCOME ${v ? 1 : 0}');
              },
            ),
            SwitchListTile(
              title: const Text('بدرقه (Farewell)'),
              value: provider.farewellEnabled,
              onChanged: (v) {
                provider.farewellEnabled = v;
                provider.sendSetting('FAREWELL ${v ? 1 : 0}');
              },
            ),
            const Divider(),
            const Text('تنظیمات بک‌فایر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _slider('زمان نمایش Show', provider.showRunTime, 1, 10, (v) {
              provider.showRunTime = v.toInt();
              provider.sendSetting('SHOWTIME ${v.toInt()}');
            }),
            _slider('فرکانس چشمک پلیسی (ms)', provider.policeFreqMs, 100, 1000, (v) {
              provider.policeFreqMs = v.toInt();
              provider.sendSetting('POLICEFREQ ${v.toInt()}');
            }),
            _slider('آستانه رگبار Race (RPM)', provider.raceBurstThreshold, 4000, 7000, (v) {
              provider.raceBurstThreshold = v.toInt();
              provider.sendSetting('RACERPM ${v.toInt()}');
            }),
            _slider('آستانه رگبار Sport (RPM)', provider.sportBurstThreshold, 4000, 7000, (v) {
              provider.sportBurstThreshold = v.toInt();
              provider.sendSetting('SPORTRPM ${v.toInt()}');
            }),
            _slider('آستانه رگبار Show (RPM)', provider.showBurstThreshold, 4000, 7000, (v) {
              provider.showBurstThreshold = v.toInt();
              provider.sendSetting('SHOWRPM ${v.toInt()}');
            }),
          ],
        ),
      ),
    );
  }

  Widget _slider(String title, int current, int min, int max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: $current'),
        Slider(
          value: current.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
