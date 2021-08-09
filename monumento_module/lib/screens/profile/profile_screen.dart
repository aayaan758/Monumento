import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/follow/follow_bloc.dart';
import 'package:monumento/blocs/profile/profile_bloc.dart';
import 'package:monumento/blocs/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/constants.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/models/post_model.dart';

class ProfileScreen extends StatefulWidget {
  static final String route = "/profileScreen";
  final UserModel user;

  const ProfileScreen({@required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfilePostsBloc _profilePostsBloc;
  FollowBloc _followBloc;
  AuthenticationBloc _authBloc;
  UserModel currentUser;

  @override
  void initState() {
    _profilePostsBloc = BlocProvider.of<ProfilePostsBloc>(context);
    _profilePostsBloc.add(LoadInitialProfilePosts(uid: widget.user.uid));
    _followBloc = BlocProvider.of<FollowBloc>(context);
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    currentUser = (_authBloc.state as Authenticated).user;
    _followBloc.add(
        GetFollowStatus(targetUser: widget.user, currentUser: currentUser));

    super.initState();
  }

  List<PostModel> posts = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LazyLoadScrollView(
              scrollOffset: 300,
              onEndOfPage: () {
                _profilePostsBloc.add(LoadMoreProfilePosts(
                    startAfterDoc: posts.last.documentSnapshot,
                    uid: widget.user.uid));
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height * .15 / 2),
                          child: widget.user.profilePictureUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.user.profilePictureUrl,
                                  height:
                                      MediaQuery.of(context).size.height * .15,
                                  placeholder: (_, text) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .15,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              .15,
                                    );
                                  },
                                )
                              : Image.asset("assets/explore.jpg"),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(widget.user.name,style: kStyle16W600,),
                        SizedBox(
                          height: 8,
                        ),
                        Text('@${widget.user.email.split("@")[0]}'), //TODO : username
                        SizedBox(
                          height: 16,
                        ),
                        BlocBuilder<FollowBloc, FollowState>(
                          bloc: _followBloc,
                          builder: (context, state) {
                            return getFollowButton(state);
                          },
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 16,
                    ),
                  ),
                  BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
                    bloc: _profilePostsBloc,
                    builder: (context, currentState) {
                      if (currentState is InitialProfilePostsLoadingFailed) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(currentState.message),
                          ),
                        );
                      }

                      if (currentState is InitialProfilePostsLoaded ||
                          currentState is MoreProfilePostsLoaded ||
                          currentState is LoadingMoreProfilePosts ||
                          currentState is MoreProfilePostsLoadingFailed) {
                        if (currentState is InitialProfilePostsLoaded) {
                          posts.insertAll(
                              posts.length, currentState.initialPosts);
                        }
                        if (currentState is MoreProfilePostsLoaded) {
                          posts.insertAll(posts.length, currentState.posts);
                        }
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate((_, index) {
                            return ClipRRect(
                              child: CachedNetworkImage(
                                  imageUrl: posts[index].imageUrl),
                              borderRadius: BorderRadius.circular(5),
                            );
                          }, childCount: posts.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8),
                        );
                      }
                      return SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget getFollowButton(FollowState state) {
    if (state is FollowStatusRetrieved) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .06,
        child: TextButton(
          onPressed: () {
            state.following
                ? _followBloc.add(UnfollowUser(
                    currentUser: currentUser, targetUser: widget.user))
                : _followBloc.add(FollowUser(
                    currentUser: currentUser, targetUser: widget.user));
          },
          child: Text(
            state.following ? 'Unfollow' : 'Follow',
            style: TextStyle(color: Colors.black),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.amberAccent)),
        ),
      );
    }
    if (state is LoadingFollowState) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .06,
        child: TextButton(
          onPressed: () {},
          child: SizedBox(
              height: MediaQuery.of(context).size.height * .03,
              width: MediaQuery.of(context).size.height * .03,
              child: CircularProgressIndicator(

                backgroundColor: Colors.white,
                strokeWidth: 3,
              )),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.amberAccent)),
        ),
      );
    }
    if (state is CurrentUserProfile) {
      return Container();
    }
    return Container();
  }
}