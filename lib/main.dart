import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/car_provider.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(Challenger207iApp());
}

class Challenger207iApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarProvider()..init(),
      child: MaterialApp(
        title: '۲۰۷i Challenger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.redAccent,
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
          // fontFamily: 'Vazir',  // اگر فونت رو نداری، این خط رو کامنت کن
        ),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fa', 'IR')],
        home: const Dashboard(),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}
