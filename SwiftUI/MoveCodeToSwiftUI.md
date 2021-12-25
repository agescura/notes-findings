Siempre que aparece algo nuevo, primero es visto como amenaza y luego como oportunidad. Ocurrió con la llegada de Swift y el miedo de mucha gente a querer aprenderlo. Y ocurre con SwiftUI.
En este artículo, vamos a construir una aplicación en UIKit, analizaremos sus características y luego moveremos la vista hacia SwiftUI.
Dar las gracias, a Point Free (Brandon Williams y Stephen Cellis), por sus videos, su forma de pensar y la forma que tienen por encontrar soluciones sencillas, adecuadas y coherentes.
En este caso, ellos hicieron la presentación de SwiftUI, y luego, fueron a UIKit, para comprobar que todo seguía funcionando igual de bien. En mi caso, he hecho el planteamiento contrario. Empezamos por UIKit. Veremos qué interesante tiene la construcción en UIKit, para encontrar los patrones que nos van a interesar y luego iremos a SwiftUI.
Todo empieza y termina con Combine.
Este es un proyecto que pretende mostrar cómo, a partir de una aplicación existente en UIKit, empezar a moverla hacia SwiftUI.
Para ello, empezaremos diseñando una aplicación, más o menos compleja en UIKit y, introduciremos, SwiftUI tan pronto como podamos. El hecho de tener una aplicación que corra en paralelo, hace que tengamos visibilidad para observar qué patrones en UIKit y en SwiftUI se van repitiendo para reconocerlos mejor.
En principio, no se requiere ningún conocimiento previo en SwiftUI, pero es recomendable haberlo tocado con anterioridad. Conocer Combine es interesante, incluso, tener algo de experiencia en RxSwift o ReactiveSwift.
Antes de empezar
El objetivo es tener una aplicación funcionando, de manera que se comparta el mismo modelo. Nuestro ViewModel estará compartido tanto por la versión en UIKit como en SwiftUI.
¿Cuál es el truco entonces? Los @Published del protocolo ObservableObject. En SwiftUI, la forma de conectar la vista con el viewModel se hace a través de un protocolo que permite reaccionar a cualquier cambio. Eso es posible gracias a @Published. Pero en UIKit, podemos usar un @Published accediendo a su binding directamente. Luego, gracias a Combine, podemos acceder a su valor (y futuras actualizaciones).
La navegación en SwiftUI también cambia, así que iremos explicando cómo construir una navegación declarativa, de forma, que con un deeplink podamos acceder y rellenar los campos de un formulario que nos habíamos dejado a la mitad desde la web, por ejemplo.
Creación del proyecto
Creamos un proyecto nuevo, en SwiftUI. El proyecto empieza con dos objetos, ContentView y AlarmApp. El protocolo App vendría a considerarse el AppDelegate de UIKit. De la misma forma, que el protocolo View en SwiftUI vendría a ser un ViewController.
Aquí tenemos el primer trabajo a realizar, es muy aconsejable, aunque no necesario, dejar de usar nibs, xibs y storyboards. Hay que mover todo a código. Luego será mucho más sencillo controlar el movimiento hacia SwiftUI. Si no lo tienes ya, ves reconsiderando una estrategia para ello.
SwiftUIWrapper
Nuestra primera tarea va a ser poder previsualizar una pantalla UIKit en SwiftUI, para ello, crearemos un nuevo archivo llamado SwiftUIWrapper.

```swift
import SwiftUI

struct SwiftUIWrapper: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIViewController

  let viewController: () -> UIViewController

  func makeUIViewController(
    context: Context
  ) -> UIViewController {
    self.viewController()
  }

  func updateUIViewController(
    _ uiViewController: UIViewController,
    context: Context
  ) {}
}
```

Gracias a este wrapper, podremos previsualizar en Xcode, cualquier ViewController de UIKit.
TabBarViewController
Vamos a crear nuestro primer ViewController, crea un nuevo archivo llamado TabBarViewController. Pondremos algo sencillo para empezar, nada complejo. Un TabBar con tres items y cada vista con un color de fondo para diferenciarse.

```swift
import UIKit
class TabBarViewController: UITabBarController {
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let clockLabel = UILabel()
    clockLabel.text = "Clock"
    clockLabel.sizeToFit()
    let clock = UIViewController()
    clock.tabBarItem.title = "Clock"
    clock.view.addSubview(clockLabel)
    clockLabel.center = clock.view.center
 
    let alarmsLabel = UILabel()
    alarmsLabel.text = "Alarms"
    alarmsLabel.sizeToFit()
    let alarms = UIViewController()
    alarms.tabBarItem.title = "Alarms"
    alarms.view.addSubview(alarmsLabel)
    alarmsLabel.center = alarms.view.center
    let cronoLabel = UILabel()
    cronoLabel.text = "Crono"
    cronoLabel.sizeToFit()
    let crono = UIViewController()
    crono.tabBarItem.title = "Crono"
    crono.view.addSubview(cronoLabel)
    cronoLabel.center = crono.view.center
 
    self.setViewControllers([clock, alarms, crono], animated: false)
  }
}
```

Ahora, copia la preview que tienes en el ContentView y adáptala para poder usar estre TabBar. Debajo pon lo siguiente:

```swift
import SwiftUI
struct TabBarViewController_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIWrapper {
      TabBarViewController()
    }
  }
}
```

Pues bien, ya tenemos nuestro primer controllador UIKit, previsualizándose en SwiftUI. Nuestro pequeño viaje ha empezado.

Por último, si quisieramos arrancar el simulador, lo que tendremos que hacer es copiar el contenido que tenemos en el preview, dentro del AlarmApp

```swift
import SwiftUI
@main
struct AlarmApp: App {
  var body: some Scene {
     WindowGroup {
       SwiftUIWrapper {
         TabBarViewController()
       }
     }
  }
}
```

TabBarView

Ya tenemos una primera pantalla, un TabBarViewController funcionando dentro de un proyecto en SwiftUI, ¿pero cómo se crea un TabBar en SwiftUI? Vamos a verlo a continuación.
Crearemos un nuevo archivo llamado TabBarView y escribimos una versión inicial en SwiftUI:

```swift
import SwiftUI

struct TabBarView: View {
  var body: some View {
    TabView {
      Text("Clock")
        .tabItem { Text("Clock") }
      Text("Alarms")
        .tabItem { Text("Alarms") }
      Text("Crono")
        .tabItem { Text("Crono") }
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var previews: some View {
    TabBarView()
  }
}
```

Como era de esperar, para hacer lo mismo, se escriben las mismas lineas. Lo que necesitamos ahora es poder guardar el estado del TabBar, por ello crearemos un ViewModel y guardaremos el estado. Crearemos un archivo nuevo llamado TabBarViewModel.

```swift
import Foundation
import Combine

enum Tab {
  case clock, alarms, crono
}

class TabBarViewModel: ObservableObject {
  @Published var selectedTab: Tab

  init(selectedTab: Tab) {
    self.selectedTab = selectedTab
  }
}
```

Con este ViewModel, actualizaremos el TabBarView de forma que el TabView pueda leer el estado actual del ViewModel, esto se consigue pasándole el Binding por el constructor y luego, para que sepa actualizar su estado, a cada Tab le asignaremos una etiqueta, que será el case adecuado.

```swift
import SwiftUI

struct TabBarView: View {
  @ObservedObject var viewModel: TabBarViewModel

  var body: some View {
    TabView(
      selection: self.$viewModel.selectedTab
    ) {
      Text("Clock")
        .tabItem { Text("Clock") }
        .tag(Tab.clock)
      
      Text("Alarms")
        .tabItem { Text("Alarms") }
        .tag(Tab.alarms)
      Text("Crono")
        .tabItem { Text("Crono") }
        .tag(Tab.crono)
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var previews: some View {
    TabBarView(
      viewModel: .init(
        selectedTab: .alarms
      )
    )
  }
}
```

Si arrancamos la previsualización, veremos que ahora el valor por defecto es el de las alarmas. Vamos muy bien!

Juntando UIKIt y SwiftUI

