import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sqllite/database/bd.dart';

class Principal extends StatefulWidget{
  const Principal ({Key? key}) : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  //All journals
List<Map<String, dynamic>> _lista = [];

//this function is used to fetch all data from the database
void _refreshTutorial() async{
  final data = await SqlDb.buscarTodos();
  setState(() {
    _lista = data;
  });
}

@override
void initState(){
  super.initState();
  _refreshTutorial();
}

final TextEditingController _titleController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();

void _showForm(int? id) async{
if (id != null){
final existingTutorial =
_lista.firstWhere((element) => element ['id'] == id);
_titleController.text = existingTutorial['title'];
_descriptionController.text = existingTutorial['description'];
}

showModalBottomSheet(
context: context,
elevation: 5,
isScrollControlled: true,
backgroundColor: Colors.white70,
builder: (_) =>
Container(
padding: EdgeInsets.only(
top: 15,
left: 15,
right: 15,
bottom: MediaQuery
    .of(context)
    .viewInsets
    .bottom + 120,
),

child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.end,
children: [
TextField(
controller: _titleController,
decoration: const InputDecoration(hintText: 'Description'),
),
const SizedBox(
  height: 10,
),
TextField(
  controller: _descriptionController,
  decoration: const InputDecoration(hintText: 'Description' ),
),
const SizedBox(
height: 20,
),
ElevatedButton(
onPressed:() async{
//salva novo tutorial
if (id == null){
await _addItem();
}
if (id != null){
  await _updateItem(id);
}

//limpar campos
_titleController.text = '';
_descriptionController.text = '';

//closer the bottom sheet
Navigator.of(context).pop();
} ,
child: Text(id == null ? 'Novo' : 'Alterar'),
)
],
),
));
}

//insert a new to the database
Future<void> _addItem() async{
  await SqlDb.insert(_titleController.text, _descriptionController.text);
  _refreshTutorial();
}
//update an existing
Future<void> _updateItem(int id) async {
  await SqlDb.atualizaItem(
  id, _titleController.text, _descriptionController.text);
  _refreshTutorial();
}
//delete an item
void _deleteItem(int id) async{
  await SqlDb.deleteItem(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  content: Text('')
));
  _refreshTutorial();
}
@override
  Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title:  const Text('APLICACAO COM SQLITE'),
      centerTitle: true,
      backgroundColor: Colors.orangeAccent,
    ),
    body: ListView.builder (
    itemCount: _lista.length,
  itemBuilder: (context, index) =>
  Card(
  color: Colors.orange[200],
  margin: const EdgeInsets.all(15),
  child: ListTile(
  title: Text(_lista[index]['title']),
  subtitle: Text(_lista[index]['description']),
  trailing: SizedBox(
  width: 100,
  child: Row(
  children: [
    IconButton(
    icon: const Icon(Icons.edit),
  onPressed: () => _showForm(_lista[index]['id']),
    ),
    IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _deleteItem(_lista[index]['id']),
    ),
  ],
  ),
  )),
    ),
  ),
  floatingActionButton: FloatingActionButton(
  child: const Icon(Icons.add),
  backgroundColor: Colors.orangeAccent,
  onPressed:  () => _showForm(null),
  ),
  );
}
}
