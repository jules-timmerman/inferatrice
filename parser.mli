type token =
  | VAR of (string)
  | CST of (string)
  | INT of (int)
  | LPAR
  | COMMA
  | RPAR
  | DERIVE
  | FROM
  | STOP
  | EOF

val rules :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string Ast.Rule.t list
val query :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string Ast.Atom.t list
