import 'package:flutter/material.dart';

import 'button_values.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = ""; // . 0-9
  String operand = ""; // + - / *
  String number2 = ""; // . 0-9

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const int maxDisplayDigits = 28; // Maximum digits allowed in the display

    // Combine the display values and truncate them if needed
    String displayText = "$number1$operand$number2";
    if (displayText.length > maxDisplayDigits) {
      displayText = displayText.substring(0, maxDisplayDigits);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Display output
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child: Text(
                  displayText.isEmpty ? "0" : displayText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            // Buttons grid
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: value == Btn.n0
                          ? screenSize.width / 2
                          : (screenSize.width / 4),
                      height: screenSize.width / 5,
                      child: buildButton(value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(value) {
    // making buttons
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white24,
            ),
            borderRadius: BorderRadius.circular(100)),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }
    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }
    appendValue(value);
  }

  // calculate the result
  void calculate() {
    if (number1.isEmpty || operand.isEmpty || number2.isEmpty) return;

    final double num1 = double.parse(number1);
    final double num2 = double.parse(number2);

    double result = 0.0;

    try {
      switch (operand) {
        case Btn.add:
          result = num1 + num2;
          break;
        case Btn.subtract:
          result = num1 - num2;
          break;
        case Btn.multiply:
          result = num1 * num2;
          break;
        case Btn.divide:
          if (num2 == 0) {
            showError("Error: Division by 0");
            return;
          }
          result = num1 / num2;
          break;
        default:
          showError("Error: Invalid operation");
          return;
      }

      // Handle infinity or invalid results
      if (result.isInfinite || result.isNaN) {
        showError("Error: Invalid operation");
        return;
      }

      setState(() {
        number1 = "$result";

        // Remove trailing ".0" for integers
        if (number1.endsWith(".0")) {
          number1 = number1.substring(0, number1.length - 2);
        }

        operand = "";
        number2 = "";
      });
    } catch (e) {
      showError("Error: Invalid calculation");
    }
  }

  void showError(String message) {
    setState(() {
      number1 = message;
      operand = "";
      number2 = "";

      // Automatically clear the error after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        clearAll();
      });
    });
  }

  // convert output to %
  void convertToPercentage() {
    if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      calculate();
    }

    if (operand.isNotEmpty) {
      showError("Error: Invalid operation");
      return;
    }

    try {
      final number = double.parse(number1);
      setState(() {
        number1 = "${(number / 100)}";
        operand = "";
        number2 = "";
      });
    } catch (e) {
      showError("Error: Invalid input");
    }
  }

  // clear all output
  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

  // delete one from the end
  void delete() {
    if (number1.startsWith("Error")) {
      clearAll();
      return;
    }

    setState(() {
      if (number2.isNotEmpty) {
        number2 = number2.substring(0, number2.length - 1);
      } else if (operand.isNotEmpty) {
        operand = "";
      } else if (number1.isNotEmpty) {
        number1 = number1.substring(0, number1.length - 1);
      }
    });
  }


  void appendValue(String value) {
    const int maxDisplayDigits = 28; // Maximum digits allowed in the display

    // prevent input when an error message is displayed
    if (number1.startsWith("Error")) {
      clearAll();
    }

    // combine current display text
    String displayText = "$number1$operand$number2";

    // If the input would exceed the display limit, return early
    if (displayText.length >= maxDisplayDigits) return;

    if (value != Btn.dot && int.tryParse(value) == null) {
      // Assign values to operand variable
      if (operand.isNotEmpty && number2.isNotEmpty) {
        calculate(); // Calculate if an equation already exists
      }
      operand = value;
    }
    // Assign values to number1
    else if (number1.isEmpty || operand.isEmpty) {
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        value = "0.";
      }
      number1 += value;
    }
    // Assign values to number2
    else if (number2.isEmpty || operand.isNotEmpty) {
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        value = "0.";
      }
      number2 += value;
    }

    setState(() {});
  }
}

Color getBtnColor(value) {
  // assign colors to buttons
  return [Btn.del, Btn.clr].contains(value)
      ? Colors.blueGrey
      : [
          Btn.per,
          Btn.multiply,
          Btn.add,
          Btn.subtract,
          Btn.divide,
          Btn.calculate
        ].contains(value)
          ? Colors.orange
          : Colors.black87;
}
