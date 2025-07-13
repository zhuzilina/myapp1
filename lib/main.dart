import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    }else{
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth>=600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home), 
                      label: Text('首页'),
                      ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('喜欢')
                      ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value){
                    print('选择了:$value');
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child:page,
                ) 
                ),
            ],
          ),
        );
      }
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var count = appState.favorites.length;

    if(count==0){
      return ListView(
        children: [
          Title(count: count),
          ListTile(
            title:Text('什么都没有')
          )
        ],
      );
    }
    return ListView(
      children:[
        Title(count: count),
        SizedBox(height: 10,),
        for(var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title:ListItem(pair: pair),
          )
      ],
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.primary
    );
    return Text(pair.asPascalCase,style:style);
  }
}

class Title extends StatelessWidget {
  const Title({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color:theme.colorScheme.primary
    );
    return Padding(
      padding: const EdgeInsets.all(18),
      child: count==0?Text('还没有收藏哦',style:style):Text('$count 个收藏',style:style),
  );
  }
}

class GeneratorPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)){
      icon = Icons.favorite;
    }else{
      icon = Icons.favorite_border;
    }

    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: (){
                    print('按下喜欢');
                    appState.toggleFavorite();
                    print('当前喜欢：${appState.favorites}');
                  }, 
                  icon:Icon(icon),
                  label: Text('喜欢')
                  ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed:(){
                    print('按下按钮');
                    appState.getNext();
                  },
                  child:Text('下一个')
                ),
              ],
            ),
          ],
        ),
      );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color:theme.colorScheme.onPrimary,
    );
    
    return Card(
      color:theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asPascalCase, 
          style:style,
          semanticsLabel: "${pair.first} ${pair.second}",
          ),
      ),
    );
  }
}
