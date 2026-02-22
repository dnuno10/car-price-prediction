class OnnxService {
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
    final age = (DateTime.now().year - year).clamp(0, 30);

    double base = 9000;
    base += engineCC * 2.8;
    base += horsepower * 18;
    base -= age * 650;
    base += mileage * 220;

    const brandFactor = {'Toyota': 1.00, 'Ford': 0.95, 'BMW': 1.30};

    const bodyFactor = {
      'Sedan': 1.00,
      'SUV': 1.12,
      'Hatchback': 0.92,
      'Coupe': 1.08,
      'Pickup': 1.05,
    };

    const fuelFactor = {
      'Petrol': 1.00,
      'Diesel': 1.03,
      'Hybrid': 1.12,
      'Electric': 1.18,
    };

    const transmissionFactor = {'Manual': 0.96, 'Automatic': 1.05};

    final estimate =
        base *
        (brandFactor[brand] ?? 1.0) *
        (bodyFactor[bodyType] ?? 1.0) *
        (fuelFactor[fuelType] ?? 1.0) *
        (transmissionFactor[transmission] ?? 1.0);

    return estimate.clamp(2500, 180000).toDouble();
  }

  void dispose() {}
}
