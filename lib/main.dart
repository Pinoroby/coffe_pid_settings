import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const BottomNavigationBarExampleApp());

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee PID Settings'),
        backgroundColor: const Color.fromRGBO(0, 112, 65, 1),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat),
            label: 'Temperature',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee_maker),
            label: 'Coffee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromRGBO(0, 0, 0, 1),
        unselectedItemColor: const Color.fromRGBO(175, 175, 175, 1),
      ),
    );
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: _optionStyle,
    ),
     
    TempScreen(),

    Text(
      'Index 2: School',
      style: _optionStyle,
    ),

    SettingsScreen(), // Index 3: Settings
  ];

  static const TextStyle _optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _numberSetting = 1;
  bool _boolSetting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildNumberSetting(),
          _buildBoolSetting(),
          // Add more settings widgets here
        ],
      ),
    );
  }

  Widget _buildNumberSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number Setting: $_numberSetting',
          style: const TextStyle(fontSize: 20),
        ),
        Slider(
          value: _numberSetting.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (double value) {
            setState(() {
              _numberSetting = value.toInt();
            });
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBoolSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Boolean Setting: $_boolSetting',
          style: const TextStyle(fontSize: 20),
        ),
        Switch(
          value: _boolSetting,
          onChanged: (bool value) {
            setState(() {
              _boolSetting = value;
            });
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class TempScreen extends StatefulWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  _TempScreenState createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  List<FlSpot> _temperatureData = [
    FlSpot(0, 100), // Temperature at 0 seconds
    FlSpot(1, 98),  // Temperature at 1 second
    FlSpot(2, 97),  // Temperature at 2 seconds
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Plot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: _temperatureData.length.toDouble() - 1,
            minY: 0,
            maxY: 100,

            borderData: FlBorderData(
              show: true,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _temperatureData,
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}