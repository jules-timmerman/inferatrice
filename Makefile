# Changer ces définitions si besoin pour passer de bytecode à nativecode,
# ou changer les flags de compilation, e.g. utiliser -g pour le déboguage.

OCAMLC = ocamlfind ocamlc -package alcotest -g
OCAMLL = ocamlfind ocamlc -package alcotest -g -linkpkg
CMO = .cmo
CMA = .cma

# Définition des fichiers sources associés aux différentes cibles

LIB_ML = term.ml unify.ml query.ml
TEST_ML = $(LIB_ML) test.ml
TEST_OBJS = $(TEST_ML:.ml=$(CMO))

INFERATRICE_ML = $(LIB_ML) ast.ml parser.ml lexer.ml convert.ml inferatrice.ml
INFERATRICE_OBJS = $(INFERATRICE_ML:.ml=$(CMO))

# Cibles

default: run_tests inferatrice

test: run_tests
	./run_tests

# Compilation des exécutables OCaml

run_tests: $(TEST_OBJS)
	$(OCAMLL) $(TEST_OBJS) -o $@
inferatrice: $(INFERATRICE_OBJS)
	$(OCAMLL) $(INFERATRICE_OBJS) -o $@

clean:
	rm -f *.cmx *.cmo *.cmi *.o
	rm -f run_tests inferatrice

-include .depend
.depend: $(wildcard *.ml) $(wildcard *.mli)
	ocamldep $(wildcard *.ml) $(wildcard *.mli) > .depend

%$(CMO): %.ml Makefile
	$(OCAMLC) -c $<
%.cmi: %.mli Makefile
	$(OCAMLC) -c $<

parser.ml: parser.mly
	ocamlyacc $<
lexer.ml: lexer.mll
	ocamllex $<
