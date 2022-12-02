(** Le type [t] correspond à la représentation interne des termes.
* Le type [var] représente les variables, c'est à dire les objets que
* l'on peut instantier.
* Le type [obs_t] correspond à un terme superficiellement explicité. *)

type var = string
type t = Fun of string * t list | Var of var * string
type obs_t = Fun of string * t list | Var of var

(** Manipulation de l'état: sauvegarde, restauration. *)

type state = (var * t) list
let global_state: state ref = ref []

let variable_number: int ref = ref 0


(* On utilise les deux prochaines variables pour éviter de faire trop d'instantiation
   Cf dans les règles, on a les variables X qui ont les mêmes noms *)
(** Liste contenant les associations pour la règle en cours d'association
   Le int est le hash de l'objet 'a passé dans convert_var *)
let instantiation_in_process : (int * var) list ref = ref []

(** Le numéro de la règle en cours *)
let instantiation_number : int ref = ref 0

(** Création d'un terme restreint à une variable. *)
let var ?(name = "") (v: var) : t =
  Var(v, name)


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
  match t with
    |Var(v,_) -> Var(v)
    |Fun(s,l) -> Fun(s,l)

let cont_def () = true

let rec equal_init (cont: unit -> bool) (t1 : t) (t2 : t) : bool =
    match (observe t1, observe t2) with 
      Var x, Var y -> var_equals_init cont x y
    | Fun(s1, l1), Fun (s2,l2) when s1 = s2 -> 
      (
        match l1, l2 with
          [], [] -> cont ()
        | _, [] -> false
        | [], _ -> false
        | t1::q1, t2::q2 -> equal_init (fun () -> cont () && (equal_init cont_def t1 t2)) (Fun(s1, q1)) (Fun(s2, q2))
      )
    | Var(x), _ when (existe x None) -> 
        equal_init cont (lookup x None) t2
    | _, Var(y) when existe y None ->
      equal_init cont t1 (lookup y None)
    | _ -> false
        

and var_equals_init (cont: unit -> bool) (v1: var) (v2: var) : bool =
  match (existe v1 None, existe v2 None) with
  | true, false -> equal_init (fun () -> cont ()) (lookup v1 None) (var v2)
  | false, true -> equal_init (fun () -> cont ()) (var v1) (lookup v2 None)
  | true, true -> equal_init (fun () -> cont ()) (lookup v1 None) (lookup v2 None)
  | _ -> v1 = v2

let equals (t1:t) (t2:t) : bool =
  equal_init cont_def t1 t2

let var_equals (v1: var) (v2: var) : bool =
  var_equals_init cont_def v1 v2
(** On suit une chaines de variables jusqu'à obtenir une valeur 
    ou une variable non initialisée *)
let follow_chain (v: var) : t = 
  let rec parcours (name: var) : t =
    if existe name None then 
      let v = lookup name None in
      match observe v with
        Var(n) -> parcours n
      | _ -> v
    else
      var name
  in parcours v  

(** Constructeurs de termes. *)

(** Création d'un terme construit à partir d'un symbole
  * de fonction -- ou d'une constante, cas d'arité 0. *)
let make (nom: string) (termes: t list) : t =
  assert (nom != "");
  Fun(nom, termes)


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
  match observe elem with 
    Var (s) ->
    if existe s None then
        let value = (lookup s None) in
          Format.fprintf ppf "@[<h>%a@]" pp value 
    else
        Format.fprintf ppf "@[<h>%s@]" s
  | Fun (f, args) -> Format.fprintf ppf "@[<h>%s(%a)@]" f pp_args args


let pp_var_name_only (ppf: Format.formatter) (v: t) : unit = 
  match observe v with
    Var(s) -> Format.fprintf ppf "@[<h>%s@]" s
  | _ -> Format.printf "@[<h>%a@]" pp v

let pp_vars_in_list (ppf: Format.formatter) (l: t list) : unit =
  let rec parcours (l: t list) : unit =
    match l with 
      [] -> ()
    | Var(s,n)::q when n = ""-> Format.fprintf ppf "@[%s = %a@]@." s pp (follow_chain s); parcours q
    | Var(s,n)::q-> Format.fprintf ppf "@[%s = %a@]@." n pp (follow_chain s); parcours q
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

let convert_var (i:int) (s:'a) : t = 
  (* Si i !=, on a changé de règle donc on vide la liste actuelle de mémoire et on change le numéro courant*)
  if i <> !instantiation_number then (
  instantiation_number := i ;
instantiation_in_process := []
  ) ;
  let h = Hashtbl.hash s in
  (* On cherche si la variable a déja été créée pendant cette instantiation *)
  try 
    let v = List.assoc h (!instantiation_in_process) in  
    var v
  with
    | Not_found -> let v = fresh () in 
      instantiation_in_process := (h,v)::(!instantiation_in_process) ; var v

let get_var_from_term (t:t) : var list =
  let rec aux (t:t) (acc: var list) : var list = 
  match (observe t) with
    |Var(v) -> v::acc
    |Fun(n,l) -> List.fold_left (fun a t -> aux t a) acc l
  in aux t [] 

let get_var_from_terms (l : t list) : var list =
  let rec aux (t:t) (acc: var list) : var list = 
  match (observe t) with
    |Var(v) -> v::acc
    |Fun(n,l) -> List.fold_left (fun a t -> aux t a) acc l
in List.fold_left (fun a t -> aux t a) [] l