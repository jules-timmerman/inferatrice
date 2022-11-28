
(** Fonction de conversion avec empactage *)
let convert (a : string Ast.Atom.t) : Query.t = 
  let n,l= (Ast.Atom.convert (Term.convert_var) a) in Query.Atom(n,l)


(* TODO : A refaire le fold sans le True ? *)
(** Prends des premices et les AND ensemble pour donner une Query*)
let premices_to_query ( premices : string Ast.Atom.t list) : Query.t =
  List.fold_left 
    (fun (x:Query.t) (y:string Ast.Atom.t) -> Query.And(x, convert y)) Query.True premices


(** Conversion des règles parsées en un [atom_to_query_t] utilisable
  par [Query.search] pour résoudre des requêtes en intégrant les
  règles d'inférence données. *)
  let rules (rules: (string Ast.Atom.t * string Ast.Atom.t list) list) : Query.atom_to_query_t =
    fun (name:string) (terms:Term.t list) -> 
      (* On garde les règles qui ont le même nom et le même cardinal que l'atome d'entrée *)
      let terms_length = List.length terms in
      let filtered = List.filter (fun (Ast.Atom.Atom(s,l),_) -> s = name && List.length l = terms_length) rules in
      
      (* On OR les premices des règles satisfantes ensembles*)
      List.fold_left 
        (fun (x: Query.t) ((_,y): string Ast.Atom.t * string Ast.Atom.t list) 
          -> Query.Or(x, premices_to_query y)) 
        Query.False filtered

(** Conversion d'une liste d'atomes parsés en une requête conjonctive.
    La fonction renvoyée peut être appelée quand une solution aura été
    trouvée: elle affiche l'état des variables à ce moment là. *)
let query (nom: string Ast.Atom.t list) : Query.t * (unit -> unit) =
  failwith "TODO query"
