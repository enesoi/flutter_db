import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Employee.dart';
import 'BareData.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo Uygulama'),
    );
  }
}

//  for the radio buttons on Sorgu page
enum Based { kul_bazli, rol_bazli }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Store your variables here!!
class _MyHomePageState extends State<MyHomePage> {
  RegExp emailRegex = RegExp(
      "([!#-'*+/-9=?A-Z^-~-]+(\.[!#-'*+/-9=?A-Z^-~-]+)*|\"\(\[\]!#-[^-~ \t]|(\\[\t -~]))+\")@([!#-'*+/-9=?A-Z^-~-]+(\.[!#-'*+/-9=?A-Z^-~-]+)*|\[[\t -Z^-~]*])");
  RegExp textRegex = RegExp("^[A-Z][a-z]*");
  late SharedPreferences sharedPreferences;

  late int
      lastID; // this is to store last id of an added row to ensure the id is inceremented
  // ---Sorgu page variables---

  String? _kulValue;
  String _rolValue = "no_role";

  //Initial selected radio button
  Based? _base = Based.kul_bazli;
  //----------------------------

  // the whole data of employees to be stored
  // late List<Employee> _employees;
  BareData _employees = BareData([]);
  BareData _filteredEmployees = BareData([]);
  late List<Employee> emps;

  late GlobalKey<ScaffoldState> _scaffoldKey;

  // controllers for Ekle dialog
  final TextEditingController _ekleFirstNameController =
      TextEditingController();
  final TextEditingController _ekleLastNameController = TextEditingController();
  final TextEditingController _ekleEmailController = TextEditingController();

  // controllers for Düzenle dialog
  final TextEditingController _duzFirstNameController = TextEditingController();
  final TextEditingController _duzLastNameController = TextEditingController();
  final TextEditingController _duzEmailController = TextEditingController();

  // other controllers
  final TextEditingController _1nameController = TextEditingController();
  final TextEditingController _sorguNameController = TextEditingController();
  final TextEditingController _sorguRoleController = TextEditingController();

  // index 0 = kullanıcılar
  // index 1 = roller
  // index 2 = kullanıcı rolleri
  // index 3 = sorgu
  var pages = [true, false, false, false];

  bool kulRadio = true;
  bool rolRadio = false;

  void resetPages(activeIndex) {
    setState(() {
      pages = [false, false, false, false];
      pages[activeIndex] = true;
    });
  }

  void removeClickedRow() {
    setState(() {
      _filteredEmployees.deleteEntry();
      _employees.deleteEntry();

      clickedRow.updateAll((key, value) => "");
    });
    updateData();
  }

  void setDuzenleText() {
    setState(() {
      _duzFirstNameController.text = clickedRow['firstName'];
      _duzLastNameController.text = clickedRow['lastName'];
      _duzEmailController.text = clickedRow['email'];
    });
  }

  void filterName(BareData toFilter, TextEditingController controller) {
    setState(() {
      List<Employee> temp = toFilter.getList().toList();
      _filteredEmployees.resetList();
      List<Employee> filtered = temp
          .where((emp) => emp.firstName.indexOf(controller.text) != -1)
          .toList();
      filtered.forEach((emp) {
        _filteredEmployees.addData(emp);
      });
    });
  }

  // REPLACE TEXT WITH COMBOBOX VALUE..
  void filterRole(BareData toFilter, TextEditingController controller) {
    setState(() {
      List<Employee> temp = toFilter.getList().toList();
      _filteredEmployees.resetList();
      List<Employee> filtered =
          temp.where((emp) => emp.role.indexOf(controller.text) != -1).toList();
      filtered.forEach((emp) {
        _filteredEmployees.addData(emp);
      });
    });
  }

