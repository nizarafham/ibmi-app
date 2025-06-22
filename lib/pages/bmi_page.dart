import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
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

  final Color activeContentColor = Colors.blue;
  final Color inactiveContentColor = Colors.grey;
  final TextStyle labelTextStyle = TextStyle(fontSize: 18.0, color: Colors.grey[600]);
  final TextStyle numberTextStyle = const TextStyle(fontSize: 50.0, fontWeight: FontWeight.w900, color: Colors.black87);

  Future<void> _calculateAndSaveBmi() async {
    // 1. Hitung BMI
    double heightInMeters = height / 100;
    double bmi = weight / pow(heightInMeters, 2);
    String bmiResult = bmi.toStringAsFixed(1);

    String status;
    if (bmi < 18.5) {
      status = 'Weight loss';
    } else if (bmi < 25) {
      status = 'Normal (ideal)';
    } else if (bmi < 30) {
      status = 'Overweight';
    } else {
      status = 'Overweight (Obesity)';
    }

    // 2. Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('bmiHistory') ?? [];

    final newEntry = jsonEncode({
      'date': DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
      'bmi': bmiResult,
      'status': status,
      'gender': selectedGender == Gender.male ? 'Male' : 'Female',
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
          builder: (context) => ResultPage(
            bmiResult: bmiResult,
            resultText: status,
            interpretation: 'The result of your IBMI calculation.',
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
        // HEIGHT SLIDER
        Expanded(
          child: InfoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Height', style: labelTextStyle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(height.toString(), style: numberTextStyle),
                    Text('cm', style: labelTextStyle),
                  ],
                ),
                Slider(
                  value: height.toDouble(),
                  min: 120.0,
                  max: 220.0,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue[100],
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
                child: _buildValueSelectorCard(
                  'Weight (kg)',
                  weight,
                  () => setState(() => weight--),
                  () => setState(() => weight++),
                ),
              ),
              Expanded(
                child: _buildValueSelectorCard(
                  'Age (yr)',
                  age,
                  () => setState(() => age--),
                  () => setState(() => age++),
                ),
              ),
            ],
          ),
        ),
        // GENDER TOGGLE
        Expanded(
          child: InfoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('GENDER', style: labelTextStyle),
                const SizedBox(height: 20),
                CupertinoSlidingSegmentedControl<Gender>(
                  groupValue: selectedGender,
                  thumbColor: Colors.blue,
                  backgroundColor: Colors.blue[100]!,
                  onValueChanged: (Gender? value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  children: const {
                    Gender.male: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Male', style: TextStyle(fontSize: 16)),
                    ),
                    Gender.female: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Female', style: TextStyle(fontSize: 16)),
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
        // CALCULATE BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (2 / 3),
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedGender != null) {
                    _calculateAndSaveBmi();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Silakan pilih gender terlebih dahulu.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                child: const Text('CALCULATE', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildValueSelectorCard(String label, int value, VoidCallback onDecrement, VoidCallback onIncrement) {
    return InfoCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: labelTextStyle),
          Text(value.toString(), style: numberTextStyle),
          const SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.grey[700],
                iconSize: 30.0,
                onPressed: onDecrement,
              ),
              const SizedBox(width: 10.0), 
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.blue, 
                iconSize: 30.0, 
                onPressed: onIncrement,
              ),
            ],
          )
        ],
      ),
    );
  }
}

