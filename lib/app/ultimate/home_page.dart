import 'package:flutter/material.dart';
import 'package:guia_entrenamiento/app/home/brigade/list_items_builder.dart';
import 'package:guia_entrenamiento/app/home/models/training.dart';
import 'package:guia_entrenamiento/app/landing_page.dart';
import 'package:guia_entrenamiento/common_widgets/common_draw.dart';
import 'package:guia_entrenamiento/common_widgets/show_alert_dialog.dart';
import 'package:guia_entrenamiento/common_widgets/show_exception_alert_dialog.dart';
import 'package:guia_entrenamiento/services/auth.dart';
import 'package:guia_entrenamiento/services/training_api.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Cerrar sesión',
      content: '¿Estás seguro de que quieres cerrar sesión?',
      cancelActionText: 'Cancelar',
      defaultActionText: 'Cerrar sesión',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LandingPage(),
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context, Training training) async {
    try {
      final database = Provider.of<TrainingApi>(context, listen: false);
      await database.deleteTraining(training.idtraining);
    } on AssertionError catch (e) {
      showAssertionAlertDialog(
        context,
        title: 'Operación fallida',
        exception: e,
      );
    } catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Operación fallida',
        exception: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guía digítal de AFM'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
        backgroundColor: Colors.black,
      ),
      drawer: CommonDraw(),
      body: _buildContents(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        // onPressed: () {
        //   EditTrailingPage.show(context);
        //   // EditBrigadePage.show(context)
        // },
        onPressed: () {},
        backgroundColor: Colors.black54,
      ),
    );
  }

  Widget _buildContents(BuildContext bodyContext) {
    // final trainingApi = bodyContext.read<TrainingApi>();
    return Center(
      child: Text('Guía digítal de AFM'),
    );
    //   StreamBuilder<List<Training>>(
    //   stream: trainingApi.trainingStream(),
    //   builder: (context, snapshot) {
    //     return ListItemsBuilder<Training>(
    //       snapshot: snapshot,
    //       itemBuilder: (context, training) => Dismissible(
    //         key: Key('brigade-${training.idtraining}'),
    //         background: Container(color: Colors.red),
    //         direction: DismissDirection.endToStart,
    //         onDismissed: (direction) => _delete(context, training),
    //         child: Card(
    //           child: Column(
    //             children: [
    //               Text(
    //                 '${training.name}',
    //                 style:
    //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 20.00),
    //               ),
    //               training.image == null
    //                   ? Image(image: AssetImage('assets/images/no-image.png'))
    //                   : FadeInImage(
    //                       image: NetworkImage(training.image),
    //                       placeholder:
    //                           AssetImage('assets/images/jar-loading.gif'),
    //                       height: 300,
    //                       width: double.infinity,
    //                       fit: BoxFit.cover,
    //                     ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
