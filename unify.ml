open Term

exception Unification_failure

(**Supprime les couples de termes déja unifiés des listes de termes qui suivent *)
let rec remove_couple (t1 : t) (t2 : t) (l1 : t list) (l2 : t list) : (t list * (t list))=
  match l1, l2 with 
  | [], l -> [],l
  | l, [] -> l, []
  | hd1::tl1, hd2::tl2 when (equals t1 hd1 && equals t2 hd2)-> remove_couple t1 t2 tl1 tl2
  | hd1::tl1, hd2::tl2 when (equals t1 hd2 && equals t2 hd1)-> remove_couple t1 t2 tl1 tl2
  | hd1::tl1, hd2::tl2 -> let (a,b) = remove_couple t1 t2 tl1 tl2 in (hd1::a, hd2::b)

(**Supprime le terme déja unifié de la liste de termes qui suit *)
let rec remove (t : t) (l : t list) : t list = 
  match l with
  | [] -> []
  | hd::tl when equals t hd -> remove t tl
  | hd::tl -> hd::(remove t tl)


(**Return true si la variable est déja dans le terme, false sinon*)
let rec look_for (v : var) (t : t) : bool = 
  match observe t with
  | Var(x) -> var_equals x v || (if (existe x None) then 
    (look_for v (lookup x None) ) else false)
  | Fun (s, []) -> false
  | Fun (s, hd::tl) ->  look_for v (Fun (s, remove hd tl)) || look_for v hd


(** La fct sort prend un terme et une liste de termes.
    lorsque'on appelle sort, t est en faite le premier terme d'une liste. 
    Si t est une fonction et que le tête de la liste l est une var : 
    on les échange dans la liste rendue.
    ON renvoie true si il y a eu changement de la liste, false sinon.
     *)
let sort (t : t) (l : t list) : (t list* bool) = 
  match observe t,l with
  | Fun(_), h1::tl ->
      (match observe h1 with
      | Var _ -> h1::t::tl, true
      | _ -> t::l, false)
  |_ -> t::l, false

(** La fonction unify prend deux termes et effectue des instantiations
  * pour les unifier. Par effet de bord elle rend les termes égaux,
  * si possible; sinon elle lève l'exception Unification_failure.
  * Elle n'effectue jamais plus d'instantiations que nécessaire.
  *
  * On ne demande pas forcément que l'état des variables soit inchangé
  * en cas d'échec. *)
let rec unify (t1: t) (t2: t) : unit =
  match observe t1, observe t2 with
  | Var x, Var y when (var_equals x y) -> ()
  | Var x, t -> (* Cas une variable et un terme : on unifie si la variable n'est pas dans t *)
    if look_for x t2 then
      raise Unification_failure
    else
        (if existe x None then
          let t_bis = lookup x None in
          (
            (if equals t_bis t2 then 
            ()
          else
            unify t_bis t2)
          )
        else 
          bind x t2)
  | t, Var y -> unify t2 t1(* Revient au cas précédent *)
  | Fun (s1, _), Fun (s2, _) when s1<>s2 -> raise Unification_failure (* Si deux fct différentes : impossible d'unifier *)
  | Fun (_, []), Fun (_, []) -> () (*déja unifié si plus que 2 listes vides*)
  | Fun (_, []), Fun (_, _) -> raise Unification_failure (* pas le meme nb de paramètres : liste vide *)
  | Fun (_, _), Fun (_, []) -> raise Unification_failure (* idem *)
  | Fun (s1, hd1::tl1), Fun (s2, hd2::tl2) ->
      let (a,b) = remove_couple hd1 hd2 tl1 tl2 in
      unify hd1 hd2; unify (Fun(s1,a)) (Fun(s2,b)) (* On unifie terme par terme *)

