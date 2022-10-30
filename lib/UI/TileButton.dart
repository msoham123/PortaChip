import 'package:flutter/material.dart';

class TileButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  const TileButton(
      {super.key, required this.onTap, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width > 800
            ? MediaQuery.of(context).size.width * 0.1
            : 80,
        height: MediaQuery.of(context).size.width > 800
            ? MediaQuery.of(context).size.width * 0.1
            : 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
          // borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            Icon(
              icon,
              color: Theme.of(context).textTheme.headlineLarge?.color,
              size: 35,
            ),
          ],
        ),
      ),
    );
  }
}
