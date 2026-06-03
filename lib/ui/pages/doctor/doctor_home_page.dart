import 'package:flutter/material.dart';
import 'package:nutriginjal/services/auth_service.dart';
import 'package:nutriginjal/services/profile_service.dart';
import 'package:nutriginjal/services/lab_service.dart';
import 'package:nutriginjal/data/models/profile_model.dart';
import 'package:nutriginjal/data/models/lab_model.dart';
import 'package:nutriginjal/ui/pages/doctor/prediction_screen.dart';
import 'package:nutriginjal/ui/pages/doctor/doctor_history_page.dart';
import 'package:nutriginjal/ui/pages/doctor/patient_selection_page.dart';
import 'package:nutriginjal/ui/pages/doctor/lab_detail_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final LabService _labService = LabService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Profile?>(
              future: _profileService.getMyProfile(),
              builder: (context, snapshot) {
                final name = snapshot.data?.fullName ?? "Dokter";
                return Text(
                  "Selamat datang, Dr. $name 👨‍⚕️",
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                );
              },
            ),
            Text(
              _getFormattedDate(),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.green, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<LabResult>>(
        future: _labService.getDoctorLabHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text("Terjadi kesalahan: ${snapshot.error}"),
                  TextButton(onPressed: () => setState(() {}), child: const Text("Coba Lagi")),
                ],
              ),
            );
          }

          final history = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          // Calculate basic stats
          final totalLab = history.length;
          final uniquePatients = history.map((e) => e.patientId).toSet().length;
          final today = DateTime.now();
          final labToday = history.where((e) => 
            e.createdAt.day == today.day && 
            e.createdAt.month == today.month && 
            e.createdAt.year == today.year
          ).length;

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _buildStatCard("Total Pasien", uniquePatients.toString(), Icons.people, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard("Lab Hari Ini", labToday.toString(), Icons.science, Colors.teal),
                      const SizedBox(width: 12),
                      _buildStatCard("Total History", totalLab.toString(), Icons.history, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text("Aksi Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Quick Action Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildActionCard("Input Hasil Lab", Icons.add_chart, const Color(0xFF2563EB), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientSelectionPage()));
                      }),
                      _buildActionCard("Profil Saya", Icons.person, const Color(0xFF0EA5E9), () {
                        Navigator.pushNamed(context, '/profile');
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (history.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("Belum ada riwayat input lab", style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Riwayat Input Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const DoctorHistoryPage())
                            );
                            // Refresh data dashboard setelah kembali dari halaman riwayat
                            if (mounted) setState(() {});
                          },
                          child: const Text("Lihat Semua")
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length > 5 ? 5 : history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final dateStr = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
                        final status = item.predictionResult?['label'] ?? "N/A";
                        
                        return _buildLabResultItem(
                          item.patientName ?? item.patientId ?? "Anonim",
                          dateStr, 
                          status,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LabDetailPage(result: item)),
                            );
                            if (result == true) {
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 40),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await _authService.signOut();
                        if (mounted) Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
    final months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return "${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}";
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLabResultItem(String name, String date, String result, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(result, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
