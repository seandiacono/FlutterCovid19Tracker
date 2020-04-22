import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class CovidNumbers {
  int newConfirmed;
  int newRecovered;
  int newCritcal;
  int newDeaths;
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
    var data = CovidNumbers.fromJson(json.decode(response.body)[0]);
    final prefs = await SharedPreferences.getInstance();

    final oldConfirmed = prefs.getInt('confirmed') ?? 0;
    final oldRecovered = prefs.getInt('recovered') ?? 0;
    final oldCritical = prefs.getInt('critical') ?? 0;
    final oldDeaths = prefs.getInt('deaths') ?? 0;

    if (oldConfirmed != 0) {
      data.newConfirmed = data.confirmed - oldConfirmed;
    } else {
      data.newConfirmed = 0;
    }

    if (oldRecovered != 0) {
      data.newRecovered = data.recovered - oldRecovered;
    } else {
      data.newRecovered = 0;
    }

    if (oldCritical != 0) {
      data.newCritcal = data.critical - oldCritical;
    } else {
      data.newCritcal = 0;
    }

    if (oldDeaths != 0) {
      data.newDeaths = data.deaths - oldDeaths;
    } else {
      data.newDeaths = 0;
    }

    prefs.setInt('confirmed', data.confirmed);
    prefs.setInt('recovered', data.recovered);
    prefs.setInt('critical', data.critical);
    prefs.setInt('deaths', data.deaths);
    return data;
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
          fontFamily: 'RobotoSlab'),
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
  Future<void> _getData() async {
    setState(() {
      fetchData(http.Client());
    });
  }

  Widget _ListTile(
      String iconPath, String name, String number, String newNumber) {
    return Card(
      child: Center(
        child: ListTile(
          title: Text(name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          leading: Image.asset(iconPath),
          trailing: RichText(
            text: TextSpan(
              text: '',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              children: <TextSpan>[
              TextSpan(
                text: number,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
              ),
              TextSpan(
                  text: ' +' + newNumber,
                  style: TextStyle(fontSize: 24, color: Colors.green))
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.grey[800],
        ),
        body: RefreshIndicator(
          onRefresh: _getData,
          child: FutureBuilder<CovidNumbers>(
            future: fetchData(http.Client()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: <Widget>[
                    Container(
                        height: 175,
                        child: _ListTile(
                            'assets/fever.png',
                            'Confirmed Cases',
                            snapshot.data.confirmed.toString(),
                            snapshot.data.newConfirmed.toString())),
                    Container(
                        height: 175,
                        child: _ListTile(
                            'assets/recovered.png',
                            'Recovered',
                            snapshot.data.recovered.toString(),
                            snapshot.data.newRecovered.toString())),
                    Container(
                        height: 175,
                        child: _ListTile(
                            'assets/death.png',
                            'Deaths',
                            snapshot.data.deaths.toString(),
                            snapshot.data.newDeaths.toString())),
                    Container(
                        height: 175,
                        child: _ListTile(
                            'assets/ventilator.png',
                            'Critical Condition',
                            snapshot.data.critical.toString(),
                            snapshot.data.newCritcal.toString()))
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CircularProgressIndicator();
            },
          ),
        ));
  }
}
