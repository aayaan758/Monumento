import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/presentation/profile_screen/mobile/user_connections_screen.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/profile_tabs_view.dart';
import 'package:monumento/presentation/settings/mobile/settings_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class ProfileScreenMobile extends StatefulWidget {
  const ProfileScreenMobile({super.key});

  @override
  State<ProfileScreenMobile> createState() => _ProfileScreenMobileState();
}

class _ProfileScreenMobileState extends State<ProfileScreenMobile>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppColor.appBackground,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/mobile/logo_profile.svg',
                  height: 25,
                  width: 161,
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColor.appBlack)),
                    IconButton(
                        onPressed: () {
                          SettingsBottomSheet().settingsBottomSheet(context);
                        },
                        icon: const Icon(Icons.settings_outlined,
                            color: AppColor.appBlack)),
                  ],
                )
              ],
            )),
        body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            bloc: locator<AuthenticationBloc>(),
            builder: (context, state) {
              state as Authenticated;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        state.user.profilePictureUrl ??
                                            defaultProfilePicture,
                                      )),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _tabController.animateTo(0);
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              state.user.posts.length
                                                  .toString(),
                                              style: AppTextStyles.s18(
                                                color: AppColor.appBlack,
                                                fontType: FontType.SEMI_BOLD,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text("Posts",
                                                style: AppTextStyles.s12(
                                                  color: AppColor.appGrey,
                                                  fontType: FontType.MEDIUM,
                                                )),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const UserConnectionsScreen(
                                                      index: 0,
                                                    )),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              state.user.followers.length
                                                  .toString(),
                                              style: AppTextStyles.s18(
                                                color: AppColor.appBlack,
                                                fontType: FontType.SEMI_BOLD,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text("Followers",
                                                style: AppTextStyles.s12(
                                                  color: AppColor.appGrey,
                                                  fontType: FontType.MEDIUM,
                                                )),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const UserConnectionsScreen(
                                                      index: 1,
                                                    )),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              state.user.following.length
                                                  .toString(),
                                              style: AppTextStyles.s18(
                                                color: AppColor.appBlack,
                                                fontType: FontType.SEMI_BOLD,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text("Following",
                                                style: AppTextStyles.s12(
                                                  color: AppColor.appGrey,
                                                  fontType: FontType.MEDIUM,
                                                )),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ]),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              state.user.name,
                              style: AppTextStyles.s16(
                                color: AppColor.appBlack,
                                fontType: FontType.MEDIUM,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              '@${state.user.username}',
                              style: AppTextStyles.s12(
                                color: AppColor.appLightGrey,
                                fontType: FontType.REGULAR,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              state.user.status,
                              style: AppTextStyles.s12(
                                color: AppColor.appGrey,
                                fontType: FontType.REGULAR,
                              ),
                            ),
                          ],
                        )),
                    const Divider(thickness: 2),
                    ProfileTabsView(
                      tabController: _tabController,
                    )
                  ],
                ),
              );
            }));
  }

// TODO: when implementing followUser and bookmark functionality
  Widget getFollowButton(FollowState state, UserEntity currentUser) {
    if (state is FollowStatusRetrieved) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .06,
        child: TextButton(
          onPressed: () {
            state.following
                ? locator<FollowBloc>().add(UnfollowUser(targetUser: currentUser))
                : locator<FollowBloc>().add(FollowUser(targetUser: currentUser));
          },
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.amberAccent)),
          child: Text(
            state.following ? 'Unfollow' : 'Follow',
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
    }
    if (state is LoadingFollowState) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .06,
        child: TextButton(
          onPressed: () {},
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.amberAccent)),
          child: SizedBox(
              height: MediaQuery.of(context).size.height * .03,
              width: MediaQuery.of(context).size.height * .03,
              child: const CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 3,
              )),
        ),
      );
    }
    return Container();
  }
}