Antes de pasar a implementar una de las pantallas principales. Vamos a poner todo junto. Crearemos, de nuevo, un nuevo archivo llamado MainView:

```swift
import SwiftUI

struct MainView: View {
  @State var isSwiftUI: Bool
  @ObservedObject var viewModel: TabBarViewModel

  var body: some View {
    VStack {
      Button(
        isSwiftUI ? "Use UIKit" : "Use SwiftUI"
      ) {
        self.isSwiftUI.toggle()
      }
      if self.isSwiftUI {
        TabBarView(viewModel: viewModel)
      } else {
        SwiftUIWrapper {
          TabBarViewController()
        }
      }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(
      isSwiftUI: true,
      viewModel: .init(selectedTab: .alarms)
   )
  }
}
```

Podemos ver la previsualización, pero nos falta una cosa.

El TabBarViewController no usa el selectedTab. Bien vamos a eso. Actualizaremos el TabBarViewController

```swift
import UIKit
import Combine

class TabBarViewController: UITabBarController {
  let viewModel: TabBarViewModel
  private var cancellables: Set<AnyCancellable> = []
  
  init(viewModel: TabBarViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let clockLabel = UILabel()
    clockLabel.text = "Clock"
    clockLabel.sizeToFit()
    let clock = UIViewController()
    clock.tabBarItem.title = "Clock"
    clock.view.addSubview(clockLabel)
    clockLabel.center = clock.view.center
    let alarmsLabel = UILabel()
    alarmsLabel.text = "Alarms"
    alarmsLabel.sizeToFit()
    let alarms = UIViewController()
    alarms.tabBarItem.title = "Alarms"
    alarms.view.addSubview(alarmsLabel)
    alarmsLabel.center = alarms.view.center
    let cronoLabel = UILabel()
    cronoLabel.text = "Crono"
    cronoLabel.sizeToFit()
    let crono = UIViewController()
    crono.tabBarItem.title = "Crono"
    crono.view.addSubview(cronoLabel)
    cronoLabel.center = crono.view.center
    self.setViewControllers([clock, alarms, crono], animated: false)
    
    self.viewModel.$selectedTab
      .sink { [unowned self] tab in
        switch tab {
          case .clock:
          self.selectedIndex = 0
          case .alarms:
          self.selectedIndex = 1
          case .crono:
          self.selectedIndex = 2
        }
    }
    .store(in: &self.cancellables)
    }
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
  guard let index = tabBar.items?.firstIndex(of: item) else { 
    return
  }
  switch index {
    case 0:
    self.viewModel.selectedTab = .clock
    case 1:
    self.viewModel.selectedTab = .alarms
    case 2:
    self.viewModel.selectedTab = .crono
    default:
    break
  }
}
}

import SwiftUI
struct TabBarViewController_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIWrapper {
      TabBarViewController(
        viewModel: .init(selectedTab: .alarms)
      )
    }
  }
}
```

Añadimos el mismo ViewModel que en el TabBarView. Tenemos que actualizar dos bindings. El primer será cuando el TabBar cambia, a través del método didSelect del UITabBarController.
Y, por otro lado, necesitamos actualizar el TabBar si cambia el ViewModel. Esto es posible, accediendo al Binding que nos ofrece el @Published del ObservableObject.
Por último, para que compile el proyecto tenemos que actualizar el MainView:

```swift
SwiftUIWrapper {
  TabBarViewController(viewModel: viewModel)
}
```

Y, también, el App.

```swift
import SwiftUI

@main
struct AlarmApp: App {
  var body: some Scene {
    WindowGroup {
      SwiftUIWrapper {
        MainView(
          isSwiftUI: true,
          viewModel: .init(selectedTab: .alarms)
        )
      }
    }
  }
}
```

Mejoremos un poco el código

Llegado aquí, hay varias cosas que mejor cambiar, antes de continuar. Lo primero, ya no necesitaremos el fichero ContentView, así que lo borramos.
MainView tiene como ViewModel TabBarViewModel. Esto no sería del todo correcto. Crea otro fichero MainViewModel

```swift
import Foundation
import Combine

class MainViewModel: ObservableObject {
  @Published var isSwiftUI = false
  @Published var tabBarViewModel: TabBarViewModel
  init(
    isSwiftUI: Bool = false,
    tabBarViewModel: TabBarViewModel
  ) {
    self.isSwiftUI = isSwiftUI
    self.tabBarViewModel = tabBarViewModel
  }
}
```

Y, ahora, tenemos que actualizar los errores de compilación cuando cambiemos el ViewModel en el MainView.

```swift
import SwiftUI

struct MainView: View {
  @ObservedObject var viewModel: MainViewModel
  
  var body: some View {
    VStack {
      Button(
        self.viewModel.isSwiftUI ? "Use UIKit" : "Use SwiftUI"
      ) {
        self.viewModel.isSwiftUI.toggle()
      }
      if self.viewModel.isSwiftUI {
        TabBarView(viewModel: self.viewModel.tabBarViewModel)
      } else {
        SwiftUIWrapper {
        TabBarViewController(viewModel: self.viewModel.tabBarViewModel)
        }
      }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(
      viewModel: .init(
        isSwiftUI: true,
        tabBarViewModel: .init(selectedTab: .alarms)
      )
    )
  }
}
```

Y, actualizaremos, la entrada al proyecto con lo siguiente:

```swift
import SwiftUI

@main
struct AlarmApp: App {
  var body: some Scene {
    WindowGroup {
      MainView(
        viewModel: .init(
          isSwiftUI: true,
          tabBarViewModel: .init(selectedTab: .alarms)
        )
      )
    }
  }
}
```

Nuestro primer deeplink
Llegado a este punto, ¿por qué no empezamos a crear un primer deeplink? Para activar un deeplink, iremos a nuestro target, seleccionaremos la pestaña Info y añadiremos un nuevo URL Types.

El método onOpenURL es el encargado de recibir un deeplink. Añadiremos este método en el MainView.

```swift
struct MainView: View {
@ObservedObject var viewModel: MainViewModel
  var body: some View {
    VStack {
      Button(
        self.viewModel.isSwiftUI ? "Use UIKit" : "Use SwiftUI"
      ) {
        self.viewModel.isSwiftUI.toggle()
      }
      if self.viewModel.isSwiftUI {
        TabBarView(viewModel: self.viewModel.tabBarViewModel)
      } else {
        SwiftUIWrapper {
          TabBarViewController(viewModel: self.viewModel.tabBarViewModel)
        }
      }
    }
    .onOpenURL { self.viewModel.open(url: $0) }
  }
}
```

Para que compile el código añadiremos la función en el ViewModel, con lo mínimo para que funcione.

```swift
func open(url: URL) {
  guard let tab = Tab(rawValue: url.lastPathComponent) else { 
    return
  }
  self.tabBarViewModel.selectedTab = tab
}
```

Tendremos un fallo en la compilación, con el enum Tab. Añade el protocolo String al Tab para que tengamos acceso al constructor por defecto.

```swift
enum Tab: String {
  case clock, alarms, crono
}
```

Hay varias formas de probar que un deeplink funciona. Una muy interesante es, a través de una aplicación de Paul Hudson llamada ControlRoom.
https://github.com/twostraws/ControlRoom
Descárgate el proyecto, ejecútalo, lo archivas y te guardas la aplicación para usar. Una vez todo esto, arranca el simulador y prueba los tres deeplinks que tenemos hasta el momento.
deeplink:///clock
deeplink:///alarms
deeplink:///crono

Debería funciona tanto en SwiftUI, como en UIKit.
Reorganizar el proyecto
Vamos a crear unas cuantas carpetas, para ordenar un poco el proyecto. Crea unas carpetas, SwiftUI, UIKit, Util y Resources.

El compilador dará un error. Actualiza el error, añadiendo la carpeta Resources al path.

Ya hemos iniciado la construcción de una nueva aplicación. De momento, tenemos solamente, la estructura base para poder visualizar un componente en SwiftUI y en UIKit. Tenemos un TabBar y, también, hemos creado un primer deeplink, lo más sencillo posible.

Ahora vamos a construir un listado de alarmas. Para ello, crearemos un fichero AlarmsListViewController.

