# Dependency Injection Principles, Practices and Patterns

## All examples are in Swift Language
#

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

* The Salutation class encapsulates the main application logic

 ```swift
class Salutation {
    
    private let writer: MessageWriter
    
    init(_ writer: MessageWriter) {
        self.writer = writer
    }
    
    func exclaim() {
        writer.write("Hello DI!")
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

* The ConsoleMessageWriter class implements MessageWriter by wrapping print from Swift Standard Library.

#### Benefits of DI

* Late binding. Services can be swapped with other services without recompiling code.
* Extensibility. Code can be extended and reused in ways not explicity planned for.
* Parallel development. Code can be developed in parallel.
* Maintainability. Classes with clearly defined responsibilities are easier to maintain.
* Testability. Classes can be unit tested.

#### Extensibility example

* Successful software must be able to change. You'll need to add new features and extend existing features. Loose coupling lets you efficiently recompose the application.

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

#### Parallel Development

* Separation of concerns makes it possible to develop code in parallel.
* A module is a group of logically related classes (or components), where a module is independent of and interchangeable with other modules.

#### Maintainability

* Single Responsability Principle
* Open Close Principle

#### Testability

* An application is considered testable when it can be unit tested.
* Unit tests provide rapid feedback on the state of an application.
* Tests isolated from its dependencies.
* Legacy application as any application that isn't covered by unit tests. Michael Feathers.
* Liskov Substitution Principle.

```swift
import XCTest
@testable import DependencyInjection

class DependencyInjectionTests: XCTestCase {

    func test_exclaimWillWriteCorrectMessageToMessageWriter() {
        let writer = SpyMessageWriter()
        let sut = Salutation(writer: writer)
        sut.exclaim()
        XCTAssertEqual(
            "Hello DI!",
            writer.writtenMessage)
    }

    private class SpyMessageWriter: MessageWriter {
        var writtenMessage = ""
        
        func write(_ message: String) {
            writtenMessage = message
        }
    }
}
```


 #### DI Scope

* Classes shouldn't have to deal with the creation of their dependencies.
* Object Composition: a class also loses the ability to control the lifetime of the object.
* Object Composition, Interception and lifetime management are three dimensions of DI.
* Dependency Injection or Inversion of Control?

##### Object LifeTime

```swift
let writer1 = ConsoleMessageWriter()
let writer2 = ConsoleMessageWriter()
        
let salutation = Salutation(writer: writer1)
let valediction = Valediction(writer: writer2)
```

```swift
let writer = ConsoleMessageWriter()
        
let salutation = Salutation(writer: writer)
let valediction = Valediction(writer: writer)
```

* Because dependencies can be shared, a single consumer can't possibly control its lifetime.
* When dependencies implements a disposable protocol, things become much more complicated.

#### Interception

* Interception is an application of the decorator design pattern.

### Summary

* DI is nothing more than a collection of design principles and patterns. It's more about a way of thinking and designing code than it is about tools and techniques.
* The purpose of DI is to make code maintainable.

## Writing tightly coupled code

* An example that implements a data layer (is a database), a domain layer (logic cases) and a UI Layer (mvc pattern).
