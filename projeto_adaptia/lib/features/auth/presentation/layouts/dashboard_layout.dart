import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
=======
>>>>>>> main

class DashboardLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.location,
  });

  int get _currentIndex {
    switch (location) {
      case '/dashboard':
      case '/dashboard/home':
        return 0;
      case '/dashboard/classes':
        return 1;
      case '/dashboard/ai':
        return 2;
      case '/dashboard/groups':
        return 3;
      case '/dashboard/profile':
        return 4;
      default:
        return 0;
    }
  }

  Widget _buildIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    bool isSelected = _currentIndex == index;
    return Icon(
      isSelected ? filledIcon : outlinedIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard/home');
              break;
            case 1:
              context.go('/dashboard/classes');
              break;
            case 2:
              context.go('/dashboard/ai');
              break;
            case 3:
              context.go('/dashboard/groups');
              break;
            case 4:
              context.go('/dashboard/profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_outlined, Icons.home, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.group_outlined, Icons.group, 1),
            label: 'Turmas',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.auto_awesome_outlined, Icons.auto_awesome, 2),
            label: 'IA',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.share_outlined, Icons.share, 3),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person_outline, Icons.person, 4),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}