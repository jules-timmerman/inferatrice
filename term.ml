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
  
  (** Modification d'une variable. 
      On rajoute en tête de liste pour le nouveau *)
  let bind (v: var) (t: t) : unit =
    global_state := (v,t)::(!global_state)
  
  (** Observation d'un terme. *)
  let observe (t: t) : obs_t =
    t
  
  (** Egalité syntaxique entre termes et variables. *)
  (** Egalité syntaxique entre termes et variables. *)
  let var_equals (v1: var) (v2: var) : bool = 
    v1 = v2

  let rec equals (t1: t) (t2: t) : bool =
    match t1, t2 with
    | Var(x),Var(y) -> var_equals x y
    | Fun (s1, []), Fun(s2, []) -> s1=s2
    | Fun (s1, l1), Fun(s2, l2) -> s1=s2 && List.equal equals l1 l2
    | _ -> false
  
  (** Constructeurs de termes. *)
  
  (** Création d'un terme construit à partir d'un symbole
    * de fonction -- ou d'une constante, cas d'arité 0. *)
  let make (nom: string) (termes: t list) : t =
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
    global_state := []
  
  (** Pretty printing *)
  
  let pp (fmt: Format.formatter) (elem: t) : unit =
    failwith "TODO pp"
  

  let convert_var s = fresh_var ()