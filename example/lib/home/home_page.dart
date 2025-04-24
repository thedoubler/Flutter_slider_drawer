import 'package:example/home/widget/author_list.dart';
import 'package:example/model/menu.dart';
import 'package:flutter/material.dart';

import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  late String title;

  final List<Menu> _menuItems = [
    Menu(Icons.home, 'Home'),
    Menu(Icons.add_circle, 'Add Post'),
    Menu(Icons.notifications_active, 'Notification'),
    Menu(Icons.favorite, 'Likes'),
    Menu(Icons.settings, 'Setting'),
  ];

  @override
  void initState() {
    title = "Home";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SliderDrawer(
        key: _sliderDrawerKey,
        isDraggable: false,
        appBar: SliderAppBar(
          config: SliderAppBarConfig(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        sliderOpenSize: MediaQuery.sizeOf(context).width * 0.75,
        sliderItems: _menuItems
            .map(
              (e) => MenuItem(
                title: e.title,
                iconData: e.iconData,
                onTap: (val) {
                  _sliderDrawerKey.currentState?.closeSlider();
                  print(val);
                },
              ),
            )
            .toList(),
        sliderTrailingItem: MenuItem(
          title: 'LogOut',
          iconData: Icons.arrow_back_ios,
          onTap: (val) {
            _sliderDrawerKey.currentState?.closeSlider();
            print('Logout');
          },
        ),
        child: const AuthorList(),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Function(String)? onTap;

  const MenuItem({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      leading: Icon(iconData, color: Colors.black),
      onTap: () => onTap?.call(title),
    );
  }
}
