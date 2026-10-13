import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecogrid/main.dart';

void main() {
  testWidgets('EcoGrid Smoke Test & UI Verification', (WidgetTester tester) async {
    // 1. Build app and initial frame
    await tester.pumpWidget(const EcoGridApp());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // 2. Verifikasi Header dan Indikator
    expect(find.text('EcoGrid Simulator'), findsOneWidget);
    expect(find.text('LIVE SIMULATION'), findsOneWidget);
    expect(find.textContaining('NIM: 202431091'), findsOneWidget);

    // 3. Verifikasi Nilai Default Kalkulasi
    // Total Daya Nominal = 15.0 kW
    expect(find.text('15.0'), findsOneWidget);
    // Total Energi Harian = 79.2 kWh/hari
    expect(find.text('79.2'), findsWidgets);
    // Rumah Disuplai = 15 Rumah
    expect(find.text('15'), findsOneWidget);

    // 4. Verifikasi Keberadaan Elemen Kanvas
    expect(find.text('Kanvas Pembangkit Interaktif'), findsOneWidget);
    expect(find.byKey(const Key('canvas_solar_device')), findsOneWidget);
    expect(find.byKey(const Key('canvas_wind_device')), findsOneWidget);

    // 5. Pengujian TAP GESTURE pada Turbin Angin
    final windFinder = find.byKey(const Key('canvas_wind_device'));
    await tester.tap(windFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Verifikasi bahwa status gesture berubah menjadi TAP GESTURE
    expect(find.text('TAP GESTURE'), findsOneWidget);

    // 6. Pengujian LONG PRESS GESTURE pada Panel Surya
    final solarFinder = find.byKey(const Key('canvas_solar_device'));
    await tester.longPress(solarFinder);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // Verifikasi Bottom Sheet terbuka
    expect(find.text('Array Panel Surya (Solar Photovoltaic)'), findsOneWidget);
    expect(find.text('Tutup Detail'), findsOneWidget);

    // Tutup bottom sheet
    await tester.tap(find.text('Tutup Detail'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 7. Pengujian DRAG / PAN GESTURE pada Turbin Angin
    await tester.drag(windFinder, const Offset(-30, 20));
    await tester.pump(const Duration(milliseconds: 300));

    // Verifikasi indikator gesture mendeteksi DRAG/PAN
    expect(find.text('DRAG/PAN GESTURE'), findsOneWidget);
  });
}
