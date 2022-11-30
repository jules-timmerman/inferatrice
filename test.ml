
let term_tests = "Term", [ (* {{{ *)

  "Fresh vars not var_equals", `Quick, begin fun () ->
    assert (not (Term.(var_equals (fresh ()) (fresh ()))))
  end ;

  "Fresh vars not equals", `Quick, begin fun () ->
    assert (not (Term.(equals (var (fresh ())) (var (fresh ())))))
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

let unify_tests = "Unify", [ (* {{{ *)

    "f(X,a) = f(a,X)", `Quick, begin fun () ->
      let open Term in
      reset () ;
      let x = var (fresh ()) in
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
      let x = var (fresh ()) in
      let a = make "a" [] in
      let b = make "b" [] in
      let u = make "f" [x;b] in
      let v = make "f" [a;x] in
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

    "Bin-tree", `Quick, begin fun () ->
      try begin 
        let node x y = Term.make "n" [x;y] in

        let x = Term.fresh_var () in
        let y = Term.fresh_var () in
        let rec tree t n =
          if n = 0 then t else tree (node t t) (n-1)
        in
        let n = 10_000_000 in
        let t1 = tree x n in
        let t2 = tree y n in
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
      unify_tests ;
      queries ]
