import 'dart:math';

/// Online logistic regression with SGD and L2 regularization.
class OnlineLogReg {
  late List<double> w;
  final double lr;
  final double l2;

  OnlineLogReg(int nFeatures, {this.lr = 0.05, this.l2 = 1e-4}) {
    w = List<double>.filled(nFeatures, 0.0);
  }

  double _dot(List<double> x) {
    var s = 0.0;
    for (var i = 0; i < x.length; i++) {
      s += x[i] * w[i];
    }
    return s;
  }

  double _sigm(double z) => 1.0 / (1.0 + exp(-z));

  /// p(y=1|x)
  double predictProba(List<double> x) => _sigm(_dot(x));

  /// Single SGD update on one example.
  void update(List<double> x, int y) {
    final p = predictProba(x);
    final err = p - y; // gradient of BCE
    for (var i = 0; i < w.length; i++) {
      final grad = err * x[i] + l2 * w[i];
      w[i] -= lr * grad;
    }
  }
}