```swift
import UIKit
import Combine

class AlarmsListViewController: UIViewController {
  let viewModel: AlarmsListViewModel
  private var cancellables: Set<AnyCancellable> = []
  init(viewModel: AlarmsListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Alarms"
  }
}

import SwiftUI

struct AlarmsListViewController_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIWrapper {
      UINavigationController(
        rootViewController: AlarmsListViewController(
          viewModel: .init()
        )
      )
    }
  }
}
```

Vamos a necesitar un ViewModel llamado AlarmsListViewModel.

```swift
class AlarmsListViewModel: ObservableObject {
}
```

En nuestro listado de alarmas, vamos a necesitar un modelo para las alarmas. Empezaremos con uno sencillo. Crea en el mismo ViewModel, al principio, esto.

```swift
struct AlarmItem: Identifiable, Hashable {
  let id: UUID
  var date: Date
  var isOn: Bool
}
```

Actualizaremos el ViewModel para que podamos pasarle las alarmas por el constructor.

```swift
class AlarmsListViewModel: ObservableObject {
  @Published var items: [AlarmItem]
 
  init(items: [AlarmItem] = []) {
    self.items = items
  }
}
```

Ahora actualizaremos el preview introduciendo unos valores por defecto.

```swift
import SwiftUI
struct AlarmsListViewController_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIWrapper {
      UINavigationController(
        rootViewController: AlarmsListViewController(
          viewModel: .init(
            items: [
              .init(id: .init(), date: .init(), isOn: false),
              .init(id: .init(), date: .init(), isOn: true),
              .init(id: .init(), date: .init(), isOn: false)
            ]
          )
        )
      )
    }
  }
}
```

Ahora ya podemos visualizar, la pantalla con unos valores adecuados. Tan “solo” necesitaremos implementar la pantalla.

Para el listado, necesitaremos una UITableView y necesitamos crear una celda de tipo UITableViewCell. Crea un fichero nuevo llamado AlarmItemCell. Vamos a crear una stack vertical con dos labels y luego una stack horizontal con la stack anterior y otro label a la derecha que nos informará si la alarma está activada.

```swift
import UIKit
class AlarmItemCell: UITableViewCell {
  let nameLabel = UILabel()
  let descriptionLabel = UILabel()
  let activateLabel = UILabel()
  let verticalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
  }()
  let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = UIStackView.spacingUseSystem
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.distribution = .equalCentering
    return stackView
  }()
 
  func bind(viewModel: AlarmItem) {
    selectionStyle = .none
    nameLabel.text = viewModel.name
    nameLabel.textColor = viewModel.isOn ? .black : .black.withAlphaComponent(0.5)
    descriptionLabel.font = .systemFont(ofSize: 14)
    descriptionLabel.text = viewModel.description
    descriptionLabel.textColor = viewModel.isOn ? .black : .black.withAlphaComponent(0.5)
    verticalStackView.addArrangedSubview(nameLabel)
    verticalStackView.addArrangedSubview(descriptionLabel)
    
    activateLabel.text = viewModel.isOn ? "" : "Disabled"
    activateLabel.textColor = viewModel.isOn ? .black : .black.withAlphaComponent(0.5)
    stackView.addArrangedSubview(verticalStackView)
    stackView.addArrangedSubview(activateLabel)
    self.contentView.addSubview(stackView)
    NSLayoutConstraint.activate([
      activateLabel.widthAnchor.constraint(equalToConstant: 100),
      stackView.topAnchor.constraint(
        equalTo: self.contentView.safeAreaLayoutGuide.topAnchor
      ),
      stackView.bottomAnchor.constraint(
        equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor
      ),
      stackView.leadingAnchor.constraint(
        equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor,
        constant: 16
      ),
      stackView.trailingAnchor.constraint(
        equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor,
        constant: 16
      )
    ])
  }
}
```

¿Qué vamos a mostrar en la celda? La hora y la fecha de la alarma. Añade este código al principio de AlarmItemCell.

```swift
extension AlarmItem {
  var name: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self.date)
  }
  var description: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, d MMMM, yyyy"
    return formatter.string(from: self.date)
  }
}
```

Añade una tableView justo antes del constructor del AlarmsListViewController.

```swift
let tableView: UITableView = {
  let tableView = UITableView(frame: .zero)
  tableView.translatesAutoresizingMaskIntoConstraints = false
  tableView.estimatedRowHeight = 60
  tableView.rowHeight = 60
  tableView.separatorStyle = .none
  tableView.register(
    AlarmItemCell.self,
    forCellReuseIdentifier: "AlarmItemCell"
  )
  return tableView
}()
```

Ahora, en el viewDidLoad, del AlarmsListViewController, añade la siguiente implementación del datasource que usará la celda anterior con el modelo.

```swift
enum Section { case one }
let dataSource = UITableViewDiffableDataSource<Section, AlarmItem>(
  tableView: tableView,
  cellProvider: { tableView, indexPath, item in
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "AlarmItemCell",
      for: indexPath
    ) as? AlarmItemCell else { 
      return UITableViewCell(frame: .zero) 
    }
    cell.bind(viewModel: item)
    cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .white : .black.withAlphaComponent(0.05)
    return cell
  }
)
dataSource.defaultRowAnimation = .none
tableView.dataSource = dataSource
self.view.addSubview(tableView)
NSLayoutConstraint.activate([
  tableView.topAnchor.constraint(
    equalTo: self.view.safeAreaLayoutGuide.topAnchor
  ),
  tableView.leadingAnchor.constraint(
    equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
  ),
  tableView.trailingAnchor.constraint(
    equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
  ),
  tableView.bottomAnchor.constraint(
    equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
  ),
])
```

Ya tenemos la tabla definida, pero aún no hemos conectado el ViewModel con el controlador. Añade, finalmente, el binding siguiente al final del viewDidLoad.

```swift
self.viewModel.$items
  .sink { items in
    var snapshot = NSDiffableDataSourceSnapshot<Section, AlarmItem>()
  snapshot.appendSections([.one])
  snapshot.appendItems(items, toSection: .one)
  dataSource.apply(snapshot, animatingDifferences: true)
  }
  .store(in: &self.cancellables)
```

Ahora vamos, a conectar la pantalla, con el TabBar. Actualiza el TabBarViewModel.

```swift
class TabBarViewModel: ObservableObject {
  @Published var selectedTab: Tab
  @Published var alarmsListViewModel: AlarmsListViewModel
  init(
    selectedTab: Tab,
    alarmsListViewModel: AlarmsListViewModel
  ) {
    self.selectedTab = selectedTab
    self.alarmsListViewModel = alarmsListViewModel
  }
}
```

Tendrás que actualizar todos los previews donde tengas problemas de compilación. Además, en el AlarmApp, pondremos lo siguiente:

```swift
import SwiftUI

@main
struct AlarmApp: App {
  var body: some Scene {
    WindowGroup {
      MainView(
        viewModel: .init(
          isSwiftUI: true,
          tabBarViewModel: .init(
            selectedTab: .alarms,
            alarmsListViewModel: .init(
              items: [
                .init(id: .init(), date: .init(), isOn: false),
                .init(id: .init(), date: .init(), isOn: true),
                .init(id: .init(), date: .init(), isOn: false)
              ]
            )
          )
        )
      )
    }
  }
}
```

Ahora, en el TabBarViewController, cambiaremos la parte relacionada con las alarmas:

```swift
let alarms = AlarmsListViewController(
  viewModel: self.viewModel.alarmsListViewModel
)
let navigationAlarms = UINavigationController(rootViewController: alarms)
navigationAlarms.tabBarItem.title = "Alarms"
Y, cambiaremos el setViewControllers:
self.setViewControllers([clock, navigationAlarms, crono], animated: false)
```

Con esto, tendremos, una pantalla, conectada a un TabBar. La información del ViewModel es mostrada a través de una UITableView. Ahora pondremos un método en el delegado para cerrar el ciclo de vida de una pantalla.
Vamos a implementar un método sencillo al hacer tap en cada una de la celda para que se active o desactive la alarma. La celda ya viene con esta programación. Solo tendremos que habilitar el delegado de la tabla.
Añade el delegado a la tableView, dentro del ViewDidLoad de AlarmsListViewController.