  // add storeData() as well!
  void getInitData() async {
    sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      String all = sharedPreferences.getString('all') ?? '';
      lastID = sharedPreferences.getInt('id') ?? 0;

      if (all != '')
        emps = Employee.decode(all);
      else
        emps = [];

      _employees.addList(emps);
      _filteredEmployees.addList(emps);
    });
  }

  void addRow() async {
    Employee add = getInput();

    _filteredEmployees.addData(add);
    _employees.addData(add);

    String allData = Employee.encode(_employees.getList().toList());
    await sharedPreferences.setString('all', allData);
    await sharedPreferences.setInt('id', lastID);
    _resetInputs();
  }

  void updateData() async {
    String allData = Employee.encode(_employees.getList().toList());
    await sharedPreferences.setString('all', allData);
  }

  void modifyRow(BareData emps) {
    emps
        .getList()
        .firstWhere((emp) =>
            emp.firstName == clickedRow['firstName'] &&
            emp.lastName == clickedRow['lastName'] &&
            emp.email == clickedRow['email'])
        .modifyEmployee(_duzFirstNameController.text,
            _duzLastNameController.text, _duzEmailController.text);
    emps.notify();
  }

  void updateRow() {
    modifyRow(_filteredEmployees);
    // modifyRow(_employees);

    setState(() {
      _duzFirstNameController.text = "";
      _duzLastNameController.text = "";
      _duzEmailController.text = "";
    });

    updateData();
  }

  Widget clickPopup() {
    return const Text("Satır seçildi.");
  }

  Future<void> _areYouSureDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Silme'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Kullanıcı ID ${clickedRow['id']} silinsin mi?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Evet'),
              onPressed: () {
                removeClickedRow();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Seçili satır silindi."),
                  action: SnackBarAction(
                    label: '',
                    onPressed: () {},
                  ),
                  duration: const Duration(seconds: 2),
                ));
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getInitData();
    setState(() {
      _filteredEmployees.addList(_employees.getList().toList());
    });
    super.initState();

    // _employees.addList(List.generate(
    //     200,
    //     (index) => Employee(
    //         id: "$index",
    //         firstName: "Ad $index",
    //         lastName: "Soyad ${Random().nextInt(1000)}",
    //         role: Random().nextBool() ? "Admin" : "User",
    //         email: "${Random().nextInt(1393)}@gmail.com")));

    //_isUpdating = false;
    //_titleProgress = widget.title;
    _scaffoldKey = GlobalKey(); // key to get the context to show a SnackBar

    //_getEmployees();
  }

  Employee getInput() {
    int temp = lastID;
    lastID++;
    return Employee(
        id: temp.toString(),
        firstName: _ekleFirstNameController.text,
        lastName: _ekleLastNameController.text,
        role: "",
        email: _ekleEmailController.text);
  }

  void _resetInputs() {
    setState(() {
      _ekleFirstNameController.text = "";
      _ekleLastNameController.text = "";
      _ekleEmailController.text = "";
    });
  }

  Widget ataPopup() {
    if (_kulValue == null || _rolValue == '')
      return const Text("Kullanıcı veya rol seçilmedi.");
    else
      return const Text("Başarıyla atandı.");
  }

  Widget expanded1(index) {
    if (index == 1) {
      return Expanded(
          flex: 1,
          child: Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Aranacak isim',
                      ),
                      controller: _1nameController,
                    )),
                Container(width: 10),
                FilledButton.tonal(
                  onPressed: () {
                    filterName(_employees, _1nameController);
                  },
                  child: const Text('Ara'),
                ),
              ],
            ),
          ));
    } else if (index == 2) {
      return Expanded(
          flex: 1,
          child: Container(
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownButton(
                    items:
                        //DropdownMenuItem(child: Text("Ali"), value: "Ali"),
                        //DropdownMenuItem(child: Text("Veli"), value: "Veli"),
                        (_filteredEmployees
                            .getList()
                            .toList()
                            .map((emp) => DropdownMenuItem(
                                  value: emp.firstName,
                                  child: Text(emp.firstName),
                                ))).toList(),
                    value: _kulValue,
                    hint: const Text("Kullanıcı"),
                    onChanged: kulCallback,
                    iconSize: 32,
                  ),
                  DropdownButton(
                    items: const [
                      DropdownMenuItem(value: "no_role", child: Text("")),
                      DropdownMenuItem(value: "User", child: Text("User")),
                      DropdownMenuItem(value: "Admin", child: Text("Admin"))
                    ],
                    value: _rolValue,
                    onChanged: rolCallback,
                    iconSize: 32,
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      setState(() {
                        _employees.addRole(_kulValue, _rolValue);
                        _filteredEmployees.addRole(_kulValue, _rolValue);
                        updateData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: ataPopup(),
                          action: SnackBarAction(
                            label: '',
                            onPressed: () {},
                          ),
                          duration: const Duration(seconds: 2),
                        ));
                      });
                    },
                    child: const Text('Ata'),
                  ),
                ],
              )));
    } else if (index == 3) {
      return Expanded(
          flex: 1,
          child: Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RadioListTile<Based>(
                      title: const Text("Kullanıcı bazlı"),
                      value: Based.kul_bazli,
                      groupValue: _base,
                      // controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.only(
                        left: 500.0,
                      ),
                      onChanged: (Based? value) {
                        setState(() {
                          _base = value;
                          kulRadio = true;
                          rolRadio = false;
                        });
                      },
                    ),
                    RadioListTile<Based>(
                      title: const Text("Rol bazlı"),
                      value: Based.rol_bazli,
                      groupValue: _base,
                      // controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.only(left: 500.0),
                      onChanged: (Based? value) {
                        setState(() {
                          _base = value;
                          kulRadio = false;
                          rolRadio = true;
                        });
                      },
                    ),
                  ],
                )),
                kulRadio
                    ? SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ad',
                          ),
                          controller: _sorguNameController,
                        ))
                    : SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Rol',
                          ),
                          controller: _sorguRoleController,
                        )),
                Container(
                  width: 10,
                ),
                FilledButton.tonal(
                  onPressed: () {
                    kulRadio
                        ? filterName(_employees, _sorguNameController)
                        : filterRole(_employees, _sorguRoleController);
                  },
                  child: const Text('Sorgula'),
                ),
                const SizedBox(
                  width: 500,
                ),
              ],
            ),
          ));
    } else
      return Expanded(
          flex: 1,
          child: Container(
            color: Colors.blue,
          ));
  }

  void kulCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _kulValue = selectedValue;
      });
    }
  }

  void rolCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _rolValue = selectedValue;
      });
    }
  }

  Future<void> _ekleDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kullanıcı Ekle'),
          content: Form(
            child: Column(
              children: [
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Ad"),
                      controller: _ekleFirstNameController,
                    )),
                Container(height: 10),
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Soyad"),
                      controller: _ekleLastNameController,
                    )),
                Container(height: 10),
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Email"),
                      controller: _ekleEmailController,
                    ))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ekle'),
              onPressed: () {
                if (!_ekleEmailController.text.contains(emailRegex)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Geçersiz email."),
                    action: SnackBarAction(
                      label: '',
                      onPressed: () {},
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                } else if (!_ekleFirstNameController.text.contains(textRegex) ||
                    !_ekleLastNameController.text.contains(textRegex)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Geçersiz isim!"),
                    action: SnackBarAction(
                      label: '',
                      onPressed: () {},
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                } else {
                  addRow();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _duzenleDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Satır Düzenle'),
          content: Form(
            child: Column(
              children: [
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Ad"),
                      controller: _duzFirstNameController,
                    )),
                Container(height: 10),
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Soyad"),
                      controller: _duzLastNameController,
                    )),
                Container(height: 10),
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Email"),
                      controller: _duzEmailController,
                    ))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Düzenle'),
              onPressed: () {
                if (!_duzEmailController.text.contains(emailRegex)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Geçersiz email."),
                    action: SnackBarAction(
                      label: '',
                      onPressed: () {},
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                } else if (!_duzFirstNameController.text.contains(textRegex) ||
                    !_duzLastNameController.text.contains(textRegex)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Geçersiz isim!"),
                    action: SnackBarAction(
                      label: '',
                      onPressed: () {},
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                } else {
                  updateRow();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Başarıyla düzenlendi."),
                    action: SnackBarAction(
                      label: '',
                      onPressed: () {},
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
              height: 100.0,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text("Menü"),
              )),

          // Kullanıcılar
          ListTile(
            title: const Text("Kullanıcılar"),
            onTap: () {
              resetPages(0);
              Navigator.of(context).pop();
              setState(() {
                _filteredEmployees.addList(_employees.getList().toList());
              });
            },
          ),

          //Roller
          ListTile(
            title: const Text("Roller"),
            onTap: () {
              resetPages(1);
              Navigator.of(context).pop();
            },
          ),

          //Kullanıcı Rolleri
          ListTile(
            title: const Text("Kullanıcı Rolleri"),
            onTap: () {
              resetPages(2);
              Navigator.of(context).pop();
            },
          ),

          //Sorgu
          ListTile(
            title: const Text("Sorgu"),
            onTap: () {
              resetPages(3);
              Navigator.of(context).pop();
            },
          ),
        ],
      )),
      body: Stack(
        children: [0, 1, 2, 3].map((index) {
          if (pages[index]) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                expanded1(index),
                Expanded(
                    flex: 6,
                    child: PaginatedDataTable(
                      columns: const [
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Ad")),
                        DataColumn(label: Text("Soyad")),
                        DataColumn(label: Text("Rol")),
                        DataColumn(label: Text("E-mail")),
                      ],
                      source: _filteredEmployees,
                      rowsPerPage: 9,
                      showCheckboxColumn: false,

                      // headingRowHeight:,
                    )),
              ],
            );
          } else
            return Container();
        }).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: Wrap(
        //will break to another line on overflow
        direction: Axis.horizontal, //use vertical to show  on vertical axis
        children: <Widget>[
          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: () => _ekleDialog(context),
                tooltip: 'Ekle',
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              )),

          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: () {
                  if (clickedRow['index'] == "") {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Satır seçilmedi."),
                      action: SnackBarAction(
                        label: '',
                        onPressed: () {},
                      ),
                      duration: const Duration(seconds: 1),
                    ));
                  } else {
                    setDuzenleText();
                    _duzenleDialog(context);
                  }
                },
                tooltip: 'Düzenle',
                backgroundColor: Colors.blue,
                child: const Icon(Icons.short_text),
              )), //button first

          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: () {
                  if (clickedRow['index'] == "") {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Satır seçilmedi."),
                      action: SnackBarAction(
                        label: '',
                        onPressed: () {},
                      ),
                      duration: const Duration(seconds: 1),
                    ));
                  } else {
                    _areYouSureDialog();
                  }
                },
                tooltip: 'Sil',
                backgroundColor: Colors.red,
                child: const Icon(Icons.highlight_remove_sharp),
              )),
        ],
      ),
    );
  }
}
