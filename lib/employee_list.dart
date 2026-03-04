import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'employee_model.dart';
import 'restapi.dart';
import 'config.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key}) : super(key: key);

  @override
  EmployeeListState createState() => EmployeeListState();
}

class EmployeeListState extends State<EmployeeList> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List data = [];
  List<EmployeeModel> employee = [];

  List<EmployeeModel> search_data = [];
  List<EmployeeModel> search_data_pre = [];

  selectAllEmployee() async {
    data = jsonDecode(await ds.selectAll(token, project, 'employee', appid));

    employee = data.map((e) => EmployeeModel.fromJson(e)).toList();

    //Refresh the UI
    setState(() {
      employee = employee;
    });
  }

  void filterEmployee(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      search_data = data.map((e) => EmployeeModel.fromJson(e)).toList();
    } else {
      search_data_pre = data.map((e) => EmployeeModel.fromJson(e)).toList();
      search_data = search_data_pre
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    //Refresh the UI
    setState(() {
      employee = search_data;
    });
  }

  //Future Reload Data Employee
  Future reloadDataEmployee(dynamic value) async {
    setState(() {
      selectAllEmployee();
    });
  }

  @override
  void initState() {
    selectAllEmployee();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !searchStatus ? const Text('Employee List') : search_field(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'employee_form_add')
                    .then(reloadDataEmployee);
              },
              child: const Icon(
                Icons.add,
                size: 26.0,
              ),
            ),
          ),
          search_icon(),
        ],
      ),
      body: ListView.separated(
        itemCount: employee.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = employee[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.email),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, 'employee_detail',
                  arguments: [item.id]).then(reloadDataEmployee);
            },
          );
        },
      ),
    );
  }

  Widget search_icon() {
    return !searchStatus
        ? Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  searchStatus = true;
                });
              },
              child: const Icon(
                Icons.search,
                size: 26.0,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  searchStatus = true;
                });
              },
              child: const Icon(
                Icons.search,
                size: 26.0,
              ),
            ),
          );
  }

  Widget search_field() {
    return TextField(
      controller: searchKeyword,
      autofocus: true,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      textInputAction: TextInputAction.search,
      onChanged: (value) => filterEmployee(value),
      decoration: InputDecoration(
        hintText: 'Search employees...',
        hintStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 18,
        ),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              searchKeyword.clear();
              searchStatus = false;
              filterEmployee('');
            });
          },
        ),
      ),
    );
  }
}
