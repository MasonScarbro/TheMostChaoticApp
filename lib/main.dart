import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 18, 11, 112)),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}



class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  final player = AudioPlayer();

  IconData iconData = Icons.play_arrow;
  Map<String, IconData> soundIconMap = {
    'losser.mp3': Icons.play_arrow,
    'chlorofimr.mp3': Icons.play_arrow,
    // Add more sound-file to icon mappings here
  };
  void getNext() {
    current = WordPair.random();
    notifyListeners(); //notifies the change
  }
  var favorites = <WordPair>[];
  var playing = <String>[];
  var currentPlaying = '';
  bool donePlaying = false;
  
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
   
  

  void togglePlaying(String currentPlaying) {
    
    if (playing.contains(currentPlaying)) {
      playing.remove(currentPlaying);
      soundIconMap[currentPlaying] = Icons.play_arrow;
      currentPlaying = '';
      player.stop();
    } else {
      soundIconMap[currentPlaying] = Icons.pause;
      playing.add(currentPlaying);
      player.play(AssetSource(currentPlaying));
    }
    notifyListeners();
  }


}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
      throw UnimplementedError('No Widget present');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.music_note),
                  label: Text('Musica'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}


class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    //Logic to handle the stopping of the player at the end
    appState.player.onPlayerComplete.listen((state) { 
      PlayerState.completed;
      setState(() {
        appState.soundIconMap.forEach((soundFile, _){
          appState.soundIconMap[soundFile] = Icons.play_arrow;
        });
      });
    });

    
    
    return SafeArea(
      minimum: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SoundFile(appState: appState, soundFileName: 'losser.mp3', name: 'Losser'),
                  SoundFile(appState: appState, soundFileName: 'chlorofimr.mp3', name: 'Chloroform'),
                  SoundFile(appState: appState, soundFileName: 'creep.mp3', name: 'Creep'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SoundFile(appState: appState, soundFileName: 'hah.mp3', name: 'Mix'),
                  SoundFile(appState: appState, soundFileName: 'nosurp.mp3', name: 'No Surprises'),
                  SoundFile(appState: appState, soundFileName: 'slow.mp3', name: 'Slow'),
                  
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SoundFile extends StatelessWidget {

  const SoundFile({
    super.key,
    required this.appState,
    required this.soundFileName,
    required this.name,
  });

  final MyAppState appState;
  final String soundFileName;
  final String name;

  @override
  Widget build(BuildContext context) {
    
    appState.soundIconMap[soundFileName] ??= Icons.play_arrow; // automatically assigns the play arrow if it does not exist see more in cmments below
    /*
    about the above code, Due to the way darts operator overloading works it actually will automatically create 
    a new mapping to the sound file if it does not exist Its part of darts null saftey features I believe all that
    code does is make sure that the above will start with the play button upon creation of the soundfile widget
    otherwise no icon would appear until I click the button!
    */
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name),
          ElevatedButton(
            onPressed: () {
              appState.player.stop(); // TESTING, will stop any other sounds before play!
              appState.togglePlaying(soundFileName);
            },
            child: Icon(appState.soundIconMap[soundFileName]),
            
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
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: pair.asPascalCase,
          ),
      ),
    );
  }
}

