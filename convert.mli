(** Conversion des règles parsées en un [atom_to_query_t] utilisable
    par [Query.search] pour résoudre des requêtes en intégrant les
    règles d'inférence données. *)
val rules :
  (string Ast.Atom.t * string Ast.Atom.t list) list ->
  Query.atom_to_query_t

(** Conversion d'une liste d'atomes parsés en une requête conjonctive.
    La fonction renvoyée peut être appelée quand une solution aura été
    trouvée: elle affiche l'état des variables à ce moment là. *)
val query : string Ast.Atom.t list -> Query.t * (unit -> unit)

(** Convertie un Ast.Atom en Query.t avec empactage*)
val convert : string Ast.Atom.t -> Query.t 


(** Prends des premices (sous forme d'Ast.Atom) et les AND ensemble pour donner une Query*)
val premices_to_query : string Ast.Atom.t list -> Query.t

