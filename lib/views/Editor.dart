import 'package:flutter/material.dart';
import 'package:INote/views/Preferences.dart';

class Editor extends StatefulWidget {
  final Map text;
  final int index;
  const Editor({Key? key, required this.text, required this.index});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> with WidgetsBindingObserver {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _titleEditingController = TextEditingController();
  // ignore: unused_field
  bool _isLoading = true; // 添加一个 isLoading 状态，表示是否正在加载
  late bool _isNewNote; // 新建笔记的标志位
  late String _initialTitle; // 初始标题
  late String _initialContent; // 初始内容
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isNewNote = widget.index == -1;
    _loadNote();
  }

  @override
  void dispose() {
    _saveNote();
    _textEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
      _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    });
  }

  void _loadNote() async {
    setState(() {
      if (_isNewNote) {
        _isLoading = false; // 如果是新建笔记则直接将 isLoading 置为 false
      } else {
        _textEditingController.text = widget.text['content'] ?? "";
        _titleEditingController.text = widget.text['title'] ?? "";
        _initialTitle = _titleEditingController.text; // 记录初始标题
        _initialContent = _textEditingController.text; // 记录初始内容
        _isLoading = false; // 加载完成后将 isLoading 置为 false
      }
    });
  }

  void _saveNote() async {
    final currentTitle = _titleEditingController.text;
    final currentContent = _textEditingController.text;
    if (_isNewNote) {
      // 如果是新建笔记，则将新建的笔记添加到笔记列表中
      if (currentTitle.isNotEmpty || currentContent.isNotEmpty) {
        var note = {
          'title': currentTitle.isNotEmpty ? currentTitle : "新建笔记",
          'content': currentContent
        };
        LocalStorage.addNote(note);
      }
    } else {
      // 如果不是新建笔记，则更新原有笔记
      if (currentTitle != _initialTitle || currentContent != _initialContent) {
        var update = {
          'title': currentTitle,
          'content': currentContent,
        };
        LocalStorage.updateNote(widget.index, update);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // _saveNote();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _titleEditingController,
            maxLines: 1,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: '在此输入标题...',
              border: InputBorder.none,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              // _saveNote();
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // 文本框
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: _isKeyboardVisible
                          ? _keyboardHeight - _keyboardHeight + 40
                          : 0,
                    ),
                    child: TextField(
                      controller: _textEditingController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: '在此输入...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isKeyboardVisible)
              Positioned(
                bottom: _keyboardHeight - _keyboardHeight,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
