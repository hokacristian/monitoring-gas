# 📚 DOKUMENTASI SISTEM MONITORING GAS - GASKEUN

Aplikasi monitoring gas real-time berbasis Flutter untuk memantau 5 jenis gas berbahaya dengan sistem alarm otomatis.

---

## 📖 Daftar Isi

1. [Arsitektur Sistem](#arsitektur-sistem)
2. [Gas Provider - Sistem Simulasi](#gas-provider---sistem-simulasi)
3. [Information Page - Panduan Keamanan Gas](#information-page---panduan-keamanan-gas)
4. [Standar Keamanan Gas](#standar-keamanan-gas)
5. [Cara Kerja Aplikasi](#cara-kerja-aplikasi)

---

## 🏗️ Arsitektur Sistem

### **Tech Stack:**
- **Framework**: Flutter 3.10+
- **State Management**: Provider Pattern
- **Backend**: Firebase (Authentication + Firestore)
- **Charts**: FL Chart
- **Audio**: Audioplayers

### **Struktur Folder:**
```
lib/
├── main.dart                    # Entry point & routing
├── firebase_options.dart        # Firebase configuration
├── models/
│   └── gas_data.dart           # Data models & thresholds
├── providers/
│   └── gas_provider.dart       # State management & simulation
├── services/
│   └── auth_service.dart       # Firebase authentication
├── pages/
│   ├── login_page.dart         # Login UI
│   ├── register_page.dart      # Registration UI
│   ├── dashboard_page.dart     # Dashboard utama
│   ├── chart_page.dart         # Grafik real-time
│   ├── sensor_list_page.dart   # Detail sensor
│   ├── history_page.dart       # Riwayat kejadian
│   ├── profile_page.dart       # Profil user
│   └── information_page.dart   # Panduan keamanan gas
└── widgets/
    └── app_drawer.dart         # Sidebar navigation
```

---

## 🔬 Gas Provider - Sistem Simulasi

File: `lib/providers/gas_provider.dart`

### **1. Overview**

Gas Provider adalah inti dari sistem monitoring yang menggunakan **Provider Pattern** untuk state management. Provider ini mensimulasikan pembacaan sensor gas secara real-time dengan menggunakan algoritma berbasis **gelombang sinus (sine wave)** untuk menciptakan transisi yang smooth dan realistis.

---

### **2. Komponen Utama**

#### **A. Data Structure - SensorCycle**

```dart
class SensorCycle {
  double phase;        // Fase saat ini (0 to 2π)
  double period;       // Periode siklus (detik)
  double phaseOffset;  // Offset awal
}
```

**Penjelasan:**
- `phase`: Posisi sensor dalam siklusnya (0 = awal siklus, 2π = akhir siklus)
- `period`: Berapa lama 1 siklus penuh (semua sensor: 60 detik)
- `phaseOffset`: Offset agar sensor tidak sync (bergantian)

---

#### **B. Inisialisasi Sensor Cycles**

```dart
void _initializeSensorCycles() {
  const commonPeriod = 60.0; // 1 menit untuk semua sensor

  _sensorCycles['1'] = SensorCycle(phase: 0,             period: 60, phaseOffset: 0);
  _sensorCycles['2'] = SensorCycle(phase: 2π * 0.2,     period: 60, phaseOffset: 2π * 0.2);
  _sensorCycles['3'] = SensorCycle(phase: 2π * 0.4,     period: 60, phaseOffset: 2π * 0.4);
  _sensorCycles['4'] = SensorCycle(phase: 2π * 0.6,     period: 60, phaseOffset: 2π * 0.6);
  _sensorCycles['5'] = SensorCycle(phase: 2π * 0.8,     period: 60, phaseOffset: 2π * 0.8);
}
```

**Penjelasan:**
- **Semua sensor memiliki periode yang SAMA (60 detik)** agar bisa kembali sync ke kondisi AMAN bersamaan
- **Phase offset berbeda** (0%, 20%, 40%, 60%, 80% dari 2π)
- Ini membuat sensor **bergantian** setiap **12 detik** (60 detik / 5 sensor)

---

### **3. Algoritma Simulasi - Sine Wave**

#### **A. Update Phase**

```dart
cycle.phase += (2 * π * updateInterval) / cycle.period;
if (cycle.phase >= 2 * π) {
  cycle.phase -= 2 * π; // Reset setelah 1 siklus
}
```

**Penjelasan:**
- Setiap 2 detik (updateInterval), phase bertambah
- Kecepatan pertambahan tergantung periode (60 detik)
- Setelah mencapai 2π (360°), reset ke 0

---

#### **B. Mapping Sine Wave ke Gas Level**

```dart
double sineValue = sin(cycle.phase); // -1 to 1

if (sineValue < -0.3) {
  // KONDISI AMAN
  // Map -1 to -0.3 => 20% to 80% dari safeMax
  double t = (sineValue + 1) / 0.7;
  targetPpm = threshold.safeMax * (0.2 + t * 0.6);
}
else if (sineValue < 0.5) {
  // TRANSISI AMAN ↔ WASPADA
  // Map -0.3 to 0.5 => safeMax to warningMax
  double t = (sineValue + 0.3) / 0.8;
  targetPpm = threshold.safeMax + t * (threshold.warningMax - threshold.safeMax);
}
else {
  // KONDISI BAHAYA
  // Map 0.5 to 1 => warningMax to dangerLevel
  double t = (sineValue - 0.5) / 0.5;
  targetPpm = threshold.warningMax + t * (dangerLevel - threshold.warningMax);
}
```

**Visualisasi Mapping:**

```
Sine Wave Value          Status Gas           PPM Range

     1.0  ────────      ┌─────────────┐
                        │   BAHAYA    │      > warningMax
     0.5  ────────      ├─────────────┤
                        │  WASPADA    │      safeMax - warningMax
    -0.3  ────────      ├─────────────┤
                        │    AMAN     │      0 - safeMax
    -1.0  ────────      └─────────────┘
```

---

### **4. Timeline Siklus (60 Detik)**

#### **Detik 0: SEMUA AMAN**
```
Sensor 1 (CO):   phase = 0.00π  → AMAN
Sensor 2 (LPG):  phase = 0.40π  → AMAN
Sensor 3 (NH3):  phase = 0.80π  → AMAN
Sensor 4 (CH4):  phase = 1.20π  → AMAN
Sensor 5 (H2S):  phase = 1.60π  → AMAN
```

#### **Detik 12: Sensor 1 naik, yang lain masih aman**
```
Sensor 1 (CO):   phase = 0.40π  → WASPADA (naik)
Sensor 2 (LPG):  phase = 0.80π  → AMAN
Sensor 3 (NH3):  phase = 1.20π  → AMAN
Sensor 4 (CH4):  phase = 1.60π  → AMAN
Sensor 5 (H2S):  phase = 2.00π  → AMAN
```

#### **Detik 24: Sensor 1 BAHAYA, Sensor 2 naik**
```
Sensor 1 (CO):   phase = 0.80π  → BAHAYA
Sensor 2 (LPG):  phase = 1.20π  → WASPADA (naik)
Sensor 3 (NH3):  phase = 1.60π  → AMAN
Sensor 4 (CH4):  phase = 2.00π  → AMAN
Sensor 5 (H2S):  phase = 0.40π  → AMAN
```

#### **Detik 30: Puncak - Sensor 1 mulai turun**
```
Sensor 1 (CO):   phase = 1.00π  → BAHAYA (puncak, mulai turun)
Sensor 2 (LPG):  phase = 1.40π  → WASPADA (naik)
Sensor 3 (NH3):  phase = 1.80π  → WASPADA (naik)
Sensor 4 (CH4):  phase = 0.20π  → AMAN
Sensor 5 (H2S):  phase = 0.60π  → WASPADA (naik)
```

#### **Detik 60: KEMBALI KE SEMUA AMAN**
```
Sensor 1 (CO):   phase = 2.00π (reset ke 0) → AMAN
Sensor 2 (LPG):  phase = 2.40π (reset ke 0.4π) → AMAN
Sensor 3 (NH3):  phase = 2.80π (reset ke 0.8π) → AMAN
Sensor 4 (CH4):  phase = 3.20π (reset ke 1.2π) → AMAN
Sensor 5 (H2S):  phase = 3.60π (reset ke 1.6π) → AMAN
```

**Kemudian siklus berulang!**

---

### **5. Sistem Alarm Audio**

```dart
void _checkAlarm() async {
  bool hasDanger = sensors.any((s) => s.status == GasStatus.danger);
  bool hasWarning = sensors.any((s) => s.status == GasStatus.warning);

  GasStatus targetStatus = hasDanger ? GasStatus.danger
                         : hasWarning ? GasStatus.warning
                         : GasStatus.normal;

  if (_currentAlarmStatus != targetStatus) {
    await _audioPlayer.stop();

    if (targetStatus == GasStatus.danger) {
      await _audioPlayer.play(AssetSource('bahaya.mp3'));
    } else if (targetStatus == GasStatus.warning) {
      await _audioPlayer.play(AssetSource('waspada.mp3'));
    }
  }
}
```

**Penjelasan:**
- **WORST CASE**: Jika ada 1 sensor BAHAYA, maka alarm BAHAYA
- **MEDIUM**: Jika ada 1 sensor WASPADA (tanpa BAHAYA), alarm WASPADA
- **SAFE**: Jika semua AMAN, alarm mati
- Alarm di-loop sampai status berubah

---

### **6. Keuntungan Sistem Ini**

✅ **Smooth Transition**: Tidak ada lompatan tiba-tiba, semua bertahap
✅ **Realistic**: Seperti sensor sungguhan dengan fluktuasi natural
✅ **Predictable**: Pola jelas, mudah dipahami
✅ **Synchronized**: Setiap 60 detik, semua kembali AMAN bersamaan
✅ **Staggered**: Sensor bergantian naik/turun setiap 12 detik
✅ **Scalable**: Mudah diubah periode atau jumlah sensor

---

## 📋 Information Page - Panduan Keamanan Gas

File: `lib/pages/information_page.dart`

### **1. Overview**

Information Page adalah halaman edukasi komprehensif yang memberikan informasi detail tentang 5 jenis gas berbahaya yang dimonitor oleh sistem. Halaman ini dirancang dengan **UI profesional** dan **konten edukatif** berdasarkan standar NIOSH (National Institute for Occupational Safety and Health).

---

### **2. Struktur Konten**

#### **A. Header Section**
```dart
Container(
  gradient: LinearGradient(colors: [teal, dark teal]),
  child: Text('Panduan Standar Keamanan Gas'),
)
```

**Konten:**
- Judul: "Panduan Standar Keamanan Gas"
- Deskripsi: Penjelasan tentang standar NIOSH
- Icon: Info outline (informasi)
- Design: Gradient teal dengan border radius

---

#### **B. Legend Section - Tingkat Bahaya**

**3 Tingkat:**

| Color | Label | Singkatan | Penjelasan |
|-------|-------|-----------|------------|
| 🟢 **Hijau** | **AMAN** | **TWA NIOSH** | Time Weighted Average - Paparan aman selama 8 jam kerja |
| 🟠 **Orange** | **WASPADA** | **Ceiling** | Batas maksimum yang tidak boleh dilampaui kapan pun |
| 🔴 **Merah** | **BAHAYA** | **IDLH** | Immediately Dangerous to Life or Health - Mengancam jiwa |

---

#### **C. Gas Information Cards**

Setiap gas memiliki card lengkap dengan informasi:

##### **1️⃣ CO (Carbon Monoxide) - Karbon Monoksida**

**Icon:** ⚠️ `Icons.warning_amber_rounded`
**Color:** 🔴 Red (#E53935)

**Informasi:**
- **Deskripsi**: Gas tidak berwarna, tidak berbau, sangat beracun dari pembakaran tidak sempurna
- **Kegunaan**: Asap kendaraan, pembakaran gas, sistem pemanas
- **Level AMAN (<34 ppm)**: Tidak ada gejala, tingkat aman 8 jam kerja
- **Level WASPADA (35-199 ppm)**: Sakit kepala ringan, pusing, mual, kelelahan, penurunan konsentrasi
- **Level BAHAYA (>200 ppm)**: Sakit kepala parah, kehilangan kesadaran, kerusakan organ permanen, **KEMATIAN dalam hitungan menit**

---

##### **2️⃣ LPG (Propane/Butane) - Liquefied Petroleum Gas**

**Icon:** 🔥 `Icons.local_fire_department`
**Color:** 🟠 Orange (#FF6F00)

**Informasi:**
- **Deskripsi**: Gas mudah terbakar, lebih berat dari udara, mengendap di area rendah
- **Kegunaan**: Kompor gas, pemanas, bahan bakar kendaraan
- **Level AMAN (<999 ppm)**: Tidak ada dampak kesehatan signifikan
- **Level WASPADA (1000-1599 ppm)**: Pusing, mual, sakit kepala, mengantuk, risiko ledakan meningkat
- **Level BAHAYA (>1600 ppm)**: Kehilangan kesadaran, asfiksia, kerusakan sistem saraf pusat, **risiko ledakan sangat tinggi**

---

##### **3️⃣ NH3 (Ammonia) - Amonia**

**Icon:** 🧪 `Icons.science_outlined`
**Color:** 🔵 Blue (#1E88E5)

**Informasi:**
- **Deskripsi**: Gas dengan bau menyengat kuat, bersifat korosif, merusak jaringan tubuh
- **Kegunaan**: Pupuk, pendingin industri, pembersih, peternakan
- **Level AMAN (<24 ppm)**: Bau terdeteksi tapi tidak berbahaya
- **Level WASPADA (25-49 ppm)**: Iritasi mata, hidung, tenggorokan, batuk, kesulitan bernapas
- **Level BAHAYA (>50 ppm)**: Luka bakar kimia, edema paru, kerusakan saluran pernapasan permanen, **kebutaan**

---

##### **4️⃣ CH4 (Methane) - Metana**

**Icon:** 💨 `Icons.air`
**Color:** 🟢 Green (#43A047)

**Informasi:**
- **Deskripsi**: Gas tidak berwarna, tidak berbau, sangat mudah terbakar, komponen gas alam
- **Kegunaan**: Pembangkit listrik, pemanas, bahan bakar, diproduksi oleh dekomposisi organik
- **Level AMAN (<1000 ppm)**: Tidak berbahaya, gas alam dalam penggunaan normal
- **Level WASPADA (1001-4999 ppm)**: Pusing, sakit kepala, mual, kelelahan, penurunan koordinasi
- **Level BAHAYA (>5000 ppm)**: Asfiksia (mati lemas), kehilangan kesadaran, kerusakan otak, **risiko ledakan sangat tinggi (5-15% volume udara)**

---

##### **5️⃣ H2S (Hydrogen Sulfide) - Hidrogen Sulfida**

**Icon:** ☠️ `Icons.dangerous`
**Color:** 🟣 Purple (#8E24AA)

**Informasi:**
- **Deskripsi**: Gas sangat beracun dengan bau telur busuk pada konsentrasi rendah. Pada konsentrasi tinggi, melumpuhkan indra penciuman
- **Kegunaan**: Industri minyak dan gas, tambang, pengolahan limbah, proses belerang
- **Level AMAN (<1 ppm)**: Bau terdeteksi (telur busuk) namun tidak berbahaya
- **Level WASPADA (2-9 ppm)**: Iritasi mata dan tenggorokan, batuk, kesulitan bernapas, mual
- **Level BAHAYA (>10 ppm)**: Kelumpuhan sistem pernapasan instan, kehilangan kesadaran, kerusakan sistem saraf, koma, **KEMATIAN dalam hitungan DETIK pada konsentrasi >500 ppm**

---

#### **D. Safety Tips Section**

**6 Tips Keselamatan:**

✅ Selalu gunakan detektor gas di area berisiko tinggi
✅ Pastikan ventilasi ruangan berfungsi dengan baik
✅ Gunakan APD (Alat Pelindung Diri) yang sesuai
✅ Jangan abaikan alarm gas - segera evakuasi
✅ Periksa peralatan gas secara berkala
✅ Latih prosedur darurat secara rutin

**Design:**
- Gradient blue (#1565C0 to #0D47A1)
- Icon: `Icons.health_and_safety`
- Checkmark bullets
- Rounded corners

---

#### **E. Emergency Contact Section**

**Kontak Darurat Indonesia:**

| Layanan | Nomor |
|---------|-------|
| 🚒 Pemadam Kebakaran | **113** |
| 🚑 Ambulans / Medis | **118 / 119** |
| 👮 Polisi | **110** |
| 🚁 SAR Nasional | **115** |

**Instruksi Darurat:**
> "Jika terpapar gas berbahaya: Segera pindah ke area terbuka, hubungi layanan darurat, dan cari bantuan medis"

**Design:**
- Background merah (#D32F2F)
- Icon: `Icons.emergency`
- Alert box dengan info icon

---

### **3. Design System**

#### **Color Coding:**
- **CO**: Red (#E53935) - Sangat berbahaya, tidak terdeteksi
- **LPG**: Orange (#FF6F00) - Mudah terbakar, risiko ledakan
- **NH3**: Blue (#1E88E5) - Korosif, merusak jaringan
- **CH4**: Green (#43A047) - Gas alam, asfiksia
- **H2S**: Purple (#8E24AA) - Super toksik, mematikan

#### **Typography:**
- **Header**: 20px Bold
- **Gas Name**: 18px Bold
- **Section Title**: 16px Bold
- **Description**: 14px Regular
- **Level Info**: 13-14px Medium

#### **Components:**
- **Level Cards**: Colored background (10% opacity) dengan border
- **Icons**: Material Icons, size 28-32
- **Shadows**: Text shadows untuk readability
- **Borders**: Rounded 8-16px
- **Spacing**: Konsisten dengan padding 12-16px

---

## 📊 Standar Keamanan Gas

### **Tabel Referensi Lengkap**

| Jenis Gas | AMAN (TWA NIOSH) | WASPADA (Ceiling) | BAHAYA (IDLH) | Karakteristik |
|-----------|------------------|-------------------|---------------|---------------|
| **CO** | <34 ppm | 35-199 ppm | >200 ppm | Tidak berbau, tidak berwarna |
| **LPG** | <999 ppm | 1000-1599 ppm | >1600 ppm | Lebih berat dari udara |
| **NH3** | <24 ppm | 25-49 ppm | >50 ppm | Bau menyengat (telur busuk) |
| **CH4** | <1000 ppm | 1001-4999 ppm | >5000 ppm | Tidak berbau, ringan |
| **H2S** | <1 ppm | 2-9 ppm | >10 ppm | Bau telur busuk, super toksik |

### **Catatan Penting:**
- **ppm** = parts per million (bagian per sejuta)
- **TWA** = Time Weighted Average (rata-rata tertimbang waktu untuk 8 jam)
- **NIOSH** = National Institute for Occupational Safety and Health
- **IDLH** = Immediately Dangerous to Life or Health

---

## 🎯 Cara Kerja Aplikasi

### **1. Login & Authentication**
1. User membuka aplikasi
2. Jika belum login → `LoginPage`
3. Jika sudah login → `MainPage`
4. Firebase Auth mengecek status authentication
5. FlutterToast menampilkan error/success message

### **2. Dashboard Monitoring**
1. `GasProvider` mulai simulasi (timer 2 detik)
2. Setiap sensor update phase berdasarkan sine wave
3. PPM dihitung dari mapping sine value
4. Status dievaluasi (AMAN/WASPADA/BAHAYA)
5. UI update otomatis via Provider
6. Alarm audio diputar jika ada bahaya

### **3. Navigation Flow**
```
MainPage (Scaffold)
├── AppDrawer (Sidebar)
│   ├── Dashboard
│   ├── Chart
│   ├── Sensor
│   ├── History
│   ├── Profile
│   └── Information ← Special
└── BottomNavigationBar
    ├── Dashboard (0)
    ├── Chart (1)
    ├── Sensor (2)
    ├── History (3)
    └── Profile (4)
```

### **4. Real-time Updates**
```
Timer (2 detik)
  ↓
Update Phase
  ↓
Calculate PPM from Sine
  ↓
Evaluate Status
  ↓
Update History
  ↓
Check Alarm
  ↓
notifyListeners()
  ↓
UI Re-render
```

---

## 🔧 Configuration

### **Firebase Setup**
1. Run: `flutterfire configure --project=monitoring-gas-424e5`
2. File generated: `lib/firebase_options.dart`
3. Platforms: Android, iOS, Web, Windows, macOS

### **Firestore Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### **Authentication Methods**
- ✅ Email/Password (enabled)
- ❌ Google Sign-In (disabled)
- ❌ Phone Auth (disabled)

---

## 📱 Fitur Aplikasi

### **✅ Implemented**
- [x] Login & Register dengan Firebase Auth
- [x] Real-time gas monitoring (5 sensors)
- [x] Sine wave simulation untuk smooth transition
- [x] Audio alarm (bahaya.mp3 & waspada.mp3)
- [x] Dashboard dengan status cards
- [x] Line charts untuk setiap gas
- [x] History events log
- [x] Sensor detail page dengan Google Maps
- [x] Profile management
- [x] Information page dengan panduan lengkap
- [x] Sidebar navigation
- [x] FlutterToast untuk error handling
- [x] Responsive design

### **🚀 Future Enhancements**
- [ ] Integrasi dengan hardware sensor sungguhan
- [ ] Push notifications untuk alarm
- [ ] Export data ke CSV/PDF
- [ ] Multi-location monitoring
- [ ] User roles (Admin, Operator, Viewer)
- [ ] Custom threshold per lokasi
- [ ] Data analytics & insights
- [ ] Offline mode dengan local storage

---

## 📞 Kontak Darurat

**Dalam Keadaan Darurat:**
- 🚒 Pemadam Kebakaran: **113**
- 🚑 Ambulans: **118 / 119**
- 👮 Polisi: **110**
- 🚁 SAR Nasional: **115**

**Prosedur:**
1. Evakuasi segera ke area terbuka
2. Hubungi layanan darurat
3. Berikan informasi jenis gas dan lokasi
4. Jangan kembali ke area sebelum dinyatakan aman

---

## 📝 Lisensi

Aplikasi ini dibuat untuk keperluan monitoring keamanan gas.
Standar berdasarkan NIOSH (National Institute for Occupational Safety and Health).


---

## 🔗 Referensi

1. **NIOSH Pocket Guide to Chemical Hazards**
   - https://www.cdc.gov/niosh/npg/

2. **OSHA Occupational Safety Standards**
   - https://www.osha.gov/

3. **Standar Keselamatan Kerja Indonesia**
   - Kemenaker RI

4. **Firebase Documentation**
   - https://firebase.google.com/docs

5. **Flutter Documentation**
   - https://flutter.dev/docs

---

**Version:** 1.0.0
**Last Updated:** December 2025
**Author:** Development Team

---

© 2025 GASKEUN - Gas Monitoring System
