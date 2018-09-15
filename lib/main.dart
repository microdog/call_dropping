import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _messages = <String>[];

  StreamSubscription _connectivitySubscription;
  Client _client;

  @override
  void initState() {
    super.initState();

    // CHANGE THIS
    int maxConnectionsPerHost = 1;

    _client = new IOClient(
        new HttpClient()..maxConnectionsPerHost = maxConnectionsPerHost);
    _connectivitySubscription = new Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _messages.add('connectivity changed: $result');
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _client.close();

    super.dispose();
  }

  Future<void> _makeCall() async {
    setState(() {
      _messages.add('Initiating call...');
    });

    try {
      final response =
          await _client.get('http://www.mocky.io/v2/5b9ca7d23000006f00f6b591');
      final data = json.decode(response.body);
      setState(() {
        _messages.add('received data: $data');
      });
    } catch (e, s) {
      setState(() {
        _messages.add('exception: $e, $s');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (BuildContext context, int index) {
          return new Container(
            padding: EdgeInsets.all(5.0),
            child: new Text(
              _messages[index],
            ),
          );
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _makeCall,
        tooltip: 'Send',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
