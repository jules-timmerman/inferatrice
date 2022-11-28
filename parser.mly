%{
open Ast
let rec term_of_int acc x =
  if x = 0 then acc else term_of_int (Term.App("s",[acc])) (x-1)
let term_of_int x = term_of_int (Term.App("z",[])) x
%}

%token <string> VAR
%token <string> CST
%token <int>    INT
%token LPAR COMMA RPAR
%token DERIVE FROM STOP
%token EOF

%start rules
%type <string Ast.Rule.t list> rules

%start query
%type <string Ast.Atom.t list> query

%%

rules:
  | EOF         { [] }
  | rule rules  { $1::$2 }

query:
  | atoms STOP  { $1 }
  | EOF         { exit 0 }

rule:
  | DERIVE atom FROM atoms STOP { $2,$4 }
  | DERIVE atom STOP            { $2,[] }

atom:
  | CST LPAR terms RPAR         { Atom ($1,$3) }

atoms:
  |                             { [] }
  | atom                        { [$1] }
  | atom COMMA atoms            { $1::$3 }

terms:
  |                             { [] }
  | term                        { [$1] }
  | term COMMA terms            { $1::$3 }

term:
  | VAR                         { Var $1 }
  | CST                         { App ($1,[]) }
  | CST LPAR terms RPAR         { App ($1,$3) }
  | INT                         { term_of_int $1 }
