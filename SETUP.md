# Setup Aplikasi Gas Monitoring

## 1. Install Dependencies

Tambahkan dependencies berikut ke `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  fl_chart: ^0.69.0
  audioplayers: ^6.1.0
  provider: ^6.1.2
  intl: ^0.19.0
```

Lalu jalankan:
```bash
flutter pub get
```

## 2. Setup Assets

Tambahkan di `pubspec.yaml` bagian flutter:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/alarm.mp3
```

## 3. Download File Alarm

Download file alarm.mp3 dari:
- https://pixabay.com/sound-effects/search/alarm/
- https://freesound.org/

Simpan di folder `assets/alarm.mp3`

## 4. Jalankan Aplikasi

```bash
flutter run
```

## Fitur Aplikasi

### 1. Dashboard
- Gauge meter real-time
- Status sistem (Normal/Ambang Batas/Peringatan)
- 3 sensor monitoring
- Trend chart gas

### 2. Chart
- Grafik trend gas detail
- Statistik sensor (max, avg, durasi)

### 3. List Sensor
- Daftar semua sensor
- Lokasi dan koordinat
- Status real-time

### 4. History
- Riwayat kejadian
- Filter hari ini & kemarin

### 5. Profile
- Log aktivitas sistem

## Klasifikasi Gas

- 🟢 **Normal**: 0-100 PPM
- 🟡 **Ambang Batas**: 101-150 PPM
- 🔴 **Peringatan Tinggi**: >150 PPM (Alarm berbunyi)

## Dummy Data

Data sensor berubah otomatis setiap 3 detik untuk simulasi real-time monitoring.

Alarm akan berbunyi terus-menerus ketika ada sensor yang mencapai status PERINGATAN TINGGI (>150 PPM).
