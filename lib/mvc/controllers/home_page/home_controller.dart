import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/home_page/my_contracts_page.dart';
import 'package:iep_app/mvc/views/project_page/add_new_project_page.dart';
import 'package:iep_app/mvc/views/home_page/my_projects_page.dart';
import 'package:iep_app/mvc/views/home_page/my_transaction_page.dart';

class HomeController {
  void navigateToAddProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProjectPage()),
    );
  }

  void onMyInvestmentsTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyTransactionPage()),
    );
  }

  void onMyContractsTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyContractsPage()),
    );
  }

  void onMyProjectsTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyProjectsPage()),
    );
  }
}
