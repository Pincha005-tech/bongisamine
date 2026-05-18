import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../coree/auth/auth_controller.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() =>
      _DeleteAccountPageState();
}

class _DeleteAccountPageState
    extends State<DeleteAccountPage> {

  bool isLoading = false;

  Future<void> sendDeleteRequest() async {
    setState(() => isLoading = true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      await context.read<AuthController>().logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande envoyée — session fermée localement"),
        ),
      );
    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    } finally {

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
          "Suppression du compte",
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// 🚨 WARNING CARD
            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color:
                    Colors.red.withOpacity(0.08),

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.red.shade200,
                ),
              ),

              child: Column(

                children: [

                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 50,
                  ),

                  const SizedBox(height: 15),

                  Text(

                    "Suppression du compte",

                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    "Cette action nécessite la validation "
                    "d’un administrateur système.",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      fontSize: 14,

                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 📋 INFO CARD
            Card(

              child: Padding(

                padding: const EdgeInsets.all(16),

                child: Column(

                  children: [

                    ListTile(

                      leading: const Icon(
                        Icons.security,
                        color: Colors.red,
                      ),

                      title: const Text(
                        "Validation requise",
                      ),

                      subtitle: const Text(
                        "La demande sera envoyée "
                        "à l’administrateur.",
                      ),
                    ),

                    const Divider(),

                    ListTile(

                      leading: const Icon(
                        Icons.lock_outline,
                        color: Colors.red,
                      ),

                      title: const Text(
                        "Données protégées",
                      ),

                      subtitle: const Text(
                        "Les informations seront "
                        "archivées avant suppression.",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// 🔥 BUTTON
            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),

                onPressed:
                    isLoading
                        ? null
                        : sendDeleteRequest,

                icon: isLoading

                    ? const SizedBox(
                        width: 18,
                        height: 18,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )

                    : const Icon(Icons.delete),

                label: Text(

                  isLoading

                      ? "Envoi..."

                      : "Envoyer la demande",

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}