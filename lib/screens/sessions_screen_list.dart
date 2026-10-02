import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/sessions_model.dart';
class SessionsScreenList extends StatefulWidget{
  const SessionsScreenList({super.key, required this.skillId});
  final int skillId;
  
  @override
  State<SessionsScreenList> createState()=> _SessionsScreenList();
}

class _SessionsScreenList extends State<SessionsScreenList>{
  List<SessionsModel> sessionStore = [];

  void _fetchData() async{ 
      var response = await AppApi.getWithParams('/session/', widget.skillId as String);
      Map<String, dynamic> json = jsonDecode(response.body);
      SessionsResponse store = SessionsResponse.fromJson(json);

      setState(() {
        sessionStore = store.data;
      });
  }

  @override
  void initState() {  
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return(
      Scaffold(
        appBar: AppBar(
          title: Text("Session"),
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
        ),
      )
    );
  }
}