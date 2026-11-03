import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final Function(String shopName, String upiId) onLoginComplete;

  const AuthScreen({super.key, required this.onLoginComplete});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int step = 1; // 1: Phone, 2: OTP, 3: Shop Details

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  void nextStep() {
    if (step == 1) {
      if (phoneController.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kripya sahi 10-digit mobile number dalein")),
        );
        return;
      }
      setState(() => step = 2);
    } else if (step == 2) {
      if (otpController.text.trim().length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kripya 6-digit OTP dalein")),
        );
        return;
      }
      setState(() => step = 3);
    } else if (step == 3) {
      if (shopNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dukan ka naam likhna zaroori hai")),
        );
        return;
      }
      // Login Complete -> 28 Din ka Trial Start
      widget.onLoginComplete(
        shopNameController.text.trim(),
        upiController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD2B8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.storefront, size: 44, color: Color(0xFF5D4037)),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  step == 1
                      ? "Apna Phone Number Dalein"
                      : step == 2
                          ? "OTP Verify Karein"
                          : "Dukan Ki Details Bharein",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  step == 1
                      ? "Dukan login aur setup ke liye mobile number zaroori hai"
                      : step == 2
                          ? "${phoneController.text} par bheja gaya 6-digit OTP dalein"
                          : "Grahak ke QR code payment aur bill ke liye",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
              const SizedBox(height: 36),

              // STEP 1: Phone Number Input
              if (step == 1) ...[
                const Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCD6C8)),
                  ),
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Text("+91", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      hintText: "10-digit number",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],

              // STEP 2: OTP Input
              if (step == 2) ...[
                const Text("6-Digit OTP", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCD6C8)),
                  ),
                  child: TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: "",
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF795548)),
                      hintText: "Jaise: 123456",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],

              // STEP 3: Shop Name & UPI Details
              if (step == 3) ...[
                const Text("Dukan Ka Naam", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCD6C8)),
                  ),
                  child: TextField(
                    controller: shopNameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.shopping_bag_outlined, color: Color(0xFF795548)),
                      hintText: "Jaise: Mahto General Store",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text("UPI Number / UPI ID", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCD6C8)),
                  ),
                  child: TextField(
                    controller: upiController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.qr_code, color: Color(0xFF795548)),
                      hintText: "Jaise: 9876543210@paytm ya PhonePe number",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Pehle 28 din bilkul Free Trial rahega!",
                          style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC88523),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: nextStep,
                  child: Text(
                    step == 1
                        ? "Get OTP"
                        : step == 2
                            ? "Verify & Next"
                            : "Start My Shop",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              if (step > 1) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => step--),
                    child: const Text("Peeche Jayein", style: TextStyle(color: Colors.black54)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
