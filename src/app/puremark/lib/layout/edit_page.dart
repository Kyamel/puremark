import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends State<EditPage> {
  final TextEditingController _controller = TextEditingController();
  String _htmlContent = '';
  bool _isHtmlVisible = false; // Controla se o HTML está visível

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Renderizar HTML"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Caixa de entrada de texto para o HTML
              Expanded(
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _controller,
                    maxLines: null, // Permite múltiplas linhas
                    keyboardType: TextInputType.multiline, // Tipo de teclado para multiline
                    decoration: InputDecoration(
                      hintText: 'Digite seu HTML aqui...',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Atualiza o conteúdo HTML com o texto digitado
                    _htmlContent = _controller.text;
                    _isHtmlVisible = !_isHtmlVisible; // Alterna a visibilidade do HTML
                  });
                },
                child: Text(_isHtmlVisible ? 'Fechar HTML' : 'Renderizar HTML'),
              ),
            ],
          ),
          
          // Se o HTML estiver visível, exibe o popup lateral
          if (_isHtmlVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isHtmlVisible = false; // Fecha o popup ao tocar fora
                });
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.3), // Fundo semitransparente
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: screenWidth * 0.9,
                    height: double.infinity,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Html(
                        data: _htmlContent, // Renderiza o HTML
                        onLinkTap: (url, _, __) {
                          // Quando um link for clicado, chama a função _launchURL
                          if (url == null) return;
                          Uri urlO = Uri.parse(url);
                          LaunchURL()._launchURL(urlO);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LaunchURL {
  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}