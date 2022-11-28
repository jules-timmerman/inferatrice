let pp_error fmt lexbuf =
  Format.fprintf fmt "au caractère %d, ligne %d"
    lexbuf.Lexing.lex_curr_p.Lexing.pos_cnum
    lexbuf.Lexing.lex_curr_p.Lexing.pos_lnum

let rules_from_filename filename =
  Format.printf "Lecture des règles dans %s...@." filename ;
  let lexbuf = Lexing.from_channel (open_in filename) in
  try
    Parser.rules Lexer.tokenize lexbuf
  with
  | Parsing.Parse_error ->
    Format.printf "Erreur de syntaxe %a.@." pp_error lexbuf ;
    exit 1
  | Ast.Lexing_error ->
    Format.printf "Echec de l'analyse lexicale %a.@." pp_error lexbuf ;
    exit 1

exception Abort

let () =
  let atom_to_query =
    if Array.length Sys.argv = 1 then None else
      let rules = rules_from_filename Sys.argv.(1) in
      Some (Convert.rules rules)
  in
  let lexbuf = Lexing.from_channel stdin in
  while true do
    Format.printf "\nRequête? " ;
    Format.print_flush () ;
    try
      let atoms = Parser.query Lexer.tokenize lexbuf in
      let query, print_solution = Convert.query atoms in
      let print_solution () =
        print_solution () ;
        Format.printf "More solutions? [Y/n] " ;
        Format.print_flush () ;
        try
          let l = input_line stdin in
          if l = "" || l.[0] = 'y' || l.[0] = 'Y' then () else
            raise Abort
        with End_of_file -> exit 0
      in
      Format.printf "Résolution de la requête %a...@." Query.pp query ;
      try
        Query.search ?atom_to_query print_solution query ;
        Format.printf "Fin des solutions pour cette requête.@."
      with Abort ->
        Format.printf "Abandon de cette requête.@."
    with
    | Parsing.Parse_error ->
      Format.printf "Erreur de syntaxe %a.@." pp_error lexbuf ;
      Lexing.flush_input lexbuf
    | Ast.Lexing_error ->
      Format.printf "Echec de l'analyse lexicale %a.@." pp_error lexbuf ;
      Lexing.flush_input lexbuf
  done
