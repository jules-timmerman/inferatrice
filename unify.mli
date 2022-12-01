open Term

exception Unification_failure

(**Supprime les couples de termes déja unifiés des listes de termes qui suivent *)
val remove_couple : t -> t -> t list -> t list -> (t list * (t list))

(**Supprime le terme déja unifié de la liste de termes qui suit *)
val remove : t -> t list -> t list

(***Return true si v est une variable de t*)
val look_for : var -> t -> bool


(** La fonction unify prend deux termes et effectue des instantiations
  * pour les unifier. Par effet de bord elle rend les termes égaux,
  * si possible; sinon elle lève l'exception Unification_failure.
  * Elle n'effectue jamais plus d'instantiations que nécessaire.
  *
  * On ne demande pas forcément que l'état des variables soit inchangé
  * en cas d'échec. *)
val unify : t -> t -> unit
