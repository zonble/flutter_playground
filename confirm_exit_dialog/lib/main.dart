import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var shouldExit = false;
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Do you really want to exit?"),
                actions: <Widget>[
                  RaisedButton(
                      child:
                          Text("Exit", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        shouldExit = true;
                        Navigator.of(context).pop();
                      }),
                  RaisedButton(
                      child:
                          Text("Cancel", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        shouldExit = false;
                        Navigator.of(context).pop();
                      })
                ],
              );
            });
        return shouldExit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'The example demonstrates how to show a dialog when the back buttton is tapped.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
