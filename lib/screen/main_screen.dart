import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart';
import 'package:finance_tracker/components/custom_button.dart';

class FinanceTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              // Gambar di bagian atas layar
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/kingdom-payment.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Title Section
              const Spacer(),
              Text(
                'FINANCE TRACKER',
                style: GoogleFonts.balooBhai2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle Section
              Text(
                'Track your expenses to prevent\noverspending from your budget',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                child: CustomButton(
                  text: 'Get Started',
                  onPressed: () {
                    // Navigasi ke halaman Dashboard
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
