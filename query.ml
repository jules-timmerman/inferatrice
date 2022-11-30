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
  | Or (t1, t2) -> Format.fprintf ppf "@[<h>(%a || %a)@]" pp t1 pp t2
  | And (t1, t2) -> Format.fprintf ppf "@[<h>(%a && %a)@]" pp t1 pp t2
  | Equals (t1, t2) -> Format.fprintf ppf "@[<h>(%a == %a)@]" Term.pp t1 Term.pp t2
  | Atom (name, l) -> Format.fprintf ppf "@[<h>%s(%a)@]" name Term.pp_args l

(** Valeur par défaut du premier argument de search*)
let default_search: atom_to_query_t = fun s l ->
  False

(** On a de base aucune règle donc c'est plutôt False*)
let default_has: atom_to_query_t = fun s l ->
  False


exception End
exception Found


let rec search ?(atom_to_query = default_search) (cont:(unit -> 'a)) (t:t) : unit =
  Format.fprintf Format.std_formatter "\n\nTraitement de la query : \n%a\n" pp t ;
  let f = search ~atom_to_query:atom_to_query in
  try 
    begin
      match t with
        | True -> ignore (cont ())
        | False -> ()
        | And(t1,t2) ->
          f (fun () -> (f cont t2) ; raise End) t1 
        | Or(t1, t2) ->
          let s = Term.save () in
          f cont t1 ;
          Term.restore s ; 
          f cont t2
        | Equals (t1, t2) ->
          begin
            try (Unify.unify t1 t2 ; ignore (cont ())) with
              |Unify.Unification_failure -> ()
          end
        | Atom(n, l) -> let q = atom_to_query n l in f cont q
    end
  with
    | End -> ()



let has_solution ?(atom_to_query = default_has)  (t:t) : bool =
  try search ~atom_to_query:atom_to_query (fun () -> raise Found) t ; false
    with 
    | Found -> true