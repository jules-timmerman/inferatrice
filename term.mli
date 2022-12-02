val debug : (unit -> unit) -> unit

(** Le type [t] correspond à la représentation interne des termes.
  * Le type [var] représente les variables, c'est à dire les objets que
  * l'on peut instantier.
  * Le type [obs_t] correspond à un terme superficiellement explicité. *)

type var = string
type t = Fun of string * t list | Var of var*string
type obs_t = Fun of string * t list | Var of var
  
type state = (var * t) list

(** Modification d'une variable. *)
val bind : var -> t -> unit

(** Vérifie si une variable existe dans l'environnement *)
val existe : var -> state option -> bool
(** Recherche d'une variable dans un environnement *)
val lookup : var -> state option -> t

(** Observation d'un terme. *)
val observe : t -> obs_t

(** Egalité syntaxique entre termes et variables. *)

val equals : t -> t -> bool
val var_equals : var -> var -> bool


(** Constructeurs de termes. *)

(** Création d'un terme construit à partir d'un symbole
  * de fonction -- ou d'une constante, cas d'arité 0. *)
val make : string -> t list -> t

(** Création d'un terme restreint à une variable. *)
val var : ?name:string -> var -> t

(** Création d'une variable fraîche. *)
val fresh : unit -> var

(** Combinaison des deux précédents. *)
val fresh_var : unit -> t

(** Manipulation de l'état: sauvegarde, restauration. *)

(** [save ()] renvoie un descripteur de l'état actuel. *)
val save : unit -> state

(** [restore s] restaure les variables dans l'état décrit par [s]. *)
val restore : state -> unit

(** Remise à zéro de l'état interne du module.
    Aucun impact sur les termes déja créés, mais garantit que
    les futurs usages seront comme dans un module fraichement
    initialisé. *)
val reset : unit -> unit

(** Pretty printing *)

val pp_args: Format.formatter -> t list -> unit
val pp : Format.formatter -> t -> unit

val pp_state : Format.formatter -> state option -> unit
val pp_vars_in_list : Format.formatter -> t list -> unit

(** Fonction de translation pour Ast *)
val convert_var : int -> 'a -> t


val get_var_from_term : t -> var list
val get_var_from_terms : t list -> var list

