
import 'package:chat_app/bloc/call/call_bloc.dart';
import 'package:chat_app/bloc/call/call_event.dart';
import 'package:chat_app/bloc/chat/chat_bloc.dart';
import 'package:chat_app/bloc/user/user_bloc.dart';
import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserBloc(UserService()),),
        BlocProvider(create: (context) => ChatBloc(api: ChatService(), socket: SocketService()),),
        BlocProvider(create: (context) => CallBloc()..add(InitializeCallEvent()),)
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AnimatedChatSplashScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}