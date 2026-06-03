import 'package:flutter/material.dart';
import 'package:nutriginjal/services/profile_service.dart';
import 'package:nutriginjal/data/models/profile_model.dart';
import 'package:nutriginjal/ui/pages/doctor/prediction_screen.dart';

class PatientSelectionPage extends StatefulWidget {
  const PatientSelectionPage({super.key});

  @override
  State<PatientSelectionPage> createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  final ProfileService _profileService = ProfileService();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Pilih Pasien", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari nama pasien...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Profile>>(
              future: _profileService.getAllProfiles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Gagal memuat data: ${snapshot.error}"),
                  );
                }

                final patients = (snapshot.data ?? [])
                    .where((p) => p.role == 'user')
                    .where((p) => 
                      p.fullName.toLowerCase().contains(_searchQuery) || 
                      p.email.toLowerCase().contains(_searchQuery)
                    )
                    .toList();

                if (patients.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada pasien ditemukan", style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Text(patient.fullName[0], style: const TextStyle(color: Colors.blue)),
                        ),
                        title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(patient.email),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PredictionScreen(patientId: patient.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
