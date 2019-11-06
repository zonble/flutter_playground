import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(title: "Flutter Demo", home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBuilder: (context, index) {
        // CupertinoTabView contains a navigator.
        return CupertinoTabView(
            builder: (context) => SimplePage(
                  level: 0,
                ));
      },
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
              title: Text("First"), icon: Icon(Icons.album)),
          BottomNavigationBarItem(
              title: Text("Second"), icon: Icon(Icons.music_note)),
        ],
        onTap: (index) {
          _activeIndex = index;
        },
      ),
    );
  }
}

class SimplePage extends StatefulWidget {
  final int level;

  SimplePage({Key key, this.level}) : super(key: key);

  @override
  _SimplePageState createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("List level ${widget.level}"),
      ),
      child: ListView.builder(
          itemBuilder: (context, index) {
            return Material(
              child: ListTile(
                title: Text("Item"),
                onTap: () {
                  final route = CupertinoPageRoute(builder: (context) {
                    return SimplePage(
                      level: widget.level + 1,
                    );
                  });
                  Navigator.of(context).push(route);
                },
              ),
            );
          },
          itemCount: 10),
    );
  }
}
