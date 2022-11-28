type t =
  | Atom of string * Term.t list
  | Equals of Term.t * Term.t
  | And of t * t
  | Or of t * t
  | False
  | True

type atom_to_query_t = string -> Term.t list -> t

let pp (format:Format.formatter) (t:t) : unit =
  failwith("TODO pp")


(** Valeur par défaut du premier argument de search*)
let default_search: atom_to_query_t = fun s l ->
  failwith "TODO defaultSearch"

let search ?(atom_to_query = default_search) (cont:(unit -> 'a)) (t:t) : unit =
  failwith("TODO search")

let default_has: atom_to_query_t = fun s l ->
  failwith "TODO defaultHas"

let has_solution ?(atom_to_query = default_has)  (t:t) : bool =
  failwith("TODO has_solution")

