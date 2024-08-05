import 'package:flutter/material.dart';
import 'package:mobile_client/screens/home/home_view_model.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          // TODO. TableCalendar() widget
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('uid: ${viewModel.userUID()}'),
                Text('email: ${viewModel.userEmail()}'),
                Text('displayName: ${viewModel.userDisplayName()}'),
                _IdToken(viewModel: viewModel),
                ElevatedButton(
                  onPressed: () {
                    viewModel.signOut();
                  },
                  child: Text('로그아웃'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _IdToken extends StatelessWidget {
  final HomeViewModel viewModel;
  const _IdToken({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: viewModel.getIdToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Text('idToken: ${snapshot.data}');
        } else {
          return Text('idToken: Not available');
        }
      },
    );
  }
}
