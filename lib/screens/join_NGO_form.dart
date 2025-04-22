import 'package:flutter/material.dart';
import 'package:petlove/models/Join_req_model.dart';
import 'package:petlove/models/User_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:petlove/screens/home_page.dart';

class JoinForm extends StatefulWidget {
  const JoinForm({Key? key, required UserModel user, required String? ngo_uid})
      : _user = user,
        _ngo_uid = ngo_uid,
        super(key: key);

  final UserModel _user;
  final String? _ngo_uid;

  @override
  State<JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  late UserModel _user;
  late String? _ngo_uid;

  @override
  void initState() {
    _user = widget._user;
    _ngo_uid = widget._ngo_uid;

    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  // editing Controller

  final contactEditingController = TextEditingController();
  final descriptionEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final contactField = TextFormField(
      style: const TextStyle(color: Color.fromARGB(255, 4, 50, 88), fontSize: 18),
      autofocus: false,
      controller: contactEditingController,
      keyboardType: TextInputType.phone,
      // validator: (value) {
      //   RegExp regex = new RegExp(
      //       "/(\+\d{1,3}\s?)?((\(\d{3}\)\s?)|(\d{3})(\s|-?))(\d{3}(\s|-?))(\d{4})(\s?(([E|e]xt[:|.|]?)|x|X)(\s?\d+))?/g");
      //   if (value!.isEmpty) {
      //     return ("Contact cannot be Empty");
      //   }
      //   if (!regex.hasMatch(value)) {
      //     return ("Enter Valid Contact Number)");
      //   }
      //   return null;
      // },
      onSaved: (value) {
        contactEditingController.text = value!;
      },
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 4, 50, 88)),
          borderRadius: BorderRadius.circular(5.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 4, 50, 88),
          ),
        ),
        prefixIcon: const Icon(
          Icons.contact_phone,
          color: Color.fromARGB(255, 4, 50, 88),
        ),
        filled: true,
        fillColor: Colors.white,
        labelText: "Contact",
        labelStyle: const TextStyle(color: Color.fromARGB(255, 4, 50, 88)),
      ),
    );
    final descriptionField = TextFormField(
      minLines: 1,
      maxLines: 5,
      style: const TextStyle(color: Color.fromARGB(255, 4, 50, 88), fontSize: 18),
      autofocus: false,
      controller: descriptionEditingController,
      keyboardType: TextInputType.text,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("description cannot be empty");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Min. 3 Characters");
        }
        return null;
      },
      onSaved: (value) {
        descriptionEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 4, 50, 88)),
          borderRadius: BorderRadius.circular(5.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 4, 50, 88),
          ),
        ),
        prefixIcon: const Icon(
          Icons.description,
          color: Color.fromARGB(255, 4, 50, 88),
        ),
        filled: true,
        fillColor: Colors.white,
        labelText: "Description",
        labelStyle: const TextStyle(color: Color.fromARGB(255, 4, 50, 88)),
      ),
    );
    final ApplyButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(3),
      color: const Color.fromARGB(255, 4, 50, 88),
      child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            Apply(_user.uid, _ngo_uid);
          },
          child: const Text(
            "Apply",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Apply'),
        backgroundColor: const Color.fromARGB(255, 4, 50, 88),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // SizedBox(
                    //     height: 180,
                    //     child: Image.asset(
                    //       "assets/logo.png",
                    //       fit: BoxFit.contain,
                    //     )),
                    // SizedBox(height: 45),
                    descriptionField,
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),
                    contactField,
                    const SizedBox(height: 20),

                    //upload logo button

                    const SizedBox(height: 8),

                    const SizedBox(height: 8),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    ApplyButton,
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void Apply(String? uid, String? ngoUid) async {
    if (_formKey.currentState!.validate()) {
      postDetailsToFirestore(uid, ngoUid);
    }
  }

  postDetailsToFirestore(String? uid, String? ngoUid) async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    JoinModel datajoin = JoinModel();

    // writing all the values
    datajoin.uid = uid;
    datajoin.ngo_uid = ngoUid;
    datajoin.description = descriptionEditingController.text;
    datajoin.contact = contactEditingController.text;
    datajoin.status = "ongoing";

    await firebaseFirestore
        .collection("JoinRequests")
        .doc()
        .set(datajoin.toMap());
    Fluttertoast.showToast(msg: "Request Sent Successfully :) ");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(
                user: _user,
              )),
    );
    //(route) => false);
  }
}
