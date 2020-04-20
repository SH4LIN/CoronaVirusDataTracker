import 'dart:collection';
import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'MoreData.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());
List<dynamic> states = List();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Display(),
      title: "COVID-19",
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}

class Display extends StatefulWidget {
  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        children: [
          Explore(),
          Home(),
          Overview(),
        ],
        controller: _tabController,
      ),
      appBar: new AppBar(
        title: Align(
            alignment: Alignment.center,
            child: Text(
              "COVID-19 Data Tracker",
            )),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        brightness: Brightness.dark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorPadding: EdgeInsets.all(40),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
          tabs: <Widget>[Text("Explore"),Text("Home"), Text("Overview")],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future _loadTotalCases() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get("https://api.covid19india.org/data.json");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        isLoading = false;
      });
      return data;
    }
  }

  Future data;
  bool isLoading = false;
  @override
  void initState() {
    data = _loadTotalCases();
    super.initState();
  }

  final RefreshController _refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SmartRefresher(
            controller: _refreshController,
            onRefresh: () async {
              _loadTotalCases();
              isLoading
                  ? _refreshController.refreshToIdle()
                  : _refreshController.refreshCompleted();
            },
            child: ListView(
              children: <Widget>[
                Container(
                  height: 200,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(4),
                  child: Card(
                    elevation: 20.0,
                    color: Colors.blueAccent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "TOTAL CONFIRMED",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var total = snapshot.data["statewise"];
                              var totalCases;
                              var deltaConfirmed;
                              total.forEach((f) {
                                if (f["statecode"].compareTo("TT") == 0) {
                                  totalCases = f["confirmed"];
                                  deltaConfirmed = f["deltaconfirmed"];
                                }
                              });
                              return Column(
                                children: <Widget>[
                                  Text(
                                    totalCases,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "[+" + deltaConfirmed.toString() + "]",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: data,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(4),
                  child: Card(
                    elevation: 20.0,
                    color: Colors.purple,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "TOTAL ACTIVE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var total = snapshot.data["statewise"];
                              var totalActive;
                              total.forEach((f) {
                                if (f["statecode"].compareTo("TT") == 0) {
                                  totalActive = f["active"];
                                }
                              });
                              return Text(
                                totalActive,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: data,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(4),
                  child: Card(
                    elevation: 20.0,
                    color: Colors.green,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "TOTAL RECOVERED",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var total = snapshot.data["statewise"];
                              var totalRecovered;
                              var deltaRecovered;
                              total.forEach((f) {
                                if (f["statecode"].compareTo("TT") == 0) {
                                  totalRecovered = f["recovered"];
                                  deltaRecovered = f["deltarecovered"];
                                }
                              });
                              return Column(
                                children: <Widget>[
                                  Text(
                                    totalRecovered,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "[+" + deltaRecovered + "]",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: data,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(4),
                  child: Card(
                    elevation: 20.0,
                    color: Colors.red,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "TOTAL DECEASED",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var total = snapshot.data["statewise"];
                              var totalDeaths;
                              var deltaDeceased;
                              total.forEach((f) {
                                if (f["statecode"].compareTo("TT") == 0) {
                                  totalDeaths = f["deaths"];
                                  deltaDeceased = f["deltadeaths"];
                                }
                              });
                              return Column(
                                children: <Widget>[
                                  Text(
                                    totalDeaths,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "[+" + deltaDeceased + "]",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: data,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(4),
                  child: Card(
                    elevation: 20.0,
                    color: Colors.white,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Text(
                              "Developed By SH4LIN",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black),
                            ),
                          ),
                        ]),
                  ),
                )
              ],
            ),
          );
  }
}

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
//  HashMap<String, dynamic> map;
  List<dynamic> states = List();
  List<dynamic> activeCases = List();
  List<dynamic> confirmed = List();
  List<dynamic> deaths = List();
  List<dynamic> recovered = List();
  List<dynamic> list = List();
  List<dynamic> dailydeceased = List();
  List<dynamic> totalrecovered = List();
  List<dynamic> totaldeceased = List();
  List<dynamic> submittedReport = List();
  List<dynamic> positiveReport = List();
  List<dynamic> testedDate = List();
  List<dynamic> date = List();
  var isLoading = false;
  List<StateWise> barchartList = List();
  List<subVsPos> barchartList1 = List();
  @override
  void initState() {
    _fetchOverviewData();
    super.initState();
  }

  _fetchOverviewData() async {
    states.clear();
    activeCases.clear();
    confirmed.clear();
    deaths.clear();
    recovered.clear();
    dailydeceased.clear();
    date.clear();
    totalrecovered.clear();
    totaldeceased.clear();
    submittedReport.clear();
    positiveReport.clear();
    setState(() {
      isLoading = true;
    });
    final response = await http.get("https://api.covid19india.org/data.json");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var statewiselist = data["statewise"] as List;
      statewiselist.forEach((f) {
        states.add(f["state"]);
        activeCases.add(double.parse(f["active"]));
        confirmed.add(double.parse(f["confirmed"]));
        deaths.add(double.parse(f["deaths"]));
        recovered.add(double.parse(f["recovered"]));
      });
      var cases_time_serieslist = data["cases_time_series"] as List;
      cases_time_serieslist.forEach((f) {
        dailydeceased.add(int.parse(f["dailydeceased"]));
        date.add(f["date"]);
        totalrecovered.add(double.parse(f["totalrecovered"]));
        totaldeceased.add(double.parse(f["totaldeceased"]));
      });
      var tested = data["tested"] as List;
      print(tested);
      tested.forEach((f) {
        submittedReport.add(f["totalsamplestested"] == ""
            ? 0
            : num.parse(f["totalsamplestested"].replaceAll(',', '')));
        positiveReport.add(f["totalpositivecases"] == ""
            ? 0
            : num.parse(f["totalpositivecases"].replaceAll(',', '')));
        testedDate.add(f["updatetimestamp"]);
      });
      int count = 1;
      if (submittedReport.length > 10) {
        while (count < 5) {
          barchartList1.add(subVsPos(
              testedDate.elementAt(testedDate.length - count),
              submittedReport.elementAt(submittedReport.length - count),
              positiveReport.elementAt(positiveReport.length - count)));
          count++;
        }
      }
      count = 1;
      if (dailydeceased.length > 10) {
        while (count <= 10) {
          barchartList.add(StateWise(
              dailydeceased.elementAt(dailydeceased.length - count),
              date.elementAt(date.length - count)));
          count++;
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception("Failed to Load Data");
    }
  }

  Widget showBarChart() {
    List<charts.Series<StateWise, String>> series = [
      charts.Series(
        id: "Daily Deaths",
        data: barchartList,
        domainFn: (StateWise series, _) => series.date,
        displayName: "Daily Deceased People",
        fillColorFn: (StateWise series, _) =>
            charts.ColorUtil.fromDartColor(Colors.red),
        outsideLabelStyleAccessorFn: (StateWise series, _) =>
            charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Colors.white)),
        insideLabelStyleAccessorFn: (StateWise series, _) =>
            charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Colors.white)),
        fillPatternFn: (StateWise series, _) => charts.FillPatternType.solid,
        overlaySeries: true,
        measureFn: (StateWise series, _) => series.deceased,
      )
    ];
    return charts.BarChart(
      series,
      animate: true,
      animationDuration: Duration(seconds: 2),
      primaryMeasureAxis: charts.NumericAxisSpec(
        showAxisLine: true,
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.white)),
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
        ),
      ),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
            tickLengthPx: 2,
            labelRotation: 45,
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.white),
              fontSize: 8,
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.white),
            ),
            minimumPaddingBetweenLabelsPx: 10),
      ),
    );
  }

  Widget showBarChart1() {
    List<charts.Series<subVsPos, String>> series = [
      charts.Series(
        id: "Positive Report",
        data: barchartList1,
        domainFn: (subVsPos series, _) => series.date,
        displayName: "Positive Report",
        fillColorFn: (subVsPos series, _) =>
            charts.ColorUtil.fromDartColor(Colors.red),
        outsideLabelStyleAccessorFn: (subVsPos series, _) =>
            charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Colors.white)),
        insideLabelStyleAccessorFn: (subVsPos series, _) =>
            charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Colors.white)),
        fillPatternFn: (subVsPos series, _) => charts.FillPatternType.solid,
        overlaySeries: true,
        measureFn: (subVsPos series, _) => series.posReport,
      ),
      charts.Series(
        id: "Submitted Report",
        data: barchartList1,
        domainFn: (subVsPos series, _) => series.date,
        displayName: "Submitted Report",
        fillColorFn: (subVsPos series, _) =>
            charts.ColorUtil.fromDartColor(Colors.tealAccent),
        outsideLabelStyleAccessorFn: (subVsPos series, _) =>
            charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Colors.white)),
        insideLabelStyleAccessorFn: (subVsPos series, _) =>
            charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Colors.white)),
        fillPatternFn: (subVsPos series, _) => charts.FillPatternType.solid,
        overlaySeries: true,
        measureFn: (subVsPos series, _) => series.reportSubmitted,
      ),
    ];
    return charts.BarChart(
      series,
      animate: true,
      barGroupingType: charts.BarGroupingType.grouped,
      animationDuration: Duration(seconds: 2),
      primaryMeasureAxis: charts.NumericAxisSpec(
        showAxisLine: true,
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.white)),
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
        ),
      ),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
            tickLengthPx: 2,
            labelRotation: 50,
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.white),
              fontSize: 8,
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Colors.white),
            ),
            minimumPaddingBetweenLabelsPx: 10),
      ),
    );
  }

  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  List<CircularStackEntry> getData() {
    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(confirmed.first, Colors.blueAccent,
              rankKey: 'Confirmed'),
          new CircularSegmentEntry(activeCases.first, Colors.purple,
              rankKey: 'Active'),
          new CircularSegmentEntry(recovered.first, Colors.green,
              rankKey: 'Recovered'),
          new CircularSegmentEntry(deaths.first, Colors.red, rankKey: 'Deaths'),
        ],
        rankKey: 'COVID-19 AFFECTED',
      ),
    ];
    return data;
  }

  final RefreshController _refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            physics: AlwaysScrollableScrollPhysics(),
            onRefresh: () async {
              _fetchOverviewData();
              isLoading
                  ? _refreshController.refreshToIdle()
                  : _refreshController.refreshCompleted();
            },
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  child: Card(
                    elevation: 20.0,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.blueAccent[200],
                              radius: 8,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Confirmed : " + confirmed.first.toString()),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.purple,
                              radius: 8,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Active : " + activeCases.first.toString()),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 8,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Recovered : " + recovered.first.toString()),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 8,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Deaths : " + deaths.first.toString()),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        AnimatedCircularChart(
                          key: _chartKey,
                          size: const Size(180.0, 180.0),
                          duration: Duration(seconds: 2),
                          initialChartData: getData(),
                          chartType: CircularChartType.Pie,
                        ),
                        Text("COVID-19 Affected Count")
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(4),
                  height: 400,
                  child: Card(
                    borderOnForeground: true,
                    child: Column(
                      children: <Widget>[
                        Expanded(child: showBarChart()),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Deceased")
                      ],
                    ),
                    elevation: 20.0,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(4),
                  height: 500,
                  child: Card(
                    borderOnForeground: true,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.tealAccent,
                              radius: 8,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Reported Cases"),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 8,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Positive Cases"),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Expanded(child: showBarChart1()),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Reports Submitted Vs Positive Report")
                      ],
                    ),
                    elevation: 20.0,
                  ),
                ),
              ],
            ));
  }
}

