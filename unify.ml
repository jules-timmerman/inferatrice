open Term

exception Unification_failure

(*Return true si la variable est déja dans le terme, false sinon*)
let rec look_for (v : var) (t : t) : bool = 
    match t with
    | Var(x) -> var_equals x v || (if (existe x None) then (look_for v (lookup x None) ) else false)
    | Fun (s, []) -> false
    | Fun (s, hd::tl) -> look_for v hd || look_for v (Fun (s, tl))


(** La fonction unify prend deux termes et effectue des instantiations
  * pour les unifier. Par effet de bord elle rend les termes égaux,
  * si possible; sinon elle lève l'exception Unification_failure.
  * Elle n'effectue jamais plus d'instantiations que nécessaire.
  *
  * On ne demande pas forcément que l'état des variables soit inchangé
  * en cas d'échec. *)
let rec unify (t1: t) (t2: t) : unit =
  match observe t1, observe t2 with
  | Var x, Var y when var_equals x y -> ()
  | Var x, t -> (* Cas une variable et un terme : on unifie si la variable n'est pas dans t *)
    if look_for x t then
      raise Unification_failure
    else
        (if existe x None then 
          (if lookup x None = t then 
            ()
          else 
            raise Unification_failure)
        else 
          bind x t)
  | t, Var y -> unify t2 t1(* Revient au cas précédent *)
  | Fun (s1, _), Fun (s2, _) when s1<>s2 -> raise Unification_failure (* Si deux fct différentes : impossible d'unifier *)
  | Fun (_, []), Fun (_, []) -> () (*déja unifié si plus que 2 listes vides*)
  | Fun (_, []), Fun (_, _) -> raise Unification_failure (* pas le meme nb de paramètres : liste vide *)
  | Fun (_, _), Fun (_, []) -> raise Unification_failure (* idem *)
  | Fun (s1, hd1::tl1), Fun (s2, hd2::tl2) -> unify hd1 hd2 ; unify (Fun(s1,tl1)) (Fun(s2,tl2)) (* On unifie terme par terme *)
