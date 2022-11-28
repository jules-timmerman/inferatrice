(** Conversion des règles parsées en un [atom_to_query_t] utilisable
    par [Query.search] pour résoudre des requêtes en intégrant les
    règles d'inférence données. *)
    let rules (jsp_cque_c: (string Ast.Atom.t * string Ast.Atom.t list) list) : Query.atom_to_query_t =
      failwith "TODO rules"
  
  (** Conversion d'une liste d'atomes parsés en une requête conjonctive.
      La fonction renvoyée peut être appelée quand une solution aura été
      trouvée: elle affiche l'état des variables à ce moment là. *)
  let query (nom: string Ast.Atom.t list) : Query.t * (unit -> unit) =
    failwith "TODO query"
  