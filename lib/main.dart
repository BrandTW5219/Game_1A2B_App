import 'package:flutter/material.dart';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Global variables
List<List<int>> userGuessList = <List<int>>[];
List<int> targetAnswer = <int>[];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1A2B 猜謎遊戲',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueGrey[100],
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1A2B'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '1A2B',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text(
                  '開始遊戲',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = '請猜測一個四位數字，數字不重複：';
  final TextEditingController _controller = TextEditingController();
  bool showEndGameButtons = false;
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    generateAnswer();
  }

  void generateAnswer() {
    Random random = Random();
    targetAnswer.clear();
    while (targetAnswer.length < 4) {
      int digit = random.nextInt(10);
      if (!targetAnswer.contains(digit)) {
        targetAnswer.add(digit);
      }
    }
    showEndGameButtons = false;
    userGuessList.clear();
  }

  void checkGuess() async {
    setState(() {
      String guessString = _controller.text;
      List<int> guess = guessString.split('').map(int.parse).toList();

      // 檢查輸入是否合法
      if (guess.length != 4 || guess.toSet().length != 4) {
        message = '請輸入四位不重複的數字！';
        return;
      }

      userGuessList.add(guess);

      // 檢查猜測是否正確
      int correct = 0;
      int misplaced = 0;
      for (int i = 0; i < 4; i++) {
        if (guess[i] == targetAnswer[i]) {
          correct++;
        } else if (targetAnswer.contains(guess[i])) {
          misplaced++;
        }
      }

      // 輸出結果
      if (correct == 4) {
        message = '恭喜你猜對了！答案是${targetAnswer.join()}，你總共猜了 ${userGuessList.length} 次。';
        showEndGameButtons = true;
        // When correct, store guess time and count in database
        DateTime currentTime = DateTime.now();
        dbHelper.insertGuess(currentTime, userGuessList.length);
      } else {
        message = '$correct A $misplaced B';
      }
    });
  }

  void clearText() {
    _controller.clear();
  }

  void addDigit(int digit) {
    if (_controller.text.length < 4) {
      _controller.text += digit.toString();
    }
  }

  void deleteDigit() {
    if (_controller.text.isNotEmpty) {
      _controller.text = _controller.text.substring(0, _controller.text.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1A2B 猜謎遊戲'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 20.0),
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20.0),
            decoration: const InputDecoration(
              hintText: '輸入你的猜測',
              counterText: '',
            ),
          ),
          const SizedBox(height: 20.0),
          if (!showEndGameButtons)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 1; i <= 3; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                            onPressed: () => addDigit(i),
                            child: Text(
                              i.toString(),
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 4; i <= 6; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                            onPressed: () => addDigit(i),
                            child: Text(
                              i.toString(),
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 7; i <= 9; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                            onPressed: () => addDigit(i),
                            child: Text(
                              i.toString(),
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          onPressed: clearText,
                          child: const Text(
                            '清除',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          onPressed: () => addDigit(0),
                          child: const Text(
                            '0',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          onPressed: checkGuess,
                          child: const Text(
                            '輸入',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (showEndGameButtons)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReviewPage()),
                    );
                  },
                  child: const Text(
                    '查看排名',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RecoveryPage()),
                    );
                  },
                  child: const Text(
                    '復盤記錄',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      generateAnswer();
                      _controller.clear();
                      message = '請猜測一個四位數字，數字不重複：';
                    });
                  },
                  child: const Text(
                    '重新開始',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  String userGuessString = '';
  String answerString = '';
  String correctString = '';
  String misplacedString = '';
  String canGuessNumString = '';
  String guessWiselyString = '';
  String pageString = '';
  String maxPageString = '';

  final List<String> _userGuessStringList = <String>[];
  final List<String> _answerStringList = <String>[];
  final List<String> _correctStringList = <String>[];
  final List<String> _misplacedStringList = <String>[];
  final List<String> _canGuessNumStringList = <String>[];
  final List<String> _guessWiselyStringList = <String>[];
  final List<String> _pageStringList = <String>[];
  final List<String> _maxPageStringList = <String>[];

  int index = -1;

  @override
  void initState() {
    super.initState();
    List<List<int>> canGuess = <List<int>>[];
    for (int a = 0; a < 10; a++) {
      for (int b = 0; b < 10; b++) {
        for (int c = 0; c < 10; c++) {
          for (int d = 0; d < 10; d++) {
            if (a != b && a != c && a != d && b != c && b != d && c != d) {
              canGuess.add([a, b, c, d]);
            }
          }
        }
      }
    }
    for (int i = 0; i < userGuessList.length; i++) {
      List<int> userGuess = userGuessList[i];
      List<int> answer = targetAnswer;
      int correct = 0;
      int misplaced = 0;
      for (int j = 0; j < 4; j++) {
        if (userGuess[j] == answer[j]) {
          correct++;
        } else if (answer.contains(userGuess[j])) {
          misplaced++;
        }
      }
      String guessWiselyString = '不合理';
      for (int j = 0; j < canGuess.length; j++) {
        if (userGuess[0] == canGuess[j][0] &&
            userGuess[1] == canGuess[j][1] &&
            userGuess[2] == canGuess[j][2] &&
            userGuess[3] == canGuess[j][3]) {
          guessWiselyString = '合理';
        }
      }
      List<List<int>> tempCanGuess = [];
      for (int j = 0; j < canGuess.length; j++) {
        int tempCorrect = 0;
        int tempMisplaced = 0;
        for (int k = 0; k < 4; k++) {
          if (userGuess[k] == canGuess[j][k]) {
            tempCorrect++;
          } else if (canGuess[j].contains(userGuess[k])) {
            tempMisplaced++;
          }
        }
        if (correct == tempCorrect && misplaced == tempMisplaced) {
          tempCanGuess.add(canGuess[j]);
        }
      }
      canGuess.clear();
      for (int j = 0; j < tempCanGuess.length; j++) {
        canGuess.add(tempCanGuess[j]);
      }
      _userGuessStringList.add(userGuess.join());
      _answerStringList.add(answer.join());
      _correctStringList.add('$correct');
      _misplacedStringList.add('$misplaced');
      _canGuessNumStringList.add('${tempCanGuess.length}');
      _guessWiselyStringList.add(guessWiselyString);
      _pageStringList.add('${i + 1}');
      _maxPageStringList.add('${userGuessList.length}');
    }
    nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('復盤記錄'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('你的猜測: $userGuessString', style: const TextStyle(fontSize: 20))
          ),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('正確答案: $answerString', style: const TextStyle(fontSize: 20))
          ),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('$correctString A $misplacedString B', style: const TextStyle(fontSize: 20))
          ),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('剩餘可猜測數字數量: $canGuessNumString', style: const TextStyle(fontSize: 20))
          ),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('你的猜測$guessWiselyString', style: const TextStyle(fontSize: 20))
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: lastPage,
                child: const Text('<'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(pageString),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('/'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(maxPageString),
              ),
              ElevatedButton(
                onPressed: nextPage,
                child: const Text('>'),
              ),
            ],
          ),
          ElevatedButton(onPressed: () { Navigator.pop(context); },
                         child: const Text("返回"))
        ],
      ),
    );
  }

  void nextPage() {
    if (index < _userGuessStringList.length - 1) {
      setState(() {
        index++;
        userGuessString = _userGuessStringList[index];
        answerString = _answerStringList[index];
        correctString = _correctStringList[index];
        misplacedString = _misplacedStringList[index];
        canGuessNumString = _canGuessNumStringList[index];
        guessWiselyString = _guessWiselyStringList[index];
        pageString = _pageStringList[index];
        maxPageString = _maxPageStringList[index];
      });
    }
  }

  void lastPage() {
    if (index > 0) {
      setState(() {
        index--;
        userGuessString = _userGuessStringList[index];
        answerString = _answerStringList[index];
        correctString = _correctStringList[index];
        misplacedString = _misplacedStringList[index];
        canGuessNumString = _canGuessNumStringList[index];
        guessWiselyString = _guessWiselyStringList[index];
        pageString = _pageStringList[index];
        maxPageString = _maxPageStringList[index];
      });
    }
  }
}

