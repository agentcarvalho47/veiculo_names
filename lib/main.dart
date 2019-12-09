import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final dummySnapshot = [
  {"marca": "Nissan", "votes": 0, "modelo": "Skyline"},
  {"marca": "Chevrolet", "votes": 0, "modelo": "Camaro"},
  {"marca": "Renault", "votes": 0, "modelo": "Sandero"},
];

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Veículo Names',
      home: MyHomePage(),      
    );
  }
}

class MyHomePage extends StatefulWidget{
  @override
  _MyHomePageState createState(){
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage>{
  @override
  Widget build(BuildContext){
    return Scaffold(
      appBar: AppBar(title: Text('Votos para Veículos')),
      body: _buildBody(context),
    );
  }
  Widget _buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('veiculo').snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData) return LinearProgressIndicator();
        
        return _buildList(context, snapshot.data.documents);
      },
    );
  }
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),      
    );
  }
  Widget _buildListItem(BuildContext context, DocumentSnapshot data){
    final record = Record.fromSnapshot(data);
    return Padding(
      key: ValueKey(record.modelo),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.modelo),
          subtitle: Text(record.marca),
          trailing: Text(record.votes.toString()),
          onTap: () => record.reference.updateData({'votes': FieldValue.increment(1)}),
        ),
      ),
    );
  }
}

class Record{
  final String marca;
  final int votes;
  final String modelo;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['marca'] != null),
        assert(map['votes'] != null),
        assert(map['modelo'] != null),
        marca = map['marca'],
        votes = map['votes'],
        modelo = map['modelo'];
  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
  @override
  String toString() => "Record<$marca:$votes:$modelo>";          
}