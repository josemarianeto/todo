import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/Item.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp();


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
       colorScheme: ColorScheme.fromSwatch(
         primarySwatch: Colors.blue,
         brightness: Brightness.dark,
       ).copyWith(
         secondary: Colors.deepPurple[400]  ,

       ),



      ),
      home: HomePage(),
    );
  }
}



class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage(){
    items = [];

  }


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var newTaskCtrl = TextEditingController();
  Future<void> add(){
    if(newTaskCtrl.text.isEmpty){
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Task Invalida'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[

                  Text('Toda Tarefa precisa ter um nome.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text,done: false));

    });
    newTaskCtrl.text = "";
    save();
  }

  void remove(int index){
    setState(() {
      widget.items.removeAt(index);
    });
    save();
  }

  Future load() async{
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null){
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();
      setState(() {
        widget.items = result;
      });
    }


  }
  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState(){
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (ctxt,index){
          final items = widget.items[index];
          return Dismissible( key:UniqueKey(), child: CheckboxListTile(title:Text(items.title),activeColor: Colors.deepPurple[400] ,checkColor: Colors.white,value: items.done,onChanged: (value) {
            setState(() {
              items.done = value;
            });
          }),
            background:
            Container(
              color: Colors.red.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text("Excluir  ",style: TextStyle(
                  fontSize: 22,
                ),),
              ),
          ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction){
              remove(index);
            },

          );
       },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