class ReviewPage extends StatefulWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> guessHistory = [];

  @override
  void initState() {
    super.initState();
    fetchGuessHistory();
  }

  void fetchGuessHistory() async {
    var history = await dbHelper.fetchAllGuesses();
    setState(() {
      guessHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歷史排名'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: guessHistory.length,
              itemBuilder: (context, index) {
                DateTime guessDateTime = DateTime.parse(guessHistory[index]["guessTime"]);
                String formattedDateTime = '${guessDateTime.year}/${guessDateTime.month.toString().padLeft(2, '0')}/${guessDateTime.day.toString().padLeft(2, '0')}  ${guessDateTime.hour.toString().padLeft(2, '0')}:${guessDateTime.minute.toString().padLeft(2, '0')}';
                return ListTile(
                  title: Text(
                    '第${index + 1}名  $formattedDateTime  猜了 ${guessHistory[index]['guessCount']} 次',
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), '1a2b_game.db');
    return await openDatabase(path, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE GuessHistory(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          guessTime TEXT,
          guessCount INTEGER
        )
      ''');
    }, version: 1);
  }

  Future<void> insertGuess(DateTime guessTime, int guessCount) async {
    final Database dbClient = await db as Database;
    await dbClient.insert(
      'GuessHistory',
      {'guessTime': guessTime.toIso8601String(), 'guessCount': guessCount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllGuesses() async {
    final Database dbClient = await db as Database;
    return await dbClient.query('GuessHistory');
  }
}
