import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:maintenance_app/screens/ProfileScreen.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late StreamSubscription<DatabaseEvent> _temperatureSubscription;
  late StreamSubscription<DatabaseEvent> _vibrationSubscription;
  double temperature = 0.0;
  double vibration = 0.0;
  List<charts.Series<TimeSeriesData, DateTime>> _seriesList = [];

  @override
  void initState() {
    super.initState();
    _seriesList = _createSampleData();
    _initializeFirebaseListener();
  }

  @override
  void dispose() {
    _temperatureSubscription.cancel();
    _vibrationSubscription.cancel();
    super.dispose();
  }

  void _initializeFirebaseListener() {
    final DatabaseReference _tempref = FirebaseDatabase.instance.ref('temperature');
    final DatabaseReference _vibref = FirebaseDatabase.instance.ref('vibration');

    _temperatureSubscription = _tempref.onValue.listen((event) {
      if (mounted) {
        final newTemp = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
        setState(() {
          temperature = newTemp;
          _updateChartData();
        });
      }
    }, onError: (error) {
      print("Erreur température: $error");
    });

    _vibrationSubscription = _vibref.onValue.listen((event) {
      if (mounted) {
        final newVib = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
        setState(() {
          vibration = newVib;
          _updateChartData();
        });
      }
    }, onError: (error) {
      print("Erreur vibration: $error");
    });
  }

  void _updateChartData() {
    final now = DateTime.now();
    final newTempData = TimeSeriesData(now, temperature);
    final newVibData = TimeSeriesData(now, vibration);

    setState(() {
      _seriesList[0].data.add(newTempData);
      _seriesList[1].data.add(newVibData);

      // Garder seulement les 20 derniers points
      if (_seriesList[0].data.length > 20) {
        _seriesList[0].data.removeAt(0);
        _seriesList[1].data.removeAt(0);
      }

      // Forcer le rafraîchissement des séries
      _seriesList = List.from(_seriesList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => nextScreen(context, ProfilePage()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cartes de données
            Row(
              children: [
                _buildDataCard('Température', '${temperature.toStringAsFixed(1)}°C', Colors.blue),
                SizedBox(width: 10),
                _buildDataCard('Vibration', '${vibration.toStringAsFixed(1)} m/s²', Colors.red),
              ],
            ),
            SizedBox(height: 20),

            // Graphique
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Données en temps réel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Expanded(
                        child: charts.TimeSeriesChart(
                          _seriesList,
                          animate: true,
                          behaviors: [
                            charts.SeriesLegend(
                              position: charts.BehaviorPosition.bottom,
                              desiredMaxRows: 1,
                            ),
                            charts.LinePointHighlighter(
                              showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.all,
                              showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.all,
                            ),
                          ],
                          domainAxis: charts.DateTimeAxisSpec(
                            renderSpec: charts.SmallTickRendererSpec(
                              labelStyle: charts.TextStyleSpec(
                                fontSize: 10,
                                color: charts.MaterialPalette.black,
                              ),
                            ),
                          ),
                          primaryMeasureAxis: charts.NumericAxisSpec(
                            renderSpec: charts.GridlineRendererSpec(
                              labelStyle: charts.TextStyleSpec(
                                fontSize: 10,
                                color: charts.MaterialPalette.black,
                              ),
                            ),
                          ),
                        ),
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
    return Expanded(
      child: Card(
        elevation: 4,
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  List<charts.Series<TimeSeriesData, DateTime>> _createSampleData() {
    return [
      charts.Series<TimeSeriesData, DateTime>(
        id: 'Température',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesData data, _) => data.time,
        measureFn: (TimeSeriesData data, _) => data.value,
        data: [],
        displayName: 'Température',
      ),
      charts.Series<TimeSeriesData, DateTime>(
        id: 'Vibration',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesData data, _) => data.time,
        measureFn: (TimeSeriesData data, _) => data.value,
        data: [],
        displayName: 'Vibration',
      ),
    ];
  }
}

class TimeSeriesData {
  final DateTime time;
  final double value;

  TimeSeriesData(this.time, this.value);

  @override
  String toString() => 'Time: $time, Value: $value';
}