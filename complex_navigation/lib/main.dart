import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'now_playing_backdrop.dart';

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
  List<GlobalKey<NavigatorState>> _keys =
      List.generate(2, (index) => GlobalKey<NavigatorState>());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final state = _keys[_activeIndex].currentState;
        if (state.canPop()) {
          state.pop();
          return false;
        }
        return true;
      },
      child: NowPlayingView(),
    );
  }
}

class NowPlayingView extends StatefulWidget {
  const NowPlayingView({
    Key key,
  }) : super(key: key);

  @override
  _NowPlayingViewState createState() => _NowPlayingViewState();
}

class _NowPlayingViewState extends State<NowPlayingView>
    with SingleTickerProviderStateMixin {
  BackdropController _backdropController;
  AnimationController _animationController;
  GlobalKey _key = GlobalKey();
  var _activeIndex = 0;
  List<GlobalKey<NavigatorState>> _keys =
      List.generate(2, (index) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    _backdropController = BackdropController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      value: 0.0,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NowPlayingBackdrop(
      backdropController: _backdropController,
      contentBuilder: (context, offset, controller) {
        return GestureDetector(
          onTap: () => _backdropController.updateBackdropVisibility(),
          onVerticalDragUpdate: _backdropController.handleDragUpdate,
          onVerticalDragEnd: _backdropController.handleDragEnd,
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Colors.red,
          ),
        );
      },
      background: Padding(
        padding: EdgeInsets.only(bottom: 60),
        child: CupertinoTabScaffold(
          tabBuilder: (context, index) {
            // CupertinoTabView contains a navigator.
            return CupertinoTabView(
                navigatorKey: _keys[index],
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
        ),
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
      child: Scrollbar(
        child: ListView.builder(
            itemBuilder: (context, index) {
              return Material(
                child: ListTile(
                  title: Text("Item"),
                  trailing: Icon(Icons.arrow_forward_ios),
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
      ),
    );
  }
}
