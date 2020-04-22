import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class CovidNumbers {
  final int confirmed;
  final int recovered;
  final int critical;
  final int deaths;

  CovidNumbers({this.confirmed, this.recovered, this.critical, this.deaths});

  factory CovidNumbers.fromJson(Map<String, dynamic> json) {
    return CovidNumbers(
        confirmed: json['confirmed'],
        recovered: json['recovered'],
        critical: json['critical'],
        deaths: json['deaths']);
  }
}

Future<CovidNumbers> fetchData(http.Client client) async {
  final response = await http.get(
    'https://covid-19-data.p.rapidapi.com/country?format=json&name=malta',
    headers: {
      "x-rapidapi-host": "covid-19-data.p.rapidapi.com",
      "x-rapidapi-key": "e89e9094a4msh8b4b495eb6ee17dp1202d3jsn05a547d69bdd",
    },
  );
  if (response.statusCode == 200) {
    return CovidNumbers.fromJson(json.decode(response.body)[0]);
  } else {
    throw Exception('Failed to load Data');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'RobotoSlab'
      ),
      home: MyHomePage(title: 'COVID-19 Malta'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.grey[800],
        ),
        body: FutureBuilder<CovidNumbers>(
          future: fetchData(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  Container(
                    height: 175,
                    child: Card(
                      child: Center(
                        child: ListTile(
                          title: Text('Confirmed Cases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                          leading: Image.asset('assets/fever.png'),
                          trailing: Text(snapshot.data.confirmed.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 175,
                    child: Card(
                      child: Center(
                        child: ListTile(
                          title: Text('Recovered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                          leading: Image.asset('assets/recovered.png'),
                          trailing: Text(snapshot.data.recovered.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 175,
                    child: Card(
                      child: Center(
                        child: ListTile(
                          title: Text('Deaths', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                          leading: Image.asset('assets/death.png'),
                          trailing: Text(snapshot.data.deaths.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 175,
                    child: Card(
                      child: Center(
                        child: ListTile(
                          title: Text('Critical Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                          leading: Image.asset('assets/ventilator.png'),
                          trailing: Text(snapshot.data.critical.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                      ),
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ));
  }
}
