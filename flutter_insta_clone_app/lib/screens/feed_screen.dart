import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta_clone_app/models/firestore/post_model.dart';
import 'package:flutter_insta_clone_app/repo/post_network_repository.dart';
import 'package:flutter_insta_clone_app/widgets/my_progress_indicator.dart';
import 'package:flutter_insta_clone_app/widgets/post.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  final List<dynamic> followings;

  const FeedScreen(
    this.followings, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<PostModel>>.value(
      value: postNetworkRepository.fetchPostFromAllFollowers(followings),
      child: Consumer<List<PostModel>>(
        builder: (BuildContext context, List<PostModel> posts, Widget child) {
          if (posts == null || posts.isEmpty) {
            return MyProgressIndicator();
          } else {
            return Scaffold(
              appBar: CupertinoNavigationBar(
                leading: IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.black87,
                  ),
                ),
                middle: Text(
                  'instagram',
                  style: TextStyle(fontFamily: 'VeganStyle', color: Colors.black87),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                        icon: ImageIcon(
                          AssetImage('assets/images/actionbar_camera.png'),
                          color: Colors.black87,
                        ),
                        onPressed: () {}),
                    IconButton(
                        icon: ImageIcon(
                          AssetImage('assets/images/direct_message.png'),
                          color: Colors.black87,
                        ),
                        onPressed: () {})
                  ],
                ),
              ),
              body: ListView.builder(
                itemBuilder: (context, index) => feedListBuilder(context, posts[index]),
                itemCount: posts.length,
              ),
            );
          }
        },
      ),
    );
  }

  Widget feedListBuilder(BuildContext context, PostModel postModel) {
    return Post(postModel);
  }
}