```swift
tableView.delegate = self
```

El compilador nos va a pedir que implementemos el delegado. Lo añadiremos.

```swift
extension AlarmsListViewController: UITableViewDelegate {
}
```

Ahora en el AlarmsListViewModel añadiremos el método toggle:

```swift
func toggle(alarm item: AlarmItem) {
  guard let index = self.items.firstIndex(where: { $0 == item }) else { return }
  self.items[index].isOn.toggle()
}
```

Ahora ya podemos implementar el métódo didSelectRow dentro del delegado de la tabla.

```swift
extension AlarmsListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  guard self.viewModel.items.count > indexPath.row else { return }
  let item = self.viewModel.items[indexPath.row]
  self.viewModel.toggle(alarm: item)
  }
}
```

Si arrancamos la aplicación, estamos viendo un TabBar y en la pestaña de alarmas, veremos un listado de alarmas, en el que si hacemos tap en cada una de las celdas, éstas se activarán o desactivarán.

Ahora, la idea es trasladar esta pantalla, en SwiftUI. Crea un archivo llamado AlarmsListView.

```swift
import SwiftUI
struct AlarmsListView: View {
  @ObservedObject var viewModel: AlarmsListViewModel
  var body: some View {
    List {
      ForEach(self.viewModel.items) { item in
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
              .foregroundColor(item.isOn ? .black : .black.opacity(0.5))
            Text(item.description)
              .font(.caption)
              .foregroundColor(item.isOn ? .black : .black.opacity(0.5))
          }
          Spacer()
          Text(item.isOn ? "" : "Disabled")
            .foregroundColor(item.isOn ? .black : .black.opacity(0.5))
        }
        .contentShape(Rectangle())
        .onTapGesture {
          self.viewModel.toggle(alarm: item)
        }
      }
    }
    .navigationTitle("Alarms")
  }
}

struct AlarmsListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AlarmsListView(
        viewModel: .init(
          items: [
            .init(id: .init(), date: .init(), isOn: false),
            .init(id: .init(), date: .init(), isOn: true),
            .init(id: .init(), date: .init(), isOn: false)
          ]
        )
      )
    }
  }
}
```

Ahora, solo nos quedará conectar esta vista con el TabBar. Actualiza el text de alarmas con el código siguiente:

```swift
TabBarView(viewModel: self.viewModel.alarmsListViewModel)
  .tabItem { Text("Alarms") }
  .tag(Tab.alarms)
```

Ya podemos arrancar la aplicación. Podrás observar que en ambos listados, con SwiftUI y con UIKit se visualiza la misma información. Y si hacemos tap en una celda tanto en SwiftUI como en UIKit se muestra siempre la información actualizada. Por lo tanto, si queremos actualizar una pantalla que tenga un listado, sea UITableView o UICollectionView, la forma de mover el código hacia SwiftUI será con un @Published y actualizando la información a través de su Binding.

Para ello, en AlarmsListViewController, añade en el UITableViewDelegate la siguiente implementación:

```swift
func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
let deleteAction = UIContextualAction(
    style: .destructive,
    title: "Remove"
  ) { action, view, completion in
    self.viewModel.deleteButtonTapped(at: indexPath.row)
    completion(true)
  }
  
  return UISwipeActionsConfiguration(actions: [deleteAction])
}
```

En el AlarmsListViewModel, añade la siguiente función para que el compilador no se queje:

```swift
func deleteButtonTapped(at index: Int) {
}
```

Llegado aquí, se nos aparece un problema. Para eliminar una celda, tenemos que obtener un valor recorriendo un array de alarmas, cuando, en realidad, lo que queremos es eliminar un objeto en concreto. Esto lo resolveremos en futuros capítulos y tiene un nombre, Derived Behaviours. Por ahora, sigamos con esta implementación, tratando el borrado de una alarma desde el listado de alarmas.
Para eliminar una alarma, queremos mostrar una alerta, avisando al usuario si está seguro que quiere eliminar la alarma. Para ello, la idea es hacer lo mismo que el listado. Crearemos un valor que determinará el estado del enrutado general. En este caso, empezaremos con un solo valor. Añade en AlarmsListViewModel:

```swift
@Published var route: Route?

enum Route: Equatable, Identifiable {
  case deleteAlert(AlarmItem)
  var id: UUID {
    switch self {
      case let .deleteAlert(item):
        return item.id
    }
  }
 
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
      case let (.deleteAlert(lhs), .deleteAlert(rhs)):
        return lhs == rhs
      }
    }
  }
  ```

Y, actualiza, el constructor:

```swift
init(
  items: [AlarmItem] = [],
  route: Route? = nil
) {
  self.items = items
  self.route = route
}
```

¿Qué hemos hecho aquí? Estamos declarando un estado Route en el que si toma como valor nil significa que presentaremos la pantalla actual y, si le asignamos un valor .delete(item), mostraremos una alerta de tipo UIAlertController.
Entonces, actualizaremos la función deleteButtonTapped así:

```swift
func deleteButtonTapped(at index: Int) {
  let item = self.items[index]
  self.route = .deleteAlert(item)
}
```

Y ahora, vamos a actualizar el AlarmsListViewController:

```swift
var presentedViewController: UIViewController?
self.viewModel.$route
  .removeDuplicates()
  .sink { route in
    switch route {
      case .none:
        guard let vc = presentedViewController else { return }
        vc.dismiss(animated: true)
        presentedViewController = nil
      case let .deleteAlert(item):
        let alert = UIAlertController(
          title: item.name,
          message: "Are you sure you want to delete this alarm?",
          preferredStyle: .alert
        )
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
          self.viewModel.cancelButtonTapped()
        }))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
          self.viewModel.delete(item)
        }))
        self.present(alert, animated: true)
        presentedViewController = alert
    }
  }
  .store(in: &self.cancellables)
  ```

Route solo tiene, por ahora, dos posibles estados, en el caso de que sea nil, quitaremos la alerta haciendo dismiss, y en el caso de que sea un .deleteAlert, mostraremos la alerta.
Ahora solo nos falta implementar dos métodos más en el AlertsListViewModel:

```swift
func cancelButtonTapped() {
  self.route = nil
}
func delete(_ item: AlarmItem) {
  guard let index = self.items.firstIndex(where: { $0.id == item.id }) else { return }
  self.items.remove(at: index)
}
```

Si, arrancamos la aplicación o la previsualizamos podremos ver, que es posible eliminar una alarma haciendo swipe.

Esta es la idea para mover el código de UIKit hacia SwiftUI. La responsabilidad de una navegación es del ViewModel porque queremos controlarla. Además, no queremos que la navegación sea un dominio global sino que forme parte de su dominio específico, en este caso, la propia pantalla a la que representa el ViewModel.
Veamos ahora un deeplink, el siguiente:

// deeplink:///alarms/:id/delete

Iremos a la función open(url:) del MainViewModel:

```swift
func open(url: URL) {
  let components = url.pathComponents
  
  if components.count == 2 {
    // deeplink:///alarms
    guard let tab = Tab(rawValue: url.lastPathComponent) else {
      return
    }
    self.tabBarViewModel.selectedTab = tab
  }
  // deeplink:///alarms/:uuid/delete
  if components.count == 4 {
    guard let tab = Tab(rawValue: components[1]) else { return }
    self.tabBarViewModel.selectedTab = tab
    
    if components.last == "delete" {
      let uuid = components[2]
      guard let item = self.tabBarViewModel.alarmsListViewModel.items.first(where: { $0.id.uuidString == uuid }) else { return }
       self.tabBarViewModel.alarmsListViewModel.route = .deleteAlert(item)
    }
  }
}
```

Pero, para, poderlo testear, tendrás que obtener un uuid válido. Por ejemplo, puedes añadir dentro del ForEach del AlarmsListView un print:

```swift
let _ = print(item.id)
```

Ahora, ejecuta la aplicación y usa el deeplink poniendo corréctamente el uuid en el deeplink. El resultado será que la aplicación muestra el listado y la alerta.

