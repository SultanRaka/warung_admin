/// -----------------------------------
///          External Packages
/// -----------------------------------

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

/// -----------------------------------
///           Auth0 Variables
/// -----------------------------------
const AUTH0_DOMAIN = 'bangsultantest1.us.auth0.com';
const AUTH0_CLIENT_ID = 'XXEHITuSuIgbNwl6vzqa8BkTkjYSUNKs';

const AUTH0_REDIRECT_URI = 'bangsultantest1.us.auth0.com://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

/// -----------------------------------
///           Profile Widget
/// -----------------------------------
class Profile extends StatelessWidget {
  final logoutAction;
  final String name;
  final String picture;

  Profile(this.logoutAction, this.name, this.picture);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 4.0),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(picture ?? ''),
            ),
          ),
        ),
        SizedBox(height: 24.0),
        Text('Name: $name'),
        SizedBox(height: 48.0),
        RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuAdmin()),
            );
          },
          child: Text('Menu Admin'),
        ),
        RaisedButton(
          onPressed: () {
            logoutAction();
          },
          child: Text('Logout'),
        ),
      ],
    );
  }
}

/// -----------------------------------
///            Login Widget
/// -----------------------------------
///
class Login extends StatelessWidget {
  final loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            loginAction();
          },
          child: Text('Login'),
        ),
        Text(loginError ?? ''),
      ],
    );
  }
}

/// -----------------------------------
///                 App
/// -----------------------------------

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

/// -----------------------------------
///              App State
/// -----------------------------------

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage;
  String name;
  String picture;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Online - Admin',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Warung Online - Admin'),
        ),
        body: Center(
          child: isBusy
              ? CircularProgressIndicator()
              : isLoggedIn
                  ? Profile(logoutAction, name, picture)
                  : Login(loginAction, errorMessage),
        ),
      ),
    );
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    final url = 'https://$AUTH0_DOMAIN/userinfo';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          scopes: ['openid', 'profile', 'offline_access'],
          // promptValues: ['login']
        ),
      );

      final idToken = parseIdToken(result.idToken);
      final profile = await getUserDetails(result.accessToken);

      await secureStorage.write(
          key: 'refresh_token', value: result.refreshToken);

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } catch (e, s) {
      print('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  void logoutAction() async {
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  @override
  void initState() {
    initAction();
    super.initState();
  }

  void initAction() async {
    final storedRefreshToken = await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    setState(() {
      isBusy = true;
    });

    try {
      final response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final idToken = parseIdToken(response.idToken);
      final profile = await getUserDetails(response.accessToken);

      secureStorage.write(key: 'refresh_token', value: response.refreshToken);

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } catch (e, s) {
      print('error on refresh token: $e - stack: $s');
      logoutAction();
    }
  }
}

//==================================================================================== Page Main Menu ===========================================================================
class MenuAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Menu"),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.all(10),
              height: 50.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageMenu()),
                  );
                },
                padding: EdgeInsets.all(10.0),
                color: Color.fromRGBO(0, 160, 227, 1),
                textColor: Colors.white,
                child: Text("Lihat Menu", style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.all(10),
              height: 50.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageOrder()),
                  );
                },
                padding: EdgeInsets.all(10.0),
                color: Color.fromRGBO(0, 160, 227, 1),
                textColor: Colors.white,
                child: Text("Lihat Pesanan", style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.all(10),
              height: 50.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
                padding: EdgeInsets.all(10.0),
                color: Color.fromRGBO(0, 160, 227, 1),
                textColor: Colors.white,
                child: Text("Kembali", style: TextStyle(fontSize: 15)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//==================================================================================== Page Lihat Menu ===========================================================================

class PageMenu extends StatefulWidget {
  @override
  _PageMenu createState() => _PageMenu();
}

class _PageMenu extends State<PageMenu> {
  List menu;

  Future<List> getData() async {
    var response = await http.get(
        Uri.parse("http://10.0.2.2/warung_makan/getmenu.php"),
        headers: {"Accept": "application/json"});

    var resBody = json.decode(response.body);
    setState(() {
      menu = resBody;
    });
  }

  Widget getLoading() {
    return new Scaffold(
      body: Center(
        child: Text("Loading gan"),
      ),
    );
  }

  Widget cekLoading() {
    if (menu == null) {
      getData();
      return getLoading();
    } else {
      return mainFunction();
    }
  }

  void del(String id) {
    var url = "http://10.0.2.2/warung_makan/del.php";

    http.post(Uri.parse(url), body: {
      "id": id,
    });
  }

  Future<void> deleteMenu(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Item telah dihapus!"),
          content: const Text(''),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PageMenu()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget mainFunction() {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Menu"),
      ),
      body: new ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, i) {
          return new Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            child: Card(
              child: new Row(
                children: <Widget>[
                  new Image.asset(
                    menu[i]["url"].toString(),
                    height: 100,
                    width: 100,
                  ),
                  new Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: new Container(
                      width: 100,
                      child: new Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: new Text(menu[i]["nama"],
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: new Text(menu[i]["detil"],
                                textAlign: TextAlign.left),
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(menu[i]["harga"],
                                  textAlign: TextAlign.left)),
                        ],
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: new Text("Stock: " + menu[i]["stock"],
                            textAlign: TextAlign.left),
                      )),
                  new Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: new Container(
                      width: 80,
                      child: new Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                child: new RaisedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditItem(id: menu[i]["id"])),
                                );
                              },
                              child: new Text("Edit"),
                            )),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                child: new RaisedButton(
                              onPressed: () {
                                del(menu[i]["id"]);
                                deleteMenu(context);
                              },
                              child: new Text("Hapus"),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: new Row(
        children: <Widget>[
          Container(
              child: new RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItem()),
              );
            },
            child: new Text("Tambah Item"),
          )),
          Container(
              child: new RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuAdmin()),
              );
            },
            child: new Text("Kembali"),
          )),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return cekLoading();
  }
}

