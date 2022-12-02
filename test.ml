
let term_tests = "Term", [ (* {{{ *)

  "Fresh vars not var_equals", `Quick, begin fun () ->
    assert (not (Term.(var_equals (fresh ()) (fresh ()))))
  end ;

  "Fresh vars not equals", `Quick, begin fun () ->
    assert (not (Term.(equals (fresh_var ()) (fresh_var ()))))
  end ;

  "Bind", `Quick, begin fun () ->
    Term.reset () ;
    let v = Term.fresh () in
    let t = Term.make "c" [] in
    Term.bind v t ;
    assert Term.(equals (var v) t)
  end ;

  "Restore", `Quick, begin fun () ->
    Term.reset () ;
    let v = Term.fresh () in
    let t = Term.make "c" [] in
    let s = Term.save () in
    assert (not Term.(equals (var v) t)) ;
    Term.bind v t ;
    assert Term.(equals (var v) t) ;
    Term.restore s ;
    assert (not Term.(equals (var v) t))
  end ;

  "Restore to non-empty stack", `Quick, begin fun () ->
    Term.reset () ;
    Term.bind (Term.fresh ()) (Term.make "c" []) ;
    let v = Term.fresh () in
    let t = Term.make "c" [] in
    let s = Term.save () in
    Term.bind v t ;
    Term.restore s ;
    assert (not Term.(equals (var v) t))
  end ;

  "Printing", `Quick, begin fun () ->
    Term.reset () ;
    let v0 = Term.fresh () in
    let v = Term.var v0 in
    Format.printf "%a@." Term.pp Term.(make "c" []) ;
    Format.printf "%a@." Term.pp Term.(make "c" [v]) ;
    Format.printf "%a@." Term.pp Term.(make "c" [v;v]) ;
    Term.bind v0 (Term.make "d" []) ;
    Format.printf "%a@." Term.pp Term.(make "c" [v]) ;
  end ;

] (* }}} *)

let equals_tests = "Equals",[
  "X -> Y ; Y -> a ; X == a", `Quick, begin fun () ->
    let get_var_name (t:Term.t) = match t with
      | Var(xn,_) -> xn
      | _ -> failwith "eh ?"
    in
    let open Term in
    reset ();
    let x = fresh_var () in
    let xn = get_var_name x in
    let y = fresh_var () in
    let yn = get_var_name y in
    let a = make "a" [] in
    bind xn y ;
    bind yn a ;
    assert (equals x a) ;
  end;

  "X -> Y ; Y -> X ; X == Y", `Quick, begin fun () ->
    let get_var_name (t:Term.t) = match t with
      | Var(xn,_) -> xn
      | _ -> failwith "eh ?"
    in
    let open Term in
    reset ();
    let x = fresh_var () in
    let xn = get_var_name x in
    let y = fresh_var () in
    let yn = get_var_name y in
    bind xn y ;
    bind yn x ;
    assert (equals x y) ;
  end ;

  "X1 -> X2 -> X3 -> X4 -> X5 -> X6 -> X1 ; X1 == X3", `Quick, begin fun () ->
    let get_var_name (t:Term.t) = match t with
      | Var(xn,_) -> xn
      | _ -> failwith "eh ?"
    in
    let open Term in
    reset ();
    let x1 = fresh_var () in
    let xn1 = get_var_name x1 in
    let x2 = fresh_var () in
    let xn2 = get_var_name x2 in
    let x3 = fresh_var () in
    let xn3 = get_var_name x3 in
    let x4 = fresh_var () in
    let xn4 = get_var_name x4 in
    let x5 = fresh_var () in
    let xn5 = get_var_name x5 in
    let x6 = fresh_var () in
    let xn6 = get_var_name x6 in
    assert(not (equals x1 x3));
    bind xn1 x2 ;
    bind xn2 x3 ;
    bind xn3 x4 ;
    bind xn4 x5 ;
    bind xn5 x6 ;
    bind xn6 x1 ;
    assert (equals x1 x3) ;
  end ;

  "X -> X ; X == X", `Quick, begin fun () ->
    let open Term in 
    let get_var_name (t:Term.t) = match t with
      | Var(xn,_) -> xn
      | _ -> failwith "eh ?"
    in
    let x = fresh_var () in
    let xn = get_var_name x in
    bind xn x ;
    assert(equals x x);
  end
]


