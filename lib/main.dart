import 'dart:async';
import 'package:flutter/material.dart';
import 'package:INote/views/Editor.dart';
import 'package:INote/views/Preferences.dart';
import 'package:INote/views/Scroll.dart';
import 'package:INote/views/settings.dart';
void main() {
  _noteinit();
  runApp(const MyApp());
}

void _noteinit() async {
  WidgetsFlutterBinding.ensureInitialized();
   // LocalStorage.updateNote(0, {'title': '新建笔记', 'content': '点击添加内容'});
  // LocalStorage.setString('note', '[{"title": "123", "content": "# this"}]');
  final note = await LocalStorage.getString('note');
  if (note == null) {
    await LocalStorage.setString('note', '[]');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'iNote',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<dynamic> _notes = [];
  StreamSubscription<NoteEvent>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = LocalStorage.noteEventStream.listen(_handleNoteEvent);
    _getNotes(); // 加载笔记数据
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getNotes() async {
    final note = await LocalStorage.getNoteList();
    setState(() {
      _notes = note;
    });
  }

  Future<void> _handleRefresh() async {
    await _getNotes(); // 执行刷新操作
  }

  void _handleNoteEvent(NoteEvent event) async {
    await _getNotes(); // 处理接收到的事件，例如刷新页面等
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'iNote',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 248, 193, 18),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Editor(
                text: {},
                index: -1,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          const CustomFloatingActionButtonLocation(90, 90),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: RefreshIndicator(
        onRefresh: _handleRefresh, // 下拉刷新回调
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2 / 1.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: List.generate(
              _notes.length,
              (index) => Scroll(note: _notes[index], index: index),
            ),
          ),
        ),
      ),
    );
  }
}
