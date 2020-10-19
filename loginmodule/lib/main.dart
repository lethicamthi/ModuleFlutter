import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'Resource/CreateAccount.dart';
import 'Resource/ForgotPasswordScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _showPassword = true;
  bool _isLoggedIn = false;
  String _message;
  final _auth = FirebaseAuth.instance;
  final _facebooklogin = FacebookLogin();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  Future _loginWithFacebook() async {
    // Gọi hàm LogIn() với giá trị truyền vào là một mảng permission
    // Ở đây mình truyền vào cho nó quền xem email
    final result = await _facebooklogin.logIn(['email']);
    // Kiểm tra nếu login thành công thì thực hiện login Firebase
    // (theo mình thì cách này đơn giản hơn là dùng đường dẫn
    // hơn nữa cũng đồng bộ với hệ sinh thái Firebase, tích hợp được
    // nhiều loại Auth

    if (result.status == FacebookLoginStatus.loggedIn) {
      final credential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      );
      // Lấy thông tin User qua credential có giá trị token đã đăng nhập
      final user = (await _auth.signInWithCredential(credential)).user;
      setState(() {
        _message = "Logged in as ${user.displayName}";
        _isLoggedIn = true;
      });
    }
  }

  Future _logout() async {
    // SignOut khỏi Firebase Auth
    await _auth.signOut();
    // Logout facebook
    await _facebooklogin.logOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  Future _checkLogin() async {
    // Kiểm tra xem user đã đăng nhập hay chưa
    final user = await _auth.currentUser();
    if (user != null) {
      setState(() {
        _message = "Logged in as ${user.displayName}";
        _isLoggedIn = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void onToggleShowPass() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Widget onToggleForgotPass(BuildContext context) {
    return ForgotPasswordScreen();
  }

  Widget CreateAccount(BuildContext context) {
    return SignUp();
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    setState(() {
      // User đã login thì hiển thị đã login
      _message = "You are signed in";
    });
    return user;
  }

  Future _handleSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    setState(() {
      // Hiển thị thông báo đã log out
      _message = "You are not sign out";
    });
  }

  Future _checkLoginGoogle() async {
    // Khi mở app lên thì check xem user đã login chưa
    final FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      setState(() {
        _message = "You are signed in";
      });
    }
  }

  @override
  void initStateGG() {
    _checkLoginGoogle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 0),
              //constraints: BoxConstraints.expand(),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Login',
                      style:
                      TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10.0, 50.0, 30.0),
                    child: FlutterLogo(
                      size: 70.0,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'tui@gmail.com',
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: _showPassword,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                                icon: Icon(_showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: onToggleShowPass)),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                          onPressed: () {},
                          textColor: Colors.white,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 20.0),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: onToggleForgotPass)),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "- Sign in with -",
                          style: TextStyle(fontSize: 15),
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(80, 10, 80, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            //onTap: () => {_loginWithFacebook()},
                            child: _isLoggedIn
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(_message),
                                SizedBox(height: 12.0,),
                                OutlineButton(
                                  onPressed: (){
                                    _logout();
                                  },
                                  child: Text('Logout'),
                                )
                              ],
                            )
                                : RaisedButton(
                              onPressed: () {
                                _loginWithFacebook();
                              },
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        image: new AssetImage(
                                            "assets/images/logoFB.png"),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),

                          GestureDetector(
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        image: new AssetImage(
                                            "assets/images/logoGG.png"),
                                        fit: BoxFit.cover)),
                              ),
                            onTap: () {
                                _handleSignIn();
                            },
                          )
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50.0, 120.0, 50.0, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 50.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}