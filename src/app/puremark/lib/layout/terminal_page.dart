import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  TerminalPageState createState() => TerminalPageState();
}

class TerminalPageState extends State<TerminalPage> {
  final List<String> consoleNames = ['js-console']; // Apenas uma instância por enquanto
  int currentConsoleIndex = 0;
  String _output = ''; // Armazena a saída do console
  final TextEditingController _inputController = TextEditingController();
  double _consoleHeight = 400; // Altura inicial do console

  late JavascriptRuntime jsRuntime;

  @override
  void initState() {
    super.initState();
    jsRuntime = getJavascriptRuntime(); // Inicializa o ambiente JS
  }

  @override
  void dispose() {
    jsRuntime.dispose(); // Libera recursos quando o widget é destruído
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terminal"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Menu de troca de consoles
          PopupMenuButton<int>(
            onSelected: (int index) {
              setState(() {
                currentConsoleIndex = index;
              });
            },
            itemBuilder: (BuildContext context) {
              return List.generate(consoleNames.length, (index) {
                return PopupMenuItem<int>(
                  value: index,
                  child: Text(consoleNames[index]),
                );
              });
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Área do terminal
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _consoleHeight -= details.primaryDelta!;
                  if (_consoleHeight < 200) _consoleHeight = 200;
                  if (_consoleHeight > 600) _consoleHeight = 600;
                });
              },
              child: Container(
                color: Colors.black,
                height: _consoleHeight,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Área de saída (console)
                    Expanded(
                      child: SingleChildScrollView(
                        reverse: true, // Faz com que o conteúdo novo apareça na parte inferior
                        child: Text(
                          _output,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    // Campo de entrada com foco manual, no final do terminal
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: _inputController,
                        autofocus: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Digite seu código JS...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        maxLines: 1, // Impede quebra de linha
                        onSubmitted: (value) {
                          String code = _inputController.text;
                          if (code.trim().isNotEmpty) {
                            _executeCommand(code); // Executa o código quando o botão é pressionado
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String code = _inputController.text;
          if (code.trim().isNotEmpty) {
            _executeCommand(code); // Executa o código quando o botão é pressionado
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }

  // Função para executar o comando JS
  void _executeCommand(String code) async {
    if (code.trim().isEmpty) return; // Não executa comandos vazios

    // Adiciona a função logMessage ao ambiente JS
    String customLogFunction = '''
      // Utiliza os template literals do JavaScript para formatar a saída
      function log(...args) {
        let formattedMessage = args.map(arg => {
          if (typeof arg === 'string') {
            return arg; // Se for uma string, retorna a string diretamente
          }
          return JSON.stringify(arg); // Se não for uma string, converte para string
        }).join(' ');

        return formattedMessage;
      }

      // A função prompt que chama o Flutter para capturar a entrada
      function prompt(message) {
        return window.promptMessage(message);  // Chama o Flutter para obter a entrada
      }
    ''';

    // Combine o código customizado com o código do usuário
    String fullCode = customLogFunction + code;

    // Execute o código usando o flutter_js
    var result = jsRuntime.evaluate(fullCode);

    // Atualize a saída do console com o resultado
    setState(() {
      _output = '> $result\n$_output'; // Exibe o código executado e seu resultado
    });

    // Limpa o campo de entrada
    _inputController.clear();
  }
}
