import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Size size;
  const LoadingWidget({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height / 3,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
