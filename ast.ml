(** Data types and utilities for parsing and pre-processing rules. *)

(** Exception raised by lexer. *)
exception Lexing_error

module Term = struct

  (** Abstract syntax tree for parsed terms.
      Variables are represented as strings in parsed terms,
      but intermediate representations before conversion to
      [Term.t] terms can be useful. *)
  type 'a t =
    | App of string * 'a t list
    | Var of 'a

  (** Map a function [f] on the variables of a term,
      i.e. replace each variable [Var x] by [f x]. *)
  let rec map f = function
    | Var x -> f x
    | App (c,args) -> App (c, List.map (map f) args)

  (** Convert ['a Ast.Term.t] to [Term.t]
      using the provided translation function for variables. *)
  let rec convert convert_var = function
    | Var s -> convert_var s
    | App (c,ts) -> Term.make c (List.map (convert convert_var) ts)

end

module Atom = struct

  type 'a t = Atom of string * 'a Term.t list

  (** Same as [Term.map] but for all terms inside an atom. *)
  let map f (Atom (a,l)) = Atom (a, List.map (Term.map f) l)

  (** Same as [Term.convert] but for atoms.
      The returned value can be used as parameter for [Query.Atom]. *)
  let convert f (Atom (a,l)) = (a, List.map (Term.convert f) l)

end

module Rule = struct

  type 'a t = 'a Atom.t * 'a Atom.t list

  (** Name of conclusion atom. *)
  let conclusion_symbol (Atom.Atom (c,_), _) = c

  (** Map a function to all atoms in a rule. *)
  let map f (conclusion,premisses) = (f conclusion, List.map f premisses)

end