class StateWise {
  final deceased;
  final date;
  StateWise(this.deceased, this.date);
}

class subVsPos {
  final date;
  final reportSubmitted;
  final posReport;
  subVsPos(this.date, this.reportSubmitted, this.posReport);
}

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<dynamic> activeCases = List();
  List<dynamic> confirmed = List();
  List<dynamic> deaths = List();
  List<dynamic> recovered = List();
  List<dynamic> deltaConfirmed = List();
  List<dynamic> deltaDeaths = List();
  List<dynamic> deltaRecovered = List();
  HashMap confirmedCasesMap = HashMap<String, int>();
  HashMap activeCasesMap = HashMap<String, int>();
  HashMap recoveredCasesMap = HashMap<String, int>();
  HashMap deathsMap = HashMap<String, int>();
  HashMap deltaConfirmedMap = HashMap<String, int>();
  HashMap deltaRecoveredMap = HashMap<String, int>();
  HashMap deltaDeathsMap = HashMap<String, int>();
  bool isLoading = false;
  bool sort = false;
  int sortingDataType;
  bool asc = true;
  LinkedHashMap sortedState;
  LinkedHashMap sortedConfirmed;
  LinkedHashMap sortedActive;
  LinkedHashMap sortedRecovered;
  LinkedHashMap sortedDeaths;
  LinkedHashMap sortedDeltaConfirmed;
  LinkedHashMap sortedDeltaRecovered;
  LinkedHashMap sortedDeltaDeaths;

  void _fetchExploreData() async {
    states.clear();
    activeCases.clear();
    confirmed.clear();
    deaths.clear();
    recovered.clear();
    deltaConfirmed.clear();
    deltaRecovered.clear();
    deltaDeaths.clear();
    confirmedCasesMap.clear();
    activeCasesMap.clear();
    recoveredCasesMap.clear();
    deathsMap.clear();
    deltaConfirmedMap.clear();
    deltaRecoveredMap.clear();
    deltaDeaths.clear();
    setState(() {
      isLoading = true;
    });
    final response = await http.get("https://api.covid19india.org/data.json");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var statewiselist = data["statewise"] as List;
      print("Total: " + statewiselist.length.toString());
      statewiselist.forEach((f) {
        if (f["statecode"].compareTo("TT") != 0) {
          confirmedCasesMap[f["state"]] = int.parse(f["confirmed"]);
          activeCasesMap[f["state"]] = int.parse(f["active"]);
          recoveredCasesMap[f["state"]] = int.parse(f["recovered"]);
          deathsMap[f["state"]] = int.parse(f["deaths"]);
          deltaConfirmedMap[f["state"]] = int.parse(f["deltaconfirmed"]);
          deltaRecoveredMap[f["state"]] = int.parse(f["deltarecovered"]);
          deltaDeathsMap[f["state"]] = int.parse(f["deltadeaths"]);
        }
      });
      if (sort) {
        _sortData();
      } else {
        states = confirmedCasesMap.keys.toList();
        confirmed = confirmedCasesMap.values.toList();
        activeCases = activeCasesMap.values.toList();
        recovered = recoveredCasesMap.values.toList();
        deaths = deathsMap.values.toList();
        deltaConfirmed = deltaConfirmedMap.values.toList();
        deltaRecovered = deltaRecoveredMap.values.toList();
        deltaDeaths = deltaDeathsMap.values.toList();
      }
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception("Failed to Load Data");
    }
  }

  void _sortData() {
    if (asc) {
      switch (sortingDataType) {
        case 1:
          var sortedkeys = confirmedCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              return k1.toString().compareTo(k2.toString());
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 2:
          var sortedkeys = confirmedCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(confirmedCasesMap[k1] > confirmedCasesMap[k2]){
                return 1;
              }
              else if(confirmedCasesMap[k1] < confirmedCasesMap[k2]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 3:
          var sortedkeys = activeCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(activeCasesMap[k1] > activeCasesMap[k2]){
                return 1;
              }
              else if(activeCasesMap[k1] < activeCasesMap[k2]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 4:
          var sortedkeys = recoveredCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(recoveredCasesMap[k1] > recoveredCasesMap[k2]){
                return 1;
              }
              else if(recoveredCasesMap[k1] < recoveredCasesMap[k2]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 5:
          var sortedkeys = deathsMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(deathsMap[k1] > deathsMap[k2]){
                return 1;
              }
              else if(deathsMap[k1] < deathsMap[k2]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
      }
    } else {
      switch (sortingDataType) {
        case 1:
          var sortedkeys = confirmedCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              return k2.toString().compareTo(k1.toString());
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 2:
          var sortedkeys = confirmedCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(confirmedCasesMap[k2] > confirmedCasesMap[k1]){
                return 1;
              }
              else if(confirmedCasesMap[k2] < confirmedCasesMap[k1]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 3:
          var sortedkeys = activeCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(activeCasesMap[k2] > activeCasesMap[k1]){
                return 1;
              }
              else if(activeCasesMap[k2] < activeCasesMap[k1]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 4:
          var sortedkeys = recoveredCasesMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(recoveredCasesMap[k2] > recoveredCasesMap[k1]){
                return 1;
              }
              else if(recoveredCasesMap[k2] < recoveredCasesMap[k1]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
        case 5:
          var sortedkeys = deathsMap.keys.toList(growable: false)
            ..sort((k1, k2) {
              if(deathsMap[k2] > deathsMap[k1]){
                return 1;
              }
              else if(deathsMap[k2] < deathsMap[k1]){
                return -1;
              }
              else{
                return 0;
              }
            });
          sortedState = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => k);
          sortedConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => confirmedCasesMap[k]);
          sortedActive = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => activeCasesMap[k]);
          sortedRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => recoveredCasesMap[k]);
          sortedDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deathsMap[k]);
          sortedDeltaConfirmed = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaConfirmedMap[k]);
          sortedDeltaRecovered = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaRecoveredMap[k]);
          sortedDeltaDeaths = new LinkedHashMap.fromIterable(sortedkeys,
              key: (k) => k, value: (k) => deltaDeathsMap[k]);
          break;
      }
    }
    states = sortedState.values.toList();
    confirmed = sortedConfirmed.values.toList();
    activeCases = sortedActive.values.toList();
    recovered = sortedRecovered.values.toList();
    deaths = sortedDeaths.values.toList();
    deltaConfirmed = sortedDeltaConfirmed.values.toList();
    deltaRecovered = sortedDeltaRecovered.values.toList();
    deltaDeaths = sortedDeltaDeaths.values.toList();
  }

  @override
  void initState() {
    _fetchExploreData();
    super.initState();
  }

  final RefreshController _refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                physics: AlwaysScrollableScrollPhysics(),
                onRefresh: () async {
                  _fetchExploreData();
                  isLoading
                      ? _refreshController.refreshToIdle()
                      : _refreshController.refreshCompleted();
                },
                child: ListView.builder(
                    primary: true,
                    scrollDirection: Axis.vertical,
                    itemCount: states.length,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? Column(
                              children: <Widget>[
                                Card(
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.all(8),
                                    child: Table(
                                      children: [
                                        TableRow(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = true;
                                                  sortingDataType = 1;
                                                  asc = !asc;
                                                });
                                                _fetchExploreData();
                                              },
                                              child: Center(
                                                child: Container(
                                                    child:
                                                        Wrap(children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      Text(
                                                        "State",
                                                        softWrap: true,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                      Icon(asc?Icons.arrow_drop_up:Icons.arrow_drop_down,color: sortingDataType == 1?Colors.black:Colors.grey,)
                                                    ],
                                                  )
                                                ])),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = true;
                                                  sortingDataType = 2;
                                                  asc = !asc;
                                                });
                                                _fetchExploreData();
                                              },
                                              child: Center(
                                                child: Container(
                                                    child:
                                                        Wrap(children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      Text(
                                                        "Confirmed",
                                                        softWrap: true,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                      Icon(asc?Icons.arrow_drop_up:Icons.arrow_drop_down,color: sortingDataType == 2?Colors.black:Colors.grey,)
                                                    ],
                                                  )
                                                ])),
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    sort = true;
                                                    sortingDataType = 3;
                                                    asc = !asc;
                                                  });
                                                  _fetchExploreData();
                                                },
                                                child: Center(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                  "Active",
                                                  softWrap: true,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                        Icon(asc?Icons.arrow_drop_up:Icons.arrow_drop_down,color: sortingDataType == 3?Colors.black:Colors.grey,)
                                                      ],
                                                    ))),
                                            GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    sort = true;
                                                    sortingDataType = 4;
                                                    asc = !asc;
                                                  });
                                                  _fetchExploreData();
                                                },
                                                child: Center(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                  "Recovered",
                                                  softWrap: true,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                        Icon(asc?Icons.arrow_drop_up:Icons.arrow_drop_down,color: sortingDataType == 4?Colors.black:Colors.grey,)
                                                      ],
                                                    ))),
                                            GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    sort = true;
                                                    sortingDataType = 5;
                                                    asc = !asc;
                                                  });
                                                  _fetchExploreData();
                                                },
                                                child: Center(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                  "Deaths",
                                                  softWrap: true,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                        Icon(asc?Icons.arrow_drop_up:Icons.arrow_drop_down,color: sortingDataType == 5?Colors.black:Colors.grey,)
                                                      ],
                                                    )))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _furtherData(index),
                                  child: Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 8),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Table(
                                        children: [
                                          TableRow(children: <Widget>[
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Center(
                                                    child:
                                                        Wrap(children: <Widget>[
                                                  Text(
                                                    states.elementAt(index),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ]))),
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Wrap(children: <Widget>[
                                                  Center(
                                                    child: deltaConfirmed
                                                                .elementAt(
                                                                    index) !=
                                                            0
                                                        ? Column(
                                                            children: <Widget>[
                                                              Text(
                                                                confirmed
                                                                    .elementAt(
                                                                        index)
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                "[+" +
                                                                    deltaConfirmed
                                                                        .elementAt(
                                                                            index)
                                                                        .toString() +
                                                                    "]",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                            .red[
                                                                        300]),
                                                              ),
                                                            ],
                                                          )
                                                        : Text(
                                                            confirmed
                                                                .elementAt(
                                                                    index)
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                  ),
                                                ])),
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Center(
                                                    child: Text(
                                                  activeCases
                                                      .elementAt(index)
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ))),
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Center(
                                                  child: deltaRecovered
                                                              .elementAt(
                                                                  index) !=
                                                          0
                                                      ? Column(
                                                          children: <Widget>[
                                                            Text(
                                                              recovered
                                                                  .elementAt(
                                                                      index)
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Text(
                                                              "[+" +
                                                                  deltaRecovered
                                                                      .elementAt(
                                                                          index)
                                                                      .toString() +
                                                                  "]",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                          .green[
                                                                      300]),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(
                                                          recovered
                                                              .elementAt(index)
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                )),
                                            TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Center(
                                                    child: deltaDeaths
                                                                .elementAt(
                                                                    index) !=
                                                            0
                                                        ? Column(
                                                            children: <Widget>[
                                                              Text(
                                                                deaths
                                                                    .elementAt(
                                                                        index)
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                "[+" +
                                                                    deltaDeaths
                                                                        .elementAt(
                                                                            index)
                                                                        .toString() +
                                                                    "]",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                            .red[
                                                                        300]),
                                                              ),
                                                            ],
                                                          )
                                                        : Text(
                                                            deaths
                                                                .elementAt(
                                                                    index)
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ))),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : GestureDetector(
                              onTap: () => _furtherData(index),
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 8),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Table(
                                    children: [
                                      TableRow(children: <Widget>[
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                                child: Wrap(children: <Widget>[
                                              Text(
                                                states.elementAt(index),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              )
                                            ]))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Wrap(children: <Widget>[
                                              Center(
                                                child: deltaConfirmed
                                                            .elementAt(index) !=
                                                        0
                                                    ? Column(
                                                        children: <Widget>[
                                                          Text(
                                                            confirmed
                                                                .elementAt(
                                                                    index)
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            "[+" +
                                                                deltaConfirmed
                                                                    .elementAt(
                                                                        index)
                                                                    .toString() +
                                                                "]",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .red[300]),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        confirmed
                                                            .elementAt(index)
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                              ),
                                            ])),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                                child: Text(
                                              activeCases
                                                  .elementAt(index)
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                                child: deltaRecovered
                                                            .elementAt(index) !=
                                                        0
                                                    ? Column(
                                                        children: <Widget>[
                                                          Text(
                                                            recovered
                                                                .elementAt(
                                                                    index)
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            "[+" +
                                                                deltaRecovered
                                                                    .elementAt(
                                                                        index)
                                                                    .toString() +
                                                                "]",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                        .green[
                                                                    300]),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        recovered
                                                            .elementAt(index)
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                                child: deltaDeaths
                                                            .elementAt(index) !=
                                                        0
                                                    ? Column(
                                                        children: <Widget>[
                                                          Text(
                                                            deaths
                                                                .elementAt(
                                                                    index)
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            "[+" +
                                                                deltaDeaths
                                                                    .elementAt(
                                                                        index)
                                                                    .toString() +
                                                                "]",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .red[300]),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        deaths
                                                            .elementAt(index)
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ))),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
                            );
                    }),
              ));
  }

  _furtherData(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoreData(index)),
    );
  }
}
