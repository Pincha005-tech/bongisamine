import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../coree/theme/app_themes.dart';
import '../coree/theme/theme_notifier.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final TextEditingController searchController = TextEditingController();
  final String baseUrl = "http://10.0.2.2:8000";

  List workers = [];
  List filteredWorkers = [];

  bool isLoading = true;
  bool isLoadingMore = false;

  int page = 1;
  bool hasMore = true;

  String currentDate = "";

  int totalWorkers = 0;
  int totalPresent = 0;
  int totalAbsent = 0;
  int totalOff = 0;

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  /// 📦 PAGINATION
  Future<void> loadWorkers({bool loadMore = false}) async {
    if (loadMore && isLoadingMore) return;

    setState(() {
      loadMore ? isLoadingMore = true : isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/workers?page=$page"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List newWorkers = data["workers"];

        setState(() {
          if (loadMore) {
            workers.addAll(newWorkers);
          } else {
            workers = newWorkers;
          }

          filteredWorkers = workers;

          currentDate = data["current_date"];

          totalWorkers = data["stats"]["total"];
          totalPresent = data["stats"]["present"];
          totalAbsent = data["stats"]["absent"];
          totalOff = data["stats"]["off"];

          page++;
          hasMore = newWorkers.isNotEmpty;

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

  /// 🔍 SEARCH (inchangé)
  void searchWorker(String value) {
    setState(() {
      filteredWorkers = workers.where((worker) {
        return worker["name"]
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  /// 🔐 ANONYMAT
  bool get isSupervisor =>
      UserRoleController.role == "supervisor";

  String displayName(int index, Map worker) {
    return isSupervisor
        ? "Employé #${index + 1}"
        : worker["name"] ?? "";
  }

  Color statusColor(String status, ThemeData theme) {
    switch (status) {
      case "present":
        return Colors.green;
      case "absent":
        return Colors.red;
      case "off":
        return Colors.orange;
      default:
        return theme.colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Gestion des Travailleurs",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          workers.clear();
          await loadWorkers();
        },

        child: Column(
          children: [

            /// 🔍 SEARCH (INCHANGÉ)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: searchWorker,
                decoration: InputDecoration(
                  hintText: "Rechercher un employé...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// 📋 LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scroll) {
                        if (scroll.metrics.pixels ==
                                scroll.metrics.maxScrollExtent &&
                            hasMore &&
                            !isLoadingMore) {
                          loadWorkers(loadMore: true);
                        }
                        return false;
                      },

                      child: ListView.builder(
                        itemCount: filteredWorkers.length + 1,

                        itemBuilder: (context, index) {
                          if (index == filteredWorkers.length) {
                            return hasMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox();
                          }

                          final worker = filteredWorkers[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Row(
                              children: [

                                /// 👤 AVATAR
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  child: const Icon(Icons.person),
                                ),

                                const SizedBox(width: 12),

                                /// INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName(index, worker),
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                      Text(worker["role"] ?? ""),
                                    ],
                                  ),
                                ),

                                /// STATUS
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(
                                      worker["status"],
                                      theme,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(worker["status"]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}