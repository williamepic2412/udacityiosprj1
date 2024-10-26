import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo {
    let id: UUID?
    var title: String?
    var isCompleted: Bool?
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {

}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {

}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {

}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)`
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {
    func listTodos() {

    }
    func addTodo(with title: String) {

    }
    func toggleCompletion(forTodoAtIndex index: Int) {

    }
    func deleteTodo(atIndex index: Int) {

    }
}


// * The `App` class should have a `func run()` method, this method should perpetually
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {
    enum Command {
        case add
        case list
        case toggle
        case delete
        case exit
    }

    func run() {
        var command: Command = .add

        while(true) {
            guard let userInput = readLine() else {
                print("Incorrect input!")
                return
            }
            switch userInput {
                case "add":
                    command = .add
                case "list":
                    command = .list
                case "toggle":
                    command = .toggle
                case "delete":
                    command = .delete
                case "exit":
                    command = .exit
                default:
                    print("Incorrect input!")
                    break
            }
            if (command == .exit) {
                break
            } else {
                print(userInput)
            }
        }
        print("app will exit!")
    }
}

// TODO: Write code to set up and run the app.
let startApp = App()
startApp.run()
