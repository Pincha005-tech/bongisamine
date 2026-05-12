import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../coree/theme/app_themes.dart';
import '../coree/theme/theme_notifier.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final String baseUrl = "http://10.0.2.2:8000";

  List logs = [];

  bool isLoading = true;
  bool isLoadingMore = false;

  int page = 1;
  bool hasMore = true;

  bool get isSupervisor => UserRoleController.role == "supervisor";

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  /// 📦 PAGINATION
  Future<void> loadActivities({bool loadMore = false}) async {
    if (loadMore && isLoadingMore) return;

    setState(() {
      loadMore ? isLoadingMore = true : isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/activities?page=$page"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List newItems = data["activities"];

        setState(() {
          if (loadMore) {
            logs.addAll(newItems);
          } else {
            logs = newItems;
          }

          hasMore = newItems.isNotEmpty;
          page++;

          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (_) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  String displayName(Map log) {
    return isSupervisor ? "Utilisateur anonyme" : log["name"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text("Activités"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (scroll.metrics.pixels ==
                        scroll.metrics.maxScrollExtent &&
                    hasMore &&
                    !isLoadingMore) {
                  loadActivities(loadMore: true);
                }
                return false;
              },

              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length + 1,

                itemBuilder: (context, index) {
                  if (index == logs.length) {
                    return hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox();
                  }

                  final log = logs[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      leading: Icon(
                        Icons.history,
                        color: theme.colorScheme.primary,
                      ),

                      title: Text(displayName(log)),

                      subtitle: Text(
                        "${log["action"]} • ${log["time"]}",
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}