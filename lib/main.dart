import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import 'register_page.dart';
import 'profile_page.dart';
import 'help_support_page.dart';


// LECTURE PAGE
import '../lectures/lecture_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vtnkrniyzdivglookekg.supabase.co',
    anonKey: 'sb_publishable_EQ9N1AfSxeBg3aDNL56dIw_RURmN0-g',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Todo App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const AuthCheck(),
    );
  }
}

// =====================================================
// AUTH CHECK
// =====================================================

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) {
          return const TodoScreen();
        }

        return const LoginPage();
      },
    );
  }
}

// =====================================================
// TODO SCREEN
// =====================================================

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController taskController = TextEditingController();

  List<Map<String, dynamic>> todos = [];

  bool isLoading = true;
  bool isAdding = false;

  // Bottom bar selected item
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  // =====================================================
  // GET TODOS
  // =====================================================

  Future<void> getTodos() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          todos = [];
          isLoading = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final data = await supabase
          .from('todos')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          todos = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (error) {
      if (mounted) {
        showMessage('Todo load nahi huay: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // ADD TODO
  // =====================================================

  Future<void> addTodo() async {
    final task = taskController.text.trim();

    if (task.isEmpty) {
      showMessage('Pehle task likhein');
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage('Pehle login karein');
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isAdding = true;
        });
      }

      await supabase.from('todos').insert({
        'task': task,
        'user_id': user.id,
      });

      taskController.clear();

      await getTodos();

      if (mounted) {
        showMessage('Todo successfully add ho gaya');
      }
    } catch (error) {
      if (mounted) {
        showMessage('Todo add nahi hua: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  // =====================================================
  // DELETE TODO
  // =====================================================

  Future<void> deleteTodo(dynamic id) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      await supabase.from('todos').delete().eq('id', id).eq('user_id', user.id);

      if (mounted) {
        setState(() {
          todos.removeWhere(
            (todo) => todo['id'] == id,
          );
        });

        showMessage('Todo delete ho gaya');
      }
    } catch (error) {
      if (mounted) {
        showMessage('Todo delete nahi hua: $error');
      }
    }
  }

  // =====================================================
  // CONFIRM DELETE
  // =====================================================

  Future<void> confirmDelete(dynamic id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: const Text(
            'Kya aap waqai is todo ko delete karna chahti hain?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteTodo(id);
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      if (mounted) {
        showMessage('Logout nahi hua: $error');
      }
    }
  }

  // =====================================================
  // BOTTOM BAR ACTION
  // =====================================================

  void onBottomBarTap(int index) async {
    setState(() {
      currentIndex = index;
    });

    // -----------------------------------------------
    // LECTURES
    // -----------------------------------------------
    if (index == 0) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LectureListPage(),
        ),
      );

      if (mounted) {
        setState(() {
          currentIndex = 0;
        });
      }
    }

    // -----------------------------------------------
    // PROFILE
    // -----------------------------------------------
    else if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );

      if (mounted) {
        setState(() {
          currentIndex = 1;
        });
      }
    }

    // -----------------------------------------------
    // REFRESH
    // -----------------------------------------------
    else if (index == 2) {
      await getTodos();

      if (mounted) {
        showMessage('Todo list refresh ho gayi');
      }
    }

    // -----------------------------------------------
    // LOGOUT
    // -----------------------------------------------
    else if (index == 3) {
      await logout();
    }
  }

  // =====================================================
  // MESSAGE
  // =====================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===================================================
      // SIDEBAR / DRAWER
      // ===================================================

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // =============================================
              // SIDEBAR HEADER
              // =============================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.school,
                        size: 35,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Shaheen American Academy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Student Panel',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =============================================
              // HOME
              // =============================================

              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // =============================================
              // LECTURES
              // =============================================

              ListTile(
                leading: const Icon(
                  Icons.video_library_outlined,
                ),
                title: const Text(
                  'Lectures',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LectureListPage(),
                    ),
                  );
                },
              ),

              // =============================================
              // PROFILE
              // =============================================

              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),

              // =============================================
              // HELP & SUPPORT
              // =============================================

              ListTile(
                leading: const Icon(
                  Icons.help_outline,
                ),
                title: const Text(
                  'Help & Support',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportPage(),
                    ),
                  );
                },
              ),

              const Divider(),

              // =============================================
              // LOGOUT
              // =============================================

              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await logout();
                },
              ),

              const Spacer(),

              // =============================================
              // SIDEBAR FOOTER
              // =============================================

              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '© Shaheen American Academy',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        title: const Text(
          'My Todo App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        // IMPORTANT:
        // Pehle yahan Lectures/Profile/Refresh/Logout
        // ke icons thay.
        // Ab ye sab Bottom Bar mein hain.
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Column(
        children: [
          // =================================================
          // ADD TODO FIELD
          // =================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    onSubmitted: (_) => addTodo(),
                    decoration: InputDecoration(
                      hintText: 'Apna task likhein...',
                      prefixIcon: const Icon(
                        Icons.task_alt,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isAdding ? null : addTodo,
                    child: isAdding
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.add,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // TODO LIST
          // =================================================

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : todos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Abhi koi Todo nahi hai',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: getTodos,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    '${index + 1}',
                                  ),
                                ),
                                title: Text(
                                  todo['task']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  todo['created_at']?.toString() ?? '',
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    confirmDelete(
                                      todo['id'],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      // =====================================================
      // BOTTOM NAVIGATION BAR
      // =====================================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onBottomBarTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          // -----------------------------------------------
          // LECTURES
          // -----------------------------------------------

          BottomNavigationBarItem(
            icon: Icon(
              Icons.video_library_outlined,
            ),
            activeIcon: Icon(
              Icons.video_library,
            ),
            label: 'Lectures',
          ),

          // -----------------------------------------------
          // PROFILE
          // -----------------------------------------------

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            activeIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),

          // -----------------------------------------------
          // REFRESH
          // -----------------------------------------------

          BottomNavigationBarItem(
            icon: Icon(
              Icons.refresh,
            ),
            label: 'Refresh',
          ),

          // -----------------------------------------------
          // LOGOUT
          // -----------------------------------------------

          BottomNavigationBarItem(
            icon: Icon(
              Icons.logout,
            ),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}
