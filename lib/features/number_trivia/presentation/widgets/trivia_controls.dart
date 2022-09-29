import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  String? inputStr;
  final controller = TextEditingController();
  late NumberTriviaBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<NumberTriviaBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //TextField
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'Input a number'),
          onChanged: (value) => inputStr = value,
          onSubmitted: (_) => dispatchConcrete(),
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                child: Text('Search'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: dispatchConcrete,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
                child: ElevatedButton(
                    child: Text('Get random trivia'),
                    onPressed: dispatchRandom)),
          ],
        )
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    bloc.add(GetTriviaForConcreteNumber(inputStr!));
  }

  void dispatchRandom() {
    bloc.add(GetTriviaForRandomNumber());
  }
}
