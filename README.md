# EcoGrid Energy Simulator

**Mata Kuliah:** Pemrograman Mobile  
**Topik Tugas:** INTERACTIVE MOBILE UI DENGAN FLUTTER GESTURES  
**Nama Aplikasi:** EcoGrid Energy Simulator  
**NIM:** 202431091  
**Platform Target:** Android (Responsive & Adaptive Mobile Layout)  
**Bahasa Antarmuka:** Bahasa Indonesia  

---

## 1. Deskripsi & Tujuan Aplikasi

**EcoGrid Energy Simulator** adalah aplikasi simulasi pembangkit listrik energi terbarukan interaktif berbasis Flutter. Aplikasi ini dirancang untuk memberikan pemahaman edukatif mengenai bagaimana bauran energi bersih—khususnya Pembangkit Listrik Tenaga Surya (PLTS) dan Pembangkit Listrik Tenaga Bayu (PLTB)—dapat disimulasikan secara dinamis untuk menyuplai kebutuhan listrik komunitas.

Aplikasi ini menyajikan antarmuka visual modern (*dark green energy dashboard*) dengan animasi hidup, visualisasi kanvas lanskap interaktif menggunakan `CustomPainter`, serta implementasi penuh **tiga gesture wajib Flutter (Tap, Long Press, dan Drag/Pan)**.

---

## 2. Kaitan dengan SDG 7 dan SDG 13

Aplikasi ini mengintegrasikan indikator keberlanjutan global PBB:
* **SDG 7 (Affordable and Clean Energy / Energi Bersih dan Terjangkau):**
  Mengedukasi pengguna mengenai optimalisasi pembangkitan daya listrik dari sumber daya alam berkelanjutan (surya dan angin) dengan memantau kapasitas terpasang (kW), energi harian (kWh/hari), dan estimasi jumlah rumah tangga yang dapat dialiri listrik.
* **SDG 13 (Climate Action / Penanganan Perubahan Iklim):**
  Menghitung estimasi emisi karbon ($CO_2$) yang berhasil dicegah per hari dibandingkan dengan pembangkitan energi fosil konvensional (faktor emisi: ~0.785 kg $CO_2$/kWh).

---

## 3. Fitur Utama Simulasi Energi

1. **Live Energy Dashboard:**
   * Total Daya Nominal terpasang (kW).
   * Total Produksi Energi Harian (kWh/hari).
   * Estimasi Jumlah Rumah yang dapat disuplai (asumsi konsumsi listrik rumah tangga harian).
   * Estimasi Reduksi Emisi Karbon $CO_2$ (kg/hari).
   * Indikator *LIVE SIMULATION* dengan animasi pulsating neon glow.
2. **Breakdown & Diagram Kontribusi:**
   * Rincian daya dan energi surya vs angin.
   * Diagram cincin (*Donut Ring Chart*) interaktif dan indikator batang proporsional sumber energi.
3. **Kanvas Pembangkit Interaktif:**
   * Lanskap bukit berlapis, langit gradasi, matahari berpendar dinamis, dan angin semilir menggunakan `CustomPainter`.
   * Objek Panel Surya dengan modul sel grid fotovoltaik.
   * Objek Turbin Angin dengan animasi rotasi 3 bilah baling-baling halus menggunakan `AnimationController` & `Transform.rotate` yang kecepatannya dipengaruhi faktor kapasitas angin.
4. **Kontrol Parameter Lengkap:**
   * Tambah/kurang jumlah panel surya (0 - 100 unit).
   * Tambah/kurang jumlah turbin angin (0 - 20 unit).
   * Slider Jam Matahari Efektif (1.0 - 10.0 jam/hari).
   * Slider Faktor Kapasitas Angin / *Capacity Factor* (5% - 80%).
   * Slider Kapasitas per Panel (Wp) dan Turbin (kW).
   * Saklar (*Switch*) aktivasi perangkat individual.
   * Tombol *Reset ke Default* dengan snackbar feedback.

---

## 4. Rumus dan Asumsi Perhitungan Matematis

