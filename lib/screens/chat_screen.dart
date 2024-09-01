import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_flash/contrain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static const String id = 'chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final _Firestore = Firestore.instance ;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final messageTextController = TextEditingController();

   late User loggedInUser;

   @override
  void initState(){
    super.initState();
    getCurrentUser();
   }
  void getCurrentUser () async{
    try{
   final user = await _auth.currentUser;
     if(user != null){
      loggedInUser = user ;
     }}
        catch (e){
      print(e);
        }
  }
late String messageText;

  void getMessageStream () async{
   await for ( var snapshot in _firestore.collection('messages').snapshots()){
     for (var message in snapshot.docs){
       print(message.data);
    }

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
            getMessageStream();
                 // _auth.signOut();
                 // Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           MessagesStream(),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText =value ;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text' : messageText ,
                        'Sender' : loggedInUser.email ,
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context,snapshot)
        {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );

          }
          final message = snapshot.data.docs ;
          List <MessageBubble> messageBubble = [];
          for (var message in messages){
            final messageText = message.data ['text'] ;
            final messageSender =message.data ['Sender'];
            final messageBubble = MessageBubble(Sender: messageSender, text: messageText);
            messageBubble.add(messageBubble);
          }
          return Expanded(
            child: ListView (
              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
              children: messageBubble ,
            ),
          );

        }
    ),;
  }
}


 class MessageBubble extends StatelessWidget {
   // const MessageBubble({super.key});
   String Sender ;
   String text ;
   MessageBubble({required this.Sender,required this.text});
 
   @override
   Widget build(BuildContext context) {
     return Padding(
       padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),

       child: Column(
         crossAxisAlignment: CrossAxisAlignment.end,
         children: [
           Text(Sender,style: TextStyle(
             fontSize: 12.0,
             color: Colors.black45,
           ),),
           Material(
             borderRadius: BorderRadius.circular(30.0),
                elevation: 5.0 ,
             color: Colors.lightBlueAccent,
             child: Text(text ,
             style: TextStyle(
               fontSize: 15,
               color: Colors.white,

             ),),
           ),
         ],
       ),
     );;
   }
 }
 