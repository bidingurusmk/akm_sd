import 'dart:async';
import 'dart:io';
import 'dart:convert';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_flutter_android;
import 'package:file_picker/file_picker.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// final webViewKey = GlobalKey<_MyHomePageState>();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 7, 1, 88)),
        useMaterial3: true,
      ),
      home: screenFlash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class screenFlash extends StatefulWidget {
  const screenFlash({super.key});

  @override
  State<screenFlash> createState() => _screenFlashState();
}

class _screenFlashState extends State<screenFlash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage())));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Image(
          image: AssetImage('assets/icon_akm_sd.png'),
          width: MediaQuery.of(context).size.width * 20 / 100,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController controller;

  bool konek = false;
  Future check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        konek = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        konek = true;
      });
    } else {
      setState(() {
        konek = false;
      });
    }
  }

  int loadingPercentage = 0;

  web1() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        // Uri.parse('https://youtube.com/'),
        // Uri.parse('https://smktelkom-mlg.sch.id/'),
        Uri.parse('https://effendidikan.my.canva.site/soal-akm-sd'),
      );
  }

  Future<List<String>> _androidFilePicker(
      final FileSelectorParams params) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      return [file.uri.toString()];
    }
    return [];
  }

  void addFileSelectionListener() async {
    if (Platform.isAndroid) {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  @override
  void initState() {
    check();
    web1();
    addFileSelectionListener();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 12, 146, 0),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              check();
              konek == true ? controller.goBack() : koneksi_not();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              check();
              konek == true ? controller.reload() : koneksi_not();
            },
          ),
        ],
      ),
      body: konek == true
          ? WebViewWidget(
              controller: controller,
            )
          : koneksi_not(),
    );
  }

  Widget koneksi_not() {
    return new Center(
        child: Image.asset(
      'assets/Internet-Access-Error.jpg',
      width: MediaQuery.of(context).size.width,
    ));
  }
}
