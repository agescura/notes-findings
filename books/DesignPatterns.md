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
