import 'package:flutter/material.dart';

import 'home.dart';
import 'splash_bloc.dart';

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
              child: Text('Load Fake Data into Database'),
              onPressed: loading
                  ? null
                  : () async {
                      try {
                        setState(() {
                          loading = true;
                        });
                        await bloc.addFakePointsToDB(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              list: [],
                            ),
                          ),
                        );
                        setState(() {
                          loading = false;
                        });
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
                          },
                        );
                      }
                    },
            ),
            RaisedButton(
              child: Text('Load Fake Data into Memory'),
              onPressed: loading
                  ? null
                  : () async {
                      try {
                        setState(() {
                          loading = true;
                        });
                        final list =
                            await bloc.getListOfLatLngAndGeohash(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(list: list),
                          ),
                        );
                        setState(() {
                          loading = false;
                        });
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
                          },
                        );
                      }
                    },
            ),
            loading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}
