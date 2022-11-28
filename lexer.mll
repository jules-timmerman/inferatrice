{
open Parser
let newline lexbuf =
  let p = lexbuf.Lexing.lex_curr_p in
  let q =
    { p with Lexing.
      pos_lnum = p.Lexing.pos_lnum+1 ;
      pos_bol = p.Lexing.pos_cnum }
  in
  lexbuf.Lexing.lex_curr_p <- q
}

let var = ['A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*
let cst = ['a'-'z'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*
let int = ['0'-'9' '_']+

rule tokenize = parse
| [' ' '\t'] { tokenize lexbuf }
| '\n'            { newline  lexbuf ; tokenize lexbuf }
| '#' [^'\n']* '\n'
                  { newline  lexbuf ; tokenize lexbuf }
| "derive"        { DERIVE }
| "from"          { FROM   }
| "("             { LPAR   }
| ")"             { RPAR   }
| ","             { COMMA  }
| "."             { STOP   }
| var as v        { VAR v  }
| cst as c        { CST c  }
| int as i        { INT (int_of_string i) }
| eof             { EOF    }
| _               { raise Ast.Lexing_error }
