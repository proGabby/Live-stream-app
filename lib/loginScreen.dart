import 'package:agora_live_streaming/pages/home_page.dart';
import 'package:agora_live_streaming/provider/auth_provider.dart';
import 'package:agora_live_streaming/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void onSubmit() async {
    if (_emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        _passwordController.text.isEmpty) {
      return;
    }
    try {
      await ref
          .read(authProvider)
          .userLogin(_emailController.text, _passwordController.text);
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => HomePage())));
    } catch (e) {
      showMessage(context, 'error occur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: 'Enter your Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      hintText: 'Enter Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                ),
                SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  color: Colors.blue,
                  height: 50,
                  onPressed: onSubmit,
                  minWidth: 100,
                  child: const Text('Login'),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )),
      ),
    );
  }
}
