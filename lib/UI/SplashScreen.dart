import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portachip/Display/ProgramView.dart';
import 'package:portachip/Services/StateNotifier.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<StatefulWidget> createState() {
    return SplashViewState();
  }
}

class SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<StateNotifier>(context).loadAppInfo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Future.delayed(Duration.zero, () {
            Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: const ProgramView()),
                (Route<dynamic> route) => false);
          });
        }
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: const Center(
            // child: Image.asset(
            //   'assets/images/logo.png',
            //   height: MediaQuery.of(context).size.height / 3,
            // ),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
