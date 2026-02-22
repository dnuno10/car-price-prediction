import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onnx_service.dart';

class CarForm extends StatefulWidget {
  const CarForm({super.key});

  @override
  State<CarForm> createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final _service = OnnxService();
  final _formKey = GlobalKey<FormState>();

  final yearCtrl = TextEditingController();
  final engineCtrl = TextEditingController();
  final hpCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();

  String brand = 'Toyota';
  String body = 'SUV';
  String fuel = 'Petrol';
  String transmission = 'Automatic';

  double? price;
  double? budget;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _service.loadModel().then((_) {
      setState(() => loading = false);
    });
  }

  double _parseDecimal(String value) {
    return double.parse(value.replaceAll(',', '.'));
  }

  String? _requiredNumber(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label es obligatorio';
    return null;
  }

  String? _validateYear(String? value) {
    final required = _requiredNumber(value, 'Año');
    if (required != null) return required;
    final year = int.tryParse(value!.trim());
    final maxYear = DateTime.now().year + 1;
    if (year == null) return 'Año inválido';
    if (year < 2000 || year > maxYear) {
      return 'Año debe estar entre 2000 y $maxYear';
    }
    return null;
  }

  String? _validateEngine(String? value) {
    final required = _requiredNumber(value, 'Engine CC');
    if (required != null) return required;
    final cc = int.tryParse(value!.trim());
    if (cc == null) return 'Engine CC inválido';
    if (cc < 600 || cc > 10000) return 'Engine CC debe estar entre 600 y 10000';
    return null;
  }

  String? _validateHorsepower(String? value) {
    final required = _requiredNumber(value, 'Horsepower');
    if (required != null) return required;
    final hp = int.tryParse(value!.trim());
    if (hp == null) return 'Horsepower inválido';
    if (hp < 40 || hp > 2000) return 'Horsepower debe estar entre 40 y 2000';
    return null;
  }

  String? _validateMileage(String? value) {
    final required = _requiredNumber(value, 'Mileage km/l');
    if (required != null) return required;
    final mileage = double.tryParse(value!.trim().replaceAll(',', '.'));
    if (mileage == null) return 'Mileage inválido';
    if (mileage <= 0 || mileage > 100) {
      return 'Mileage debe estar entre 0 y 100';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    final required = _requiredNumber(value, 'Presupuesto');
    if (required != null) return required;
    final amount = double.tryParse(value!.trim().replaceAll(',', '.'));
    if (amount == null) return 'Presupuesto inválido';
    if (amount <= 0) return 'Presupuesto debe ser mayor a 0';
    return null;
  }

  @override
  void dispose() {
    yearCtrl.dispose();
    engineCtrl.dispose();
    hpCtrl.dispose();
    mileageCtrl.dispose();
    budgetCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          children: [
            TextFormField(
              controller: yearCtrl,
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateYear,
            ),
            TextFormField(
              controller: engineCtrl,
              decoration: const InputDecoration(labelText: 'Engine CC'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateEngine,
            ),
            TextFormField(
              controller: hpCtrl,
              decoration: const InputDecoration(labelText: 'Horsepower'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateHorsepower,
            ),
            TextFormField(
              controller: mileageCtrl,
              decoration: const InputDecoration(labelText: 'Mileage km/l'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
              ],
              validator: _validateMileage,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: budgetCtrl,
              decoration: const InputDecoration(
                labelText: 'Presupuesto (USD)',
                hintText: 'Ej: 15000',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
              ],
              validator: _validateBudget,
            ),

            const SizedBox(height: 14),

            DropdownButton<String>(
              value: brand,
              items: [
                'Toyota',
                'Ford',
                'BMW',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => brand = v!),
            ),

            ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (!(_formKey.currentState?.validate() ?? false)) return;

                final result = await _service.predict(
                  year: int.parse(yearCtrl.text.trim()),
                  engineCC: int.parse(engineCtrl.text.trim()),
                  horsepower: int.parse(hpCtrl.text.trim()),
                  mileage: _parseDecimal(mileageCtrl.text.trim()),
                  brand: brand,
                  bodyType: body,
                  fuelType: fuel,
                  transmission: transmission,
                );

                final parsedBudget = _parseDecimal(budgetCtrl.text.trim());

                setState(() {
                  price = result;
                  budget = parsedBudget;
                });
              },
              child: const Text('Predecir precio'),
            ),

            const SizedBox(height: 14),

            if (price != null)
              Text(
                'Precio estimado: \$${price!.toStringAsFixed(2)} USD',
                style: const TextStyle(fontSize: 18),
              ),

            if (price != null && budget != null) ...[
              const SizedBox(height: 8),
              if (budget! >= price!)
                Text(
                  'Sí te alcanza. Te sobran: \$${(budget! - price!).toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9CFF9C),
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  'No te alcanza. Te faltan: \$${(price! - budget!).toStringAsFixed(2)} USD para comprar el carro deseado.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFFB3B3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
