import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/page.essentials/button_row.dart';

class EditForm extends StatefulWidget {
  const EditForm({super.key, required this.user});

  final User user;

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  // final displayName = TextEditingController();
  // final name = TextEditingController();
  // final gender = TextEditingController();
  late String displayName;
  late String name;
  late String gender;
  late Gender genVal;
  @override
  void initState() {
    super.initState();
    UserService.instance.get(myUid ?? '');
    displayName = widget.user.displayName;
    name = widget.user.name;
    gender = 'Male';
    genVal = Gender.M;
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   displayName.dispose();
  //   name.dispose();
  //   gender.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      alignment: Alignment.center,
      child: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: SizedBox(
            height: constraints.maxHeight / 3 - 14,
            width: 400,
            child: Column(
              children: [
                _textFieldBuilder('Display Name', widget.user.displayName == '' ? displayName : widget.user.displayName,
                    isDisplay: true),
                _textFieldBuilder('Name', widget.user.name == '' ? name : widget.user.name, isName: true),
                DropdownButton(
                  value: genVal,
                  items: const [
                    DropdownMenuItem(
                      value: Gender.F,
                      child: Text('Female'),
                    ),
                    DropdownMenuItem(
                      value: Gender.M,
                      child: Text('Male'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == Gender.F) {
                      setState(() {
                        gender = 'Female';
                        genVal = Gender.F;
                      });
                    }
                    if (value == Gender.M) {
                      setState(() {
                        gender = 'Male';
                        genVal = Gender.M;
                      });
                    }
                    debugPrint(gender);
                  },
                ),
                ButtonRow(
                  label1: 'Update',
                  action1: () async {
                    await widget.user
                        .update(
                      displayName: displayName,
                      name: name,
                      gender: gender,
                    )
                        .then((value) {
                      context.pop();
                      toast(
                        backgroundColor: Theme.of(context).indicatorColor,
                        title: 'Profile Updated',
                        message: 'Profile has been updated successfully',
                      );
                    });
                  },
                  label2: 'Cancel',
                  action2: () => context.pop(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _textFieldBuilder(String label, String initialValue, {bool isDisplay = false, bool isName = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: (value) => setState(() {
          if (isDisplay) {
            displayName = value;
            name = name == '' ? widget.user.name : name;
            gender = gender == '' ? widget.user.gender : gender;
            return;
          }
          if (isName) {
            name = value;
            displayName = displayName == '' ? widget.user.displayName : displayName;
            gender = gender == '' ? widget.user.gender : gender;
            return;
          }
          gender = value;
          name = name == '' ? widget.user.name : name;
          displayName = displayName == '' ? widget.user.displayName : displayName;
        }),
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            gapPadding: 13,
          ),
          label: Text(label),
        ),
      ),
    );
  }
}
