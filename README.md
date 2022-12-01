# Infératrice

## Installation et prise en main

### Installation

Les dépendances de ce projet sont :

- Naturellement OCaml, testé à partir de 4.13.1
- `alcotest`, installable à l'aide de `opam install alcotest`
- Pas nécessaire, mais recommandé : l'utilitaire `make` pour simplifier la compilation

Le téléchargement se fait via `git` :

```shell
git clone https://github.com/snoopinou30/inferatrice.git
```

La compilation est aussi simple que 

```shell
$ cd inferatrice/
$ make
```

Vous pouvez désormais utiliser l'infératrice, plus d'informations dessus se trouvent dans la section suivante.

Pour alléger le dossier et enlever les fichiers générés par la compilations, `make clean` est la solution.

### Tests

Le fichier `test.ml` définit des cas de tests qui permettent de vérifier la correction du programme. Lancer les tests se résume à 

```shell
$ make
$ ./run_tests
```

Si tout se passe bien il ne devrait y avoir que des tests passés, sinon Alcotest indique le test qui a échoué ainsi que la raison.

### Présentation

L'infératrice prend en entrée un fichier contenant des règles d'inférence, de la forme 

```
derive plus(z,Y,Y).

derive plus(s(X),Y,s(Z))
  from plus(X,Y,Z).
```

Dans ces règles, `z` signifie zero et `s(X)` signifie le successeur de `X`. Les lettres en majuscule sont des variables, que l'infératrice va essayer de remplacer par des valeurs satisfaisant les contraintes des règles d'inférence. Ici, si l'on peut inférer `plus(X,Y,Z)` à partir des règles disponibles, cela veut dire que `X + Y = Z`. Le cas de base (`derive plus(z,Y,Y).`) indique que `Y + 0 = Y`, et le deuxième traduit le fait que si `X + Y = Z`, alors `(X + 1) + Y = (Z + 1)`.

Regardons un exemple, ce sera plus clair :

```shell
$ ./inferatrice 2_arith.inf
Lecture des règles dans 2_arith.inf...

Requête? plus(X,Y,5).
Résolution de la requête plus(Var_0, Var_1, s(s(s(s(s(z()))))))...
Var_1 = s(s(s(s(s(z())))))
Var_0 = z()
More solutions? [Y/n]
```

On voit ici que l'infératrice a lu et compris les règles du fichier d'entrée, puis a attendu notre requète. On a entré `plus(X,Y,5).`, ce qui signifie qu'on demande à l'infératrice les couples `(X, Y)` tels que `X + Y = 5`. Le premier couple trouvé est `X = z()`, soit `X = 0` et `Y = s(s(s(s(s(z)))))` soit `Y = 5`, ce qui est correct. L'infératrice propose ensuite de continuer à rechercher d'autres couples qui satisfont la recherche.

De la même manière que pour plus, on peut définir les fonctions vérifiant si un entier est pair, puis si un est la moitié d'un autre de cette manière :

```
derive half(z,z).
derive half(s(s(X)),s(Y)) 
	from half(X,Y).

derive even(z).
derive even(s(s(X))) 
	from even(X).
```

Un peu plus compliqué, la fonction d'Ackermann se définit comme suit :

```
derive ack(z,X,s(X)).
derive ack(s(X),z,Y)    
	from ack(X,s(z),Y).
derive ack(s(X),s(Y),Z) 
	from ack(s(X),Y,R), ack(X,R,Z).
```

Dans les trois cas précédents, on définit un cas de base et les suivants sont les cas récursifs, où on va essayer de déduire le cas à partir des autres.  

Une fois toutes ces règles d'inférences définies, on peut les combiner dans notre recherche ! Par exemple, la requète

```
ack(2,3,s(X)), half(X,H), even(H).
```

recherche `X` et `H` tels que `Ack(2,3) = X + 1`, `H * 2 = X`, et `H pair`.

Il n'y a qu'une solution (`H = 4` et `X = 8`), que l'infératrice nous renvoit :

```
Requête? ack(2,3,s(X)), half(X,H), even(H).
Résolution de la requête (ack(s(s(z())), s(s(s(z()))), s(Var_1)) && (half(Var_1, Var_0) && even(Var_0)))...
Var_0 = s(s(s(s(z()))))
```

En revanche si il n'y a pas de solutions l'infératrice termine sans rien trouver, ici dans un cas très similaire mais avec un chiffre de changé :

```
Requête? ack(2,2,s(X)), half(X,H), even(H).
Résolution de la requête (ack(s(s(z())), s(s(z())), s(Var_1)) && (half(Var_1, Var_0) && even(Var_0)))...
Fin des solutions pour cette requête.
```

 
