# Notas de Concurrency con Swift

## Empezando con Concurrency

En ciencias de la computación, concurrencia se refiere a la habilidad de distintas partes de un programa, algoritmo, o problema de ser ejecutado en desorden o en orden parcial, sin afectar el resultado final. 

## GCD & Operations

GCD es la implementación de libdispatch para Apple. Su propósito es poner en cola tareas, ya sea un método o una clausura. Se pueden ejecutar en paralelo, dependiendo de la disponibilidad de los recursos.

GCD se gestiona usando colas de tipo FIFO (First In, First Out).

Las colas se pueden ejecutar de forma síncrona o asíncrona. Cuando ejecutas una tarea síncrona, tu aplicación esperará, bloqueará el ciclo de ejecución actual hasta que finalice dicha tarea para ir a la siguiente tarea.
Una tarea asíncrona empezará, pero no bloqueará el ciclo de ejecución.

```swift
let queue = DispatchQueue(label: "queue-identifier")
queue.async {
  DispatchQueue.main.async {
} }
```

Las colas se pueden ejecutar en serie o de forma concurrente. Una cola concurrente utilizará tantos hilos en función de los recursos libres del sistema.

Asíncrono no significa concurrente. Ser síncrono o asíncrono simplemente identifica si la cosa en la que se está ejecutando la tarea debe esperar a que se complete antes de que puede generar la siguiente.
En serie o concurrente identifica si la cola tiene un solo hilo o varios hilos disponibles.

En otras palabras, una tarea síncrona o no habla de la fuente de la tarea. En serie o concurrente habla del destino de la tarea.

Las operaciones son clases completamente funcionales que se pueden enviar a una cola de operaciones. Al ser clases, podemos conocer los estados en los que se encuentra la operación.
* isReady
* isExecuting
* isCancelled
* isFinished

Una operación se ejecuta de forma síncrona por defecto. En general las operaciones las envias a la cola de operaciones.

Si queremos gestionar operaciones podemos usar la clase BlockOperation.

No hay directiva clara sobre cuándo usar GCD o Operations. GCD es más sencillo. Las operaciones se usan cuando necesitamos tener un control de un trabajo, como cancelarlo.

## Queues & Threads

Una aplicación iOS es un proceso que ejecuta múltiples tareas utlizando múltiples threads. Puede tener tantos subprocesos ejecutándose a la vez como núcleos tenga en la CPU de su dispositivo.

* Ejecución más rápida. Al ejecutar tareas en threads es posible realizar el trabajo al mismo tiempo, lo que le permitirá terminar más rápido que ejecutar todo en serie.

* Responsiveness (capacidad de respuesta). si solo realiza trabajas visibles para el usuario en el main UI Thread, los usuarios no notarán que la aplicación se ralentiza o se congela periódicamente debido al trabajo que podría realizarse en otro subproceso.

* Consumo de recursos optimizado. Los threads están altamente optimizados por el sistema operativo.

```swift
let label = "serial-queue-identifier"
let queue = DispatchQueue(label: label)
```

Cuando tu aplicación inicia, se crea el main dispatch queue automáticamente. Es una cola en serie que se responsabiliza de la UI. Puedes acceder con DispatchQueue.main.

Nunca querrás ejecutar algo de forma síncrona en la main queue, a menos que esté relacionado con el trabajo real de la UI. De lo contrario, bloquearás la UI, lo que podría degradar el rendimiento de la aplicación.

Si quieres crear una cola concurrente.

```swift
let label = "concurrent-queue-identifier"
let queue = DispatchQueue(label: label, attributes: .concurrent)
```

Existen seis tipos de colas concurrentes que dependen del Quality of service.

```swift
let queue = DispatchQueue.global(qos: .userInteractive)
```

* .userInteractive para tareas donde el usuario interactua directamente con la UI. Tienen que ser tareas muy rápidas o bloquearás la UI. En general, serán calculos sobre la UI, animaciones o procesos relacionados con la UI.

* .userInitiated para tareas rápidas pero que pueden hacerse asíncronamente. Por ejemplo, un acceso a un documento o leer de la base de datos cuando haces tap a un botón.

* .utility en general se usa para tareas donde quieres mostrar un progress view. Tareas largas o llamadas a la red.