Perhitungan diimplementasikan secara terpisah dan murni di dalam `lib/utils/energy_calculator.dart`.

### A. Rumus

1. **Energi Surya Harian:**
   $$\text{solarEnergyKwh} = \frac{\text{solarPanelCount} \times \text{solarPanelPowerWp} \times \text{effectiveSunHours} \times \text{performanceRatio}}{1000}$$
2. **Daya Surya Nominal:**
   $$\text{solarPowerKw} = \frac{\text{solarPanelCount} \times \text{solarPanelPowerWp}}{1000}$$
3. **Energi Angin Harian:**
   $$\text{windEnergyKwh} = \text{windTurbineCount} \times \text{windTurbinePowerKw} \times \text{windCapacityFactor} \times 24$$
4. **Daya Angin Nominal:**
   $$\text{windPowerKw} = \text{windTurbineCount} \times \text{windTurbinePowerKw}$$
5. **Total Energi Harian:**
   $$\text{totalEnergyKwh} = \text{solarEnergyKwh} + \text{windEnergyKwh}$$
6. **Total Daya Nominal:**
   $$\text{totalPowerKw} = \text{solarPowerKw} + \text{windPowerKw}$$
7. **Estimasi Rumah yang Disuplai:**
   $$\text{homesPowered} = \left\lfloor \frac{\text{totalEnergyKwh}}{\text{householdConsumptionKwhPerDay}} \right\rfloor$$
8. **Persentase Kontribusi Sumber Energi:**
   $$\text{solarContributionPercent} = \frac{\text{solarEnergyKwh}}{\text{totalEnergyKwh}} \times 100\%$$
   $$\text{windContributionPercent} = \frac{\text{windEnergyKwh}}{\text{totalEnergyKwh}} \times 100\%$$
   *(Kondisi $\text{totalEnergyKwh} = 0$ ditangani secara aman untuk mencegah pembagian dengan nol).*

### B. Nilai Default dan Hasil Evaluasi

* Panel Surya: **20 unit**, **450 Wp**, **5.0 jam efektif**, PR: **0.80**
* Turbin Angin: **3 unit**, **2.0 kW**, Capacity Factor: **0.30**
* Konsumsi Rumah Tangga: **5.0 kWh/hari**

**Hasil Kalkulasi Default:**
* Energi Surya = $\frac{20 \times 450 \times 5 \times 0.80}{1000} = \mathbf{36.0\text{ kWh/hari}}$
* Daya Nominal Surya = $\frac{20 \times 450}{1000} = \mathbf{9.0\text{ kW}}$
* Energi Angin = $3 \times 2.0 \times 0.30 \times 24 = \mathbf{43.2\text{ kWh/hari}}$
* Daya Nominal Angin = $3 \times 2.0 = \mathbf{6.0\text{ kW}}$
* Total Daya Nominal = $9.0 + 6.0 = \mathbf{15.0\text{ kW}}$
* Total Energi Harian = $36.0 + 43.2 = \mathbf{79.2\text{ kWh/hari}}$
* Estimasi Rumah Disuplai = $\lfloor 79.2 / 5.0 \rfloor = \mathbf{15\text{ rumah}}$

> **Pernyataan Simulasi:** Semua angka yang disajikan adalah simulasi edukatif, bukan data sensor nyata. Produksi aktual di lapangan bergantung pada kondisi cuaca, radiasi matahari harian, kecepatan angin lokal, efisiensi inverter, sudut kemiringan instalasi, dan rugi-rugi transmisi jaringan.

---

## 5. Implementasi Tiga Gesture Wajib

Aplikasi menerapkan tiga gesture Flutter utama pada objek kanvas dan kartu statistik tanpa konflik:

### 1. TAP GESTURE (`GestureDetector.onTap` & `InkWell.onTap`)
* **Aksi:** Mengetuk objek Panel Surya atau Turbin Angin pada kanvas, atau kartu breakdown statistik.
* **Respon Visual:**
  - Border objek menyala (*neon highlight glow*).
  - Badge perangkat terpilih berubah.
  - Banner HUD *Indikator Gesture Terakhir* menampilkan status: `TAP GESTURE • [Nama Perangkat]`.
  - Informasi koordinat saat ini diperbarui.

