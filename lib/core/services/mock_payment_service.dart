class MockPaymentService {
  // === payment simulation ===
  Future<bool> makePayment({required double amount}) async {
    try {
      // === delay simulation ===
      await Future.delayed(const Duration(seconds: 2));

      // === always sucess ===
      bool isSuccess = true;

      if (isSuccess) {
        print(" Payment of \$$amount processed successfully (MOCK).");
        return true;
      } else {
        print(" Payment failed (MOCK).");
        return false;
      }
    } catch (e) {
      print("Error in payment: $e");
      return false;
    }
  }
}
