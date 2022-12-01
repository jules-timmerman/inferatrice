(** Les requêtes constituent le langage interne de l'Infératrice.
    Le simple utilisateur n'a pas le droit de saisir directement une requête.
    Les requêtes sont élaborées par l'Infératrice elle-même pour mener à
    bien sa tâche.
    Elles sont résolues selon les préceptes immuables:
    - une recherche en profondeur,
    - toujours de haut en bas et de gauche à droite,
    - rien n'arrête l'infératrice! *)

type t =
  | Atom of string * Term.t list
  | Equals of Term.t * Term.t
  | And of t * t
  | Or of t * t
  | False
  | True

val pp : Format.formatter -> t -> unit

type atom_to_query_t = string -> Term.t list -> t

(** L'argument optionnel [atom_to_query] permet de traduire un atome
    rencontré dans une requête en une nouvelle requête.
    Sa valeur par défaut envoie tout atome sur [False].
    Quand cette fonction dérive d'un fichier de description de règles,
    on pourrait par exemple avoir [plus(z,z,z)] qui est transformé
    en [True]... ou quelquechose d'équivalent pour l'Infératrice. *)
val search : ?atom_to_query:atom_to_query_t -> (unit -> 'a) -> t -> unit
val has_solution : ?atom_to_query:atom_to_query_t -> t -> bool

val get_var_from_query : t -> Term.var list 
