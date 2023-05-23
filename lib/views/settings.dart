import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:INote/main.dart';
import 'package:INote/views/Preferences.dart';
import 'package:INote/views/upandown.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isSwitched = false;
  bool _isSettingOpen = false;
  bool _isLoggedIn = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (await LocalStorage.getString('islogin') == null) {
      await LocalStorage.setString('islogin', "false");
      _isLoggedIn = false;
    } else {
      _isLoggedIn =
          // ignore: unrelated_type_equality_checks
          await LocalStorage.getString('islogin') == true ? true : false;
    }
    if (await LocalStorage.getString('token') != null) {
      await LocalStorage.setString('islogin', "true");
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  Future islogin() async {
    return LocalStorage.getString('islogin');
  }

  _showToast(icon, Color color, String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(
            width: 12.0,
          ),
          Text(text),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  void _login() {
    bool loginFailed = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('登录'),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _usernameController.clear();
                      _passwordController.clear();
                    },
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    onTap: () => {loginFailed = false, setState(() {})},
                    decoration: const InputDecoration(
                      hintText: '请输入邮箱',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    onTap: () => {loginFailed = false, setState(() {})},
                    decoration: const InputDecoration(
                      hintText: '请输入密码',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final username = _usernameController.text;
                      final password = _passwordController.text;
                      if (username.isNotEmpty && password.isNotEmpty) {
                        try {
                          var result =
                              await UpandDown.login(username, password);
                          if (result['status'] == 200) {
                            await LocalStorage.setString('email', username);
                            await LocalStorage.setString(
                                'token', result['token']);
                            await LocalStorage.setString('islogin', "true");
                            setState(() {
                              _isLoggedIn = true;
                            });
                            _showToast(Icons.check, Colors.greenAccent,
                                result['message']);
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                            _usernameController.clear();
                            _passwordController.clear();
                          } else {
                            loginFailed = true;
                            setState(() {});
                            _showToast(Icons.close, Colors.redAccent,
                                result['message']);
                          }
                        } catch (e) {
                          print(e);
                          _showToast(
                              Icons.close, Colors.redAccent, '服务器异常,请联系管理人员!');
                        }
                      } else {
                        _showToast(Icons.info, Colors.blueGrey, "请输入完整信息");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: loginFailed ? Colors.red : null,
                    ),
                    child: const Text('登录'),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      if (_isLoggedIn) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "设置",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          if (!_isLoggedIn)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              child: TextButton(
                onPressed: _login,
                child: const Text(
                  '登录',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          if (_isLoggedIn)
            Visibility(
                visible: _isLoggedIn,
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 60,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () async {
                                await LocalStorage.remove('email');
                                await LocalStorage.remove('token');
                                setState(() {
                                  _isLoggedIn = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                elevation: 4,
                                backgroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('退出'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            var result = await UpandDown.upload(
                                await LocalStorage.getString('email'),
                                await LocalStorage.getString('note'),
                                await LocalStorage.getString('token'));
                            if (result['status'] == 200) {
                              _showToast(Icons.check, Colors.greenAccent,
                                  result['msg']);
                            } else {
                              _showToast(
                                  Icons.close, Colors.redAccent, result['msg']);
                            }
                          } catch (e) {
                            print(e);
                            _showToast(Icons.close, Colors.redAccent,
                                '服务器异常,请联系管理人员!');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          elevation: 4,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('上传'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            var result = await UpandDown.download(
                                await LocalStorage.getString('email'),
                                await LocalStorage.getString('token'));

                            if (result['status'] == 200) {
                              _showToast(
                                  Icons.check, Colors.greenAccent, '下载成功');
                              // ignore: use_build_context_synchronously
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => const MyApp()),
                                      (route) => false);
                            } else {
                              _showToast(Icons.close, Colors.redAccent, '下载失败');
                            }
                          } catch (e) {
                            print(e);
                            _showToast(Icons.close, Colors.redAccent,
                                '服务器异常,请联系管理人员!');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          elevation: 4,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('下载'),
                      ),
                    ],
                  )
                ])),
          SwitchListTile(
            title: const Text("啥都"),
            value: _isSwitched,
            onChanged: (bool value) {
              setState(() {
                _isSwitched = value;
                if (_isSwitched) {
                  print('123444');
                } else {
                  print('123');
                }
              });
            },
          ),
          SwitchListTile(
            title: const Text("没写"),
            value: _isSettingOpen,
            onChanged: (bool value) {
              setState(() {
                _isSettingOpen = value;
                if (_isSettingOpen) {
                  print('Setting Opened');
                } else {
                  print('Setting Closed');
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
