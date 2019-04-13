import 'package:example/home.dart';
import 'package:example/splash_bloc.dart';
import 'package:flutter/material.dart';
import 'package:clustering_google_maps/clustering_google_maps.dart';

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
                            builder: (context) => HomeScreen(),
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
                 final List<LatLngAndGeohash> list =  await bloc.getListOfLatLngAndGeohash(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(list:list),
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
