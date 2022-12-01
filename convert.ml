
(** Compteur pour identifier chaque instantiation des règles différentes*)
let rule_counter = ref 0 


(** Fonction de conversion d'un Ast.Atom en Query avec empactage *)
let convert (a : string Ast.Atom.t) : Query.t = 
  let n,l= (Ast.Atom.convert (Term.convert_var !rule_counter) a) in Query.Atom(n,l)

(** Prends des premices et les AND ensemble pour donner une Query*)
let rec build_and_query (liste: string Ast.Atom.t list) : Query.t = 
  match liste with
    [] -> Query.True
  | [a] -> convert a
  | t::q -> Query.And(convert t, build_and_query q)


(** Filter en appliquant unify en terme à terme entre les arguments de la conclusion et les arguments du paramètres*)
(* let filter_unify (terms : Term.t list) ((a,_) : string Ast.Rule.t) : bool = 
  let _,l = Ast.Atom.convert (Term.convert_var) a in
  try (List.iter2  Unify.unify l terms) ; true with
    |Unify.Unification_failure -> false *)


(** Renvoie un AND avec des tests d'égalités entre les paramètres de l'atome et de la liste de termes *)
let and_query_args (terms: Term.t list) (a: string Ast.Atom.t) : Query.t =
  let _,l = Ast.Atom.convert (Term.convert_var (!rule_counter)) a in
  assert (List.length l = List.length terms) ; (* On vérifie si on a la même taille de listes *)
  let rec aux l1 l2 = match l1,l2 with
    |[],[] -> Query.True
    |[a],[b] -> Equals(a,b)
    |t1::q1, t2::q2 -> And(Equals(t1,t2), aux q1 q2)
    |_ -> failwith("Not the same length")
  in aux terms l


(** Prends des règles et le terme original 
    Renvoie une query représentant un OU des différentes query composées de AND entre les arguments et les prémices *)
let rec or_equals_query (terms: Term.t list) (rules : string Ast.Rule.t list) : Query.t =
  (* On commence par incrémenter : A chaque exécution, on considère une règle différente *)
  incr rule_counter ; 
  match rules with
    |[] -> Query.False
    |[(a,premices)] -> And(and_query_args terms a, build_and_query premices)
    |(a,premices)::q -> Or(And(and_query_args terms a, build_and_query premices), or_equals_query terms q)


(** Conversion des règles parsées en un [atom_to_query_t] utilisable
  par [Query.search] pour résoudre des requêtes en intégrant les
  règles d'inférence données. *)
let rules (rules: (string Ast.Atom.t * string Ast.Atom.t list) list) : Query.atom_to_query_t =
  fun (name:string) (terms:Term.t list) -> 
    (* On garde les règles qui ont le même nom et le même cardinal que l'atome d'entrée *)
    let terms_length = List.length terms in
    let filtered = List.filter (fun (Ast.Atom.Atom(s,l),_) -> s = name && List.length l = terms_length) rules in
    
    (* Problème : on ne limite jamais avec un unify les règles
       cf plus(0,n,n) va s'unifier avec plus(1,2,3) *)
    (* Solution ? : On va essayer d'unifier termes à termes les arguments des règles *)
    (* On va plutôt utiliser l'arnaque suivante : 
       On va metre des tests d'égalités entre les paramètres dans dans le AND de la requête
       Ca permet de forcer, LORS DE L'EVALUATION, l'unification.
       On pourrait le faire maintenant mais ca demanderait d'annuler les modifications de l'unify puis de le refaire...*)

    (* On OR les premices des règles satisfantes ensembles en les convertissant en Query*)
    or_equals_query terms filtered

(** Conversion d'une liste d'atomes parsés en une requête conjonctive.
    La fonction renvoyée peut être appelée quand une solution aura été
    trouvée: elle affiche l'état des variables à ce moment là. *)
let query (atomes: string Ast.Atom.t list) : Query.t * (unit -> unit) =
  (* On crée la query à partir des atomes *)
  let q = build_and_query atomes in
  (* On récupère les variables qui apparaissent pour pouvoir afficher uniquement celle-ci *)
  let vars = List.map (fun v -> Term.var v) (Query.get_var_from_query q) in
  q, fun () -> Format.printf "%a" Term.pp_vars_in_list vars 