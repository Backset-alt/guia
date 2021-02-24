import 'package:flutter/material.dart';
import 'package:guia_entrenamiento/app/home/models/session.dart';
import 'package:guia_entrenamiento/app/home/models/training.dart';
import 'package:guia_entrenamiento/common_widgets/show_alert_dialog.dart';
import 'package:guia_entrenamiento/common_widgets/show_exception_alert_dialog.dart';
import 'package:guia_entrenamiento/services/training_api.dart';
import 'package:provider/provider.dart';

import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditForTimePage extends StatefulWidget {
  EditForTimePage({Key key, @required this.trainingApi, this.training})
      : super(key: key);
  final TrainingApi trainingApi;
  final Training training;

  static Future<void> show(BuildContext context, {Training training}) async {
    final trainingApi = context.read<TrainingApi>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditForTimePage(
          trainingApi: trainingApi,
          training: training,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _EditForTimePageState createState() => _EditForTimePageState();
}

class _EditForTimePageState extends State<EditForTimePage> {
  final _formKey = GlobalKey<FormState>();
  File _selectedFile;
  bool _inProcess = false;

  String _image;
  String _name;
  String _description;
  String _time;
  String _intensity;

  @override
  void initState() {
    super.initState();
    if (widget.training != null) {
      _image = widget.training.image;
      _name = widget.training.name;
      _description = widget.training.description;
      _time = widget.training.time.toString();
      _intensity = widget.training.intensity.toString();
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      final session = context.read<Session>();

      try {
        final brigades = await widget.trainingApi.forKmStream().first;
        final allNames = brigades.map((brigade) => brigade.name).toList();
        if (widget.training != null) {
          allNames.remove(widget.training.name);
        }
        if (allNames.contains(_name)) {
          showAlertDialog(
            context,
            title: 'Nombre ya usado',
            content: 'Elija un nombre de trabajo diferente',
            defaultActionText: 'OK',
          );
        } else {
          final Training training = new Training().copyWith(
            type: 'for_time',
            image: _image,
            name: _name,
            description: _description,
            repetitions: int.parse(_time),
            intensity: int.parse(_intensity),
          );
          if (widget.training == null) {
            await widget.trainingApi.setTraining(training);
            Navigator.of(context).pop();
          } else {
            await widget.trainingApi
                .updateTraining(widget.training.idtraining, training);
            Navigator.of(context).pop();
          }
        }
      } on AssertionError catch (e) {
        showAssertionAlertDialog(
          context,
          title: 'Operación fallida',
          exception: e,
        );
      } on CastError catch (e) {
        print(e.toString());
      } catch (e) {
        showExceptionAlertDialog(
          context,
          title: 'Operación fallida',
          exception: e,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2.0,
        title: Text(widget.training == null
            ? 'Nuevo estiramiento'
            : 'Editar estiramiento'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () => _submit(),
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_photo_alternate),
        onPressed: () {
          getImage(ImageSource.gallery);
        },
      ),
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      Stack(
        children: [
          if (widget.training == null)
            (_selectedFile == null)
                ? Image.asset('assets/images/no-image.png')
                : Image.file(_selectedFile)
          else
            (_selectedFile != null)
                ? Image.file(_selectedFile)
                : FadeInImage(
                    image: NetworkImage(_image),
                    placeholder: AssetImage('assets/images/jar-loading.gif'),
                    height: 200.00,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          (_inProcess)
              ? Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center()
        ],
      ),
      SizedBox(
        height: 10,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Nombre'),
        initialValue: _name,
        validator: (value) =>
            value.isNotEmpty ? null : 'El campo no puede estar vacío',
        onSaved: (value) => _name = value,
        textInputAction: TextInputAction.next,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'descripción'),
        initialValue: _description,
        validator: (value) =>
            value.isNotEmpty ? null : 'El campo no puede estar vacío',
        onSaved: (value) => _description = value,
        textInputAction: TextInputAction.next,
        maxLines: null,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'time'),
        initialValue: _time,
        validator: (value) =>
            value.isNotEmpty ? null : 'El nombre no puede estar vacío',
        onSaved: (value) => _time = value,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'intensidad'),
        initialValue: _intensity,
        validator: (value) =>
            value.isNotEmpty ? null : 'El nombre no puede estar vacío',
        onSaved: (value) => _intensity = value,
        onEditingComplete: _submit,
        keyboardType: TextInputType.number,
      ),
    ];
  }

  uploadImageToFirebase() {
    final String path = 'for_time/for_time_${DateTime.now().toString()}.jpg';
    final Reference postImageRef = FirebaseStorage.instance.ref().child(path);
    final UploadTask uploadTask = postImageRef.putFile(_selectedFile);
    uploadTask.whenComplete(() async {
      _image = await postImageRef.getDownloadURL();
    }).catchError((onError) {
      showAssertionAlertDialog(
        context,
        title: 'Operación fallida',
        exception: onError,
      );
    });
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    await ImagePicker().getImage(source: source).then((image) async {
      image.path;
      if (image != null) {
        File cropped = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.red,
              toolbarTitle: "Guía digital AFM",
              statusBarColor: Colors.red.shade900,
              backgroundColor: Colors.white,
            ));

        this.setState(() {
          _selectedFile = cropped;
          _inProcess = false;
        });
      } else {
        this.setState(() {
          _inProcess = false;
        });
      }
    });
    await uploadImageToFirebase();
  }
}
