import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

import './helpers/db_helper.dart';
import './models/result.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _form = GlobalKey<FormState>();
  var name;
  var marks;
  var _storedImage;
  List<Result> _results = [];

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 700,
    );
    setState(() {
      _storedImage = File(imageFile!.path);
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile!.path);
    final savedImage =
        await File(imageFile.path).copy('${appDir.path}/$fileName');
  }

  void _saveForm() {
    _form.currentState!.save();
    addMarks();
    fetchAndSetMarks();
  }

  Future<void> addMarks() async {
    await DBHelper.insert('exam_results', {
      'id': DateTime.now().toString(),
      'name': name,
      'marks': marks,
      'image': _storedImage.path,
    });
  }

  Future<void> fetchAndSetMarks() async {
    final dataList = await DBHelper.getData('exam_results');
    setState(() {
      _results = dataList.map((item) {
        return Result(
          id: item['id'],
          name: item['name'],
          marks: (item['marks']).toString(),
          image: File(item['image']),
        );
      }).toList();
    });
  }

  Future<void> deleteItem() async {
    await DBHelper.delete('exam_results', 'name');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('2.0 practice native'),
        actions: [
          TextButton(
              child: Text(
                'Clear Database',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: deleteItem)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet<dynamic>(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Form(
                  key: _form,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Enter Name'),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          onSaved: (newValue) {
                            setState(() {
                              name = newValue.toString();
                            });
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Enter Marks'),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          onSaved: (newValue) {
                            setState(() {
                              marks = newValue.toString();
                            });
                          },
                        ),
                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 100,
                              width: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: _storedImage == null
                                  ? Text(
                                      'Image not taken',
                                      textAlign: TextAlign.center,
                                    )
                                  : Image.file(_storedImage, fit: BoxFit.cover, ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: Icon(Icons.photo),
                              label: Text('Take Photo'),
                              onPressed: _takePicture,
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen,
                          ),
                          icon: Icon(Icons.save),
                          label: Text('Submit My Marks !'),
                          onPressed: () {
                            _saveForm();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      body: FutureBuilder(
        future: fetchAndSetMarks(),
        builder: (context, snapshot) => SingleChildScrollView(
          child: Column(
            children: [
              ...(_results.map(
                (item) {
                  return Column(
                    children: [
                      Card(
                        elevation: 10,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 50,
                            child: Image.file(
                              height: 100,
                              width: 100,
                              item.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text('NAME: ${item.name.toUpperCase()}'),
                          subtitle: Text(
                            'MARKS: ${item.marks.toString()}',
                          ),
                          // trailing: IconButton(icon: Icon(Icons.delete), onPressed: deleteItem)
                        ),
                      ),
                    ],
                  );
                },
              ).toList()),
            ],
          ),
        ),
      ),
    );
  }
}
