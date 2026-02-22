import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class OnnxService {
  late OrtEnv _env;
  late OrtSession _session;

  Future<void> loadModel() async {
    _env = OrtEnv.instance;
    _env.init();

    final sessionOptions = OrtSessionOptions();
    try {
      final modelData = await rootBundle.load('assets/car_price_model.onnx');
      final modelBytes = modelData.buffer.asUint8List(
        modelData.offsetInBytes,
        modelData.lengthInBytes,
      );
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);
    } finally {
      sessionOptions.release();
    }
  }

  Future<double> predict({
    required int year,
    required int engineCC,
    required int horsepower,
    required double mileage,
    required String brand,
    required String bodyType,
    required String fuelType,
    required String transmission,
  }) async {
    final inputs = <String, OrtValue>{
      'Manufacture_Year': OrtValueTensor.createTensorWithDataList([
        [year.toDouble()],
      ]),
      'Engine_CC': OrtValueTensor.createTensorWithDataList([
        [engineCC.toDouble()],
      ]),
      'Horsepower': OrtValueTensor.createTensorWithDataList([
        [horsepower.toDouble()],
      ]),
      'Mileage_km_per_l': OrtValueTensor.createTensorWithDataList([
        [mileage],
      ]),
      'Brand': OrtValueTensor.createTensorWithDataList([
        [brand],
      ]),
      'Body_Type': OrtValueTensor.createTensorWithDataList([
        [bodyType],
      ]),
      'Fuel_Type': OrtValueTensor.createTensorWithDataList([
        [fuelType],
      ]),
      'Transmission': OrtValueTensor.createTensorWithDataList([
        [transmission],
      ]),
    };

    final runOptions = OrtRunOptions();
    List<OrtValue?> outputs = const [];

    try {
      outputs = _session.run(runOptions, inputs);
      final outputValue = outputs.first?.value;
      if (outputValue is List &&
          outputValue.isNotEmpty &&
          outputValue.first is List &&
          (outputValue.first as List).isNotEmpty) {
        return ((outputValue.first as List).first as num).toDouble();
      }
      if (outputValue is num) {
        return outputValue.toDouble();
      }

      throw StateError('Formato de salida ONNX no soportado: $outputValue');
    } finally {
      for (final input in inputs.values) {
        input.release();
      }
      for (final output in outputs) {
        output?.release();
      }
      runOptions.release();
    }
  }

  void dispose() {
    _session.release();
    _env.release();
  }
}
