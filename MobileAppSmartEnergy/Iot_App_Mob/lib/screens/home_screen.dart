import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  late Timer _timer;
  bool _isLoading = true;
  String? _errorMessage;

  double _voltageLimit = 1.0; // Limite par défaut

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _apiService.fetchData();
      setState(() {
        if (_data == null) {
          _data = {};
        }
        if (_data!.containsKey("entries")) {
          (_data!["entries"] as List).add(data);
        } else {
          _data!["entries"] = [data];
        }
        _isLoading = false;
        _errorMessage = null;
      });

      // Vérifiez si une alerte doit être affichée
      final voltage = double.tryParse(data['voltage'].toString()) ?? 0.0;
      if (_isVoltageHigh(voltage)) {
        _showVoltageAlert(voltage); // Déclenche l'alerte
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData();
    });
  }

  bool _isVoltageHigh(dynamic voltage) {
    try {
      final value = double.tryParse(voltage.toString()) ?? 0.0;
      return value > _voltageLimit;
    } catch (e) {
      return false;
    }
  }

  void _showVoltageAlert(dynamic voltage) {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Force l'utilisateur à attendre
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context); // Fermer après 3 secondes
        });
        return Container(
          color: Colors.red[400],
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Alerte : Voltage élevé",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Voltage détecté : $voltage V, supérieur à la limite $_voltageLimit V.",
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSettingsDialog() {
    TextEditingController voltageController =
    TextEditingController(text: _voltageLimit.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Paramètres"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Définir la limite de voltage :"),
            const SizedBox(height: 10),
            TextField(
              controller: voltageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Voltage limite (V)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _voltageLimit =
                    double.tryParse(voltageController.text) ?? _voltageLimit;
              });
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Données Firebase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsDialog,
            tooltip: "Paramètres",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Text(
          'Erreur : $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      )
          : _data == null
          ? const Center(child: Text('Aucune donnée disponible.'))
          : _buildDataList(),
    );
  }

  Widget _buildDataList() {
    final entries = _data?["entries"] as List<dynamic>? ?? [];

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final voltage = entry['voltage'] ?? "N/A";
        final current = entry['current'] ?? "N/A";
        final kWh = entry['kWh'] ?? "N/A";
        final temps = entry['temps'] ?? "N/A";

        return Card(
          margin: const EdgeInsets.all(16.0),
          color: _isVoltageHigh(voltage) ? Colors.red[100] : Colors.white,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: _isVoltageHigh(voltage)
                      ? const Icon(Icons.warning, color: Colors.red)
                      : const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    'Voltage: $voltage',
                    style: TextStyle(
                      color: _isVoltageHigh(voltage) ? Colors.red : Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current: $current'),
                      Text('kWh: $kWh'),
                      Text('Temps: $temps'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

