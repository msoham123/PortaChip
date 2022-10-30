import 'package:flutter/material.dart';
import 'package:portachip/Services/StateNotifier.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  final VoidCallback stop, pause;
  const Footer({super.key, required this.pause, required this.stop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Text(
              Provider.of<StateNotifier>(context, listen: false).deviceData,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(" |", style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: pause,
              child: Text(
                "${Provider.of<StateNotifier>(context, listen: false).isPaused ? "Resume" : "Pause"} Emulation",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.merge(const TextStyle(color: Colors.blue)),
              ),
            ),
            Text(" |", style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: stop,
              child: Text(
                "Stop Emulation",
                style: Theme.of(context).textTheme.headlineSmall?.merge(
                      const TextStyle(color: Colors.blue),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
