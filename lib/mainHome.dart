import 'package:flutter/material.dart';
import 'package:myappapple/page/webviewPage.dart';

void handleLocation(BuildContext context) {
  print('페이지 이동');
  // Your logic here
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
}

class MainHomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        alignment: Alignment.center,
        height: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
                onPressed: () => handleLocation(context),
                child: Text(
                  'simple 앱',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
