import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/page.essentials/button_row.dart';

class EditForm extends StatefulWidget {
  const EditForm({super.key});

  // final User? user;

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  // final displayName = TextEditingController();
  // final name = TextEditingController();
  // final gender = TextEditingController();

  String displayName = my.displayName;
  String name = my.name;
  String gender = 'Male';
  Gender genVal = Gender.M;
  @override
  void initState() {
    super.initState();
    UserService.instance.get(myUid ?? '');
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
                _textFieldBuilder('Display Name', my.displayName == '' ? displayName : my.displayName, isDisplay: true),
                _textFieldBuilder('Name', my.name == '' ? name : my.name, isName: true),

                /// TODO: Design dropdown button
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
                    await my
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
                    await my.updateComplete(true);
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
            name = name == '' ? my.name : name;
            gender = gender == '' ? my.gender : gender;
            return;
          }
          if (isName) {
            name = value;
            displayName = displayName == '' ? my.displayName : displayName;
            gender = gender == '' ? my.gender : gender;
            return;
          }
          gender = value;
          name = name == '' ? my.name : name;
          displayName = displayName == '' ? my.displayName : displayName;
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
