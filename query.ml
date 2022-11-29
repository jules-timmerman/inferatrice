type t =
  | Atom of string * Term.t list
  | Equals of Term.t * Term.t
  | And of t * t
  | Or of t * t
  | False
  | True

type atom_to_query_t = string -> Term.t list -> t

let rec pp (ppf: Format.formatter) (t: t) : unit =
  match t with 
    True -> Format.fprintf ppf "True"
  | False -> Format.fprintf ppf "False"
  | Or (t1, t2) -> Format.fprintf ppf "@[(%a || %a)@]" pp t1 pp t2
  | And (t1, t2) -> Format.fprintf ppf "@[(%a && %a)@]" pp t1 pp t2
  | Equals (t1, t2) -> Format.fprintf ppf "@[(%a == %a)@]" Term.pp t1 Term.pp t2
  | Atom (name, l) -> Format.fprintf ppf "@[%s(%a)@]" name Term.pp_args l

(** Valeur par défaut du premier argument de search*)
let default_search: atom_to_query_t = fun s l ->
  False

(** On a de base aucune règle donc c'est plutôt False*)
let default_has: atom_to_query_t = fun s l ->
  False


let rec has_solution ?(atom_to_query = default_has)  (t:t) : bool = match t with
  | True -> true
  | False -> false
  | And(t1,t2) ->  
    (* On devra calculer les deux donc on fait aussi les modifications associées pour avoir la réponse*)
    let b1 = has_solution ~atom_to_query:atom_to_query t1 in
    b1 && (has_solution ~atom_to_query:atom_to_query t2)
  | Or(t1,t2) -> 
    (* On calcule jusqu'à avoir un résultat, au quel cas on change l'environnement, sinon on restore*)
    let save = Term.save () in
    if (has_solution ~atom_to_query:atom_to_query t1) then
      true  
    else (
      Term.restore save ; let save = Term.save () in
      if (has_solution ~atom_to_query:atom_to_query t2) then
        true
      else(
        Term.restore save ; false
      )
    )
  | Equals(t1, t2) -> 
  begin 
    try (Unify.unify t1 t2 ; true) with
      |Unify.Unification_failure -> false
  end
  | Atom(n,l) -> let q = atom_to_query n l in has_solution ~atom_to_query:atom_to_query q

and has_solution_no_modification (atom_to_query : atom_to_query_t) (t:t) : bool =
  let s = Term.save () in 
  let b = has_solution t ~atom_to_query:atom_to_query in
  Term.restore s ; b 

let search ?(atom_to_query = default_search) (cont:(unit -> 'a)) (t:t) : unit =
  if (has_solution ~atom_to_query:atom_to_query t) then
    ignore (cont ())