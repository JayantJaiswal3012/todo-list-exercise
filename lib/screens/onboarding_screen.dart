import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:todo_list/screens/todo_list.dart';

import '../constants.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => TodoList(title: Const.TODO_LIST_TITLE)),
    );
  }

  Widget _buildFullscrenImage() {
    return Image.asset(
      'assets/sorting.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset(
      'assets/$assetName',
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 22.0, color: Colors.black87),
      bodyTextStyle: TextStyle(fontSize: 20.0, color: Colors.black87),
      pageColor: Colors.black12,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Welcome to Clear",
          body: "Tap or swipe to begin.",
          image: _buildImage('any.jpg'),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
            bodyTextStyle: TextStyle(fontSize: 20.0, color: Colors.black87),
            pageColor: Colors.black12,
            descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          ),
        ),
        PageViewModel(
            title: "Clear sorts items by priority.",
            body: "Important items are highlighted at the top....",
            image: _buildImage('sorting.png'),
            decoration: pageDecoration),
        PageViewModel(
            title: "Tap and hold to pick an item up.",
            body: "Drag it up or down to change its priority.",
            image: _buildImage('tapnhold.png'),
            decoration: pageDecoration),
        PageViewModel(
            title: "",
            body: "There are three navigation levels...",
            image: _buildImage('levels.png'),
            decoration: pageDecoration),
        PageViewModel(
            title: "",
            body:
                "Pinch together vertically to collapse your current level and navigate up.",
            image: _buildImage('pinch.png'),
            decoration: pageDecoration),
        PageViewModel(
            title: "",
            body:
                "Tap on a list to see its content.\nTap on a list title to edit it....",
            image: _buildImage('list.png'),
            decoration: pageDecoration),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text('Skip', style: TextStyle(color: Colors.black87)),
      next: Icon(Icons.arrow_forward, color: Colors.black87),
      done: Text('Done',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      curve: Curves.fastLinearToSlowEaseIn,
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.black26,
        activeColor: Colors.black54,
        activeSize: Size(10.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