### 2. LONG PRESS GESTURE (`GestureDetector.onLongPress`)
* **Aksi:** Menekan dan menahan jari pada objek perangkat selama ~500ms.
* **Respon Visual:**
  - Membuka *Modal Bottom Sheet* (`DeviceDetailSheet`).
  - Menampilkan lembar detail perangkat: nama, status aktif/nonaktif, jumlah unit, kapasitas per unit, daya nominal, estimasi energi harian, serta kontribusi grid.
  - Terdapat kontrol saklar interaktif untuk menyalakan/mematikan perangkat langsung dari modal.
  - Indikator gesture mencatat: `LONG PRESS GESTURE • Membuka Modal Detail`.

### 3. DRAG / PAN GESTURE (`GestureDetector.onPanUpdate`)
* **Aksi:** Menyentuh dan menggeser objek perangkat di atas area kanvas.
* **Respon Visual:**
  - Objek bergerak secara *real-time* mengikuti perpindahan jari (`details.delta`).
  - Posisi dibatasi secara aman dalam batas kanvas menggunakan batasan `LayoutBuilder` (*clamped coordinates*).
  - HUD Kanvas dan Banner Gesture menampilkan koordinat $(X, Y)$ objek yang diperbarui secara langsung saat drag berlangsung.

---

## 6. Diagram Pohon Widget (Widget Tree)

Berikut arsitektur hierarki widget yang dibangun:

```
EcoGridApp (StatelessWidget)
 └── MaterialApp
      └── DashboardScreen (StatefulWidget)
           └── Scaffold
                ├── AppBar (Header, Logo, NIM: 202431091, Live Simulation Pulse)
                └── SafeArea
                     └── SingleChildScrollView
                          └── Column
                               ├── _buildGestureFeedbackBanner (HUD Status Gesture Terakhir)
                               ├── InteractiveEnergyCanvas (StatefulWidget)
                               │    └── LayoutBuilder
                               │         └── Stack
                               │              ├── CustomPaint (_LandscapePainter)
                               │              ├── HUD Koordinat (Positioned)
                               │              ├── Panel Surya (Positioned + GestureDetector [Tap, LongPress, Pan])
                               │              │    └── AnimatedContainer (_SolarGridPainter)
                               │              └── Turbin Angin (Positioned + GestureDetector [Tap, LongPress, Pan])
                               │                   └── AnimatedContainer + AnimatedBuilder + Transform.rotate (_WindBladePainter)
                               ├── Grid Kartu Statistik (Row)
                               │    ├── EnergyStatCard (Total Daya kW)
                               │    └── EnergyStatCard (Total Energi kWh/hari)
                               ├── Grid Kartu Statistik Rumah & CO2 (Row)
                               │    ├── EnergyStatCard (Rumah Disuplai)
                               │    └── EnergyStatCard (Reduksi CO2 kg/hari)
                               ├── Breakdown Surya & Angin (Row)
                               │    ├── EnergyStatCard (Energi Surya + onTap + onLongPress)
                               │    └── EnergyStatCard (Energi Angin + onTap + onLongPress)
                               ├── EnergyContributionChart (StatelessWidget)
                               │    └── CustomPaint (_DonutChartPainter) + Legend Bars
                               ├── _buildEnvironmentStatusCard (Status Perangkat & Cuaca)
                               ├── EnergyControlPanel (StatelessWidget)
                               │    ├── Header & Tombol Reset ke Default
                               │    ├── Kontrol PLTS (Counter, Slider Jam Matahari, Slider Wp, Switch)
                               │    ├── Kontrol PLTB (Counter, Slider Kapasitas CF, Slider kW, Switch)
                               │    └── Slider Asumsi Konsumsi Rumah Tangga
                               └── _buildEducationalFooter (Catatan Edukasi SDG 7 & 13)
```

---

## 7. Struktur Folder Proyek

