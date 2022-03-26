import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:log/ui/test.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Presentation/signin_bloc.dart';


class DashDesign extends StatefulWidget {
  const DashDesign({Key key}) : super(key: key);

  @override
  _DashDesignState createState() => _DashDesignState();
}

class _DashDesignState extends State<DashDesign> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List list = [];
  int documentLimit = 10;
  SigninBloc signinBloc;
  DocumentSnapshot lastDocument; // flag for last document from where next 10 records to be fetched

  Future<void> get() async {
    FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot querySnapshot) {
      list.clear();
      for(int i = 0; i< querySnapshot.docs.length; i++){
        setState(() {
          list.add(querySnapshot.docs[i].data());
        });
      }});
  }

  ScrollController controller = new ScrollController();
  int count = 0;
  String imageUrl;
  UploadTask task;
  File file;
  double delta;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
  }
  String basename1;

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  TextEditingController name = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController priceCont = TextEditingController();
  String path = "";
  final RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context, ) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter stateSetter)
          {
            return LoaderOverlay(
              child: AlertDialog(
                title: const Text(
                  "Upload Information",
                  style: TextStyle(color: Colors.blue),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 100,
                          child: TextFormField(
                            controller: name,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Name',
                              hintText: 'Enter name',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 100,
                          child: TextFormField(
                            controller: descriptionCont,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Description',
                              hintText: 'Enter Description',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 100,
                          child: TextFormField(
                            keyboardType: TextInputType.numberWithOptions(),
                            controller: priceCont,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Price',
                              hintText: 'Enter Price',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 70,
                        child: RaisedButton(
                          child: Text('Upload Image'),
                          color: Colors.lightBlue,
                          onPressed: () async {
                            ImagePicker imagePicker = ImagePicker();
                            final compressedImage = await imagePicker.getImage(
                              source: ImageSource.gallery,
                              imageQuality: 25,
                            );

                            if (compressedImage == null) return;
                            stateSetter(() {
                              path = compressedImage.path;
                              file = File(path);
                            });
                          },
                        ),
                      ),
                      path != "" ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                              onTap: () {
                                stateSetter(() {
                                  path = "";
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.cancel, color: Colors.red,),
                              )),
                          Expanded(child: Text(path != "" ? "$path" : "")),
                        ],
                      ) : Container(),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),
                          RaisedButton(
                            onPressed: () async {
                              context.loaderOverlay.show();
                              firebase_storage.FirebaseStorage storage =
                                  firebase_storage.FirebaseStorage.instance;
                              basename1 = basename(file.path);

                              try{
                                Reference ref = FirebaseStorage.instance.ref();
                                TaskSnapshot addImg =
                                    await ref.child("image/img${DateTime.now()}").putFile(file);
                                if (addImg.state == TaskState.success) {
                                  final String downloadUrl =
                                      await addImg.ref.getDownloadURL();
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .add({'name': "${name.text}", // John Doe
                                    'description': "${descriptionCont.text}", // Stokes and Sons
                                    'price': "${priceCont.text}",
                                    'image': downloadUrl});
                                }
                                else {
                                  print(
                                      'Error from image repo ${addImg.state.toString()}');
                                  throw ('This file is not an image');
                                }
                                context.loaderOverlay.hide();
                                Navigator.pop(context);
                                get();
                              }
                              catch(value){
                                print(value);
                              }
                              setState(() {
                                name.text = "";
                                descriptionCont.text = "";
                                priceCont.text = "";
                                path = "";
                              });
                            },
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Future _onRefresh() async {
    print("========================= Refresh called =====================");

    //sometimes location keeps on loading due to permission issue so make sure that refreshes stops itself after 6 seconds
    Future.delayed(
        Duration(seconds: 6), () => _refreshController.refreshCompleted());
    await get();

    _refreshController.refreshCompleted();
  }


  @override
  Widget build(BuildContext context) {
    delta = MediaQuery.of(context).size.height * 0.20;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => FirebaseImage()));
            },
            child: Row(
              children: [
                Text("Task"),
                Spacer(),
                GestureDetector(
                  onTap: () async* {
                    signinBloc?.add(LoggedOut());
                    Navigator.of(context).pushNamedAndRemoveUntil('/AuthMain', (Route<dynamic> route) => false);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.logout,size: 25,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Logout",style: TextStyle(fontSize: 18),),
                      )
                    ],
                  ),
                ),

              ],
            )),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(
          // begin: Alignment.topLeft,
          // end: Alignment.bottomRight,
          colors: [
            Color(0xFF7F00FF),
            Color(0xFFE100FF),
          ],
        )),
        child: SafeArea(
          child: list == null ? CircularProgressIndicator() : Column(
            children: [
              SmartRefresher(
                enablePullDown: true,
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView.builder(
                    controller: controller,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return list == null ?
                      Container() : ListTile(
                        leading: CircleAvatar(
                          maxRadius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                              list == null ? CircularProgressIndicator() : '${list[index]['image']}'
                          ),                ),
                        title: Text(list[index]['name']),
                        subtitle: Text(list[index]['description']),
                        trailing: Text("Rs. ${list[index]['price']}"),
                      );
                    }),
              ),
              GestureDetector(
                onTap: () async* {
                  signinBloc?.add(LoggedOut());
                  Navigator.of(context).pushNamedAndRemoveUntil('/AuthMain', (Route<dynamic> route) => false);
                },
                child: Row(
                  children: [
                    Icon(Icons.logout,size: 25,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Logout",style: TextStyle(fontSize: 18),),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showChoiceDialog(context);
          },
          child: Icon(Icons.add)),
    );
  }
}
