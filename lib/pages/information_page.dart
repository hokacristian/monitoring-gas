import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF00796B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informasi Gas Berbahaya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00796B), Color(0xFF004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Panduan Standar Keamanan Gas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Informasi penting tentang tingkat bahaya gas dan dampaknya bagi kesehatan manusia berdasarkan standar NIOSH (National Institute for Occupational Safety and Health)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Legend
            _buildLegend(),
            SizedBox(height: 24),

            // Gas Information Cards
            _buildGasCard(
              name: 'CO (Carbon Monoxide)',
              fullName: 'Karbon Monoksida',
              description: 'Gas tidak berwarna, tidak berbau, dan sangat beracun yang dihasilkan dari pembakaran tidak sempurna bahan bakar.',
              usage: 'Sering ditemukan pada asap kendaraan, pembakaran gas, dan sistem pemanas yang tidak berfungsi dengan baik.',
              safeLevel: '<34 ppm',
              warningLevel: '35-199 ppm',
              dangerLevel: '>200 ppm',
              safeEffect: 'Tidak ada gejala yang terlihat. Tingkat aman untuk paparan jangka panjang (8 jam kerja).',
              warningEffect: 'Sakit kepala ringan, pusing, mual, kelelahan, dan penurunan konsentrasi. Paparan berkepanjangan dapat menyebabkan kerusakan organ.',
              dangerEffect: 'Sakit kepala parah, kebingungan, kehilangan kesadaran, kerusakan jantung dan otak permanen, hingga kematian dalam hitungan menit.',
              icon: Icons.warning_amber_rounded,
              color: Color(0xFFE53935),
            ),

            _buildGasCard(
              name: 'LPG (Propane/Butane)',
              fullName: 'Liquefied Petroleum Gas',
              description: 'Gas mudah terbakar yang digunakan sebagai bahan bakar. Lebih berat dari udara sehingga mengendap di area rendah.',
              usage: 'Digunakan untuk kompor gas, pemanas, dan bahan bakar kendaraan.',
              safeLevel: '<999 ppm',
              warningLevel: '1000-1599 ppm',
              dangerLevel: '>1600 ppm',
              safeEffect: 'Tidak ada dampak kesehatan yang signifikan. Tingkat konsentrasi normal dan aman.',
              warningEffect: 'Pusing, mual, sakit kepala, mengantuk, dan kesulitan bernapas. Risiko ledakan meningkat karena konsentrasi mendekati batas mudah terbakar.',
              dangerEffect: 'Kehilangan kesadaran, asfiksia (kekurangan oksigen), kerusakan sistem saraf pusat, dan risiko ledakan sangat tinggi. Dapat menyebabkan kematian.',
              icon: Icons.local_fire_department,
              color: Color(0xFFFF6F00),
            ),

            _buildGasCard(
              name: 'NH3 (Ammonia)',
              fullName: 'Amonia',
              description: 'Gas dengan bau menyengat yang sangat kuat. Bersifat korosif dan dapat merusak jaringan tubuh.',
              usage: 'Digunakan dalam pupuk, pendingin industri, dan pembersih. Sering ditemukan di peternakan dan fasilitas industri.',
              safeLevel: '<24 ppm',
              warningLevel: '25-49 ppm',
              dangerLevel: '>50 ppm',
              safeEffect: 'Bau terdeteksi tapi tidak berbahaya. Tingkat aman untuk paparan kerja.',
              warningEffect: 'Iritasi mata, hidung, dan tenggorokan. Batuk, kesulitan bernapas, sakit dada, dan mual. Paparan lama dapat merusak paru-paru.',
              dangerEffect: 'Luka bakar kimia pada mata dan kulit, edema paru (pembengkakan paru), kerusakan saluran pernapasan permanen, kebutaan, dan kematian.',
              icon: Icons.science_outlined,
              color: Color(0xFF1E88E5),
            ),

            _buildGasCard(
              name: 'CH4 (Methane)',
              fullName: 'Metana',
              description: 'Gas tidak berwarna dan tidak berbau yang sangat mudah terbakar. Komponen utama gas alam.',
              usage: 'Sumber energi utama untuk pembangkit listrik, pemanas, dan bahan bakar. Juga diproduksi oleh dekomposisi bahan organik.',
              safeLevel: '<1000 ppm',
              warningLevel: '1001-4999 ppm',
              dangerLevel: '>5000 ppm',
              safeEffect: 'Tidak berbahaya dalam konsentrasi rendah. Gas alam dalam penggunaan normal.',
              warningEffect: 'Pusing, sakit kepala, mual, kelelahan, dan penurunan koordinasi. Menggantikan oksigen di udara menyebabkan kesulitan bernapas.',
              dangerEffect: 'Asfiksia (mati lemas), kehilangan kesadaran, kerusakan otak akibat kekurangan oksigen, dan risiko ledakan sangat tinggi (5-15% volume udara).',
              icon: Icons.air,
              color: Color(0xFF43A047),
            ),

            _buildGasCard(
              name: 'H2S (Hydrogen Sulfide)',
              fullName: 'Hidrogen Sulfida',
              description: 'Gas sangat beracun dengan bau telur busuk pada konsentrasi rendah. Pada konsentrasi tinggi, melumpuhkan indra penciuman.',
              usage: 'Ditemukan di industri minyak dan gas, tambang, pengolahan limbah, dan proses industri yang melibatkan belerang.',
              safeLevel: '<1 ppm',
              warningLevel: '2-9 ppm',
              dangerLevel: '>10 ppm',
              safeEffect: 'Bau terdeteksi (telur busuk) namun tidak berbahaya. Tingkat aman untuk paparan singkat.',
              warningEffect: 'Iritasi mata dan tenggorokan, batuk, kesulitan bernapas, mual, dan sakit kepala. Paparan 50-100 ppm dapat merusak mata.',
              dangerEffect: 'Kelumpuhan sistem pernapasan instan, kehilangan kesadaran, kerusakan sistem saraf, koma, dan kematian dalam hitungan detik pada konsentrasi >500 ppm.',
              icon: Icons.dangerous,
              color: Color(0xFF8E24AA),
            ),

            SizedBox(height: 24),

            // Safety Tips
            _buildSafetyTips(),

            SizedBox(height: 24),

            // Emergency Contact
            _buildEmergencyContact(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tingkat Bahaya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildLegendItem(Colors.green, 'AMAN (TWA NIOSH)', 'Time Weighted Average - Paparan aman selama 8 jam kerja'),
          SizedBox(height: 8),
          _buildLegendItem(Colors.orange, 'WASPADA (Ceiling)', 'Batas maksimum yang tidak boleh dilampaui kapan pun'),
          SizedBox(height: 8),
          _buildLegendItem(Colors.red, 'BAHAYA (IDLH)', 'Immediately Dangerous to Life or Health - Mengancam jiwa'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGasCard({
    required String name,
    required String fullName,
    required String description,
    required String usage,
    required String safeLevel,
    required String warningLevel,
    required String dangerLevel,
    required String safeEffect,
    required String warningEffect,
    required String dangerEffect,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        fullName,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                _buildSection('Deskripsi', description),
                SizedBox(height: 12),
                _buildSection('Penggunaan', usage),
                SizedBox(height: 16),

                // Levels
                Text(
                  'Tingkat Bahaya & Dampak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                _buildLevelCard(
                  'AMAN',
                  safeLevel,
                  safeEffect,
                  Colors.green,
                  Icons.check_circle,
                ),
                SizedBox(height: 10),
                _buildLevelCard(
                  'WASPADA',
                  warningLevel,
                  warningEffect,
                  Colors.orange,
                  Icons.warning,
                ),
                SizedBox(height: 10),
                _buildLevelCard(
                  'BAHAYA',
                  dangerLevel,
                  dangerEffect,
                  Colors.red,
                  Icons.dangerous,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF00BFA5),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(String level, String range, String effect, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      level,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      range,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  effect,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Tips Keselamatan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildTipItem('Selalu gunakan detektor gas di area berisiko tinggi'),
          _buildTipItem('Pastikan ventilasi ruangan berfungsi dengan baik'),
          _buildTipItem('Gunakan APD (Alat Pelindung Diri) yang sesuai'),
          _buildTipItem('Jangan abaikan alarm gas - segera evakuasi'),
          _buildTipItem('Periksa peralatan gas secara berkala'),
          _buildTipItem('Latih prosedur darurat secara rutin'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Kontak Darurat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildEmergencyItem('Pemadam Kebakaran', '113'),
          _buildEmergencyItem('Ambulans / Medis', '118 / 119'),
          _buildEmergencyItem('Polisi', '110'),
          _buildEmergencyItem('SAR Nasional', '115'),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Jika terpapar gas berbahaya: Segera pindah ke area terbuka, hubungi layanan darurat, dan cari bantuan medis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(String service, String number) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
