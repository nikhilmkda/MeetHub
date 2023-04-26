import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/image_provider.dart';
import '../service/auth_service.dart';
import '../widgets/widget.dart';
import 'auth/login_page.dart';
import 'homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final String currentuser = auth.currentUser!.uid;

class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;

  const ProfilePage({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // AuthService authService = AuthService();

  String? profilePicUrl;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profileProvider = ProfileProvider();
    AuthServiceProvider authService =
        Provider.of<AuthServiceProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
          StreamBuilder<DocumentSnapshot>(
            stream: profileProvider.getUserStream(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/userimage.png'),
                );
              }

              if (!snapshot.hasData) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/userimage.png'),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>?;

              if (data == null) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/userimage.png'),
                );
              }

              final profilePicUrl = data['profilePic'] as String?;

              return CircleAvatar(
                radius: 110,
                backgroundImage: profilePicUrl != null
                    ? NetworkImage(
                        profilePicUrl,
                      ) as ImageProvider<Object>?
                    : AssetImage('assets/userimage.png'),
              );
            },
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: () {
              nextScreen(context, const HomePage());
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Groups",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {},
            selected: true,
            selectedColor: Theme.of(context).primaryColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
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
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      )),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: profileProvider.getUserStream(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/userimage.png'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/userimage.png'),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;

                    if (data == null) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/userimage.png'),
                      );
                    }

                    final profilePicUrl = data['profilePic'] as String?;

                    return CircleAvatar(
                      radius: 120,
                      backgroundImage: profilePicUrl != null
                          ? NetworkImage(
                              profilePicUrl,
                            ) as ImageProvider<Object>?
                          : AssetImage('assets/userimage.png'),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: profileProvider.getImage),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Full Name", style: TextStyle(fontSize: 17)),
                Text(widget.userName, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email", style: TextStyle(fontSize: 17)),
                Text(widget.email, style: const TextStyle(fontSize: 17)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