let unify_tests = "Unify", [

    "X = Y", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = fresh_var () in
      let y = fresh_var () in
      Unify.unify x y ;
      assert (equals x y)
    end ;

    "X = f()", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = Term.fresh_var () in
      let f = Term.make "f" [] in
      Unify.unify f x ;
      assert (equals f x)
    end ;

    "X = f(Y)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = Term.fresh_var () in
      let y = Term.fresh_var () in
      let f t = Term.make "f" [t] in
      Unify.unify (f y) x ;
      assert (equals (f y) x)
    end ;

    "X = f(X)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = fresh_var () in
      let fx = make "f" [x] in
      assert (not (equals x fx)) ;
      Alcotest.check_raises "unify" Unify.Unification_failure
        (fun () -> Unify.unify x fx)
    end ;

    "f(X) = g(X)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = fresh_var () in
      let u = make "f" [x] in
      let v = make "g" [x] in
      assert (not (equals u v)) ;
      Alcotest.check_raises "unify" Unify.Unification_failure
        (fun () -> Unify.unify u v)
    end ;

    "f(X,a) = f(a,X)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = fresh_var () in
      let a = make "a" [] in
      let u = make "f" [x;a] in
      let v = make "f" [a;x] in
      assert (not (equals u v)) ;
      Unify.unify u v ;
      assert (equals u v)
    end ;

    "f(X,b) = f(a,X)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = fresh_var () in
      let a = make "a" [] in
      let b = make "b" [] in
      let u = make "f" [x;b] in
      let v = make "f" [a;x] in
      assert (not (equals u v)) ;
      Alcotest.check_raises "unify" Unify.Unification_failure
        (fun () -> Unify.unify u v)
    end ;

    "f(Y,X) = f(f(X,a),Y)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = fresh_var () in
      let y = fresh_var () in
      let a = make "a" [] in
      let u = make "f" [y;x] in
      let v = make "f" [make "f" [x;a];y] in
      assert (not (equals u v)) ;
      Alcotest.check_raises "unify" Unify.Unification_failure
        (fun () -> Unify.unify u v)
    end ;

    "X = f(X)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = var (fresh ()) in
      let fx = make "f" [x] in
      Alcotest.check_raises "unify" Unify.Unification_failure
        (fun () -> Unify.unify x fx)
    end ;


    "X = f(Y)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = var (fresh ()) in
      let y = fresh_var () in
      let fy = make "f" [y] in
      assert(not (equals x fy)) ;
      Unify.unify x fy ;
      assert(equals x fy)
    end ;

    "Bin-tree", `Quick, begin fun () ->
      try begin 
        let node x y = Term.make "n" [x;y] in

        let x = Term.fresh_var () in
        let y = Term.fresh_var () in
        let rec tree t n =
          if n = 0 then t else tree (node t t) (n-1)
        in
        let n = 10_000 in
        let t1 = tree x n in
        let t2 = tree y n in
        Unify.unify t1 t2
      end with 
        Stack_overflow -> raise Stack_overflow
    end;

        (*"Fil", `Quick, begin fun () ->
      try begin 
        let node x = Term.make "n" [x] in

        let x = Term.fresh_var () in
        let y = Term.fresh_var () in
        let rec fil t n =
          if n = 0 then t else fil (node t) (n-1)
        in
        let n = 10_000_000 in
        let t1 = fil x n in
        let t2 = fil y n in         
        Unify.unify t1 t2
      end with 
        Stack_overflow -> raise Stack_overflow
    end;*)

    "Peigne", `Quick, begin fun () ->
      try begin 
        let node x y = Term.make "n" [x;y] in

        let x = Term.fresh_var () in
        let y = Term.fresh_var () in
        let rec peigne t v n =
          if n = 0 then t else peigne (node t v) v (n-1)
        in
        let n = 20 in
        let t1 = peigne x x n in
        let t2 = peigne y y n in
        Unify.unify t1 t2
      end with 
        Stack_overflow -> raise Stack_overflow
    end


] (* }}} *)

let (==) a b = Query.Equals (a,b)
let (||) a b = Query.Or (a,b)
let (&&) a b = Query.And (a,b)

let queries = "Queries", let open Query in [ (* {{{ *)

  "True", `Quick, begin fun () ->
    assert (has_solution True)
  end ;

  "False", `Quick, begin fun () ->
    assert (not (has_solution False))
  end ;

  "Foo", `Quick, begin fun () ->
    assert (not (has_solution (Atom ("foo",[]))))
  end ;

  "Closed propositional", `Quick, begin fun () ->
    let q1 = And (False,True) in
    let q2 = Or (False,True) in
    assert (not (has_solution q1)) ;
    assert (not (has_solution (Or (q1,q1)))) ;
    assert (has_solution q2) ;
    assert (has_solution (Or (q1,q2)))
  end ;

  "Equalities", `Quick, begin fun () ->
    Term.reset () ;
    let x = Term.fresh_var () in
    let y = Term.fresh_var () in
    let f t = Term.make "f" [t] in
    assert (has_solution (x == f y)) ;
    Term.reset () ;
    assert (has_solution (y == x)) ;
    Term.reset () ;
    assert (has_solution ((x == y || x == f y) && (x == f y))) ;
    Term.reset () ;
    assert (not (has_solution ((x == y || x == f y) &&
                               (x == f y && x == y))))
  end

] (* }}} *)

let () =
  Alcotest.run ~argv:Sys.argv "Infératrice"
    [ term_tests ;
      equals_tests ;
      unify_tests ;
      queries ]
