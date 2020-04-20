import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

class MoreData extends StatelessWidget {
  int index;
  MoreData(this.index);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DisplayData(index),
      appBar: new AppBar(
        title: Align(
            alignment: Alignment.center,
            child: Text(
              "COVID-19 Data Tracker",
            )),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        brightness: Brightness.dark,
      ),
    );
  }
}

class DisplayData extends StatefulWidget {
  int index;
  DisplayData(this.index);
  @override
  _DisplayDataState createState() => _DisplayDataState(index);
}

class _DisplayDataState extends State<DisplayData> {
  int index;
  _DisplayDataState(this.index);
  List<dynamic> district = List();
  List<dynamic> confirmedCases = List();
  List<dynamic> deltaConfirmed = List();
  HashMap districtDataMap = HashMap<String, int>();
  LinkedHashMap sortedMap;
  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  bool isLoading = false;
  bool isAvailable = true;
  var state;
  void _fetchData() async {
    district.clear();
    confirmedCases.clear();
    deltaConfirmed.clear();
    districtDataMap.clear();
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get("https://api.covid19india.org/state_district_wise.json");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      state = states.elementAt(index);
      if (data[state] == null) {
        setState(() {
          isAvailable = false;
        });
      } else {
        setState(() {
          isAvailable = true;
        });
        var stateDistrictwiselist = data[state]["districtData"];
        stateDistrictwiselist.forEach((f, e) {
          districtDataMap[f] = e["confirmed"];
        });
        //Sort Type TRUE = ASCENDING
        //Sort Type FALSE = DESCENDING
        if(sort){
          if (sortAlpha) {
            if (sortType) {
              var sortedKeys = districtDataMap.keys.toList(growable: false)
                ..sort((k1, k2) {
                  return k1.compareTo(k2);
                });
              sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
                  key: (k) => k, value: (k) => districtDataMap[k]);
              district = sortedMap.keys.toList();
              confirmedCases = sortedMap.values.toList();
              district.forEach((f) {
                deltaConfirmed.add(stateDistrictwiselist[f]["delta"]["confirmed"]);
              });
            } else {
              var sortedKeys = districtDataMap.keys.toList(growable: false)
                ..sort((k1, k2) {
                  return k2.compareTo(k1);
                });
              sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
                  key: (k) => k, value: (k) => districtDataMap[k]);
              district = sortedMap.keys.toList();
              confirmedCases = sortedMap.values.toList();
              district.forEach((f) {
                deltaConfirmed.add(stateDistrictwiselist[f]["delta"]["confirmed"]);
              });
            }
          } else {
            if (sortType) {
              var sortedKeys = districtDataMap.keys.toList(growable: false)
                ..sort((k1, k2) {
                  return districtDataMap[k1].compareTo(districtDataMap[k2]);
                });
              sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
                  key: (k) => k, value: (k) => districtDataMap[k]);
              district = sortedMap.keys.toList();
              confirmedCases = sortedMap.values.toList();
              district.forEach((f) {
                deltaConfirmed.add(stateDistrictwiselist[f]["delta"]["confirmed"]);
              });
            } else {
              var sortedKeys = districtDataMap.keys.toList(growable: false)
                ..sort((k1, k2) {
                  return districtDataMap[k2].compareTo(districtDataMap[k1]);
                });
              sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
                  key: (k) => k, value: (k) => districtDataMap[k]);
              district = sortedMap.keys.toList();
              confirmedCases = sortedMap.values.toList();
              district.forEach((f) {
                deltaConfirmed.add(stateDistrictwiselist[f]["delta"]["confirmed"]);
              });
            }
          }
        }
        else{
          district = districtDataMap.keys.toList();
          confirmedCases = districtDataMap.values.toList();
          district.forEach((f) {
            deltaConfirmed.add(stateDistrictwiselist[f]["delta"]["confirmed"]);
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception("Failed to Load Data");
    }
  }

  final RefreshController _refreshController = RefreshController();
  bool sortAlpha = true;
  bool sort = false;
  bool sortType = true;
  @override
  Widget build(BuildContext context) {
    return isAvailable
        ? isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                physics: AlwaysScrollableScrollPhysics(),
                onRefresh: () async {
                  _fetchData();
                  isLoading
                      ? _refreshController.refreshToIdle()
                      : _refreshController.refreshCompleted();
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return index == 0
                        ? Column(
                            children: <Widget>[
                              Card(
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(4),
                                  child: Table(
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                                child: Text(
                                              state,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                      ])
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(10),
                                  child: Table(
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    sortAlpha = true;
                                                    sort = true;
                                                    sortType = !sortType;
                                                  });
                                                  _fetchData();
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Center(
                                                        child: Text("District",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))),
                                                    Icon(sortType?Icons.arrow_drop_up:Icons.arrow_drop_down,color: sortAlpha?Colors.black:Colors.grey,)
                                                  ],
                                                ))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sortAlpha = false;
                                                  sort = true;
                                                  sortType = !sortType;
                                                });
                                                _fetchData();
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Center(
                                                      child: Text(
                                                    "Confirmed Cases",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold),
                                                  )),Icon(sortType?Icons.arrow_drop_up:Icons.arrow_drop_down,color: sortAlpha?Colors.grey:Colors.black,)
                                                ],
                                              ),
                                            )),
                                      ])
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Table(
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                                child: Text(district
                                                    .elementAt(index)))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                              child: deltaConfirmed
                                                          .elementAt(index) !=
                                                      0
                                                  ? Center(
                                                      child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(confirmedCases
                                                            .elementAt(index)
                                                            .toString()),
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
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      ],
                                                    ))
                                                  : Text(confirmedCases
                                                      .elementAt(index)
                                                      .toString()),
                                            )),
                                      ])
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Card(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Table(
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Center(
                                            child: Wrap(children: <Widget>[
                                          Text(
                                            district.elementAt(index),
                                            textAlign: TextAlign.center,
                                          )
                                        ]))),
                                    TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Center(
                                          child: deltaConfirmed
                                                      .elementAt(index) !=
                                                  0
                                              ? Center(
                                                  child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(confirmedCases
                                                        .elementAt(index)
                                                        .toString()),
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
                                                            color: Colors.red))
                                                  ],
                                                ))
                                              : Text(confirmedCases
                                                  .elementAt(index)
                                                  .toString()),
                                        )),
                                  ])
                                ],
                              ),
                            ),
                          );
                  },
                  itemCount: district.length,
                ))
        : Center(child: Text("No Recoed Available"));
  }
}
