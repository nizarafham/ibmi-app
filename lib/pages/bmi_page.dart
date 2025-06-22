import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';

import 'package:ibmi_app/widgets/info_card.dart';
import 'package:ibmi_app/pages/result_page.dart';

enum Gender { male, female }

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  Gender? selectedGender;
  int height = 160;
  int weight = 60;
  int age = 25;

  // Warna Kartu
  final Color activeCardColor = const Color(0xFF1D1E33);
  final Color inactiveCardColor = const Color(0xFF111328);

  Future<void> _calculateAndSaveBmi() async {
    // 1. Hitung BMI
    double heightInMeters = height / 100;
    double bmi = weight / pow(heightInMeters, 2);
    String bmiResult = bmi.toStringAsFixed(1);

    String status;
    if (bmi < 18.5) {
      status = 'Kekurangan berat badan';
    } else if (bmi < 25) {
      status = 'Normal (ideal)';
    } else if (bmi < 30) {
      status = 'Kelebihan berat badan';
    } else {
      status = 'Kegemukan (Obesitas)';
    }

    // 2. Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('bmiHistory') ?? [];

    final newEntry = jsonEncode({
      'date': DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
      'bmi': bmiResult,
      'status': status,
      'gender': selectedGender == Gender.male ? 'Pria' : 'Wanita',
      'age': age.toString(),
      'weight': weight.toString(),
      'height': height.toString(),
    });

    history.add(newEntry);
    await prefs.setStringList('bmiHistory', history);

    // 3. Navigasi ke Halaman Hasil
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ResultPage(
                bmiResult: bmiResult,
                resultText: status,
                interpretation: 'Hasil perhitungan IBMI Anda.',
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // GENDER CARDS
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: InfoCard(
                  onTap: () => setState(() => selectedGender = Gender.male),
                  color:
                      selectedGender == Gender.male
                          ? activeCardColor
                          : inactiveCardColor,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.male, size: 80.0), Text('PRIA')],
                  ),
                ),
              ),
              Expanded(
                child: InfoCard(
                  onTap: () => setState(() => selectedGender = Gender.female),
                  color:
                      selectedGender == Gender.female
                          ? activeCardColor
                          : inactiveCardColor,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.female, size: 80.0), Text('WANITA')],
                  ),
                ),
              ),
            ],
          ),
        ),
        // HEIGHT SLIDER
        Expanded(
          child: InfoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TINGGI BADAN',
                  style: TextStyle(fontSize: 18.0, color: Color(0xFF8D8E98)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      height.toString(),
                      style: const TextStyle(
                        fontSize: 50.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'cm',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF8D8E98),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: height.toDouble(),
                  min: 120.0,
                  max: 220.0,
                  activeColor: Colors.pink,
                  inactiveColor: const Color(0xFF8D8E98),
                  onChanged: (double newValue) {
                    setState(() => height = newValue.round());
                  },
                ),
              ],
            ),
          ),
        ),
        // WEIGHT & AGE CARDS
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: InfoCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'BERAT BADAN',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF8D8E98),
                        ),
                      ),
                      Text(
                        weight.toString(),
                        style: const TextStyle(
                          fontSize: 50.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            onPressed: () => setState(() => weight--),
                            backgroundColor: const Color(0xFF4C4F5E),
                            mini: true,
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          FloatingActionButton(
                            onPressed: () => setState(() => weight++),
                            backgroundColor: const Color(0xFF4C4F5E),
                            mini: true,
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InfoCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'UMUR',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF8D8E98),
                        ),
                      ),
                      Text(
                        age.toString(),
                        style: const TextStyle(
                          fontSize: 50.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            onPressed: () => setState(() => age--),
                            backgroundColor: const Color(0xFF4C4F5E),
                            mini: true,
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          FloatingActionButton(
                            onPressed: () => setState(() => age++),
                            backgroundColor: const Color(0xFF4C4F5E),
                            mini: true,
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // CALCULATE BUTTON
        GestureDetector(
          onTap: () {
            if (selectedGender != null) {
              _calculateAndSaveBmi();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Silakan pilih gender terlebih dahulu.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Container(
            color: Colors.pink,
            margin: const EdgeInsets.only(top: 10.0),
            width: double.infinity,
            height: 60.0,
            child: const Center(
              child: Text(
                'CALCULATE',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
