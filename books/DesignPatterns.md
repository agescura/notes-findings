# Patrones de diseño - Elementos de software orientado a objetos reutilizable

## Todos los ejemplos están en el lenguaje Swift

* Cada patrón describe un problema que ocurre una y otra vez en nuestro entorno, así como la solución a ese problema, de tal modo que se pueda aplicar esta solución un millón de veces, sin hacer lo mismo dos veces.

* Nombre del patrón
* El problema
* La solución
* Las consecuencias, ventajas e inconvenientes

## Modelo/Vista/Controlador

* El modelo es el objeto de aplicación.
* La vista es su representación en pantalla.
* El controlador define el modo en que la interfaz reacciona a la entrada del usuario.
* MVC desacopla las vistas de los modelos estableciendo entre ellos un protocolo de suscripción/notificación. Aparece el patrón Observer.
* Vistas anidadas. El patrón Composite.
* La relación entre la vista y el controlador es un ejemplo del patrón Strategy.
* También puede aparecer una factoría y un decorador.

## Patrones de creación

* Abstraen el proceso de creación de instancias

### Abstract Factory

* Proporciona una interfaz para crear familias de objetos relacionados o que dependen entre sí, sin especificar sus clases concretas.

Imaginemos que tenemos un parking con coches, que tienen, por ejemplo, motor diesel. Para tener coches, tienen que crearse de una fábrica. Dicho almacén será la factoria.

 ```swift
class Car {
    let motor = "diesel"
}

class Factory {
    func createCar() -> Car {

    }
}

let parking: [Car] = [
    Car(),
    Car()
]

parking.map { print($0.motor) }
```

Genial, pero, ahora queremos añadir un vehiculo más.

 ```swift
class Moto: Vehicle {
    let motor = "petrol"
}

let parking: [Car] = [
    Car(),
    Moto()
]
```

Aquí podemos ver, que la cosa va complejizándose. Vamos a crear la factoría.

 ```swift
protocol VehicleFactory {
    func create(vehicle: String) -> Vehicle?
}

enum VehicleProducerError: Error {
    case failed
}

class VehicleProducer: VehicleFactory {
    func create(vehicle: String) -> Vehicle? {
        if vehicle == "car" {
            return Car()
        } else if vehicle == "moto" {
            return Moto()
        }
        return nil
    }
}
```

Con lo cual, se nos quedará lo siguiente.

 ```swift
let factory = VehicleProducer()

let parking: [Vehicle] = [
    factory.create(vehicle: "car")!,
    factory.create(vehicle: "moto")!,
]

parking.map { print($0.motor) }
```

Esto ya tiene buena pinta. Y si ahora, ¿añadimos una bicicleta?

 ```swift
class Bike: Vehicle {
    let motor = "none"
}

class VehicleProducer: VehicleFactory {
    func create(vehicle: String) -> Vehicle? {
        if vehicle == "car" {
            return Car()
        } else if vehicle == "moto" {
            return Moto()
        } else if vehicle == "bike" {
            return Bike()
        }
        return nil
    }
}

let factory = VehicleProducer()

let parking: [Vehicle] = [
    factory.create(vehicle: "car")!,
    factory.create(vehicle: "moto")!,
    factory.create(vehicle: "bike")!,
]

parking.map { print($0.motor) }
```

Pues ya lo tendríamos.

* Ventajas. 
Es un patrón bien interesante cuando necesitamos construir objetos diferentes que cumplan una determinada interfaz, por ejemplo, los mensajes de un chat.

* Desventajas. Un nuevo vehículo, implica extender la factoría.

### Builder

* Separa la construcción de un objeto complejo de su representación, de forma que el mismo proceso de construcción pueda crear diferentes representaciones.

Este es un ejemplo práctico de como usar el patrón builder para generar textos con diferentes formatos.

 ```swift
public extension NSMutableAttributedString {
    @discardableResult 
    func bold(_ text: String, size: Double) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: CGFloat(size))]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)

        return self
    }
    
    @discardableResult
    func normal(_ text: String) -> NSMutableAttributedString {
        let regularString = NSMutableAttributedString(string: text, attributes: nil)
        append(regularString)
        
        return self
    }
}
```

¿Cómo se usa este patrón? Así.

 ```swift
let emptyAttributedString = NSMutableAttributedString()

let helloString = emptyAttributedString
    .normal("Hola, ")

let helloWorldString = NSMutableAttributedString()
    .normal("Hola, ")
    .bold("¡MUNDO!", size: 24)

let worldHelloString = NSMutableAttributedString()
    .bold("¡MUNDO!", size: 24)
    .normal("Hola, ")
```

Con este patrón, estamos generando múltiples construcciones posibles de una forma sencilla y elegante.

### Factory Method

* Define una interfaz para crear un objeto, pero deja que sean las subclases quienes decidan qué clase instanciar. Permite que una clase delegue en sus subclases la creación de objetos.

 ```swift
let factory = Factory()
let product1 = factory.createProduct1()
let product2 = factory.createProduct2()
```

 ```swift
protocol FactoryProtocol {
    func createProduct() -> ProductProtocol
}

class Factory: FactoryProtocol {

    func createProduct() -> ProductProtocol {
        Product()
    }
}

protocol ProductProtocol {}

class Product: ProductProtocol {}

let factory = Factory()
let product = factory.createProduct()
```

### Prototype

Especifica los tipos de objetos a crear por medio de una instancia, y crea nuevos objetos copiando dicho prototipo.