* .background para tareas donde no haya interacción con el usuario. Una sincronización de datos, backups en segundo plano o mantenimiento de la base de datos, pueden ser ejemplos. Aquí hay una limitación, si el dispositivo tiene poca bateria puede que el sistema operativo no lo ejecute.

* .default y .unspecified no deberías usarlos.

Cómo añadir una tarea a una cola.

```swift
DispatchQueue.global(qos: .utility).async { [weak self] in
  guard let self = self else { return }
  
  /// Aquí pon tu código que quieres ejecutar 

  DispatchQueue.main.async {
    self.textLabel.text = "Tarea finalizada"
  }
}
```

Nunca llame síncronamente desde el main thread, ya que bloquearás el main thread. Podrías causar lo que se llama un deadlock.

```swift
DispatchQueue.main.sync {}
```

Para una collection view donde se muestran imágenes que vienen de internet usaremos una cola con .utility.

Tenemos también DispatchWorkItem

```swift
let queue = DispatchQueue(label: "job")
let workItem = DispatchWorkItem {
    print("The block of code ran!")
}
queue.async(execute: workItem)
```

Un DispatchWorkItem funciona igual que DispatchQueue. Además, puedes llamar a cancel()
Si la tarea no ha empezado aún, la eliminará; si está ejecutándose, se isCancelled se pondrá a true.

## Groups & Semaphores

Dispatch Groups para agrupar jobs.
Descargar de internet debería siempre ser una operación asíncrona.

Para controlar el número de threads se pueden usar semáforos.

## Concurrency Problems

Race Conditions son threads que comparten el mismo proceso. El problema de guardar la misma variable en el mismo tiempo.
Se soluciona con una cola en serie.

```swift
private let threadSafeCountQueue = DispatchQueue(label: "...")
private var _count = 0
public var count: Int {
  get {
    return threadSafeCountQueue.sync { _count }
} set {
    threadSafeCountQueue.sync {
      _count = newValue
    }
} }
```

Thread Barrier representa un escenario de tipo lector/escritor. Permita leer con una cola concurrente, pero cuando escriba, bloquee la cola.

```swift
private let threadSafeCountQueue = DispatchQueue(label: "...", attributes: .concurrent)
private var _count = 0
public var count: Int {
  get {
    return threadSafeCountQueue.sync {
      return _count
    }
} set {
    threadSafeCountQueue.async(flags: .barrier) { [unowned self] in
      self._count = newValue
} }
}
```

Deadlock, ojo al bloquear dos colas que dependan entre si. Nunca terminarán.

Priority Inversion ocurre cuando una cola con una calidad de servicio más baja recibe una prioridad del sistema más alta. En general, evite mezclar colas con calidades de servicio diferentes.

## Operations

Las operaciones son reusables, GCD son de usar y tirar.


Operation -> isReady -> isExecuting -> isCancelled -> IsFinished
                                    -> isFinished

```swift
let operation = BlockOperation {
    print("2 + 3 = \(2 + 3))
}
```

Las tareas en una BlockOperation corren concurrentemente.

## Operation Queues

El poder real de las operaciones empieza con las OperationQueues.

Tenemos un método waitUntilAllOperationAreFinished que bloquea la cola hasta que todas las operaciones terminen.

Tienen un QoS que por defecto es .background

Puedes pausar una queue, puedes establecer un líminte de número de operaciones.

Por ejemplo, puedes crear una cola en un ViewController

```swift
private let queue = OperationQueue()
```

Podemos crear una operación custom, por lo general, tendrá un valor de entrada o ninguno y alguna salida. Sobreescribe el método main que és donde se procesará la operación como tal.

```swift
final class CustomOperation: Operation {
  var output: ......

  private let input: ....
  init(input: .....) {
    inputImage = image
    super.init()
  }

  override func main() {
    // Do the operation
    self.output = ....
  }
}
```

Imagina que tienes que procesar la operación en cada una de las celdas a modo de cargar una URL o hacer muchas mutaciones largas.

Dentro del cellForRow

```swift
let op = CustomOperation(input: ....)
op.completionBlock = {
    DispatchQueue.main.async {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        // Terminar de configurar la celda
    }
}
queue.addOperation(op)
```

## Asynchronous Operations

Hasta el momento, las operaciones son síncronas.
Las operaciones usan las notificaciones KVO

## Operation Dependencies

