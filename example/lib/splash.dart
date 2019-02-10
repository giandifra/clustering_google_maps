import 'package:example/home.dart';
import 'package:example/splash_bloc.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() {
    return SplashState();
  }
}

class SplashState extends State<Splash> {
  final SplashBloc bloc = SplashBloc();

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                child: Text('Load Fake Data'),
                onPressed: loading
                    ? null
                    : () async {
                        try {
                          setState(() {
                            loading = true;
                          });
                          await bloc.addFakePointsToDB(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        } catch (e) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Column(
                                  children: <Widget>[
                                    Text('Error'),
                                    Text(e.toString()),
                                  ],
                                );
                              });
                        }
                      }),
            RaisedButton(
                child: Text('Go to Map'),
                onPressed: loading
                    ? null
                    : () {
                        goToHome(context);
                      }),
            loading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }

  goToHome(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }
}
