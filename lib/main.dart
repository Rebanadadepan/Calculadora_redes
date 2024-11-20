import 'package:flutter/material.dart';

// Definimos el color aquamarine como constante global
const Color aquamarine = Color(0xFF7FFFD4);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // Tema oscuro
      home: IpCalculator(),
    );
  }
}

class IpCalculator extends StatefulWidget {
  @override
  _IpCalculatorState createState() => _IpCalculatorState();
}

class _IpCalculatorState extends State<IpCalculator> {
  final List<TextEditingController> controllers = List.generate(8, (_) => TextEditingController());

  bool isValidInput(String value) {
    final intVal = int.tryParse(value);
    return intVal != null && intVal >= 0 && intVal <= 255;
  }

  void calculate() {
    if (controllers.any((c) => !isValidInput(c.text))) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Por favor ingrese valores entre 0 y 255."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
          ],
        ),
      );
      return;
    }

    final digits = controllers.map((c) => int.parse(c.text)).toList();

    final binarioLocal = digits.sublist(0, 4).map((d) => d.toRadixString(2).padLeft(8, '0')).join('.');
    final binarioMaskLocal = digits.sublist(4, 8).map((d) => d.toRadixString(2).padLeft(8, '0')).join('.');
    final binaryResults = List.generate(4, (i) {
      return andBinary(binarioLocal.split('.')[i], binarioMaskLocal.split('.')[i]);
    });
    final binarioResultLocal = binaryResults.join('.');
    final decimalResultLocal = binaryResults.map((b) => int.parse(b, radix: 2)).join('.');

    // Navegar a la nueva pantalla con los resultados
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          binario: binarioLocal,
          binarioMask: binarioMaskLocal,
          binarioResult: binarioResultLocal,
          decimalResult: decimalResultLocal,
        ),
      ),
    );
  }

  String andBinary(String bin1, String bin2) {
    return List.generate(bin1.length, (i) => (bin1[i] == '1' && bin2[i] == '1') ? '1' : '0').join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de imagen que cubre toda la pantalla, incluido AppBar
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/hoja.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Título de la aplicación
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Calculadora de Red",
                    style: TextStyle(color: aquamarine, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Filas de TextFields para la IP
                          Row(
                            children: List.generate(4, (index) {
                              return Expanded(
                                child: TextField(
                                  controller: controllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "IP ${index + 1}",
                                    labelStyle: TextStyle(
                                      color: Colors.white, // Texto y etiqueta en blanco
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white, // Texto en blanco
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 10),
                          // Filas de TextFields para la máscara
                          Row(
                            children: List.generate(4, (index) {
                              return Expanded(
                                child: TextField(
                                  controller: controllers[index + 4],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Máscara ${index + 1}",
                                    labelStyle: TextStyle(
                                      color: Colors.white, // Texto y etiqueta en blanco
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white, // Texto en blanco
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botón en la parte inferior
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aquamarine, // Fondo del botón
                      foregroundColor: Colors.black, // Texto negro
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 5,
                    ),
                    child: Text("Calcular", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Nueva pantalla para mostrar los resultados
class ResultPage extends StatelessWidget {
  final String binario;
  final String binarioMask;
  final String binarioResult;
  final String decimalResult;

  ResultPage({
    required this.binario,
    required this.binarioMask,
    required this.binarioResult,
    required this.decimalResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados"),
        backgroundColor: aquamarine,
        iconTheme: IconThemeData(color: Colors.black), // Cambia el color de la flecha
        titleTextStyle: TextStyle(
          color: Colors.black, // Cambia el color del texto
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultText("IP en binario:", binario),
            _buildResultText("Máscara en binario:", binarioMask),
            _buildResultText("Resultado en binario:", binarioResult),
            _buildResultText("Resultado en decimal:", decimalResult),
          ],
        ),
      ),
    );
  }

  Widget _buildResultText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: aquamarine, fontSize: 18)),
        Text(value, style: TextStyle(color: Colors.teal, fontSize: 16)),
        SizedBox(height: 10),
      ],
    );
  }
}
