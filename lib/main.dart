import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// This is just a demo of graphql
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


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> character = [];
  bool _loading = false;

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

    setState((){
      character = queryResult.data!['characters']['results']; // taking in the character list now we will use this data to display
      _loading = false;
    });
  }

}