Solo nos queda, la parte de SwiftUI. Para ello, usaremos las herramientas que nos ofrece SwiftUI para mostrar una alerta.
Lo primero, será crear un swipe en la lista de la siguiente forma, debajo del .tapGesture:

```swift
.swipeActions(edge: .trailing) {
  Button(role: .destructive){
    guard let index = self.viewModel.items.firstIndex(where: { $0.id == item.id }) else { return }
    self.viewModel.deleteButtonTapped(at: index)
  } label: {
    Label("Trash", systemImage: "trash.circle")
  }
}
```

Ahora, lo que necesitamos es que el route reaccione y se muestre en la pantalla. Existen muchos métodos .alert pero usaremos uno bien interesante.

```swift
public func alert<S, A, M, T>(
  _ title: S, 
  isPresented: Binding<Bool>, 
  presenting data: T?, 
  @ViewBuilder actions: (T) -> A, 
  @ViewBuilder message: (T) -> M
) -> some View where S : StringProtocol, A : View, M : View
```

title y message son los textos de la alerta.
isPresented va a representar si se muestra o no la alerta, pero este valor lo representa nuestro Route, vamos a necesitar transformar ese Route a un Binding<Bool>
presenting representa el objeto que devolverá las siguientes clausuras, las acciones y el mensaje.
Con esta información, nuestra alerta tendrá la siguiente apariencia. Añádelo justo debajo del swipe anterior.

```swift
.alert(
  item.name,
  isPresented: Binding(
    get: {
      guard case let .deleteAlert(itemToDelete) = self.viewModel.route else { return false }
      return itemToDelete == item
    },
    set: { isPresented in
      if !isPresented {
        self.viewModel.route = nil
      }
    }
  ),
  presenting: item,
  actions: { item in
    Button("Delete", role: .destructive) {
      withAnimation {
        self.viewModel.delete(item)
      }
    }
  },
  message: { _ in
    Text("Are you sure you want to delete this alert?")
  }
)
```

Queremos presentar la alerta solo y solo si el Route es igual al tipo .deleteAlert. Si dicha presentación desaparece, solo así, volveremos a asignar el Route a nil. Así funciona el Binding en la alerta.
Parece que la alerta se comporta de una forma rara al actualiza la lista, esto se soluciona añadiendo un withAnimation antes de modificar la lista.
Y ya tendríamos la funcionalidad de borrar un elemento en SwiftUI. Si ejecutamos ahora un deeplink, veríamos que sigue funcionando todo como en UIKit.

La idea de esta pantalla es implementar un picker para seleccionar la fecha de la alarma y un switch para marcar si la alarma estará activa o no.

```swift
import UIKit
import Combine

class AlarmItemViewController: UIViewController {
  let viewModel: AlarmItemViewModel
  private var cancellables: Set<AnyCancellable> = []
  let datePicker: UIDatePicker = {
    let view = UIDatePicker()
    view.preferredDatePickerStyle = .wheels
    return view
  }()
  let labelView: UILabel = {
    let label = UILabel()
    label.text = "Do you want to activate?"
    return label
  }()
  let switchView: UISwitch = {
    let view = UISwitch()
    return view
  }()
  init(viewModel: AlarmItemViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
   
    self.view.backgroundColor = .white
    let horizontalStackView = UIStackView(arrangedSubviews: [labelView, switchView])
    horizontalStackView.axis = .horizontal
    let stackView = UIStackView(arrangedSubviews: [datePicker, horizontalStackView])
    stackView.spacing = UIStackView.spacingUseSystem
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    self.view.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor),
    ])
  }
}

import SwiftUI

struct AlarmItemViewController_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIWrapper {
      UINavigationController(
        rootViewController: AlarmItemViewController(
          viewModel: .init(
            alarmItem: .init(
              id: .init(),
              date: .init(),
              isOn: false
            )
          )
        )
      )
    }
  }
}
```

Seguimos los mismos pasos que en capítulos anteriores, ahora crearemos un fuchero nuevo llamado AlarmItemViewModel:

```swift
import Foundation
import Combine

class AlarmItemViewModel: ObservableObject {
  @Published var alarmItem: AlarmItem
  init(alarmItem: AlarmItem) {
    self.alarmItem = alarmItem
  }
}
```

Ya podemos previsualizar la pantalla nueva.

Para terminar la pantalla, necesitamos configurar los bindings. Añade el siguiente código al final del viewDidLoad:

```swift
self.viewModel.$alarmItem
  .map(\.date)
  .removeDuplicates()
  .sink { [unowned self] in
    self.datePicker.date = $0
  }
  .store(in: &self.cancellables)
self.viewModel.$alarmItem
  .map(\.isOn)
  .removeDuplicates()
  .sink { [unowned self] in
    self.switchView.isOn = $0
  }
  .store(in: &self.cancellables)
  self.datePicker.addAction(
    .init { [unowned self] _ in
      self.viewModel.alarmItem.date = self.datePicker.date
  }, for: .valueChanged
  )
  self.switchView.addAction(
    .init { [unowned self] _ in
      self.viewModel.alarmItem.isOn = self.switchView.isOn
  }, for: .valueChanged
  )
  ```

Ya tenemos la pantalla hecha, ahora queremos crear una nueva ruta. Para ello, añade una nueva opción en nuestro Route.
Añade un nuevo case:

```swift
case add(AlarmItemViewModel)
```

Tenemos que actualizar el código para que se cumpla el Equatable como el Identifiable.

```swift
var id: UUID {
  switch self {
    case let .deleteAlert(item):
      return item.id
    case let .add(item):
      return item.id
    }
}

static func == (lhs: Self, rhs: Self) -> Bool {
  switch (lhs, rhs) {
    case let (.add(lhs), .add(rhs)):
      return lhs === rhs
    case let (.deleteAlert(lhs), .deleteAlert(rhs)):
      return lhs == rhs
    case (.add, .deleteAlert), (.deleteAlert, .add):
      return false
  }
}
```

Ahora haz que el AlarmItemViewModel cumpla con el protocolo Identifiable. Por último, tenemos que implementar el case de Route en el viewDidLoad de AlarmsListViewController.

```swift
case let .add(viewModel):
  let vc = AlarmItemViewController(viewModel: viewModel)
  let nc = UINavigationController(rootViewController: vc)
  vc.title = "Add Alarm"
  vc.navigationItem.leftBarButtonItem = .init(
    title: "Cancel",
    primaryAction: .init { [unowned self] _ in
      self.viewModel.cancelButtonTapped()
    }
  )
  vc.navigationItem.rightBarButtonItem = .init(
    title: "Add",
    primaryAction: .init { [unowned self] _ in
      self.viewModel.add(item: vc.viewModel.alarmItem)
   }
  )
  
  self.present(nc, animated: true)
  presentedViewController = nc
  ```

Nos quedará implementar el metodo add(item:) en el AlarmsListViewModel.

```swift
func add(item: AlarmItem) {
  self.items.append(item)
  self.route = nil
}
```

Aún nos queda una cosa, añadir un botón para lanzar la acción.

```swift
self.navigationItem.rightBarButtonItem = .init(
  title: "Add",
  primaryAction: .init { [unowned self] _ in
    self.viewModel.addButtonTapped()
  }
)
```

Y, finalmente, añade el metodo addButtonTapped() en el AlarmsListViewModel.

```swift
func addButtonTapped() {
  self.route = .add(.init(alarmItem: .init(id: .init(), date: .init(), isOn: true)))
}
```

Si arrancamos la aplicación, verás un botón Add en la parte superior derecha. Si hacemos tap, se presentará la nueva pantalla. Podemos seleccionar el picker y el switch y luego si cancelamos, desaparecerá la pantalla y si le damos a añadir, el listado de alarmas se actualizará.

Funciona perfectamente. Ahora vamos a añadir un nuevo deeplink.

// deeplink:///alarms/add

Añade este código dentro del open(url:)

```swift
if components.count == 3 {
  if components.last == "add" {
    self.tabBarViewModel.alarmsListViewModel.route = .add(.init(alarmItem: .init(id: .init(), date: .init(), isOn: false)))
  }
}
```

