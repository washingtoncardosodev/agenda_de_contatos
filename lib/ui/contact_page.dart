import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  
  final Contact contact;

  // Construtor recebe o contato, contato é opcional pq esta entre {}
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameFocus = FocusNode();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _userEdited = false;
  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    // Para pegar o contato que esta na outra classe usa-se o widget
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      // Transforma o contato passado pra pagina em um map e cria um novo contato atraves desse map
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(        
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.save),
          onPressed: (){
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.img != null ? FileImage(File(_editedContact.img)) : AssetImage("assets/images/default.png"),
                      fit: BoxFit.cover
                    )
                  )
                ),
                onTap: (){
                  ImagePicker().getImage(source: ImageSource.camera).then((file) {
                    if (file == null) return;
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
                controller: _nameController,
                focusNode: _nameFocus,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
                controller: _phoneController,
              )
            ]
          ),
        ) 
      )
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar alterações"),
            content: Text("Ao sair as alterações serão perdidas"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context); // Da um pop no alert
                }
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context); // Da um pop no alert
                  Navigator.pop(context); // Da um pop da pagina
                }
              )
            ]
          );
        }
      );
      return Future.value(false); // Não permite sair da tela
    } else {
      return Future.value(true); // Permite sair da tela
    }
  }
}