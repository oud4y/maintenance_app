import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maintenance_app/screens/ProfileScreen.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late StreamSubscription<DatabaseEvent> _dataSubscription;
  late StreamSubscription<DatabaseEvent> _statusSubscription;
  late StreamSubscription<DatabaseEvent> _messageSubscription;
  double temperature = 0.0;
  double vibration = 0.0;
  String motorStatus = 'Unknown';
  String predictionMessage = 'No data';
  List<FlSpot> temperatureSpots = [];
  List<FlSpot> vibrationSpots = [];
  final int maxDataPoints = 30;
  String errorMessage = '';
  bool isLoading = true;
  Timer? _simulationTimer;
  bool _useSimulation = false; // Set to true to enable simulation

  @override
  void initState() {
    super.initState();
    // Initialize chart with dummy data
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    temperatureSpots.add(FlSpot(now - 20000, 20.0));
    temperatureSpots.add(FlSpot(now - 10000, 25.0));
    temperatureSpots.add(FlSpot(now, 22.0));
    vibrationSpots.add(FlSpot(now - 20000, 1.0));
    vibrationSpots.add(FlSpot(now - 10000, 1.5));
    vibrationSpots.add(FlSpot(now, 1.2));
    _initializeFirebaseListeners();
    if (_useSimulation) {
      _simulateSinusoidalData();
    }
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    _statusSubscription.cancel();
    _messageSubscription.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _initializeFirebaseListeners() {
    try {
      final database = FirebaseDatabase.instance;
      final dataRef = database.ref('sensors/data');
      final statusRef = database.ref('prediction/status');
      final messageRef = database.ref('prediction/message');

      _dataSubscription = dataRef.onValue.listen((event) {
        if (mounted) {
          final snapshot = event.snapshot;
          print('Data snapshot: ${snapshot.value}');
          if (snapshot.value != null) {
            try {
              // Cast snapshot to Map
              final data = Map<String, dynamic>.from(snapshot.value as Map);
              // Sort by key (millis) to get latest entry
              final latestKey = data.keys.reduce((a, b) {
                final aVal = int.tryParse(a) ?? 0;
                final bVal = int.tryParse(b) ?? 0;
                return aVal > bVal ? a : b;
              });
              final latestData = Map<String, dynamic>.from(data[latestKey]);
              final newTemp = double.tryParse(latestData['temperature']?.toString() ?? '0.0') ?? 0.0;
              final newVib = double.tryParse(latestData['vibration']?.toString() ?? '0.0') ?? 0.0;
              setState(() {
                temperature = newTemp;
                vibration = newVib;
                _updateChartData(temperature: newTemp, vibration: newVib);
                isLoading = false;
                errorMessage = '';
              });
            } catch (e) {
              print('Data parsing error: $e');
              setState(() {
                errorMessage = 'Error parsing sensor data: $e';
                isLoading = false;
              });
            }
          } else {
            setState(() {
              errorMessage = 'No sensor data found';
              isLoading = false;
            });
          }
        }
      }, onError: (error) {
        print('Data error: $error');
        setState(() {
          errorMessage = 'Failed to load sensor data: $error';
          isLoading = false;
        });
      });

      _statusSubscription = statusRef.onValue.listen((event) {
        if (mounted) {
          final status = event.snapshot.value?.toString() ?? 'Unknown';
          print('Status snapshot: $status');
          setState(() {
            motorStatus = status;
            isLoading = false;
            errorMessage = '';
          });
        }
      }, onError: (error) {
        print('Status error: $error');
        setState(() {
          errorMessage = 'Failed to load status: $error';
          isLoading = false;
        });
      });

      _messageSubscription = messageRef.onValue.listen((event) {
        if (mounted) {
          final message = event.snapshot.value?.toString() ?? 'No data';
          print('Message snapshot: $message');
          setState(() {
            predictionMessage = message;
            isLoading = false;
            errorMessage = '';
          });
        }
      }, onError: (error) {
        print('Message error: $error');
        setState(() {
          errorMessage = 'Failed to load message: $error';
          isLoading = false;
        });
      });
    } catch (e) {
      print('Initialization error: $e');
      setState(() {
        errorMessage = 'Initialization error: $e';
        isLoading = false;
      });
    }
  }

  void _simulateSinusoidalData() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final now = DateTime.now();
        double t = now.second.toDouble();
        setState(() {
          temperature = 25 + 5 * sin(t * pi / 30);
          vibration = 2 + 1 * cos(t * pi / 30);
          _updateChartData(temperature: temperature, vibration: vibration);
        });
      }
    });
  }

  void _updateChartData({double? temperature, double? vibration}) {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    setState(() {
      if (temperature != null) {
        temperatureSpots.add(FlSpot(now, temperature));
        if (temperatureSpots.length > maxDataPoints) {
          temperatureSpots.removeAt(0);
        }
      }
      if (vibration != null) {
        vibrationSpots.add(FlSpot(now, vibration));
        if (vibrationSpots.length > maxDataPoints) {
          vibrationSpots.removeAt(0);
        }
      }
      print('Chart updated: Temp spots: ${temperatureSpots.length}, Vib spots: ${vibrationSpots.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        leading: null,
        actions: [
          IconButton(
            onPressed: () => nextScreen(context, const ProfilePage()),
            icon: const Icon(Icons.account_circle, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  Expanded(
                    child: _buildDataCard(
                      'Temperature',
                      '${temperature.toStringAsFixed(2)} °C',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDataCard(
                      'Vibration',
                      '${vibration.toStringAsFixed(2)} m/s²',
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: _buildDataCard(
                'Motor Status',
                '$motorStatus\n$predictionMessage',
                _getStatusColor(motorStatus),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Text(
                        'Real-Time Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final time = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                    return Text(
                                      '${time.hour}:${time.minute}:${time.second}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                  interval: 10000,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: temperatureSpots,
                                isCurved: true,
                                color: Colors.blue,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              ),
                              LineChartBarData(
                                spots: vibrationSpots,
                                isCurved: true,
                                color: Colors.red,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      '${spot.y.toStringAsFixed(1)} ${spot.barIndex == 0 ? "°C" : "m/s²"}',
                                      TextStyle(
                                        color: spot.barIndex == 0 ? Colors.blue : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            minY: 0,
                            maxY: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend('Temperature', Colors.blue),
                          const SizedBox(width: 20),
                          _buildLegend('Vibration', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: title == 'Motor Status' ? 16 : 20, color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}