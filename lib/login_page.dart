import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String? _storedToken;

  final _mockUsers = {
    'usuario@email.com': '123456',
    'admin@weg.net': 'admin123',
  };

  Future<void> _simulateLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;

      if (_mockUsers[email] == password) {
        const seed = 'SEGURA';
        final raw = '$email:$password:$seed';
        final token = base64.encode(utf8.encode(raw));

        await _storage.write(key: 'token', value: token);
        setState(() => _storedToken = token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou senha inválidos')),
        );
      }
    }
  }

  Future<void> _loadToken() async {
    final token = await _storage.read(key: 'token');
    setState(() => _storedToken = token);
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'token');
    setState(() => _storedToken = null);
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Seguro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _storedToken != null
              ? Column(
                  children: [
                    const Icon(Icons.lock_open, size: 64, color: Color.fromARGB(255, 5, 22, 255)),
                    const SizedBox(height: 20),
                    Text(
                      'Token armazenado:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_storedToken!),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(Icons.lock, size: 64, color: Colors.deepPurple),
                      const SizedBox(height: 20),
                      Text(
                        'Acesse com segurança',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) => value != null &&
                                value.contains('@')
                            ? null
                            : 'Email inválido',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) =>
                            (value != null && value.isNotEmpty)
                                ? null
                                : 'Informe a senha',
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _simulateLogin,
                        icon: const Icon(Icons.login),
                        label: const Text('Entrar'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}