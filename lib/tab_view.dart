import 'package:flutter/material.dart';
import 'View/data_view.dart';
import 'View/device_view.dart';
import 'View/settings_view.dart';
import './View/alarms_view.dart';

class TabView extends StatefulWidget {
  const TabView({super.key});

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  int _currentIndex = 0;
  String? _selectedDeviceId;
  String? _selectedDeviceName;


  void _handleDeviceSelected(String id, String name) {
    setState(() {
      _selectedDeviceId = id;
      _selectedDeviceName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DeviceView(
            selectedDeviceId: _selectedDeviceId,
            onDeviceSelected: _handleDeviceSelected,
          ),

          DataView(
            selectedDeviceId: _selectedDeviceId,
            selectedDeviceName: _selectedDeviceName,
            isActive: _currentIndex == 1,),

          AlarmsView(
            selectedDeviceId: _selectedDeviceId, 
            selectedDeviceName: _selectedDeviceName, 
            isActive: _currentIndex == 2),

          SettingsView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color.fromARGB(255, 26, 29, 200),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: "设备"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "数据"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "警报"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置"),
        ],
      ),
    );
  }
}
