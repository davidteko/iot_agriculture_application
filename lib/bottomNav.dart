import 'package:flutter/material.dart';
import 'package:iot_agriculture_application/AgritechAssistantPage.dart';
import 'package:iot_agriculture_application/home_page.dart';
import 'package:iot_agriculture_application/sensorData_page.dart';
import 'package:iot_agriculture_application/weatherForecast_page.dart';
import 'package:iot_agriculture_application/irrigationSystem_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class bottomNav extends StatefulWidget {
  const bottomNav({super.key});

  @override
  State<bottomNav> createState() => _bottomNavState();
}

class _bottomNavState extends State<bottomNav> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    home_page(),
    AgritechAssistantPage(),
    sensorData(),
    irrigationSystemPage()

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.indigo[800]!, Colors.indigo[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green[900]!,
            )
          ],
        ),
        child: GNav(
          tabs: [
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.assistant, text: "Ai assistant"),
            GButton(icon: Icons.sensors, text: "Sensor Data"),
            GButton(icon: Icons.water, text: "Irrigation System"),
          ],
          activeColor: Colors.white,
          color: Colors.white,
          tabBackgroundColor: Colors.grey[900]!,
          padding: EdgeInsets.all(12),
          curve: Curves.bounceIn,
          iconSize: 28,
          gap: 5,
          duration: Duration(milliseconds: 500),
          selectedIndex: selectedIndex,
          onTabChange: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
      body: pages[selectedIndex],
    );
  }
}
