import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartdingdong/constants/app_themes.dart';
import 'package:smartdingdong/models/user_model.dart';
import 'package:smartdingdong/provider/auth_provider.dart';
import 'package:smartdingdong/ui/widgets/touchable_opacity.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreen createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return StreamBuilder(
      stream: authProvider.user,
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        final UserModel currentUser = snapshot.data;
        return Scaffold(
          backgroundColor: AppThemes.lightBackgroundColor,
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      color: Colors.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              TouchableOpacity(
                                onTap: () {
                                  _close(context);
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: ShapeDecoration(
                                    shape: CircleBorder(),
                                    color: Color(0xFFCBCBCB),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.xmark,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TouchableOpacity(
                      onTap: () {
                        // _presentUserProfile();
                        // await authProvider.signOut();
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: currentUser != null &&
                                    currentUser.photoURL != null
                                ? NetworkImage(
                                    'https://images.unsplash.com/photo-1457449940276-e8deed18bfff?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8cHJvZmlsZXxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80')
                                : AssetImage(
                                    'assets/images/user_profile.png',
                                  ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Text(currentUser.displayName),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _close(BuildContext context) {
    Navigator.pop(context);
  }
}
