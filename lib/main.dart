// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, deprecated_member_use, avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AccountPage(),
    );
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Entre ou faça seu cadastro.',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    WidgetSpan(child: SizedBox(width: 30)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'LOGIN',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
                backgroundColor: Colors.purple,
                textColor: Colors.white,
              ),
              SizedBox(height: 10),
              CustomButton(
                text: 'CADASTRO',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroPage())),
                backgroundColor: Colors.white,
                textColor: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CadastroPage extends StatelessWidget {
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  Future<void> _cadastrar(BuildContext context) async {
    final cpf = _removeFormatting(cpfController.text);
    final nome = nomeController.text;
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    if (!_validarDados(context, cpf, senha, confirmarSenha)) return;

    try {
      final response = await _postCadastro(cpf, nome, senha);
      final responseData = json.decode(response.body);
      final message = response.statusCode == 200 ? responseData['message'] : 'Erro durante o cadastro: ${responseData['message']}';
      _showSnackBar(context, message);
    } catch (e) {
      print('Erro: $e');
      _showSnackBar(context, 'Cadastro não realizado: erro de conexão.');
    }
  }

  bool _validarDados(BuildContext context, String cpf, String senha, String confirmarSenha) {
    if (senha.length < 6) {
      _showSnackBar(context, 'A senha deve ter pelo menos 6 caracteres.');
      return false;
    }

    if (senha != confirmarSenha) {
      _showSnackBar(context, 'As senhas não coincidem.');
      return false;
    }

    if (!_validarCPF(cpf) && !_validarCNPJ(cpf)) {
      _showSnackBar(context, 'CPF ou CNPJ inválido.');
      return false;
    }

    return true;
  }

  Future<http.Response> _postCadastro(String cpf, String nome, String senha) {
    return http.post(Uri.parse('http://127.0.0.1:5000/cadastrar'), body: {
      'cpf': cpf,
      'nome': nome,
      'senha': senha,
    });
  }

  bool _validarCPF(String cpf) {
    cpf = _removeFormatting(cpf);

    if (cpf.length != 11 || RegExp(r'(\d)\1{10}').hasMatch(cpf)) return false;

    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digitoVerificador1 = resto < 2 ? 0 : 11 - resto;
    if (digitoVerificador1 != int.parse(cpf[9])) return false;

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    int digitoVerificador2 = resto < 2 ? 0 : 11 - resto;
    return digitoVerificador2 == int.parse(cpf[10]);
  }

  bool _validarCNPJ(String cnpj) {
    cnpj = _removeFormatting(cnpj);

    if (cnpj.length != 14 || RegExp(r'(\d)\1{13}').hasMatch(cnpj)) return false;

    int soma = 0;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * (5 - (i % 4));
    }
    int resto = soma % 11;
    int digitoVerificador1 = resto < 2 ? 0 : 11 - resto;
    if (digitoVerificador1 != int.parse(cnpj[12])) return false;

    soma = 0;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * (6 - (i % 4));
    }
    resto = soma % 11;
    int digitoVerificador2 = resto < 2 ? 0 : 11 - resto;
    return digitoVerificador2 == int.parse(cnpj[13]);
  }

  String _removeFormatting(String text) => text.replaceAll(RegExp(r'\D'), '');

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Cadastro Anunciante',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTextField('CPF ou CNPJ', Icons.confirmation_number, cpfController),
            _buildTextField('Nome Completo', Icons.person, nomeController),
            _buildTextField('Senha', Icons.lock, senhaController, obscureText: true),
            _buildTextField('Confirmar Senha', Icons.lock, confirmarSenhaController, obscureText: true),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _cadastrar(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text('Cadastrar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.purple),
        prefixIcon: Icon(icon, color: Colors.purple),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> _realizarLogin(BuildContext context) async {
    final String cpf = cpfController.text;
    final String senha = senhaController.text;

    try {
      final response = await http.post(Uri.parse('http://127.0.0.1:5000/login'), body: {'cpf': cpf, 'senha': senha});
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['authenticated']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Page(),
            settings: RouteSettings(arguments: cpf),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CPF ou senha incorretos.')));
      }
    } catch (e) {
      print('Erro: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro durante o login: erro de conexão.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTextField('CPF ou CNPJ', Icons.confirmation_number, cpfController),
            _buildTextField('Senha', Icons.lock, senhaController, obscureText: true),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _realizarLogin(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text('Entrar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.purple),
        prefixIcon: Icon(icon, color: Colors.purple),
      ),
    );
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Você entrou.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({required this.text, required this.onPressed, required this.backgroundColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16), backgroundColor: backgroundColor),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
    );
  }
}