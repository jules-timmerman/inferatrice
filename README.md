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

## Fonctionnement 
### Term.ml

Ce fichier contient tout le code se rapportant à nos termes. 

Nous définissions un terme avec les types suivants : 
```ocaml
type var = string
type t = Fun of string * t list | Var of var * string
type obs_t = Fun of string * t list | Var of var
```

Le type `var` encode les variables : il s'agit d'un nom local de la forme `var_n` où `n` est un nombre que l'on incrémente à chaque nouvelle variable.

Le type `t` encode les termes. Il s'agit soit :
- d'une fonction `Fun`. Par exemple, `plus(1,2,X)` est un type `Fun`. `plus` est la `string` associée et les termes représentant `1`, `2` et `X` sont dans la liste.
- d'une variable `Var`. Par exemple, `X` en est une. Le type `var` contient le nom local pour que le programme la reconaisse. La seconde `string` est le nom original (`X` dans l'exemple) qui permet de l'afficher à la fin pour l'utilisateur.

Pour pouvoir convertir du type `Ast.Term.t`, on utilise la fonction `convert_var`. On utilise aussi deux variables globales : `instantiation_in_process` et `instantiation_counter`. Ces variables permettent de se souvenir des variables que l'on vient de créer pendant une règle. 

On considère par exemple la règle suivante :
```
derive lt(s(X),s(Y))
  from lt(X,Y).
```
Dans cette règle, nous avons besoin que les `X` et `Y` crées soient les mêmes. Lors de la création de la première instance, nous ajoutons le couple composé du hash (pour garder le typage `'a`) ainsi que la variable créée dans notre `instantiation_in_process`. La prochaine fois que l'on fera référence à cette variable, le hash étant identique, nous renverrons l'instance déjà créée. On réinitialise `instantiation_in_process` à chaque fois que l'on considère une nouvelle règle, ce qui est identifié grâce au numéro passé en argument. On se souviens aussi du numéro d'instantiation dans le fichier `convert.ml`.



### Query.ml

Ce fichier définit le type `Query.t` et permet son utilisation, principalement via l'utilisation de la fontion `search`.

Cette fonction prend en argument la fonction de conversion d'un `Ast.Atom.t` vers un `Query.t`, une fonction `unit -> 'a` qui fonctionne comme une espèce de callback et la query que l'on souhaite évaluer. 

La fonction de callback contient la fonction d'affichage des variables lorsqu'on a trouvé. En revanche, dans la fonction `has_solution` qui renvoie un booléen, la fonction de callback est utilisée pour lever une exception, que l'on attrape ensuite dans `has_solution` pour renvoyer le booléen. 




### Convert.ml

Le but de ce fichier est de définirles utilitaires nécessaire à la conversion du type `Ast.Atom.t` au type `Query.t`. Pour cela, la fonction `rules` est utilisée pour créer une fonction `atom_to_query` qui permet de faire cette conversion tout en tenant compte des règles d'inférences saisies par l'utilisateur.

La fonction `atom_to_query` prends en entrée un `Atom` dépaqueter. La fonction cherche dans les règles d'inférences saisies celles qui pourraient être utiliser comme dérivation. On s'intéresse uniquement aux règles qui ont le même nom ainsi que le même nombre d'argument que l'`Atom` d'entrée. 

On crée ensuite la query résultante en encodant de la manière suivante :
- Pour chque règle, les prémices sont encodées récursivement et `AND` entre elles.
- On rajoute à ce `AND` des `EQUALS` termes à termes entre les arguments de la conclusion et ceux de l'`Atom` initial. Cela a pour effet de forcer un appel à `unify` au moment de l'évaluation de la query.
- On `OR` finalement toutes les query ensembles.

La fonction `query` quand à elle est utilise le même principe d'encodage que la fonction `rules` mais elle n'est limitée qu'à une règle donc nous n'avons pas besoin de `OR` à la fin. Nous renvoyons aussi la fonction permettant l'affichage du résultat après l'exécution. Pour cela, nous récupérons récursivement les variables apparaissant dans l'atome passé en argument (ce qui donne le nom saisi par l'utilisateur). Nous pouvons ensuite les utilisée pour remplir le second champ des `Var` de `Term.t`.



