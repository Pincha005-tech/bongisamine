import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../coree/theme/app_themes.dart';
import '../../coree/colors/app_colors.dart';

class DataAccessPage extends StatefulWidget {
  const DataAccessPage({super.key});

  @override
  State<DataAccessPage> createState() =>
      _DataAccessPageState();
}

class _DataAccessPageState
    extends State<DataAccessPage> {

  final String baseUrl =
      "http://10.0.2.2:8000";

  bool isLoading = true;

  List userLogs = [];

  @override
  void initState() {
    super.initState();

    loadLogs();
  }

  /// 📡 LOAD USER ACCESS LOGS
  Future<void> loadLogs() async {

    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/user/data-access",
        ),
      );

      if (response.statusCode == 200) {

        setState(() {

          userLogs =
              jsonDecode(response.body);

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });

        debugPrint(
          'Failed to load logs',
        );
      }

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Theme.of(context)
              .scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          "Accès aux données",
        ),
      ),

      body: isLoading

          /// ⏳ LOADING
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : userLogs.isEmpty

              /// 📭 EMPTY STATE
              ? const Center(
                  child: Text(
                    "Aucune activité trouvée",
                  ),
                )

              : Padding(

                  padding:
                      const EdgeInsets.all(16),

                  child: ListView.builder(

                    itemCount: userLogs.length,

                    itemBuilder:
                        (context, index) {

                      final log =
                          userLogs[index];

                      return Card(

                        margin:
                            const EdgeInsets.only(
                          bottom: 14,
                        ),

                        child: ListTile(

                          contentPadding:
                              const EdgeInsets.all(
                            12,
                          ),

                          leading: CircleAvatar(

                            backgroundColor:
                                AppColors.skyBlue
                                    .withOpacity(0.1),

                            child: const Icon(
                              Icons.history,
                              color:
                                  AppColors.skyBlue,
                            ),
                          ),

                          title: Text(

                            log['action'] ?? '',

                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle: Padding(

                            padding:
                                const EdgeInsets.only(
                              top: 5,
                            ),

                            child: Text(
                              log['date'] ?? '',
                            ),
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}