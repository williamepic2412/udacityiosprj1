import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: CustomStringConvertible, Encodable, Decodable {
    var id: UUID
    var title: String
    var isCompleted: Bool

    // Custom initializer to auto-generate UUID
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false // Default to not completed
    }

    // Conforming to CustomStringConvertible for a custom string representation
    var description: String {
        return "\(isCompleted ? "✅" : "❌") \(title)"
    }
}

func getDocumentsDirectory() -> URL {
    // Get the paths for the user's document directory
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    // Return the first path (which is the documents directory)
    return paths[0]
}

enum Status {
    case success
    case failedCache
    case noIndex
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo]) -> Bool
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.
final class FileSystemCache: Cache {
    private let fileURL: URL

    init() {
        fileURL = getDocumentsDirectory().appendingPathComponent("todos.json")
    }

    func save(todos: [Todo]) -> Bool {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(todos)
            try data.write(to: fileURL)
            return true // Successfully saved
        } catch {
            print("Failed to save todos to file: \(error)")
            return false // Save failed
        }
    }

    func load() -> [Todo]? {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: fileURL)
            let todos = try decoder.decode([Todo].self, from: data)
            return todos
        } catch {
            print("Failed to load todos from file: \(error)")
            return nil // Load failed
        }
    }
}


// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    private var todos: [Todo] = []

    func save(todos: [Todo]) -> Bool {
        self.todos = todos
        return true // In-memory storage always succeeds
    }

    func load() -> [Todo]? {
        return todos // Return the current in-memory todos
    }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)`
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodosManager {
    private var todos: [Todo] = []
    private let cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
        self.todos = cache.load() ?? [] // Load existing todos
    }

    func addTodo(with title: String) -> Status {
        let newTodo = Todo(title: title)
        todos.append(newTodo)
        // Save the updated todos to cache
        if cache.save(todos: todos) {
            return .success
        } else {
            return .failedCache
        }
    }

    func listTodos() -> [Todo] {
        return todos
    }

    func toggleCompletion(at index: Int) -> Status {
        if index >= 0 && index < todos.count {
            todos[index].isCompleted.toggle()
            // Save the updated todos to cache
            if cache.save(todos: todos) {
                return .success
            } else {
                return .failedCache
            }
        } else {
            return .noIndex
        }
    }

    func delete(at index: Int) -> Status {
        if index >= 0 && index < todos.count {
            todos.remove(at: index)
            // Save the updated todos to cache
            if cache.save(todos: todos) {
                return .success
            } else {
                return .failedCache
            }
        } else {
            return .noIndex
        }
    }
}


// * The `App` class should have a `func run()` method, this method should perpetually
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {
    enum Command {
        case add(String)
        case list
        case toggle(Int)
        case delete(Int)
        case exit
        case help
    }

    private let todosManager: TodosManager

    init(todosManager: TodosManager) {
        self.todosManager = todosManager
    }

    func run() {
        print("Welcome to the Todo App!")
        
        while true {
            print("\nWhat would you like to do? (type 'help' for more infomation): ", terminator: "")
            if let input = readLine() {
                let command = parseCommand(input)
                executeCommand(command)
            }
        }
    }

    private func parseCommand(_ input: String) -> Command {
        let components = input.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        guard let action = components.first else {
            print("No command provided! Displaying 'help':")
            return .help // Default to 'help' panel if no command is given
        }

        switch action {
        case "add":
            if (components.count < 2) {
                print("No to do title provided! Please try again!")
                return .help
            } else if let title = components.last {
                return .add(String(title))
            }
        case "list":
            return .list
        case "toggle":
            if let indexString = components.last, let index = Int(indexString) {
                return .toggle(index)
            }
        case "delete":
            if let indexString = components.last, let index = Int(indexString) {
                return .delete(index)
            }
        case "exit":
            return .exit
        case "help":
            return .help
        default:
            return .help // Default to 'help' panel when an unknown command is given
        }
        return .help // Default to 'help' panel
    }

    private func executeCommand(_ command: Command) {
        var status: Status = .success

        switch command {
        case .add(let title):
            status = todosManager.addTodo(with: title)
            switch status {
            case .success:
                print("Todo added: \(title)")
            default:
                print("Adding Todo failed!")
            }
        case .list:
            let todos = todosManager.listTodos()
            print("Current Todos:")
            for (index, todo) in todos.enumerated() {
                print("\(index + 1): \(todo)")
            }
        case .toggle(let index):
            status = todosManager.toggleCompletion(at: index - 1)
            switch status {
            case .success:
                print("Toggled completion for todo at index \(index).")
            case .noIndex:
                print("No todo found at index \(index)")
            case .failedCache:
                print("Failed to save todos to cache.")
            }
        case .delete(let index):
            status = todosManager.delete(at: index - 1)
            switch status {
            case .success:
                print("Deleted todo at index \(index).")
            case .noIndex:
                print("No todo found at index \(index)")
            case .failedCache:
                print("Failed to save todos to cache.")
            }
        case .exit:
            print("Exiting the app. Goodbye!")
            exit(0) // Exit the application
        case .help:
            print("""
            LIST OF COMMANDS
            ----------------
            - add <To do title>: add a to do into the list
            - list: list all to dos
            - toggle <index>: mark/unmark as 'Done' a to do at an index
            - delte <index>: delete a to do at an index
            - exit: exit the program
            - help: display this message
            ----------------
            """)
        }
    }
}


// TODO: Write code to set up and run the app.
// Create an instance of the caching strategy you want to use
let cache: Cache = FileSystemCache() // or InMemoryCache()

// Initialize the TodosManager with the chosen cache
let todosManager = TodosManager(cache: cache)

// Create an instance of the App class
let app = App(todosManager: todosManager)

// Run the app
app.run()
