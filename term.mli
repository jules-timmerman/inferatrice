(** Le type [t] correspond à la représentation interne des termes.
  * Le type [var] représente les variables, c'est à dire les objets que
  * l'on peut instantier.
  * Le type [obs_t] correspond à un terme superficiellement explicité. *)

type var = string
type t = Fun of string * t list | Var of var
type obs_t = t

type state = (var * t) list

(** Modification d'une variable. *)
val bind : var -> t -> unit

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
val var : var -> t

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

val test_print : unit -> unit


(** Fonction de translation pour Ast *)
val convert_var : 'a -> t
