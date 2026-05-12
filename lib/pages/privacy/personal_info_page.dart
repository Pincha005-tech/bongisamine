import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../coree/theme/app_themes.dart';
import '../../coree/colors/app_colors.dart';


class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() =>
      _PersonalInfoPageState();
}

class _PersonalInfoPageState
    extends State<PersonalInfoPage> {

  final String baseUrl =
      "http://10.0.2.2:8000";

  bool isLoading = true;

  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();

    loadUserInfo();
  }

  /// 👤 LOAD USER PROFILE
  Future<void> loadUserInfo() async {

    try {

      final response = await http.get(

        Uri.parse(
          "$baseUrl/user/profile",
        ),
      );

      if (response.statusCode == 200) {

        setState(() {

          userData =
              jsonDecode(response.body);

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });
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
          "Informations personnelles",
        ),
      ),

      body: isLoading

          /// ⏳ LOADING
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                children: [

                  /// 👤 PROFILE CARD
                  Card(

                    child: Padding(

                      padding:
                          const EdgeInsets.all(20),

                      child: Column(

                        children: [

                          CircleAvatar(

                            radius: 40,

                            backgroundColor:
                                AppColors.skyBlue
                                    .withOpacity(0.1),

                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color:
                                  AppColors.skyBlue,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(

                            userData['name']
                                    ?? '---',

                            style:
                                Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                          ),

                          const SizedBox(height: 5),

                          Text(

                            userData['role']
                                    ?? '---',

                            style: TextStyle(
                              color: Colors
                                  .grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 📋 INFORMATIONS
                  Card(

                    child: Column(

                      children: [

                        ListTile(

                          leading:
                              CircleAvatar(

                            backgroundColor:
                                AppColors.skyBlue
                                    .withOpacity(
                              0.1,
                            ),

                            child: const Icon(
                              Icons.person,
                              color:
                                  AppColors.skyBlue,
                            ),
                          ),

                          title: Text(
                            userData['name']
                                    ?? '---',
                          ),

                          subtitle: const Text(
                            "Nom complet",
                          ),
                        ),

                        const Divider(height: 1),

                        ListTile(

                          leading:
                              CircleAvatar(

                            backgroundColor:
                                AppColors.skyBlue
                                    .withOpacity(
                              0.1,
                            ),

                            child: const Icon(
                              Icons.email,
                              color:
                                  AppColors.skyBlue,
                            ),
                          ),

                          title: Text(
                            userData['email']
                                    ?? '---',
                          ),

                          subtitle: const Text(
                            "Adresse email",
                          ),
                        ),

                        const Divider(height: 1),

                        ListTile(

                          leading:
                              CircleAvatar(

                            backgroundColor:
                                AppColors.skyBlue
                                    .withOpacity(
                              0.1,
                            ),

                            child: const Icon(
                              Icons.badge,
                              color:
                                  AppColors.skyBlue,
                            ),
                          ),

                          title: Text(
                            userData['role']
                                    ?? '---',
                          ),

                          subtitle: const Text(
                            "Rôle utilisateur",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔄 REFRESH BUTTON
                  SizedBox(

                    width: double.infinity,

                    height: 50,

                    child: ElevatedButton.icon(

                      onPressed:
                          loadUserInfo,

                      icon: const Icon(
                        Icons.refresh,
                      ),

                      label: const Text(
                        "Actualiser les données",
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}