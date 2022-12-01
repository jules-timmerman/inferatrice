(** Le type [t] correspond à la représentation interne des termes.
* Le type [var] représente les variables, c'est à dire les objets que
* l'on peut instantier.
* Le type [obs_t] correspond à un terme superficiellement explicité. *)

type var = string
type t = Fun of string * t list | Var of var
type obs_t = t

(** Manipulation de l'état: sauvegarde, restauration. *)

type state = (var * t) list
let global_state: state ref = ref []

let variable_number: int ref = ref 0


(** Vérifie si une variable existe dans l'environnement *)
let existe (v: var) (s: state option) : bool = 
  assert (v != "");
  let state_to_search = Option.value s ~default:!global_state in
  let rec search l = 
    match l with
      [] -> false
    | (name, _)::q -> name = v || search q
  in search state_to_search

(** Modification d'une variable.
    On rajoute en tête de liste pour le nouveau *)
let bind (v: var) (t: t) : unit =
  assert (v != "");
  Format.printf "Bind appelé : %s\n" v;
  global_state := (v,t)::(!global_state)

(** Recherche d'une variable dans un environnement 
    None : dans l'environnement actuel
    Some(s) : dans l'environnement s 
    Renvoie la valeur, ou raise fail sinon *)
let lookup (v: var) (s: state option) : t =
  assert (v != "");
  let state_to_search = Option.value s ~default:!global_state in
  let rec search l =
    match l with
      [] -> failwith "Variable existe pas, faut call existe avant"
    | (name, value)::q -> if name = v then value else search q
  in assert (existe v s) (* Au cas où *); search state_to_search

(** Observation d'un terme. *)
let observe (t: t) : obs_t =
  t

(** Egalité syntaxique entre termes et variables. *)
let rec var_equals (v1: var) (v2: var) : bool = 
  let ex1 = existe v1 None and ex2 = existe v2 None in
  v1 = v2 || 
  (ex1 && equals (lookup v1 None) (Var v2)) || 
  (ex2 && equals (lookup v2 None) (Var v1)) || 
  (ex1 && ex2 && equals (lookup v1 None) (lookup v2 None))     

and equals (t1:t) (t2:t) : bool =
  let rec aux (b : bool) (t1 : t) (t2 : t) : bool =
    match t1, t2 with
    | Var(x), Var(y) -> var_equals x y
    | Fun (s1, l1), Fun(s2, l2) when s1=s2 -> 
      (
      match l1,l2 with
      | [],[] -> true
      | [], _ -> false
      | _, [] -> false
      | hd1::tl1, hd2::tl2 -> aux b hd1 hd2 && aux b (Fun (s1, tl1)) (Fun (s2, tl1))
      )
    | Var(x), y when (existe x None) -> 
        lookup x None = y
    | x, Var(y) when existe y None ->
        lookup y None = x
    | _ -> false
  in aux true t1 t2



(** Constructeurs de termes. *)

(** Création d'un terme construit à partir d'un symbole
  * de fonction -- ou d'une constante, cas d'arité 0. *)
let make (nom: string) (termes: t list) : t =
  assert (nom != "");
  Fun(nom, termes)

(** Création d'un terme restreint à une variable. *)
let var (v: var) : t =
  Var(v)

(** Création d'une variable fraîche. *)
let fresh () : var = 
  let name = "Var_" ^ (string_of_int !variable_number) in
    incr variable_number;
    name

(** Combinaison des deux précédents. *)
let fresh_var () : t =
  var (fresh ())

(** [save ()] renvoie un descripteur de l'état actuel. *)
let save () : state =
  !global_state

(** [restore s] restaure les variables dans l'état décrit par [s]. *)
let restore (s: state) : unit = 
  global_state := s

(** Remise à zéro de l'état interne du module.
    Aucun impact sur les termes déja créés, mais garantit que
    les futurs usages seront comme dans un module fraichement
    initialisé. *)
let reset () : unit =
  global_state := [];
  variable_number := 0

(** Pretty printing *)
let rec pp_args (ppf: Format.formatter) (args: t list) : unit = 
  match args with 
    [] -> Format.fprintf ppf ""
  | [t] -> Format.fprintf ppf "%a" pp t
  | t::q -> Format.fprintf ppf "%a, %a" pp t pp_args q
and pp (ppf: Format.formatter) (elem: t) : unit =
  match elem with 
    Var (s) ->
    if existe s None then
        let value = (lookup s None) in
          Format.fprintf ppf "@[<h>(%s = %a)@]" s pp value 
    else
        Format.fprintf ppf "@[<h>%s@]" s
  | Fun (f, args) -> Format.fprintf ppf "@[<h>%s(%a)@]" f pp_args args

let test_print () : unit = 
  Format.printf "%a" pp (Fun ("f", [Fun ("g", [Var "X"]); Fun ("h", [Var "y"]); Var "Z"]))

let pp_var_name_only (ppf: Format.formatter) (v: t) : unit = 
  match v with
    Var(s) -> Format.fprintf ppf "@[<h>%s@]" s
  | _ -> Format.printf "@[<h>%a@]" pp v

let pp_vars_in_list (ppf: Format.formatter) (l: t list) : unit =
  let rec parcours (l: t list) : unit =
    match l with 
      [] -> ()
    | Var(s)::q -> Format.fprintf ppf "%a" pp_var_name_only (Var s); parcours q
    | _::q -> parcours q
  in parcours l

let pp_state (ppf: Format.formatter) (s: state option) : unit = 
  let rec pp_state_rec (ppf: Format.formatter) (s: state) = match s with
    [] -> Format.fprintf ppf ""
  | (n, v)::q -> Format.fprintf ppf "\t@[<h>%s -> %a@]@.%a" n pp_var_name_only v pp_state_rec q
  in let st = Option.value s ~default:(!global_state) in
    Format.fprintf ppf "{@.";
    Format.fprintf ppf "@[<h>%a@]@.}" pp_state_rec st 
(*
let pp_state (ppf: Format.formatter) (s: state option) : unit =
  ignore (ppf, s);
  let rec parcours s = match s with
    [] -> ()
  | (n, v)::q -> Format.printf "\t%s -> %a\n" n pp v; parcours q
    in parcours !global_state
*)

let convert_var s = fresh_var ()