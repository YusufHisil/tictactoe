import 'package:flutter/material.dart';

enum GameState { playing, stalemate, end }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tictactoe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'tictactoe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GameState gameState = GameState.playing;
  bool isRed = false;
  List<List<Color>> matrix = [
    [Colors.white, Colors.white, Colors.white],
    [Colors.white, Colors.white, Colors.white],
    [Colors.white, Colors.white, Colors.white]
  ];
  bool hasWon = false;
  int red = 0;
  int green = 0;
  bool wasRed = true;

  GameState checkWin() {
    bool a = false;
    if (matrix[0][0] == matrix[1][1] && matrix[1][1] == matrix[2][2] && matrix[0][0] != Colors.white) {
      a = true;
    }
    if (matrix[0][2] == matrix[1][1] && matrix[1][1] == matrix[2][0] && matrix[0][2] != Colors.white) {
      a = true;
    }

    for (int i = 0; i < 3; i++) {
      if ((matrix[i][0] == matrix[i][1] && matrix[i][1] == matrix[i][2] && matrix[i][1] != Colors.white) ||
          (matrix[0][i] == matrix[1][i] && matrix[2][i] == matrix[1][i] && matrix[1][i] != Colors.white)) {
        a = true;
      }
    }

    if (a) {
      if (isRed) {
        red++;
      } else {
        green++;
      }
    }

    if (a) {
      return GameState.end;
    } else {
      bool stalemate = true;
      matrix.forEach((element) {
        element.forEach((item) {
          if (item == Colors.white) stalemate = false;
        });
      });
      if (stalemate) return GameState.stalemate;
      return GameState.playing;
    }
  }

  void colorTile(int index) {
    int row = index ~/ matrix[0].length;
    int col = index % matrix[0].length;

    if (matrix[row][col] == Colors.white) {
      if (isRed) {
        matrix[row][col] = Colors.red;
      } else {
        matrix[row][col] = Colors.greenAccent;
      }
    }
  }

  void dialogbox(String text) {
    bool reset = false;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(title: Text(text), actions: <Widget>[
            const Text('reset: '),
            StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Checkbox(value: reset, onChanged: (value) => setState(() => reset = value!));
            }),
            TextButton(
              child: const Text('Play again!'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  for (int i = 0; i < 3; i++) {
                    for (int j = 0; j < 3; j++) {
                      matrix[i][j] = Colors.white;
                    }
                  }
                  if (reset) {
                    red = 0;
                    green = 0;
                  }
                  hasWon = false;
                });
              },
            )
          ]);
        });
  }

  void handleWin(GameState gameState) {
    if (gameState == GameState.end) {
      dialogbox('${isRed ? 'Red' : 'Green'} has won!');
    }

    if (gameState == GameState.stalemate) {
      dialogbox('Out of moves!');
    }
    isRed = !wasRed;
    wasRed = !wasRed;
  }

  List<Widget> createCards() {
    List<Widget> cards = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        cards.add(GestureDetector(
          onTap: () {
            colorTile(i * 3 + j);
            setState(() {
              gameState = checkWin();
              handleWin(gameState);
            });
            isRed = !isRed;
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(color: matrix[i][j], boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Set shadow color with transparency
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 3),
              )
            ]),
          ),
        ));
      }
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: Image.network('https://nakano-knives.com/cdn/shop/files/CHEFKNIFE_01_1024x.png?v=1700305705',
                scale: 3, fit: BoxFit.fitHeight),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width,
            child: GridView.count(
              crossAxisCount: 3,
              children: createCards(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Red: $red\nGreen: $green',
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
        ],
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
