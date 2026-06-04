import 'package:flutter/material.dart';

class CustomTextField {
 static  Widget buildTextField({
   required TextEditingController controller,
   required String hint,
   required IconData icon,
   bool obscure = false,
   TextInputType? keyboardType,
 }) {
   return Container(
     decoration: BoxDecoration(
       color: Colors.white.withOpacity(0.06),
       borderRadius: BorderRadius.circular(18),
       border: Border.all(color: Colors.white.withOpacity(0.08)),
     ),
     child: TextField(
       controller: controller,
       obscureText: obscure,
       keyboardType: keyboardType,
       style: const TextStyle(
         color: Colors.white,
         fontWeight: FontWeight.w500,
       ),
       decoration: InputDecoration(
         contentPadding: .only(top: 13),
         border: InputBorder.none,
         prefixIcon: Icon(icon, color: Colors.deepPurple.shade200),
         hintText: hint,
         hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
       ),
     ),
   );
 }
}