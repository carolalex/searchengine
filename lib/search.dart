import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Jobs extends StatefulWidget {
  Jobs() : super();

  @override
  JobsState createState() => JobsState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class JobsState extends State<Jobs> {
  final _debouncer = Debouncer();

  List<Subject> ulist = [];
  List<Subject> userLists = [];

  // API call for Brand List
  String url = 'http://3.110.165.54:5005/api/v1/brands/best_deals?customerId';

  Future<List<Subject>> getAllBrandList() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<Subject> list = parseBrands(response.body);
        return list;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static List<Subject> parseBrands(String responseBody) {
    final parsed =
        json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
    return parsed.map<Subject>((json) => Subject.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    getAllBrandList().then((brandList) {
      setState(() {
        ulist = brandList;
        userLists = ulist;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Brand List',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Search Bar for Brand List
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                suffixIcon: InkWell(
                  child: Icon(Icons.search),
                ),
                contentPadding: EdgeInsets.all(15.0),
                hintText: 'Search Brand',
              ),
              onChanged: (string) {
                _debouncer.run(() {
                  setState(() {
                    userLists = ulist
                        .where(
                          (u) => (u.advertiserName.toLowerCase().contains(
                                string.toLowerCase(),
                              )),
                        )
                        .toList();
                  });
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.all(5),
              itemCount: userLists.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            userLists[index].advertiserName,
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            userLists[index].advertiserCategory,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Subject {
  String id;
  String brandId;
  String network;
  String advertiserName;
  String advertiserUrl;
  String shoppistCategory;
  List<String> keywords;
  String advertiserCategory;

  Subject({
    required this.id,
    required this.brandId,
    required this.network,
    required this.advertiserName,
    required this.advertiserUrl,
    required this.shoppistCategory,
    required this.keywords,
    required this.advertiserCategory,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'],
      brandId: json['brandId'],
      network: json['network'],
      advertiserName: json['advertiserName'],
      advertiserUrl: json['advertiserUrl'],
      shoppistCategory: json['shoppistCategory'],
      keywords: List<String>.from(json['keywords']),
      advertiserCategory: json['advertiserCategory'],
    );
  }
}
