import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String userInput = "";
  String result = "0";

  final List<String> buttons = [
    'C',
    'DEL',
    '%',
    '/',
    '7',
    '8',
    '9',
    'x',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    'Ans',
    '=',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for the whole page
      appBar: AppBar(
        title: const Text("Simple Calculator"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // --- THE FIX STARTS HERE ---
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
          ), // Standard phone width
          child: Column(
            children: [
              // Display Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        // Prevents text overflow
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          userInput,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result,
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons Section
              Expanded(
                flex: 3, // Give more space to buttons
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    itemCount: buttons.length,
                    // Fix: childAspectRatio prevents buttons from stretching vertically
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.1,
                        ),
                    itemBuilder: (context, index) {
                      return CalcButton(
                        text: buttons[index],
                        color: getButtonColor(buttons[index]),
                        textColor: Colors.white,
                        onTap: () => onButtonPressed(buttons[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Improved button coloring logic
  Color getButtonColor(String x) {
    if (x == 'C' || x == 'DEL') return Colors.redAccent;
    if (x == '=' || x == 'Ans') return Colors.blueAccent;
    if (isOperator(x)) return Colors.orange;
    return Colors.grey[900]!;
  }

  bool isOperator(String x) =>
      x == '/' || x == 'x' || x == '-' || x == '+' || x == '%';

  void onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        userInput = "";
        result = "0";
      } else if (label == 'DEL') {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
      } else if (label == '=') {
        calculateResult();
      } else if (label == 'Ans') {
        userInput = result;
      } else {
        userInput += label;
      }
    });
  }

  void calculateResult() {
    if (userInput.isEmpty) return;
    try {
      String finalInput = userInput.replaceAll('x', '*');
      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Clean up decimal if it's .0
      if (eval == eval.toInt()) {
        result = eval.toInt().toString();
      } else {
        result = eval.toStringAsFixed(2);
      }
    } catch (e) {
      result = "Error";
    }
  }
}

class CalcButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const CalcButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