Y que tal si hacemos este deeplink, un poco más interesante, añadiendo parámetros que modifiquen tanto el picker como el switch:

```swift
if components.count == 3 {
  guard let tab = Tab(rawValue: components[1]) else { return }
  self.tabBarViewModel.selectedTab = tab
  var date = Date()
  var isOn = false
  if components.last == "add" {
    if let params = URLComponents(string: url.absoluteString)?.queryItems {
      if let paramIsOn = params.first(where: { $0.name == "isOn"})?.value {
        if paramIsOn.lowercased() == "true" {
          isOn = true
        }
      }
      if let paramDate = params.first(where: { $0.name == "date"})?.value {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        date = formatter.date(from: paramDate) ?? Date()
      }
    }
    self.tabBarViewModel.alarmsListViewModel.route = .add(.init(alarmItem: .init(id: .init(), date: date, isOn: isOn)))
  }
}
```

Si probamos con un deeplink como el siguiente, vemos que funciona.
deeplink:///alarms/add?isOn=true&date=2015-01-01T00:00:00.000Z
Ahora nos queda, montar lo mismo para SwiftUI. Crea un fichero nuevo llamado AlarmItemView.

```swift
import SwiftUI

struct AlarmItemView: View {
  @ObservedObject var viewModel: AlarmItemViewModel
  var body: some View {
    Form {
      DatePicker("Date", selection: self.$viewModel.alarmItem.date)
      Toggle("Do you want to activate?", isOn:
self.$viewModel.alarmItem.isOn)
    }
  }
}

struct AlarmItemView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AlarmItemView(
        viewModel: .init(
          alarmItem: .init(
            id: .init(),
            date: .init(),
            isOn: false
          )
        )
      )
    }
  }
}
```

Ya podemos previsualizar la pantalla.

Añadiremos en AlarmsListView un botón para presentar la nueva pantalla. Justo debajo del .navigationTitle, añade lo siguiente:

```swift
.toolbar {
  ToolbarItem(placement: .primaryAction) {
    Button("Add") { self.viewModel.addButtonTapped() }
  }
}
```

Ahora, tenemos la misma problemática que con el alert. Tenemos que usar este método:

```swift
func sheet<Item, Content>(
item: Binding<Item?>, 
onDismiss: (() -> Void)? = nil, 
@ViewBuilder content: @escaping (Item) -> Content
) -> some View where Item : Identifiable, Content : View
```

item va a ser nuestro binding hacia la ruta, es decir, vamos a presentar la vista solo si y solo si, Route es igual a .add
onDismiss es un parámetro que no hace falta usarlo
pero, tenemos un problema, queremos usar el valor del modelo que le pasamos en .add en el ViewBuilder para poder construir la vista.
Para conseguir esto, necesitamos crear un método que nos ayude.

```swift
extension View {
  func sheet<Value, Content>(
    value optionalValue: Binding<Value?>,
    @ViewBuilder content: @escaping (Binding<Value>) -> Content
  ) -> some View where Value: Identifiable, Content: View {
    self.sheet(
      item: optionalValue
    ) { _ in
      if let wrappedValue = optionalValue.wrappedValue,
        let value = Binding(
          get: { wrappedValue },
          set: { optionalValue.wrappedValue = $0 }
        ) {
          content(value)
        }
     }
   }
}
```

Gracias a este método, ya podemos usar en la vista. Añade el sheet justo debajo del toolbar añadido anteriormente.

```swift
.sheet(
  value: Binding<AlarmItemViewModel?>(
    get: {
      guard case let .add(viewModel) = self.viewModel.route else { return nil }
      return viewModel
    },
    set: { isPresented in
      if isPresented == nil {
        self.viewModel.route = nil
      }
    }
  )
) { $viewModel in
  NavigationView {
    AlarmItemView(viewModel: viewModel)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { self.viewModel.cancelButtonTapped() }
        }
        ToolbarItem(placement: .primaryAction) {
          Button("Save") { self.viewModel.add(item: viewModel.alarmItem) }
      }
    }
  }
}
```

Si arracamos el simulador, no vemos el botón Add. Esto es porque en el TabBarView hay que añadir NavigationView a las alarmas:

```swift
NavigationView {
  AlarmsListView(viewModel: self.viewModel.alarmsListViewModel)
}
.tabItem { Text("Alarms") }
.tag(Tab.alarms)
```

Ahora si y los deeplinks funcionando perfectamente.

En la próxima entrega, tenemos que modificar el Route. Tenemos una aplicación que funciona correctamente, pero el planteamiento no es del todo correcto. Cuando estamos haciendo .delete(item), estamos dando la responsabilidad del borrado al listado. Lo que necesitamos es derivar esa responsabilidad al item.
Crearemos un nuevo Route items(id:, route:), de forma que el objeto item, tendrá su propio Route, pero esta vez será simplemente .delete. Así, en la próxima entrega, crearemos un route con esta apariencia

```swift
self.route = .items(id: item.id, route: .delete)
```

Ya tenemos que muestra un listado de alarmas. Si hacemos tap en una de sus celdas, la podemos marcar o desmarcar. También podemos añadir una nueva alarma y, finalmente, podemos eliminarla.
Tanto para UIKit, como para SwiftUI la aplicación es totalmente funcional. Pero, vamos a tener un pequeño problema de escalabilidad.
Cuando queremos borrar una alarma, la acción de borrar se responsabiliza el listado de alarmas. Esto no es del todo correcto.
En este capítulo, vamos a derivar comportamientos (derived behaviour) del listado a un objeto.

Vamos a empezar creando el AlarmItemRowViewModel.

```swift
import SwiftUI

class AlarmItemRowViewModel: ObservableObject {
  @Published var item: AlarmItem
  @Published var route: Route?
  enum Route: Equatable {
    case deleteAlert
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.deleteAlert, .deleteAlert):
        return true
      }
    }
  }
  init(
    item: AlarmItem
  ) {
    self.item = item
  }
}
```

Estamos creando el ViewModel que va a contener toda la lógica correspondiente a una alarma, es decir, el modelo de una alarma y sus posibles rutas, que de momento, tenemos sólamente, .deleteAlert.
Ahora ya no le vamos a pasar un valor a través del pattern matching del enum porque no es necesario.
Ahora, tenemos que actualizar el AlarmItemCell. Empieza importando Combine al inicio del fichero. Luego añade lo siguiente dentro de la clase.

```swift
var cancellables: Set<AnyCancellable> = []
override func prepareForReuse() {
    super.prepareForReuse()
    self.cancellables = []
  }
  ```

Y finalmente, sustituye la función bind por esta otra. Ahora el método está recibiendo un AlarmItemRowViewModel.

```swift
class AlarmItemCell: UITableViewCell {
func bind(viewModel: AlarmItemRowViewModel) {
    selectionStyle = .none
    viewModel.$item
      .map(\.name)
      .removeDuplicates()
      .sink { [unowned self] name in
        self.nameLabel.text = name
      }
      .store(in: &self.cancellables)
    viewModel.$item
      .map(\.description)
      .removeDuplicates()
      .sink { [unowned self] description in
        self.descriptionLabel.text = description
      }
      .store(in: &self.cancellables)
    viewModel.$item
      .map(\.isOn)
      .removeDuplicates()
      .sink { [unowned self] isOn in
        self.nameLabel.textColor = isOn ? .black : .black.withAlphaComponent(0.5)
        self.descriptionLabel.textColor = isOn ? .black : .black.withAlphaComponent(0.5)
        self.activateLabel.text = isOn ? "" : "Disabled"
        self.activateLabel.textColor = isOn ? .black : .black.withAlphaComponent(0.5)
     }
     .store(in: &self.cancellables)
    descriptionLabel.font = .systemFont(ofSize: 14)
    verticalStackView.addArrangedSubview(nameLabel)
    verticalStackView.addArrangedSubview(descriptionLabel)
    stackView.addArrangedSubview(verticalStackView)
    stackView.addArrangedSubview(activateLabel)
    self.contentView.addSubview(stackView)
    NSLayoutConstraint.activate([
      activateLabel.widthAnchor.constraint(equalToConstant: 100),
      stackView.topAnchor.constraint(
        equalTo: self.contentView.safeAreaLayoutGuide.topAnchor
      ),
      stackView.bottomAnchor.constraint(
        equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor
      ),
      stackView.leadingAnchor.constraint(
        equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor,
        constant: 16
      ),
      stackView.trailingAnchor.constraint(
      equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor,
        constant: 16
      )
    ])
  }
}
```

