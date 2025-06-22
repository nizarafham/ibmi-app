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
     _loadHistory(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _clearHistory,
        icon: const Icon(Icons.delete_forever),
        label: const Text("Clear History"),
        backgroundColor: Colors.blue, 
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory, 
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? const Center(
                    child: Text('There is no calculation history yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return Card(
                        elevation: 5,
                        color: Colors.white,
                        shadowColor: Colors.blue.withOpacity(0.15),
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BMI: ${item['bmi']} - ${item['status']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['date']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item['gender']}, ${item['age']} y.o, ${item['weight']} kg, ${item['height']} cm',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                    },
                  ),
      ),
    );
  }
}