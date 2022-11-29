open Term

exception Unification_failure


(*Return true si variable non liée à une fct, false sinon*)
let rec not_bound (v: var) : bool =
  (
  try
    let new_v = (lookup v None) in
    match new_v with
    | Var(x) -> not_bound x
    | Fun(s,ts) -> false
  with
    Lookup_failure ->  true
  )


(*Return true si la variable est déja dans le terme, false sinon*)
  let rec look_for (v : var) (t : t) : bool = 
    if not_bound v then
      match t with
      | Var(x) -> var_equals x v
      | Fun (s, []) -> false
      | Fun (s, hd::tl) -> look_for v hd || look_for v (Fun (s, tl))
    else true
  


(** La fonction unify prend deux termes et effectue des instantiations
  * pour les unifier. Par effet de bord elle rend les termes égaux,
  * si possible; sinon elle lève l'exception Unification_failure.
  * Elle n'effectue jamais plus d'instantiations que nécessaire.
  *
  * On ne demande pas forcément que l'état des variables soit inchangé
  * en cas d'échec. *)
let rec unify (t1: t) (t2: t) : unit =
  if equals t1 t2 then
    () (* déja unifiés *)
  else
    match observe t1, observe t2 with
    | Var x, t -> (* Cas une variable et un terme : on unifie si la variable n'est pas dans t *)
      if look_for x t then 
        raise Unification_failure
      else
        bind x t
    | t, Var y -> (* Cas symétrique *)
      if look_for y t then 
        raise Unification_failure
      else
        bind y t
    | Fun (s1, _), Fun (s2, _) when s1<>s2 -> raise Unification_failure (* Si deux fct différentes : impossible d'unifier *)
    | Fun (_, []), Fun (_, _) -> raise Unification_failure (* pas le meme nb de paramètres : liste vide *)
    | Fun (_, _), Fun (_, []) -> raise Unification_failure (* idem *)
    | Fun (s1, hd1::tl1), Fun (s2, hd2::tl2) -> unify hd1 hd2 ; unify (Fun(s1,tl1)) (Fun(s2,tl2)) (* On unifie terme par terme *)