```
ecogrid/
├── lib/
│   ├── main.dart                          # Titik masuk utama aplikasi & konfigurasi tema
│   ├── models/
│   │   ├── energy_simulation.dart         # Model data konfigurasi simulasi
│   │   └── energy_device.dart             # Model status & posisi perangkat kanvas
│   ├── screens/
│   │   └── dashboard_screen.dart          # Layar dashboard utama & orkestrasi gesture
│   ├── widgets/
│   │   ├── energy_stat_card.dart          # Komponen kartu statistik dengan animasi angka
│   │   ├── energy_contribution_chart.dart # Diagram kontribusi donut & progress bar
│   │   ├── interactive_energy_canvas.dart # Kanvas Stack, LayoutBuilder, CustomPainter, dan Gestures
│   │   ├── device_detail_sheet.dart       # Modal Bottom Sheet untuk Long Press
│   │   └── energy_control_panel.dart      # Panel kontrol input, counter, slider, switch, reset
│   └── utils/
│       └── energy_calculator.dart         # Rumus matematika simulasi energi murni
├── test/
│   ├── energy_calculator_test.dart        # Unit test perhitungan energi & edge cases
│   └── widget_test.dart                   # Widget test antarmuka, kalkulasi default, & 3 gestures
├── pubspec.yaml                           # Konfigurasi dependensi Flutter
└── README.md                              # Dokumentasi lengkap proyek
```

---

## 8. Panduan Menjalankan & Menguji Aplikasi

### A. Prasyarat
* Flutter SDK (versi >= 3.13.0)
* Android Studio / VS Code dengan Flutter Plugin
* Emulator Android atau perangkat fisik Android yang terhubung via USB Debugging.

### B. Menjalankan Aplikasi
1. Buka terminal di direktori proyek:
   ```bash
   flutter pub get
   ```
2. Jalankan aplikasi pada perangkat Android:
   ```bash
   flutter run
   ```

### C. Menjalankan Pengujian Otomatis
1. **Unit Test Perhitungan:**
   ```bash
   flutter test test/energy_calculator_test.dart
   ```
2. **Widget Test & Pengujian Gesture:**
   ```bash
   flutter test test/widget_test.dart
   ```
3. **Seluruh Test:**
   ```bash
   flutter test
   ```

---

## 9. Panduan Menguji Setiap Gesture di Aplikasi

1. **Menguji TAP GESTURE:**
   * Sentuh/ketuk gambar **Panel Surya** atau **Turbin Angin** di area kanvas.
   * Amati border objek yang bersinar (*glow border*) dan teks `AKTIF GESTURE`.
   * Periksa banner di bawah header: akan muncul label hijau `TAP GESTURE • Panel Surya` atau biru `TAP GESTURE • Turbin Angin` beserta koordinat posisi.
2. **Menguji LONG PRESS GESTURE:**
   * Tekan dan tahan jari Anda pada objek **Panel Surya** atau **Turbin Angin** di kanvas selama 1 detik.
   * *Modal Bottom Sheet* akan terbuka dari bawah layar yang menampilkan informasi teknis rinci.
   * Ubah saklar status (Aktif/Nonaktif) pada modal sheet, lalu tekan tombol **Tutup Detail**.
   * Periksa banner gesture yang mencatat: `LONG PRESS GESTURE • Membuka Modal Detail`.
3. **Menguji DRAG / PAN GESTURE:**
   * Sentuh dan tahan objek perangkat di kanvas, lalu geser jari Anda ke segala arah.
   * Objek akan bergerak halus mengikuti jari Anda secara *real-time*.
   * Perhatikan bahwa objek tidak akan tembus ke luar area kanvas (*clamped bounds*).
   * HUD kanvas dan banner status di atas akan menampilkan koordinat $(X, Y)$ terkini saat Anda menggeser.

---

## 10. Identitas Pengembang

* **Nama:** Jonathan Steven Sitorus
* **NIM:** 202431091 (Ganjil)
* **Program Studi:** Teknik Informatika / Sistem Informasi
* **Mata Kuliah:** Pemrograman Mobile E
