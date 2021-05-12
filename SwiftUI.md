# Notas de SwiftUI

## Empezando con SwiftUI

```swift
import SwiftUI
```

Las vistas se declaran como struct

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

View es un protocol, es un comportamiento. Pero ¿qué es una View?

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol View {
    associatedtype Body : View
    @ViewBuilder var body: Self.Body { get }
}
```

Una View implementa un body que es de tipo some View. Significa que cualquier objeto que tenga el mismo comportamiento que View, será valido. Para más información, mirar Opaque Types en Swift.

Una view puede ser Text.

```swift
    Text("Hello, World!")
```

A este texto le podemos añadir muchas propiedades con notación declarativa. Por ejemplo, foregroundColor, que cambia el color del texto.

```swift
    Text("Hello, World!")
        .foregroundColor(.red)
```

También podemos hacer que la letra salga en negrita con bold.

```swift
    Text("Hello, World!")
        .foregroundColor(.red)
        .bold()
```

## ¿Todo de memoria? Hola Inspector

Si pones el cursor encima de Text y usas opción más click, verás un popup. Selecciona Show SwiftUI Inspector. Gracias a este menú, podemos cambiar los parámetros de Text.

Podemos ir añadiendo propiedades gracias a este menú.

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.purple)
            .bold()
            .padding(30.0)
            .frame(width: 200.0, height: 400.0)
            .cornerRadius(40.0)
            .background(Color.orange)
    }
}
````

También podemos crear Stacks con este menú, hay tres tipus Horizontales, Verticales y ZStack. Ahora creamos una VStack con el menú.

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Notes")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(30.0)
                .background(Color.blue)
                .cornerRadius(15.0)

            Text("This had a red border")
                .border(.red, width: 1)
        }
    }
}

````
