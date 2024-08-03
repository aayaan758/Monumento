import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/presentation/popular_monuments/desktop/widgets/monument_details_card.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'monument_details_view_desktop.dart';

class PopularMonumentsViewDesktop extends StatefulWidget {
  const PopularMonumentsViewDesktop({super.key});

  @override
  State<PopularMonumentsViewDesktop> createState() =>
      _PopularMonumentsViewDesktopState();
}

class _PopularMonumentsViewDesktopState
    extends State<PopularMonumentsViewDesktop> {
  @override
  void initState() {
    locator<PopularMonumentsBloc>().add(GetPopularMonuments());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: ResponsiveVisibility(
          hiddenConditions: const [
            Condition.smallerThan(breakpoint: 800),
          ],
          child: AppBar(
            title: Text(
              'Popular Monuments',
              style: AppTextStyles.s18(
                color: AppColor.appSecondary,
                fontType: FontType.MEDIUM,
              ),
            ),
            backgroundColor: AppColor.appBackground,
            elevation: 1,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColor.appSecondary,
                ),
                onPressed: () {},
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<PopularMonumentsBloc, PopularMonumentsState>(
        bloc: locator<PopularMonumentsBloc>(),
        builder: (context, state) {
          if (state is LoadingPopularMonuments) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: AppColor.appPrimary,
              ),
            );
          } else if (state is PopularMonumentsRetrieved) {
            return GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
              itemCount: state.popularMonuments.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 400.w / 250.h,
              ),
              itemBuilder: (BuildContext context, int index) {
                return MonumentDetailsCard(
                  monument: state.popularMonuments[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) {
                          return MonumentDetailsViewDesktop(
                            monument: state.popularMonuments[index],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(
              child: Text(state.toString()),
            );
          }
        },
      ),
    );
  }
}