import 'package:flutter/material.dart';

class IrrigationControlCard extends StatefulWidget {
  final String title;
  final String subtitle;

  const IrrigationControlCard({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  _IrrigationControlCardState createState() => _IrrigationControlCardState();
}

class _IrrigationControlCardState extends State<IrrigationControlCard> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOn ? Colors.lightGreenAccent[400] : Colors.redAccent[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.water_drop_outlined,
                color: isOn ? Colors.black : Colors.white,
                size: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  color: isOn ? Colors.black : Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.power_settings_new),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isOn = !isOn;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isOn ? Colors.black : Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            isOn ? "ON" : "OFF",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isOn ? Colors.black87 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

