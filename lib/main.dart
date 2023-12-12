import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

const htmlString = '''
<!DOCTYPE html>
<head>
<title>webview demo | IAM17</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, 
  maximum-scale=1.0, user-scalable=no,viewport-fit=cover" />
<style>
*{
  margin:0;
  padding:0;
}
body{
   background:#BBDFFC;  
   display:flex;
   justify-content:center;
   align-items:center;
   height:400px;
   color:#C45F84;
   font-size:20px;
}
</style>
</head>
<html>
<body>
<div >大家好，我是 17</div>
</body>
</html>
''';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebView()),
    );
  }
}

/// 自定义的webView
class WebView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController controller;
  double height = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Report', onMessageReceived: (message) {
        setState(() {
          height = double.parse(message.message);
        });
      })
      ..addJavaScriptChannel('Jump', onMessageReceived: (message) {
        /// 根据信息跳转
        print('JUMP：====>${message.message}');
      })
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (url) async {
        ///可以注入js
        controller.runJavaScript(
            '''const resizeObserver = new ResizeObserver(entries =>
          Report.postMessage(document.scrollingElement.scrollHeight))
    resizeObserver.observe(document.body)''');

        /// 注入js
        controller.runJavaScript('''Jump.postMessage('video')''');
      },

          /// 进行拦截
          onNavigationRequest: (request) {
        if (request.url.endsWith('/android')) {
          /// 跳到原生页面
          return NavigationDecision.prevent;
        }

        /// 继续原来的请求
        return NavigationDecision.navigate;
      }))
      ..loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: height,
            child: WebViewWidget(
              controller: controller,
            )),
        Expanded(
            child: Container(
          color: Colors.red,
        ))
      ],
    );
  }
}
