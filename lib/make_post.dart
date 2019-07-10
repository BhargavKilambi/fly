import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MakepostScreen extends StatefulWidget {
  @override
  _MakepostScreenState createState() => _MakepostScreenState();
}

class _MakepostScreenState extends State<MakepostScreen> {

File postImage;
bool readyForUpload = false;
TextEditingController _tec = new TextEditingController();
String postTitle = '';
bool beingUploaded = false;
@override
void initState(){
  super.initState();
}

Future getImage() async{
  File temp;
  temp = await ImagePicker.pickImage(source:ImageSource.gallery,maxHeight: 1080,maxWidth: 1080,);
  setState(() {
   postImage = temp; 
  });
}

void uploadPost() async{

  setState(() {
      beingUploaded = true;
    });
  
  FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
  String fileName = DateTime.now().toIso8601String() + '.jpg';
  final StorageReference stRef = FirebaseStorage.instance.ref().child('posts').child(fileName);
  final DocumentReference dRef = Firestore().collection('user').document(fUser.uid).collection('posts').document();
  final StorageUploadTask task = stRef.putFile(postImage);
  StorageTaskSnapshot taskSnapshot = await task.onComplete;
  String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    dRef.setData({
        'title':postTitle,
        'url':downloadUrl
    }).then((onValue){
      print('Upload Complete!');
      setState(() {
       beingUploaded = false; 
      });
      Navigator.of(context).pop();
    });


}

Widget build(BuildContext context){
  final _height = MediaQuery.of(context).size.height;
  final _width = MediaQuery.of(context).size.width;
  return SafeArea(
    child: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Post it!',
        backgroundColor: (postImage == null || postTitle == '') ? Colors.grey.withOpacity(0.5) : Colors.black87,
        child: Icon(Icons.add_a_photo,
        color: (postImage == null || postTitle == '') ? Colors.black26 : Colors.white,
        ),
        onPressed: (){
          if(!(postImage == null || postTitle == '')) uploadPost();
        } ,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black87
        ),
        centerTitle: true,
        title: Text('Add a Post',style: TextStyle(color: Colors.black87),),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                (postImage == null ?
                Container(
                  margin: EdgeInsets.all(_height * 0.02),
                  height: _height * 0.4,
                  width: _height * 0.4,
                  color: Colors.black.withOpacity(0.08),
                  child: MaterialButton(
                    child: Icon(Icons.add,size: 30,color: Colors.black54,),
                    onPressed: getImage,
                  ),
                ) :
                Container(
                  margin: EdgeInsets.all(_height * 0.02),
                  height: _height * 0.4,
                  width: _height * 0.4,
                  color: Colors.black.withOpacity(0.08),
                  child: Image.file(postImage,fit: BoxFit.cover,),
                )),
                Container(
                  width: _width * 0.6,
                  child: TextField(
                    controller: _tec,
                    onChanged: (text){
                      print(_tec.text);
                      postTitle = _tec.text;
                    },
                  )
                )
              ],
            )
          ),
          ( beingUploaded == true ? Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            )
          ) : Center()),
        ],
      ),
      ),
  );
}

}