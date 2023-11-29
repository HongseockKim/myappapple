import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class MyApp extends StatefulWidget {
  @override
  _WebViewPage createState() => _WebViewPage();
}

class _WebViewPage extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  // 옵션
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  void handleLocationPath(List? args) {
    print('Received from JavaScript: $args');
  }

  bool get wantKeepAlive => true;

  Future<bool> permission() async {
    Map<Permission, PermissionStatus> status =
        await [Permission.location].request();
    print('@@@@@@@@@@@@@@@@');
    print(Permission.location);
    print(Permission.location.isGranted);
    print(Platform.isAndroid);
    print(Platform.isIOS);
    print('@@@@@@@@@@@@@@@@');

    // Checking for Android platform.
    if (Platform.isAndroid) {
      if (await Permission.location.isGranted) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    }

    // Considering other platforms like iOS.
    else if (Platform.isIOS) {
      // Replace this with the iOS permission handling code.
      print("Running on iOS");
      return Future.value(true);
    }

    // In case of a non-Android, non-iOS platform.
    else {
      print("Running on a non-Android, non-iOS platform.");
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: permission(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              // 권한이 허용되었을 때 웹뷰를 띄우는 로직
              return InAppWebView(
                  key: webViewKey,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    controller.addJavaScriptHandler(
                        handlerName: 'alert', callback: handleLocationPath);
                  },
                  onLoadStart: (InAppWebViewController controller, Uri? url) {
                    print('Started loading: $url');
                  },
                  onLoadStop: (InAppWebViewController controller, Uri? url) {
                    // controller.evaluateJavascript(source: "location.href = '/'");
                    print('Stopped loading: $url');
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    print('Page loading progress: $progress%');
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    Map<String, dynamic> messageAsMap =
                        jsonDecode(consoleMessage.message);
                    print('Console message: $messageAsMap');
                    print(consoleMessage.message);
                    print('Message level: ${consoleMessage.messageLevel}');
                  },
                  androidOnPermissionRequest:
                      (InAppWebViewController controller, String origin,
                          List<String> resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;
                    print(uri);

                    return NavigationActionPolicy.ALLOW;
                  },
                  initialUrlRequest: URLRequest(
                    url: Uri.parse('https://www.bankx.co.kr/'),
                  ),
                  initialOptions: options);
            }
            if (snapshot.hasError) {
              // 에러가 발생한 경우 처리하는 로직
              return Text('An error occurred');
            }
            // 권한요청 중 또는 권한 거부 시 보여줄 UI
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
