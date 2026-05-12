import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../coree/theme/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.brightness_6),
      label: const Text("Changer thème"),
      onPressed: () {
        AppThemeController.toggleTheme();
      },
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  List<FlSpot> productionData = [];

  int travailleurs = 0;
  int alertes = 0;

  int present = 0;
  int absent = 0;
  int off = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  /// 🔗 API CALL
  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse("http://TON_BACKEND/api/dashboard"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          /// 📊 production (liste venant du backend)
          productionData = (data["production"] as List)
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
              .toList();

          travailleurs = data["travailleurs"];
          alertes = data["alertes"];

          present = data["present"];
          absent = data["absent"];
          off = data["off"];

          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur API: $e");
    }
  }

  /// 🔄 refresh manuel
  Future<void> refresh() async {
    await fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("BONGISA MINE RDC"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// STATS
              Row(
                children: [
                  Expanded(child: _statCard("Production",
                      "${productionData.last.y}T", Icons.factory)),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard("Travailleurs",
                      "$travailleurs", Icons.people)),
                ],
              ),

              const SizedBox(height: 10),

              _statCard("Alertes sécurité", "$alertes", Icons.warning),

              const SizedBox(height: 20),

              /// GRAPH
              _chartCard(
                child: SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: productionData,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// PIE
              _chartCard(
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: present.toDouble(),
                          title: "Présents",
                        ),
                        PieChartSectionData(
                          value: off.toDouble(),
                          title: "Repos",
                        ),
                        PieChartSectionData(
                          value: absent.toDouble(),
                          title: "Absents",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _chartCard({required Widget child}) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(10),
      child: child,
    ));
  }
}