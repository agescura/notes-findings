# Advanced Swift

## Built-In Collections

Las constantes definidas con let son inmutables. Pero, ojo, que las clases tienen una referencia y pueden cambiar.

```swift
let numbers = [1, 2, 3, 4, 5, 6]
var mutableNumbers = [1, 2, 3, 4, 5, 6]
mutableNumbers.append(7)
mutableNumbers.append(contentsOf: [8, 9]) // [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

Los arrays son colecciones de la libreria estándard en Swift. Nótese que la copia crea otro objeto.

```swift
var x = [1, 2, 3]
var y = x
y.append(4)
print(x) // [1, 2, 3]
print(y) // [1, 2, 3 , 4]
```

Si usamos NSArray, en cambio, la copia es una referencia.

```swift
let x = NSMutableArray(array: [1,2,3])
let y: NSArray = x
x.insert(4, at: 3)
print(x) // [1, 2, 3, 4]
print(y) // [1, 2, 3 , 4]

let z = x.copy() as! NSArray
x.insert(5, at: 4)
print(x) // [1, 2, 3, 4, 5]
print(z) // [1, 2, 3, 4]
```

En Swift solo hay un tipo de array y su mutabilidad se controla definiendo var en vez de let. Copy-on-write es una técnica en la que la información se copia solo cuando sea necesario.

### Array Indexing

* isEmpty
* count
* x[3]

### Transforming Arrays

```swift
let integers = [1, 2, 3, 4, 5]
var squared: [Int] = []
for integer in integers {
    squared.append(integer * integer)
}
print(squared) // [1, 4, 9, 16, 25]

let squares = integers.map { $0 * $0 }
print(squares) // [1, 4, 9, 16, 25]

extension Array {

    func map<T>(_ transform: (Element) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        for x in self {
            result.append(transform(x))
        }
        return result
    }
}
```

An example.

```swift
let array: [Int] = [1, 2, 2, 2, 3, 4, 4]
var result: [[Int]] = array.isEmpty ? [] : [[array[0]]]
for (previous, current) in zip(array, array.dropFirst()) {
    if previous == current {
        result[result.endIndex - 1].append(current)
    } else {
        result.append([current])
    }
}
print(result) // [[1], [2, 2, 2], [3], [4, 4]]

extension Array {
    func split(where condition: (Element, Element) -> Bool) -> [[Element]] {
        var result: [[Element]] = array.isEmpty ? []: [[self[0]]]
        for (previous, current) in zip(self, self.dropFirst()) {
            if condition(previous, current) {
                result.append([current])
            } else {
                result[result.endIndex - 1].append(current)
            }
        }
        return result
    }
}

print(array.split { $0 != $1 }) // [[1], [2, 2, 2], [3], [4, 4]]
print(array.split(where: != )) // [[1], [2, 2, 2], [3], [4, 4]]
```

### Mutation and Stateful Closures

```swift
extension Array {
    func accumulate<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, Element) -> Result) -> [Result] {
        var running = initialResult
        return map { next in
            running = nextPartialResult(running, next)
            return running
        }
    }
}

print([1, 2, 3, 4].accumulate(0, +)) // [1, 3, 6, 10]
```

### Filters

```swift
let integers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
print(integers.filter { $0 % 2 == 0 }) // [2, 4, 6, 8, 10]

print((1..<10).map { $0 * $0 }.filter { $0 % 2 == 1 }) // [1, 9, 25, 49, 81]

extension Array {
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for x in self where isIncluded(x) {
            result.append(x)
        }
        return result
    }
}
```

### Reduce

```swift
let integers = [1, 2, 3, 4, 5]
var total = 0
for num in integers {
    total = total + num
}
print(total) // 15

print(integers.reduce(0) { total, number in total + number }) // 15
print(integers.reduce(0, +)) // 15
print(integers.reduce("") { string, number in string + "\(number), "}) // 1, 2, 3, 4, 5,

extension Array {
    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, Element) -> Result) -> Result {
        var result = initialResult
        for x in self {
            result = nextPartialResult(result, x)
        }
        return result
    }
}

```swift

Con Reduce, podemos crear una nueva versión de map

```swift
extension Array {
    
    func map<T>(_ transform: (Element) -> T) -> [T] {
        reduce([]) {
            $0 + [transform($1)]
        }
    }
    
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        reduce([]) {
            isIncluded($1) ? $0 + [$1] : $0
        }
    }
}
```swift

Cuando usamos inout, el compilador no tiene que crear un nuevo array cada vez.

```swift
extension Array {
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        reduce(into: []) { (result, element) in
            if isIncluded(element) {
                result.append(element)
            }
        }
    }
}
```swift

### A Flattening Map

Con flatMap podemos combinar elementos de diferentes sources.

extension Array {
    
    func flatMap<T>(_ transform: (Element) -> [T]) -> [T] {
        var result: [T] = []
        for x in self {
            result.append(contentsOf: transform(x))
        }
        return result
    }
}

let suits = ["1", "2", "3", "4"]
let ranks = ["a", "b", "c", "d"]

suits.flatMap { suit in
    ranks.map { rank in
        (suit, rank)
    }
}

## Dictionaries

