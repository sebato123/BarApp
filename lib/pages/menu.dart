import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'navegation/mis_recestas.dart';
import 'navegation/cocteles.dart';
import 'navegation/destilados.dart';
import 'navegation/todos.dart';



class Menu extends StatefulWidget {
  const Menu({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  State<Menu> createState() => _MyMenuPageState();
  
}

class _MyMenuPageState extends State<Menu> {
  
 
  @override
  Widget build(BuildContext context) {
    var logger = Logger();

    logger.d("Logger is working!");
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(120, 0, 0, 0), 
      title: Text(widget.title),
),

      body: Center(
        child:  Card (
          margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
        const SizedBox(height: 12),
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Todos los tragos
                  SizedBox(
                  width: 400,
                  height: 100,
                  child: Image.asset(
                     "assets/allDrinks.png",
                   fit: BoxFit.contain,
                  ),
          ),
                const SizedBox(height: 8),
                  ElevatedButton.icon(
                   onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Todos(),
                        ),
                      );
                      },
                  icon: const Icon(Icons.wine_bar),
                  label: const Text("Todos los tragos"),
              ),
            ],
          ),

                  SizedBox(
                  width: 400,
                  height: 100,
                  child: Image.asset(
                     "assets/tragos.png",
                   fit: BoxFit.contain,
                  ),
                ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Cocteles(),
                        ),
                      );
                      },
                          icon: const Icon(Icons.local_bar),
                          label: const Text("Cocteles"),
                    ),


                    SizedBox(
                  width: 400,
                  height: 100,
                  child: Image.asset(
                     "assets/Destilados.png",
                   fit: BoxFit.contain,
                  ),
                ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Destilados(),
                        ),
                      );
                      },
                      icon: const Icon(Icons.liquor),
                      label: const Text("Destilados"),
                    ),

                   SizedBox(
                  width: 400,
                  height: 100,
                  child: Image.asset(
                     "assets/Create.png",
                   fit: BoxFit.contain,
                  ),
          ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MisRecestas(),
                        ),
                      );
                        },
                      icon: const Icon(Icons.menu_book),
                      label: const Text("Mis recetas"),
                    ),
                  ],
                ),
                  
                ),  
                    
                  ),
                  
            ),
            );
        
            
        
      
      
    }
  }