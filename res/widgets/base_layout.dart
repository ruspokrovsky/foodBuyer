import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class BaseLayout extends StatelessWidget {
  final bool isAppBar;
  final bool isBottomNav;
  final bool isFloatingContainer;
  final String? appBarTitle;
  final String? appBarSubTitle;
  final String? avatarUrl;
  final Widget flexibleContainerChild;
  final Widget flexibleSpaceBarTitle;
  final List<Widget> slivers;
  final List<Widget>? actions;
  final bool isProgress;
  final bool? isMiniPrgress;
  final bool? isPinned;
  final bool? isFloating;
  final Function onWillPop;
  final double? expandedHeight;
  final double? collapsedHeight;
  final double? radiusCircular;
  final Color? flexContainerColor;
  final int? bottomBarSelectedIndex;
  final Function? bottomBarTap;
  final Widget? floatingContainer;
  final Widget? titleContainer;
  final List<BottomNavigationBarItem>? bottomNavigationBarItems;
  final VoidCallback? avatarTap;

  const BaseLayout({super.key,
  required this.onWillPop,
  required this.isAppBar,
  required this.isBottomNav,
  required this.isFloatingContainer,
  this.avatarUrl,
  this.appBarTitle,
  this.appBarSubTitle,
  required this.flexibleContainerChild,
  required this.flexibleSpaceBarTitle,
  required this.slivers,
  this.actions,
  required this.isProgress,
  this.isMiniPrgress,
  this.isPinned = true,
  this.isFloating = false,
  this.expandedHeight = 190.0,
  this.collapsedHeight,
  this.radiusCircular = 25.0,
  this.flexContainerColor,
  this.bottomBarSelectedIndex,
  this.bottomBarTap,
  this.floatingContainer,
  this.titleContainer,
  this.bottomNavigationBarItems,
  this.avatarTap,
  });

  @override
  Widget build(BuildContext context) {

    AppStyles styles = AppStyles.appStyle(context);

    List<Widget> sliverWidgets = [
      SliverAppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        snap: false,
        floating: isFloating!,
        pinned: isPinned!,
        expandedHeight: expandedHeight,
        collapsedHeight: collapsedHeight,
        elevation: 0.0,
        flexibleSpace: FlexibleSpaceBar.createSettings(

          currentExtent: 0.0,
          child: FlexibleSpaceBar(
            background: Container(
              //padding: EdgeInsets.only(top: 90),
              decoration: BoxDecoration(
                  color: styles.flexBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radiusCircular!),
                    bottomRight: Radius.circular(radiusCircular!),
                  )),
              child: flexibleContainerChild,
            ),
            title: flexibleSpaceBarTitle,
            centerTitle: true,
            titlePadding: EdgeInsets.zero,
          ),
        ),

      ), ...slivers
    ];


    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: Stack(
        children: [
          Scaffold(
            appBar: isAppBar ? AppBar(
                foregroundColor: Colors.white,

              title: titleContainer ?? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                      child: GestureDetector(
                        onTap: avatarTap,
                        child: CachedNetworkImg(
                            imageUrl: avatarUrl??'',
                            width: 43.0,
                            height: 43.0,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Column(
                    children: [
                      Text(
                        appBarTitle??'',
                        style: styles.appBarTitleTextStyle,
                      ),
                      Text(
                        appBarSubTitle??'',
                        style: styles.appBarSubTitleTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              actions: actions??[],
            ) : null,
            body: CustomScrollView(
              slivers: sliverWidgets,
            ),
            floatingActionButton: isFloatingContainer ? floatingContainer : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            bottomNavigationBar: isBottomNav ? BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              currentIndex: bottomBarSelectedIndex??0,
              showUnselectedLabels: true,
              unselectedItemColor: Colors.grey,
              selectedItemColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0.0,
              onTap: (int index) => bottomBarTap!(index),
              items: bottomNavigationBarItems??[],


            ) : null,
          ),

          if(isMiniPrgress??false)

            const ProgressMini(),

          if(isProgress)

            const ProgressDialog(),
        ],
      ),
    );
  }
}
