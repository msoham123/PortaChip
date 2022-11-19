import 'package:flutter/material.dart';
import 'package:portachip/Services/StateNotifier.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).colorScheme.background,
      title: Center(
        child: Text(
          "Settings",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      content: Container(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Dark Mode",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Switch(
                    value: Provider.of<StateNotifier>(context).isDarkMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (bool value) {
                      Provider.of<StateNotifier>(context, listen: false)
                          .updateTheme(value);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.merge(const TextStyle(color: Colors.blue)),
          ),
        ),
        TextButton(
          onPressed: () async {
            Future.delayed(Duration.zero, () async {
              await Provider.of<StateNotifier>(context, listen: false)
                  .updateSettings(
                      "darkMode",
                      Provider.of<StateNotifier>(context, listen: false)
                          .isDarkMode);
            });
            Navigator.pop(context);
          },
          child: Text(
            "Save",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.merge(const TextStyle(color: Colors.blue)),
          ),
        ),
      ],
    );
  }
}