//==================================================================================================PAGE TAMBAH ITEM==============================================================
class AddItem extends StatelessWidget {
  TextEditingController id = new TextEditingController();
  TextEditingController nama = new TextEditingController();
  TextEditingController detil = new TextEditingController();
  TextEditingController harga = new TextEditingController();
  TextEditingController stok = new TextEditingController();
  final alamat = 'img/placeholder.png';
  void addData() {
    var url = "http://10.0.2.2/warung_makan/post3.php";

    http.post(Uri.parse(url), body: {
      "id": id.text,
      "nama": nama.text,
      "detil": detil.text,
      "harga": harga.text,
      "url": this.alamat,
      "stok": stok.text,
    });
  }

  Future<void> valid(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Berhasil"),
          content: const Text('Item berhasil ditambahkan'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PageMenu()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Item"),
      ),
      body: Column(children: [
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50, top: 15),
          child: Text("ID Item"),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: TextField(
            controller: id,
          ),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: Text("Nama Item"),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: TextField(
            controller: nama,
          ),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: Text("Detil Item"),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: TextField(
            controller: detil,
          ),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: Text("Harga Item"),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: TextField(
            controller: harga,
          ),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: Text("Stok Item"),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: TextField(
            controller: stok,
          ),
        ),
        RaisedButton(
          onPressed: () {
            addData();
            valid(context);
          },
          child: Text("Tambah"),
        )
      ]),
    );
  }
}

//======================================================================================
class EditItem extends StatelessWidget {
  TextEditingController stok = new TextEditingController();
  final id;
  EditItem({Key key, @required this.id}) : super(key: key);

  void addData() {
    var url = "http://10.0.2.2/warung_makan/edit.php";

    http.post(Uri.parse(url), body: {
      "id": this.id,
      "stok": stok.text,
    });
  }

  Future<void> valid(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Berhasil"),
          content: const Text('Stok telah diperbarui'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PageMenu()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Stok"),
      ),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Container(
            width: 250,
            margin: EdgeInsets.only(left: 50),
            child: Text("Stok Item untuk " + this.id),
          ),
        ),
        Container(
          width: 250,
          margin: EdgeInsets.only(left: 50),
          child: TextField(
            controller: stok,
          ),
        ),
        RaisedButton(
          onPressed: () {
            addData();
            valid(context);
          },
          child: Text("Perbarui"),
        )
      ]),
    );
  }
}

//======================================================================================
class PageOrder extends StatefulWidget {
  @override
  _PageOrder createState() => _PageOrder();
}

class _PageOrder extends State<PageOrder> {
  List order;

  Future<List> getData() async {
    var response = await http.get(
        Uri.parse("http://10.0.2.2/warung_makan/getorder.php"),
        headers: {"Accept": "application/json"});

    var resBody = json.decode(response.body);
    setState(() {
      order = resBody;
    });
  }

  Widget getLoading() {
    return new Scaffold(
      body: Center(
        child: Text("Loading gan"),
      ),
    );
  }

  Widget cekLoading() {
    if (order == null) {
      getData();
      return getLoading();
    } else {
      return mainFunction();
    }
  }

  Widget mainFunction() {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Orders"),
      ),
      body: new ListView.builder(
        itemCount: order.length,
        itemBuilder: (context, i) {
          return new Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            child: Card(
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: new Container(
                      width: 125,
                      child: new Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: new Text("Nama: " + order[i]["nama"],
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: new Text("Alamat: " + order[i]["alamat"],
                                textAlign: TextAlign.left),
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                  "Detail pesanan: " + order[i]["detil"],
                                  textAlign: TextAlign.left)),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: new Text("total: " + order[i]["total"],
                                  textAlign: TextAlign.left))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget build(BuildContext context) {
    return cekLoading();
  }
}
