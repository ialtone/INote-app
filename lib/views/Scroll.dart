import 'package:flutter/material.dart';
import 'Editor.dart';
import 'package:INote/views/Preferences.dart';

class Scroll extends StatefulWidget {
  final Map note;
  final int index;

  const Scroll({Key? key, required this.note, required this.index})
      : super(key: key);

  @override
  State<Scroll> createState() => _ScrollState();
}

class _ScrollState extends State<Scroll> {
  String? _text;
  void _updateText(String? newText) {
    setState(() {
      _text = newText;
    });
  }

  void _onLongPress(LongPressStartDetails details) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          details.globalPosition.dx,
          details.globalPosition.dy,
          details.globalPosition.dx,
          details.globalPosition.dy),
      items: [
        const PopupMenuItem(
          value: 0,
          child: Text('删除'),
        ),
        // const PopupMenuItem(
        //   value: 1,
        //   child: Text('删除'),
        // ),
      ],
    ).then((value) {
      if (value == 0) {
        // 执行修改操作
        LocalStorage.deleteNote(widget.index);
      } else if (value == 1) {
        // 执行删除操作
        print(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
              builder: (context) => Editor(
                    text: widget.note,
                    index: widget.index,
                  )),
        );
        if (result != null) {
          _updateText(result);
        }
      },
      onLongPressStart: _onLongPress,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _text ?? widget.note['title'] ?? '新建笔记',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _text ?? widget.note['content'] ?? '点击添加内容',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text != null || widget.note['content'] != null
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 按钮位置调整

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double offsetX;
  final double offsetY;

  const CustomFloatingActionButtonLocation(this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    double x = scaffoldGeometry.scaffoldSize.width - offsetX;
    double y = scaffoldGeometry.scaffoldSize.height - offsetY;
    return Offset(x, y);
  }
}
