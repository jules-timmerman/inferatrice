(** Le type [t] correspond à la représentation interne des termes.
  * Le type [var] représente les variables, c'est à dire les objets que
  * l'on peut instantier.
  * Le type [obs_t] correspond à un terme superficiellement explicité. *)

  type t
  type var
  type obs_t = Fun of string * t list | Var of var
  
  (** Modification d'une variable. *)
  let bind (v: var) (t: t) : unit =
    failwith "TODO bind"
  
  (** Observation d'un terme. *)
  let observe (t: t) : obs_t =
    failwith "TODO observe"
  
  (** Egalité syntaxique entre termes et variables. *)
  let equals (t1: t) (t2: t) : bool =
    failwith "TODO equals"
  let var_equals (v1: var) (v2: var) : bool = 
    failwith "TODO var_equals"

  
  
  (** Constructeurs de termes. *)
  
  (** Création d'un terme construit à partir d'un symbole
    * de fonction -- ou d'une constante, cas d'arité 0. *)
  let make (nom: string) (termes: t list) : t =
    failwith "TODO make"
  
  (** Création d'un terme restreint à une variable. *)
  let var (v: var) : t =
    failwith "TODO var"
  
  (** Création d'une variable fraîche. *)
  let fresh () : var = 
    failwith "TODO fresh"
  
  (** Combinaison des deux précédents. *)
  let fresh_var () : t =
    failwith "FODO fresh_var"
  
  (** Manipulation de l'état: sauvegarde, restauration. *)
  
  type state
  
  (** [save ()] renvoie un descripteur de l'état actuel. *)
  let save () : state =
    failwith "TODO save"
  
  (** [restore s] restaure les variables dans l'état décrit par [s]. *)
  let restore (s: state) : unit = 
    failwith "TODO restore"
  
  (** Remise à zéro de l'état interne du module.
      Aucun impact sur les termes déja créés, mais garantit que
      les futurs usages seront comme dans un module fraichement
      initialisé. *)
  let reset () : unit =
    failwith "TODO reset"
  
  (** Pretty printing *)
  
  let pp (fmt: Format.formatter) (elem: t) : unit =
    failwith "TODO pp"
  