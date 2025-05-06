// Full Flutter Code for CheckMe Todo App (with Riverpod and Theme Switching)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: CheckMeApp(),
    ),
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class CheckMeApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userName: _emailController.text.split('@')[0]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('CheckMe Login'),
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                  backgroundColor: Colors.teal.shade100,
                ),
                SizedBox(height: 20),
                Text('Welcome Back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor)),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: themeColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: themeColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value != null && value.length >= 6 ? null : 'Password must be 6+ chars',
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Login', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Global Todo List using StateNotifier
class Todo {
  String title;
  String description;
  bool isDone;
  DateTime? dueDate;
  String category;

  Todo({required this.title, this.description = '', this.isDone = false, this.dueDate, this.category = "General"});
}

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void add(Todo todo) => state = [...state, todo];
  void remove(Todo todo) => state = state.where((t) => t != todo).toList();
  void toggleDone(Todo todo) {
    state = state.map((t) => t == todo ? Todo(
      title: t.title,
      description: t.description,
      isDone: !t.isDone,
      dueDate: t.dueDate,
      category: t.category,
    ) : t).toList();
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) => TodoNotifier());

class HomeScreen extends ConsumerStatefulWidget {
  final String userName;
  HomeScreen({required this.userName});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String filterCategory = 'All';
  String searchQuery = '';

  void _addTodo() {
    String title = '';
    String description = '';
    DateTime? dueDate;
    String category = 'General';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Todo'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              DropdownButton<String>(
                value: category,
                onChanged: (newValue) => setState(() => category = newValue!),
                items: ['General', 'School', 'Personal', 'Urgent']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  dueDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text('Pick Due Date'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (title.isNotEmpty) {
                ref.read(todoProvider.notifier).add(
                  Todo(title: title, description: description, dueDate: dueDate, category: category),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);
    final filteredTodos = todos.where((todo) {
      final matchSearch = todo.title.contains(searchQuery) || todo.description.contains(searchQuery);
      final matchCategory = filterCategory == 'All' || todo.category == filterCategory;
      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('CheckMe Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: () => _showThemeDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(child: Text(widget.userName[0].toUpperCase())),
                SizedBox(width: 10),
                Text('Welcome, ${widget.userName}!', style: TextStyle(fontSize: 20))
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: ['All', 'School', 'Personal', 'Urgent'].map((cat) => ChoiceChip(
              label: Text(cat),
              selected: filterCategory == cat,
              onSelected: (selected) => setState(() => filterCategory = cat),
            )).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return Dismissible(
                  key: Key(todo.title),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) => ref.read(todoProvider.notifier).remove(todo),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) => ref.read(todoProvider.notifier).toggleDone(todo),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now()))
                          Text('Overdue', style: TextStyle(color: Colors.red)),
                        if (todo.category.isNotEmpty)
                          Text('Category: ${todo.category}'),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TodoDetailScreen(todo: todo)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select Theme'),
        content: Consumer(
          builder: (context, ref, _) {
            final current = ref.watch(themeModeProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: current,
                  onChanged: (value) => ref.read(themeModeProvider.notifier).state = value!,
                ),
                RadioListTile(
                  title: Text('Light'),
                  value: ThemeMode.light,
                  groupValue: current,
                  onChanged: (value) => ref.read(themeModeProvider.notifier).state = value!,
                ),
                RadioListTile(
                  title: Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: current,
                  onChanged: (value) => ref.read(themeModeProvider.notifier).state = value!,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TodoDetailScreen extends StatelessWidget {
  final Todo todo;
  TodoDetailScreen({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${todo.title}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Description: ${todo.description}'),
            if (todo.dueDate != null)
              Text('Due Date: ${todo.dueDate!.toLocal().toString().split(' ')[0]}'),
            Text('Category: ${todo.category}'),
          ],
        ),
      ),
    );
  }
}
