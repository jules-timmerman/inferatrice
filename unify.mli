open Term

exception Unification_failure


(** La fonction unify prend deux termes et effectue des instantiations
  * pour les unifier. Par effet de bord elle rend les termes égaux,
  * si possible; sinon elle lève l'exception Unification_failure.
  * Elle n'effectue jamais plus d'instantiations que nécessaire.
  *
  * On ne demande pas forcément que l'état des variables soit inchangé
  * en cas d'échec. *)
val unify : t -> t -> unit
