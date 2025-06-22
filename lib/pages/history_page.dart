import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final historyStringList = prefs.getStringList('bmiHistory') ?? [];
    
    // Reverse list agar data terbaru di atas
    final loadedHistory = historyStringList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList().reversed.toList();
        
    setState(() {
      _history = loadedHistory;
      _isLoading = false;
    });
  }
  
  Future<void> _clearHistory() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('bmiHistory');
     _loadHistory(); // Reload untuk menampilkan list kosong
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _clearHistory,
        icon: const Icon(Icons.delete_forever),
        label: const Text("Clear History"),
        backgroundColor: Colors.pink,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat perhitungan.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      color: const Color(0xFF1D1E33),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          'BMI: ${item['bmi']} - ${item['status']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          '${item['date']}\n${item['gender']}, ${item['age']} thn, ${item['weight']} kg, ${item['height']} cm',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}