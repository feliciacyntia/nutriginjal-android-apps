import 'package:flutter/material.dart';
import 'package:nutriginjal/services/lab_service.dart';
import 'package:nutriginjal/data/models/lab_model.dart';
import 'package:nutriginjal/ui/pages/doctor/lab_detail_page.dart';

class DoctorHistoryPage extends StatefulWidget {
  const DoctorHistoryPage({super.key});

  @override
  State<DoctorHistoryPage> createState() => _DoctorHistoryPageState();
}

class _DoctorHistoryPageState extends State<DoctorHistoryPage> {
  final LabService labService = LabService();
  List<LabResult>? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await labService.getDoctorLabHistory();
      if (mounted) {
        setState(() {
          _history = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Semua Riwayat Lab", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : (_history == null || _history!.isEmpty)
            ? const Center(child: Text("Belum ada riwayat input lab", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _history!.length,
              itemBuilder: (context, index) {
                final item = _history![index];
                final dateStr = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year} ${item.createdAt.hour}:${item.createdAt.minute}";
                final status = item.predictionResult?['label'] ?? "N/A";
                
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Hapus Riwayat?"),
                        content: const Text("Data ini akan dihapus permanen."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text("Hapus"),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    final deletedId = item.id;
                    final originalHistory = List<LabResult>.from(_history!);
                    
                    setState(() {
                      _history!.removeAt(index);
                    });
                    
                    try {
                      await labService.deleteLabResult(deletedId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Riwayat berhasil dihapus"), duration: Duration(seconds: 2)),
                        );
                      }
                    } catch (e) {
                      // Jika gagal (misal: masalah RLS), kembalikan data ke list
                      if (mounted) {
                        setState(() {
                          _history = originalHistory;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: _buildLabResultItem(
                    item.patientName ?? item.patientId ?? "Anonim", 
                    dateStr, 
                    status,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LabDetailPage(result: item)),
                      );
                      if (result == true) {
                        _loadHistory();
                      }
                    },
                  ),
                );
              },
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
