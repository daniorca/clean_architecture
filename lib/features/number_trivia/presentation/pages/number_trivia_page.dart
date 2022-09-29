import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(child: _buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider<NumberTriviaBloc>(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              // Top Half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                  builder: (context, triviaState) {
                if (triviaState is Empty) {
                  return MessageDisplay(
                    size: size,
                    message: 'Start searching!',
                  );
                } else if (triviaState is Loading) {
                  return LoadingWidget(size: size);
                } else if (triviaState is Loaded) {
                  return TriviaDisplay(
                      size: size, numberTrivia: triviaState.trivia);
                } else if (triviaState is Error) {
                  return MessageDisplay(
                    size: size,
                    message: triviaState.message,
                  );
                }
                return SizedBox();
              }),
              SizedBox(height: 20),
              //Bottom Half
              TriviaControls()
            ],
          ),
        ),
      ),
    );
  }
}
