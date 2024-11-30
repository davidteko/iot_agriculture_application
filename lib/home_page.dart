import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';

class home_page extends StatefulWidget {


  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("sensors");
  final DatabaseReference irrigationRef = FirebaseDatabase.instance.ref().child("irrigation system");
  final DatabaseReference weatherRef = FirebaseDatabase.instance.ref().child("weather_forecast");

  String currentTime = ""; // this is to hold the current real time

  int soilMoisture = 0;
  int temperature = 0;
  int humidity = 0;

  String irrigationStatus = "OFF";
  String lastActivated = "N/A";

  Map<String, dynamic> weatherData = {};
  String currentTemp = "--";
  String currentWeather = "--";
  String currentMinMax = "--";
  List<String> hourlyTimes = [];
  List<String> hourlyTemps = [];
  List<String> hourlyRainChances = [];
  List<String> hourlyConditions = [];

  @override
  void initState(){
    super.initState();
    updateTime(); // Set initial time
    Timer.periodic(Duration(seconds: 1), (Timer t) => updateTime()); // Update every second

    // Listen for real-time updates
    sensorListener();
    // listening to irrigation status for real-time update
    listenToIrrigationStatus();

    fetchWeatherData();
  }

  void fetchWeatherData() {
    weatherRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {

          final firstEntry = data.values.first as Map<dynamic, dynamic>;
          currentTemp = "${firstEntry['temperature'].toString()}°";
          currentWeather = firstEntry['weather'].toString();
          currentMinMax = "${firstEntry['min_temp']}° / ${firstEntry['max_temp']}°";

          // Update hourly data
          hourlyTimes = data.keys.map((key) => key.toString()).toList();
          hourlyTemps = data.values
              .map((entry) => (entry as Map<dynamic, dynamic>)['temperature'].toString() + '°')
              .toList();
          hourlyRainChances = data.values
              .map((entry) => (entry as Map<dynamic, dynamic>)['chance_of_rain'].toString() + '%')
              .toList();
          hourlyConditions = data.values
              .map((entry) => (entry as Map<dynamic, dynamic>)['weather'].toString())
              .toList();
        });
      } else {
        print('Data is null or not a valid map');
      }
    });
  }


  IconData _getWeatherIcon(String condition) {
    if (condition.contains("cloud")) {
      return FontAwesomeIcons.cloud;
    } else if (condition.contains("rain")) {
      return FontAwesomeIcons.cloudRain;
    } else if (condition.contains("clear")) {
      return FontAwesomeIcons.sun;
    } else if (condition.contains("thunderstorm")) {
      return FontAwesomeIcons.bolt;
    } else if (condition.contains("snow")) {
      return FontAwesomeIcons.snowflake;
    } else {
      return FontAwesomeIcons.cloud;
    }
  }

  Widget _getLottieAnimation(String weather) {
    weather = weather.toLowerCase();

    if (weather.contains("clear sky")) {
      return Lottie.asset('assets/animations/sunny.json', width: 100, height: 100);
    } else if (weather.contains("few clouds") ||
        weather.contains("broken clouds") ||
        weather.contains("overcast clouds")) {
      return Lottie.asset('assets/animations/cloudy.json', width: 800, height: 800);
    } else if (weather.contains("light rain") ||
        weather.contains("moderate rain") ||
        weather.contains("heavy rain")) {
      return Lottie.asset('assets/animations/rain.json', width: 100, height: 100);
    } else {
      // Default animation in case of other weather types
      return Lottie.asset('assets/animations/rain.json', width: 100, height: 100);
    }
  }

  void listenToIrrigationStatus() {
    irrigationRef.onValue.listen(
          (DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            setState(() {
              irrigationStatus = data['status'] ?? "OFF";
              lastActivated = formatTime(data['lastActivated'] ?? DateTime.now().toIso8601String());
            });
          }
        }
      },
      onError: (error) {
        print("Error listening to Firebase data: $error");
      },
    );
  }




  String formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime).toLocal();
      final difference = DateTime.now().difference(dateTime);
      final minutesAgo = difference.inMinutes;
      print("Last activated at: $dateTime, which is $minutesAgo minutes ago");
      return "$minutesAgo mins ago";
    } catch (e) {
      print("Error parsing lastActivated time: $e");
      return "N/A"; // Fallback if there's an error
    }
  }



  // listening to sensor dats for real time update
  void sensorListener(){
    _sensorRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        soilMoisture = data['soilMoisture'];
        temperature = data['temperature'];
        humidity = data['humidity'];
      });
    });
  }

  // method to update the time
  void updateTime(){
    // getting the current time
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('EEE, d MMMM HH:mm').format(now); // this is to format time
    setState(() {
      currentTime = formattedTime; // Updating the state with the new time
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

         SingleChildScrollView(
           scrollDirection: Axis.vertical,
           child: Column(

             children: [
               SizedBox(height: 20,),
               Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.45,
                 padding: EdgeInsets.all(22),
                 margin: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [Colors.indigo[800]!, Colors.indigo[600]!],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   borderRadius: BorderRadius.circular(25),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.indigo.withOpacity(0.3),
                       blurRadius: 10,
                       offset: Offset(0, 8),
                     ),
                   ],
                 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location and Date-Time
                    Text(
                      "Durban",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      currentTime,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Current Temperature
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getWeatherIcon(currentWeather.toLowerCase()),
                              size: 50,
                              color: Colors.white,
                            ),
                            SizedBox(width: 15),
                            Text(
                              currentTemp,
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currentWeather,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "25° / 18°",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),

                    // Hourly Forecast
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(hourlyTimes.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 22.0),
                              child: Column(
                                children: [
                                  Text(
                                    hourlyTimes[index],
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: 80,
                                    height: 50,
                                    child: _getLottieAnimation(hourlyConditions[index].toLowerCase()),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    hourlyTemps[index],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.droplet,
                                        size: 12,
                                        color: Colors.blue[300],
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        hourlyRainChances[index],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                       ),

               Container(
                 width: MediaQuery.of(context).size.width * 0.95,
                 padding: EdgeInsets.all(16),
                 margin: EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                 decoration: BoxDecoration(
                   color: Colors.grey[900],
                   borderRadius: BorderRadius.circular(25),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.2),
                       blurRadius: 10,
                       offset: Offset(0, 5),
                     ),
                   ],
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       "Sensor Data",
                       style: TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
                     ),
                     SizedBox(height: 20),
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                         children: [
                           Icon(FontAwesomeIcons.water, color: Colors.blue, size: 30),
                           SizedBox(width: 15,),
                           Text(
                             "Soil Moisture",
                             style: TextStyle(color: Colors.white, fontSize: 14),
                           ),
                           SizedBox(width: 150,),
                           Text(
                             "$soilMoisture%",
                             style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                           ),

                         ],
                       ),
                     ),
                     Divider(),
                     SizedBox(height: 15),
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                         children: [
                           Icon(FontAwesomeIcons.temperatureHalf, color: Colors.orange, size: 30),
                           SizedBox(width: 15,),
                           Text(
                             "Temperature",
                             style: TextStyle(color: Colors.white, fontSize: 14),
                           ),
                           SizedBox(width: 150,),
                           Text(
                             "$temperature°C",
                             style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                           ),
                         ],
                       ),
                     ),
                     Divider(),
                     SizedBox(height: 15),
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                         children: [
                           Icon(FontAwesomeIcons.droplet, color: Colors.blueAccent, size: 30),
                           SizedBox(width: 15,),
                           Text(
                             "Humidity",
                             style: TextStyle(color: Colors.white, fontSize: 14),
                           ),
                           SizedBox(width: 180,),
                           Text(
                             "$humidity%",
                             style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),

               Container(
                 width: MediaQuery.of(context).size.width * 0.95,
                 padding: EdgeInsets.all(16),
                 margin: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [Colors.indigo[600]!, Colors.indigo[800]!],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   borderRadius: BorderRadius.circular(25),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.greenAccent.withOpacity(0.2),
                       blurRadius: 10,
                       offset: Offset(0, 5),
                     ),
                   ],
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       "Irrigation System",
                       style: TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
                     ),
                     SizedBox(height: 20),
                     // Irrigation Status
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                         children: [
                           Icon(
                             FontAwesomeIcons.solidSun,
                             color: Colors.yellowAccent,
                             size: 30,
                           ),
                           SizedBox(width: 15),
                           Text(
                             "Irrigation Status:",
                             style: TextStyle(color: Colors.white, fontSize: 14),
                           ),
                           SizedBox(width: 140),
                           Text(
                             irrigationStatus,
                             style: TextStyle(
                               color: irrigationStatus == "ON" ? Colors.greenAccent : Colors.redAccent,
                               fontSize: 22,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ],
                       ),
                     ),
                     Divider(),
                     SizedBox(height: 15),
                     // Flow Rate
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                         children: [
                           Icon(
                             FontAwesomeIcons.tint,
                             color: Colors.blueAccent,
                             size: 30,
                           ),
                           SizedBox(width: 15),
                           Text(
                             "Flow Rate:",
                             style: TextStyle(color: Colors.white, fontSize: 14),
                           ),
                           SizedBox(width: 150),
                           Text(
                             "5 L/min", // Or change to a dynamic value
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 22,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ],
                       ),
                     ),
                     Divider(),
                     SizedBox(height: 15),
                     // Last Activated Time
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                         children: [
                           Icon(
                             FontAwesomeIcons.clock,
                             color: Colors.orangeAccent,
                             size: 30,
                           ),
                           SizedBox(width: 18),
                           Text(
                             "Last Activated:",
                             style: TextStyle(color: Colors.white, fontSize: 14),
                           ),
                           SizedBox(width: 70),
                           Text(
                             lastActivated,
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 22,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),

    );
  }
}

