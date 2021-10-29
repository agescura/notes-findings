# Notas de Haskell

## Empezando con Haskell

Instalar el compilador

```haskell
brew install ghc cabal-install
```

### Operaciones

Sumas, restas, multiplicaciones y divisiones

```haskell
1 + 1
2 + 2
2 - 1
2 / 1
```

Prioridades

```haskell
1 + 2 * 4
(1 + 2) * 4
1 + ( 2 * 4)
```

Cuidado con los números negativos

```haskell
1 * -3 -- Error
1 * (-3)
```

Booleanos

```haskell
True && False
True && True
False || True
not False
not (True && True)
```

```haskell
1 == 1
1 == 0
1 /= 1
1 /= 0
"world" == "world"
5 == "world -- Error
5 == 5.0
```

Funciones

```haskell
succ 1 -- devuelve el sucesor de 1
min 1 2 -- devuelve el min de 1 y 2
min 1.2 1.4
max 1 2
```

Composicion de funciones

```haskell
succ 1 + max 1 2 + 1
(succ 1) + (max 1 2) + 1
div 11 2 -- div entera de 11 entre 2 = 5
11 `div` 2 -- infix operation (more readable)
```

Baby's first functions

New file baby.hs
```haskell
doubleMe x = x + x
```

```haskell
:l baby
doubleMe 3
```

Listas

```haskell
let lostNumbers = [1,2,3,4,5,6,7,8]
[1,2,3,4] ++ [5,6,7,8] -- Operador ++ concatena listas
"hello" ++ " " ++ "world"
['w','o'] ++ ['r','l', 'd']
'C' : "AT" -- : añade un elemento a una lista
1 : [2,3,4,5]
```

```haskell
"World" !! 0 -- W
"World" !! 4 -- d
```