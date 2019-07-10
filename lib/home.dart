import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './make_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseUser fUser;
  int cIndex = 2;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String accountState = 'no';
  DocumentReference userRef;

  void initState() {
    super.initState();
    getFirebaseUser();
  }

  signOut() {
    _auth.signOut();
  }

  getFirebaseUser() async {
    FirebaseUser user = await _auth.currentUser();
    setState(() {
      fUser = user;
      accountState = "yes";
      userRef = Firestore().collection('user').document(user.uid);
    });
  }

  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 2,
        length: 3,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black87,
            child: Icon(Icons.arrow_back),
            onPressed: signOut,
          ),
          body: TabBarView(
            children: <Widget>[
              homeTab(),
              Tab(
                child: Icon(Icons.memory),
              ),
              profileTab()
            ],
          ),
          bottomNavigationBar: TabBar(
            labelPadding: EdgeInsets.all(7),
            indicatorColor: Colors.black45,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: <Widget>[
              Icon(
                Icons.whatshot,
                color: Colors.black,
              ),
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.black,
              ),
              Icon(
                Icons.person_outline,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget homeTab() {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Center(
          child: Column(
        children: <Widget>[
          Container(
            height: _height * 0.05,
            padding: EdgeInsets.all(_height*0.005),
            child: Text('Fly',style: TextStyle(fontSize: 20,letterSpacing: 3),),
          ),
          Container(
            height: _height * 0.85,
            child: userRef == null ? Center(
              child: CircularProgressIndicator(),
            ) : FutureBuilder(
              future: userRef.collection('posts').getDocuments(),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  QuerySnapshot qs = snapshot.data;
                  print(qs.documents[0]['title']);
                  return ListView.builder(itemCount: qs.documents.length,
                  itemBuilder: (context,index){
                    return _post(qs.documents[index]['url'],qs.documents[index]['title']);
                  },
                  );
                }else{
                  return Center(child: 
                  CircularProgressIndicator(),);
                }
              },
            )
          ),
        ],
      ),
    );
  }

  Widget _post(String url,String title) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    return Container(
        height: _height * 0.75,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: <Widget>[
            Container(
              height: _height * 0.8,
              width: _width * 0.9,
              margin: EdgeInsets.only(bottom: _height * 0.01),
              decoration: BoxDecoration(
                  color: Colors.black12
                  ),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/loader.gif',
                image: url,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: _height * 0.15,
              width: _width * 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.00)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                )
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(accountState == 'no' ? '' : fUser.photoUrl),
                      ),
                      SizedBox(
                        width: _width * 0.033,
                      ),
                      Text(accountState == 'no' ? '' : fUser.displayName,style: TextStyle(color: Colors.white),),
                      
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: _width * 0.05,top: _height * 0.02),
                    child: Text(title,style: TextStyle(color: Colors.white,fontFamily: 'Arial',fontWeight: FontWeight.w100),)),
                ],
              ),
            )
          ],
        ));
  }

  Widget profileTab() {
    final _height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              profileImage(),
              Text(
                accountState == 'no' ? 'Loading...' : fUser.displayName,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                child: Container(
                  color: Colors.black26,
                  height: 1,
                  margin: EdgeInsets.symmetric(vertical: 4),
                ),
                height: 9,
                width: MediaQuery.of(context).size.width * 0.9,
              ),
              Container(
            child:RaisedButton(
              color: Colors.black87,
              child: Row(
                children: <Widget>[
                  Text('Add Post'),
                  Icon(Icons.add)
                ],
              ),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => MakepostScreen() )
                );
              },
            )
          ),
          Container(
            height: _height * 0.63,
            child: 
            userRef == null ? Container(
                height: 40,
                child: CircularProgressIndicator(),
              )
             : 
            FutureBuilder(
              future: userRef.collection('posts').getDocuments(),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  QuerySnapshot qs = snapshot.data;
                  print(qs.documents.length);
                  return gb(qs);
                }else{
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }
              },
            ),
          )
            ],
          )
    );
  } 

  Widget gb(QuerySnapshot qs){
    final _height = MediaQuery.of(context).size.height;
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(qs.documents.length,(index){
        return Container(
          height: _height * 0.2,
          width: _height * 0.2,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(width: 1,color: Colors.black12),
          ),
          child: FadeInImage.assetNetwork(
            image: qs.documents[index]['url'],
            placeholder: 'assets/images/loader.gif',
            fadeInDuration: Duration(milliseconds:500),
          )
          //child: Image.network(qs.documents[index]['url'],fit: BoxFit.cover,),
        );
      })
    );
  }

  CircleAvatar profileImage() {
    return CircleAvatar(
      backgroundImage: NetworkImage(
          accountState == 'no'
              ? "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png"
              : fUser.photoUrl,
          scale: 1.0),
      backgroundColor: Colors.black12,
    );
  }
}