Nos aparecen problemas de compilación en el AlarmsListViewController.
Como estamos modificando la parte de UIKit, primero comentaremos la parte de SwiftUI para no tener problemas de compilación. En AlarmsListView, comenta todo el objeto que tenemos dentro del ForEach, y pon un EmptyView.
Más adelante, volveremos.

```swift
ForEach(self.viewModel.items) { item in
  EmptyView()
}
```

Tenemos que actualizar el DataSource de la UITableView. En la definición del DatSource, actualizaremos el modelo de datos usado.

```swift
let dataSource = UITableViewDiffableDataSource<Section, AlarmItemRowViewModel>(
```

Ahora, el compilador nos pide que AlarmItemRowViewModel cumpla con el protocolo Hashable y Equatable. Lo hacemos.

```swift
func hash(into hasher: inout Hasher) {
  hasher.combine(self.item.id)
}
static func == (lhs: AlarmItemRowViewModel, rhs: AlarmItemRowViewModel) -> Bool {
  lhs.item.id == rhs.item.id
}
```

Ahora, es el snapshot, quien se queja.

```swift
var snapshot = NSDiffableDataSourceSnapshot<Section, AlarmItemRowViewModel>()
```

Una vez, hemos cambiado esto, es hora de cambiar el modelo de datos del ViewModel.

```swift
@Published var items: [AlarmItemRowViewModel]
```

Actualizaremos, el constructor:

```swift
init(
  items: [AlarmItemRowViewModel] = [],
  route: Route? = nil
) {
  self.items = items
  self.route = route
}
```

Ahora, las siguientes funciones toggle, deleteButtonTapped y delete no las vamos a necesitar aquí.
En la función add(item:), la actualizaremos.

```swift
func add(item: AlarmItem) {
  self.items.append(.init(item: item))
  self.route = nil
}
```

En el enum Route, no vamos a necesitar .delete(item), lo vamos a borrar. Y vamos a añadir un .items(id:route:) que representará el enrutado de cada uno de sus items. Añade el siguiente case.

```swift
case items(id: AlarmItemRowViewModel.ID, route: AlarmItemRowViewModel.Route)
```

Necesitaremos que AlarmItemRowViewModel cumpla con el protocol Identifiable.

```swift
var id: AlarmItem.ID { self.item.id }
```

Resolveremos los errores de compilación en AlarmsListViewModel.Route:

```swift
enum Route: Equatable, Identifiable {
  case add(AlarmItemViewModel)
  case items(id: AlarmItemRowViewModel.ID, route: AlarmItemRowViewModel.Route)
  var id: UUID {
    switch self {
      case let .add(item):
        return item.id
      case let .items(id: id, route: _):
        return id
    }
  }
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.add(lhs), .add(rhs)):
      return lhs === rhs
    case let (.items(lhsId, lhsRoute), .items(rhsId, rhsRoute)):
      return lhsId == rhsId && lhsRoute == rhsRoute
    case (.add, .items), (.items, .add):
      return false
    }
  }
}
```

Ahora iremos al AlarmsListViewController, en el switch del route, borramos el case de .delete. y añadiremos un nuevo case

```swift
case .items:
  break
  ```

Vamos a comentar las funciones que nos dan error. La función toggle dentro del didSelectRowAt y la función deleteButtonTapped dentro de trailingSwipeActionsConfigurationForRowAt.
Finalmente, actualizaremos el preview, añadiendo el ViewModel.

```swift
.init(item: .init(id: .init(), date: .init(), isOn: false)),
.init(item: .init(id: .init(), date: .init(), isOn: true)),
.init(item: .init(id: .init(), date: .init(), isOn: false)),
```

También, en el preview de AlarmsListView, hay que actualizar esta parte. Y también en AlarmApp.
Tenemos un problema con el deeplink de borrar. Lo comentaremos, de momento. Tenemos ya el proyecto compilando.
Ahora, vamos a volver a hacer funcionar el borrar una alarma. En el AlarmItemRowViewModel, crearemos las siguientes funciones.
Ahora, la función deleteButtonTapped no necesita que le pasemos un indexPath porque el objeto a eliminar es el mismo item de la clase.

```swift
func deleteButtonTapped() {
  self.route = .deleteAlert
}
func deleteConfirmationButtonTapped() {
  ????
}
```

¿Pero qué hacemos si queremos borrar el item? Tenemos que informar a AlarmsListViewModel. Usaremos una clausura

```swift
var onDelete: () -> Void = {}
```

Y, finalmente, implementaremos la siguiente función.

```swift
func deleteConfirmationButtonTapped() {
  self.onDelete()
  self.route = nil
}
```

Ahora, tenemos que actualizar la construcción de los objetos y derivar su comportamiento. Dicho de otra forma, cuando construimos cada una de las celdas, tenemos que implementar la función onDelete.
Actualiza el constructor del AlarmsListViewModel

```swift
init(
  items: [AlarmItemRowViewModel] = [],
  route: Route? = nil
) {
  self.items = []
  self.route = route
}
```

Ahora lo que queremos es bindear cada uno de los items con la función onDelete.

```swift
private func bind(itemRowViewModel: AlarmItemRowViewModel) {
  itemRowViewModel.onDelete = { [weak self, item =  itemRowViewModel.item] in
    self?.delete(item: item)
  }
  self.items.append(itemRowViewModel)
}
```

Necesitamos aquí una función delete.

```swift
func delete(item: AlarmItem) {
  guard let index = self.items.firstIndex(where: { $0.item == item }) else { return }
  self.items.remove(at: index)
}
```

Por último, añade lo siguiente, al final del constructor.

```swift
for row in items {
  self.bind(itemRowViewModel: row)
}
```

Ahora, tenemos que implementar el Route en el AlarmItemCell. Añadiremos la implementación del Route al final del método bind(viewModel:)

```swift
var presentedViewController: UIViewController?
viewModel.$route
  .removeDuplicates()
  .sink { route in
    switch route {
      case .none:
        guard let vc = presentedViewController else { return }
        vc.dismiss(animated: true)
        presentedViewController = nil
      case .deleteAlert:
        let alert = UIAlertController(
          title: viewModel.item.name,
          message: "Are you sure you want to delete this item?",
          preferredStyle: .alert
        )
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
          viewModel.cancelButtonTapped()
        }))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
          viewModel.deleteConfirmationButtonTapped()
        }))
        context.present(alert, animated: true)
        presentedViewController = alert
      }
    }
    .store(in: &self.cancellables)
```

En el ViewModel, crea la siguiente función:

```swift
func cancelButtonTapped() {
  self.route = nil
}
```

No podemos presentar una alerta desde dentro de una UITableViewCell, así que le pasaremos el ViewController por parámetro.
Actualiza la función:

```swift
func bind(viewModel: AlarmItemRowViewModel, context: UIViewController)
```
Y, ahora actualiza la llamada dentro del DiffableDataSource:

```swift
cell.bind(viewModel: item, context: self)
```

Por último, en el trailingSwipeActionsConfigurationForRowAt, actualizaremos la llamada para borrar la celda.

```swift
self.viewModel.items[indexPath.row].deleteButtonTapped()
```

Si probamos en el Preview, veremos que la funcionalidad de borrar un item sigue funcionando como siempre.

Vayamos, a implementar lo mismo con SwiftUI. Crea un fichero AlarmItemRowView.

```swift
import SwiftUI
struct AlarmItemRowView: View {
  @ObservedObject var viewModel: AlarmItemRowViewModel
  var body: some View {
    EmptyView()
  }
}
```

Ahora, actualiza el AlarmsListView:

```swift
ForEach(self.viewModel.items) { item in
  AlarmItemRowView(viewModel: item)
}
```

Ahora en el AlarmItemRowView vamos a implementar el body, que va a ser muy parecido al que teníamos antes pero derivando su dominio.

