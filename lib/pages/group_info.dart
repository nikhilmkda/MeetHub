import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/database_service.dart';
import '../widgets/widget.dart';
import 'homepage.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo(
      {Key? key,
      required this.adminName,
      required this.groupName,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  Future<String?> getProfilePictureUrl(String uid) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(getId(uid));
    final userSnapshot = await userDoc.get();
    final userData = userSnapshot.data();
    if (userData != null && userData['profilePic'] != null) {
      return userData['profilePic'];
    } else {
      return null;
    }
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();
   // final ProfileProvider profileProvider = ProfileProvider();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Group Info"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Exit"),
                        content:
                            const Text("Are you sure you exit the group? "),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              DatabaseService(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .toggleGroupJoin(
                                      widget.groupId,
                                      getName(widget.adminName),
                                      widget.groupName)
                                  .whenComplete(() {
                                nextScreenReplace(context, const HomePage());
                              });
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: FutureBuilder(
                    future: databaseService.getadminDP(widget.groupId),
                    builder: (BuildContext context, AsyncSnapshot dpSnapshot) {
                      if (dpSnapshot.hasData) {
                        if (dpSnapshot.data.isEmpty) {
                          return CircleAvatar(
                            backgroundImage: AssetImage('assets/userimage.png'),
                          );
                        } else {
                          return CircleAvatar(
                            backgroundImage: NetworkImage(dpSnapshot.data),
                          );
                        }
                      } else {
                        return CircleAvatar(
                          backgroundImage: AssetImage('assets/userimage.png'),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Group: ${widget.groupName}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text("Admin: ${getName(widget.adminName)}")
                  ],
                )
              ],
            ),
          ),
          memberList(),
        ]),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: SizedBox(
                          height: 100,
                          child: ListTile(
                            leading: SizedBox(
                              width: 56,
                              child: FutureBuilder(
                                future: DatabaseService()
                                    .getmembersDP(widget.groupId, index),
                                builder: (BuildContext context,
                                    AsyncSnapshot dpSnapshot) {
                                  if (dpSnapshot.hasData) {
                                    if (dpSnapshot.data.isEmpty) {
                                      return CircleAvatar(
                                        backgroundImage:
                                            AssetImage('assets/userimage.png'),
                                      );
                                    } else {
                                      return CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(dpSnapshot.data),
                                      );
                                    }
                                  } else {
                                    return CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/userimage.png'),
                                    );
                                  }
                                },
                              ),
                            ),
                            title: Text(
                              getName(snapshot.data['members'][index]),
                            ),
                            subtitle: Text(
                                '${getId(snapshot.data['members'][index])}'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return Center(
                child: Text('No Members'),
              );
            }
          } else {
            return Center(
              child: Text('No Members'),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ));
        }
      },
    );
  }
}
