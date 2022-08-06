import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> character = [];
  bool _loading = false;

  // Why to use graphql?
  // It is faster than efficient than rest
  // You can get that field only which is required, remove those which you don't want
  // Here we are using
  // https://rickandmortyapi.com/graphql

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _loading
          ? CircularProgressIndicator()
          : character.isEmpty
          ? Center(
            child: ElevatedButton(child: Text("Fetch Data"),onPressed: () {
              fetchData();
            },),
          )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: character.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Image.network(
                      character[index]['image']
                  ),
                  title: Text(character[index]['name']),
                ),
              );
            }),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void fetchData() async {
    setState(() {
      _loading = true;
    });

    HttpLink link = HttpLink("https://rickandmortyapi.com/graphql");
    GraphQLClient qlClient = GraphQLClient(link: link, cache: GraphQLCache(
        store: HiveStore()
    ));

    QueryResult queryResult = await qlClient.query(
        QueryOptions(document: gql("""
        query {
  characters(filter: { name: "rick" }) {
    results {
      name,
      image
    }
  }
}
        """))
    );

    // queryResult.data // It contains data
    // queryResult.exception // will give you exception
    // queryResult.hasException //you can check if you have any exception or not
    // queryResult.context.entry<HttpLinkResponseContext>()?.statusCode // to get status code of response

    setState((){
      character = queryResult.data!['characters']['results']; // taking in the character list now we will use this data to display
      _loading = false;
    });
  }

}