```swift
HStack {
  VStack(alignment: .leading, spacing: 4) {
    Text(self.viewModel.item.name)
  .foregroundColor(self.viewModel.item.isOn ? .black : .black.opacity(0.5))
    Text(self.viewModel.item.description)
      .font(.caption)
      .foregroundColor(self.viewModel.item.isOn ? .black : .black.opacity(0.5))
  }
  Spacer()
  Text(self.viewModel.item.isOn ? "" : "Disabled")
    .foregroundColor(self.viewModel.item.isOn ? .black : .black.opacity(0.5))
}
.contentShape(Rectangle())
.onTapGesture {
  //self.viewModel.toggle(alarm: item)
}
.swipeActions(edge: .trailing) {
  Button(role: .destructive){
    self.viewModel.deleteButtonTapped()
  } label: {
    Label("Trash", systemImage: "trash.circle")
  }
}
.alert(
  viewModel.item.name,
  isPresented: Binding(
    get: {
      guard case.deleteAlert = self.viewModel.route else { return false }
      return true
    },
    set: { isPresented in
      if !isPresented {
        self.viewModel.route = nil
      }
    }
  ),
  presenting: viewModel.item,
  actions: { item in
    Button("Delete", role: .destructive) {
      withAnimation {
        self.viewModel.deleteConfirmationButtonTapped()
      }
    }
  },
  message: { _ in
    Text("Are you sure you want to delete this alert?")
  }
)
```

Ya podemos probar con la previsualización que todo sigue funcionando como antes.

Llegado a este punto, podemos actualiza el toggle, pero esta vez, el toggle no será un tap sino un leadingSwipe. Reservaremos el uso del tap para más adelante.
En el AlarmItemRowViewModel, añade otro case al Route:

```swift
case toggleConfirmationDialog
Actualizaremos el Equatable.
static func == (lhs: Self, rhs: Self) -> Bool {
  switch (lhs, rhs) {
  case (.deleteAlert, .deleteAlert):
    return true
  case (.toggleConfirmationDialog, .toggleConfirmationDialog):
    return true
  case (.deleteAlert, _), (.toggleConfirmationDialog, _):
    return false
  }
}
```

Ahora implementaremos el case .toggleConfirmationDialog dentro del switch en el AlarmItemCell.

```swift
case .toggleConfirmationDialog:
  let alert = UIAlertController(
    title: viewModel.item.name,
    message: viewModel.item.description,
    preferredStyle: .actionSheet
  )
  alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
    viewModel.toggleButtonTapped()
  }))
  alert.addAction(.init(title: viewModel.item.status, style: .default, handler: { _ in
    viewModel.toggleConfirmationButtonTapped()
  }))
  context.present(alert, animated: true)
  presentedViewController = alert
```

Define en el AlarmItemRowView la siguiente extensión:

```swift
extension AlarmItem {
  var status: String {
    self.isOn ? "Disable" : "Enable"
  }
}
```

Y luego, implementaremos los siguientes métodos.

```swift
func toggleButtonTapped() {
  self.route = .toggleConfirmationDialog
}
```

Con el siguiente método, haremos como con el Delete. Necesitamos enviar la acción al dominio superior.

```swift
var onToggle: () -> Void = {}
func toggleConfirmationButtonTapped() {
  self.onToggle()
  self.route = nil
}
```

Ahora iremos al constructor del AlarmsListViewModel. Añade lo siguiente dentro de la función bind, antes del append.

```swift
itemRowViewModel.onToggle = { [weak self, item =  itemRowViewModel.item] in
  self?.toggle(item: item)
}
```

Y luego, implementa la siguiente función.

```swift
func toggle(item: AlarmItem) {
  guard let index = self.items.firstIndex(where: { $0.item == item }) else { return }
  self.items[index].item.isOn.toggle()
}
```

Finalmente, añadiremos la función leadingSwipe en el UITableViewDelegate.

```swift
func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
  let toggleAction = UIContextualAction(
    style: .normal,
    title: self.viewModel.items[indexPath.row].item.status
  ) { action, view, completion in
    self.viewModel.items[indexPath.row].toggleButtonTapped()
    completion(true)
  }
  return UISwipeActionsConfiguration(actions: [toggleAction])
}
```

Perfecto, ara vamos a probar el toggle, haciendo swipe por la parte de la izquierda. Probamos una primera vez pero si lo probamos una segunda vez. Problema, no funciona.
Esto es debido a la función toggle, en el momento de encontrar el index. Falla el protocolo Equatable. Al modificar el isOn, ya no se encuentra un objeto que cumpla con el Equatable. En la definición de AlarmItem, añade el protocolo Equatable y definiremos su método propio.

```swift
struct AlarmItem: Identifiable, Hashable, Equatable {
  let id: UUID
  var date: Date
  var isOn: Bool
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}
```

Ya lo tenemos. Vamos a por SwiftUI. Eliminaremos de AlarmItemRowView lo siguiente. No lo vamos a necesitar ya que queremos implementar un SwipeLeading.

```swift
.contentShape(Rectangle())
.onTapGesture {
  //self.viewModel.toggle(alarm: item)
}
```

Ahora, agrega lo siguiente.

```swift
.swipeActions(edge: .leading) {
  Button {
    self.viewModel.toggleButtonTapped()
  } label: {
    Label(self.viewModel.item.status, systemImage: "alarm")
  }
}
```

Y ahora, implementaremos un confirmationDialog:

```swift
.confirmationDialog(
  viewModel.item.name,
  isPresented: Binding(
    get: {
      guard case.toggleConfirmationDialog = self.viewModel.route else { return false }
      return true
    },
    set: { isPresented in
      if !isPresented {
        self.viewModel.route = nil
      }
    }
  ),
  titleVisibility: .visible,
  presenting: viewModel.item,
  actions: { item in
    Button(item.status) {
      withAnimation {
        self.viewModel.toggleConfirmationButtonTapped()
      }
    }
  },
  message: { item in
    Text(item.description)
  }
)
```

Ya lo tenemos.
Para finalizar este artículo, nos faltarán los deeplinks. Para resolver el delete, haremos lo siguiente. En el MainViewModel, sustituye la linea que teníamos comentada por esta.

```swift
self.tabBarViewModel.alarmsListViewModel.route = .items(id: item.id, route: .deleteAlert)
```

¿Fácil no? Podemos probar con un deeplink:

deeplink:///alarms/C3050F46-B575-46D1-93C3-95858E365C8D/delete

Bien, no funciona, ¿qué está ocurriendo? Pues que en el constructor, no estamos derivando el valor del route hacia el route de la cell/row. Necesitamos binder el route “padre” al route “hijo”.
Añade lo siguiente en el constructor, después de setear las clausuras onDelete y onToggle y antes del append final de la función bind.

```swift
itemRowViewModel.$route
  .map { [id = itemRowViewModel.id] route in
    route.map { .items(id: id, route: $0) }
  }
  .removeDuplicates()
  .dropFirst()
  .assign(to: &self.$route)
self.$route
  .map { [id = itemRowViewModel.id] route in
    guard case let .items(id: routeRowId, route: route) = route,
 routeRowId == id else { return nil }
    return route
  }
  .removeDuplicates()
  .assign(to: &itemRowViewModel.$route)
```

Ya nos funciona. Ahora implementaremos el deeplink para el Toggle.

```swift
if components.count == 4 {
  guard let tab = Tab(rawValue: components[1]) else { return }
  self.tabBarViewModel.selectedTab = tab
  let uuid = components[2]
  guard let item = self.tabBarViewModel.alarmsListViewModel.items.first(where: { $0.id.uuidString == uuid }) else { return }
  // deeplink:///alarms/:id/delete
  if components.last == "delete" {
    self.tabBarViewModel.alarmsListViewModel.route = .items(id: item.id, route: .deleteAlert)
  }
 
  // deeplink:///alarms/:id/toggle
  if components.last == "toggle" {
    self.tabBarViewModel.alarmsListViewModel.route = .items(id: item.id, route: .toggleConfirmationDialog)
  }
}
```

Ya tenemos los dos deeplinks funcionando, tanto para el delete y el toggle.