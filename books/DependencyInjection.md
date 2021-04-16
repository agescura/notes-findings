# Dependency Injection Principles, Practices and Patterns

## The basics of Dependency Injection: What, why and how

 * Dependency Injection is a set of software design principles and patterns that enables you to develop loosely coupled code.  

 * Program to an interface, not an implementation.

 #### Common myths about DI

 * DI is only relevant for late binding.
 * DI is only relevant for unit testing.
 * DI is a sort of Abstract Factory on steroids. Be careful with Service Locators, is the opposite of DI.
 * DI requires a DI Container. There are Pure DI implementations without DI Container. DI is a set of principles and patterns, and a DI Container is a useful, but optional tool.

 #### Understanding the purpose of DI

 * DI isn't an end goal.
 * DI enables loose coupling, and loose coupling makes code more maintainable.

 #### Hello DI in Swift!

* A simple example

 ```swift
let writer: MessageWriter = ConsoleMessageWriter()
let salutation = Salutation(writer)
salutation.exclaim()
```

* Salutation class encapsulates the main application logic

 ```swift
class Salutation {
    
    private let writer: MessageWriter
    
    init(_ writer: MessageWriter) {
        self.writer = writer
    }
    
    func exclaim() {
        writer.write("Hello DI")
    }
}
```

* Constructor injection is the act of statically defining the list of required dependencies by specifying thtem as parameters to the class's constructor.
* We can say MessageWriter dependency is injected into the Salutation class using a constructor argument.

```swift
protocol MessageWriter {
    func write(_ message: String)
}

class ConsoleMessageWriter: MessageWriter {
    
    func write(_ message: String) {
        print(message)
    }
}
```

* ConsoleMessageWriter class implements MessageWriter by wrapping print from Swift Standard Library.

#### Benefits of DI

* Late binding. Services can be swapped with other services without recompiling code.
* Extensibility. Code can be extended and reused in ways not explicity planned for.
* Parallel development. Code can be developed in parallel.
* Maintainability. Classes with clearly defined responsibilities are easier to maintain.
* Testability. Classes can be unit tested.

#### Extensibility example

```swift
class SecureMessageWriter: MessageWriter {
    
    private let writer: MessageWriter
    private let identity: Identity
    
    init(writer: MessageWriter, identity: Identity) {
        self.writer = writer
        self.identity = identity
    }
    
    func write(_ message: String) {
        if identity.isAuthenticated {
            writer.write(message)
        }
    }
}

protocol Identity {
    var isAuthenticated: Bool { get }
}

class PersonalIdentity: Identity {
    
    private let uuid: UUID
    private(set) var isAuthenticated: Bool
    
    init(_ uuid: UUID, isAuthenticated: Bool) {
        self.uuid = uuid
        self.isAuthenticated = isAuthenticated
    }
}
```

```swift
let secureWriter: MessageWriter = SecureMessageWriter(
    writer: ConsoleMessageWriter(),
    identity: PersonalIdentity(UUID.init(), isAuthenticated: false)
)
let salutation = Salutation(
    writer: secureWriter
)
salutation.exclaim()
```