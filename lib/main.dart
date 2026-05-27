import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

/// The root widget for the calculator application.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF9F0A),
        fontFamily: 'Roboto',
      ),
      home: const CalculatorScreen(),
    );
  }
}

/// The calculator screen with the display and button grid.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '0';
  String operator = '';
  double previousValue = 0;
  bool waitingForSecondOperand = false;
  String _pressedButton = '';

  final List<String> _buttons = [
    'C', '', '', '/',
    '7', '8', '9', '*',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '', '', '='
  ];

  /// Handles button taps and updates the calculator state.
  void _onPressed(String buttonText) {
    if (buttonText.isEmpty) return;

    setState(() {
      _pressedButton = buttonText;

      if (buttonText == 'C') {
        input = '0';
        operator = '';
        previousValue = 0;
        waitingForSecondOperand = false;
        return;
      }

      if (_isOperator(buttonText) && buttonText != '=') {
        if (input.startsWith('Error')) return;

        if (operator.isNotEmpty && !waitingForSecondOperand) {
          _calculateResult();
        }

        previousValue = double.tryParse(_currentOperandText()) ?? 0;
        operator = buttonText;
        input = '${_formatNumber(previousValue)}$operator';
        waitingForSecondOperand = true;
        return;
      }

      if (buttonText == '=') {
        if (operator.isNotEmpty && !input.endsWith(operator)) {
          _calculateResult();
        }
        return;
      }

      if (input == '0' || input.startsWith('Error')) {
        input = buttonText;
      } else {
        input += buttonText;
      }

      waitingForSecondOperand = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _pressedButton = '';
      });
    });
  }

  /// Returns true when [text] is one of the calculator operators.
  bool _isOperator(String text) {
    return text == '+' || text == '-' || text == '*' || text == '/' || text == '=';
  }

  /// Extracts the current operand text after the selected operator.
  String _currentOperandText() {
    if (operator.isEmpty) return input;
    final index = input.lastIndexOf(operator);
    if (index < 0 || index == input.length - 1) {
      return input;
    }
    return input.substring(index + 1);
  }

  /// Formats the displayed number without trailing .0 for integers.
  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  /// Calculates the result for the current expression and updates the display.
  void _calculateResult() {
    final operandText = _currentOperandText();
    final currentInput = double.tryParse(operandText) ?? 0;

    double result;
    switch (operator) {
      case '+':
        result = previousValue + currentInput;
        break;
      case '-':
        result = previousValue - currentInput;
        break;
      case '*':
        result = previousValue * currentInput;
        break;
      case '/':
        if (currentInput == 0) {
          input = 'Error: / 0';
          operator = '';
          waitingForSecondOperand = false;
          return;
        }
        result = previousValue / currentInput;
        break;
      default:
        return;
    }

    input = _formatNumber(result);
    operator = '';
    waitingForSecondOperand = false;
    previousValue = result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17171C),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  input,
                  style: const TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final btnText = _buttons[index];
                    if (btnText.isEmpty) return const SizedBox.shrink();

                    final isPressed = _pressedButton == btnText;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      transform: isPressed
                          ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
                          : Matrix4.identity(),
                      child: ElevatedButton(
                        onPressed: () => _onPressed(btnText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnText == 'C'
                              ? const Color(0xFFA5A5A5)
                              : _isOperator(btnText)
                                  ? const Color(0xFFFF9F0A)
                                  : const Color(0xFF333333),
                          foregroundColor: btnText == 'C' ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: isPressed ? 0 : 4,
                        ),
                        child: Text(
                          btnText,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: _isOperator(btnText)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
