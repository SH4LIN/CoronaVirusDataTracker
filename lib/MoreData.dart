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
  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  bool isLoading = false;
  var state;
  void _fetchData() async {
    district.clear();
    confirmedCases.clear();
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get("https://api.covid19india.org/state_district_wise.json");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      state = states.elementAt(index);
      var stateDistrictwiselist = data[state]["districtData"];
      stateDistrictwiselist.forEach((f, e) {
        district.add(f);
        confirmedCases.add(e["confirmed"]);
      });
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception("Failed to Load Data");
    }
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
    _fetchData();
    isLoading
    ? _refreshController.refreshToIdle()
        : _refreshController.refreshCompleted();
    },
    child:ListView.builder(
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
                                    TableCellVerticalAlignment.middle,
                                    child: Center(
                                        child: Text(state,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),))),
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
                                    TableCellVerticalAlignment.middle,
                                    child: Center(
                                        child: Text("District",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)))),
                                TableCell(
                                    verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                    child: Center(
                                        child: Text("Confirmed Cases",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),))),
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
                                          TableCellVerticalAlignment.middle,
                                      child: Center(
                                          child: Text(district.elementAt(index)))),
                                  TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Center(
                                          child: Text(confirmedCases
                                              .elementAt(index)
                                              .toString()))),
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
                                      child: Text(district.elementAt(index)))),
                              TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Center(
                                      child: Text(confirmedCases
                                          .elementAt(index)
                                          .toString()))),
                            ])
                          ],
                        ),
                      ),
                    );
            },
            itemCount: district.length,
          ));
  }
}
