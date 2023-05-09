use "sol3.sml";

fun assert(b: bool) =
    let
        exception Failure
    in
        if b 
        then ()
        else raise Failure
    end;

(* ------------ 1. check_pat ------------ *)
assert((check_pat(Wildcard) = true));
assert((check_pat(UnitP) = true));
assert((check_pat(ConstP 17) = true));
assert((check_pat(ConstP 42) = true));
assert((check_pat(TupleP [Wildcard, Variable "x"]) = true));
assert((check_pat(ConstructorP("A", Wildcard)) = true));
assert((check_pat(ConstructorP("B", TupleP [Wildcard, Variable "x"])) = true));
assert((check_pat(TupleP [Variable "x", Variable "y", Variable "z"]) = true));
assert((check_pat(TupleP [Wildcard, Wildcard, Variable "x", Variable "y"]) = true));
assert((check_pat(ConstructorP("A", TupleP [Variable "x", Variable "y"])) = true));

assert((check_pat(Variable "x") = true));
assert((check_pat(TupleP [Wildcard, Wildcard, Variable "x", Variable "x"]) = false));
assert((check_pat(TupleP [Variable "x", Variable "x", Wildcard]) = false));
assert((check_pat(TupleP [Variable "x", Variable "y", Variable "x"]) = false));
assert((check_pat(ConstructorP("A", TupleP [Variable "x", Variable "x"])) = false));

(* ------------ 2. match ------------ *)
(* Wildcard *)
assert(match(Const 1, Wildcard) = SOME []);

(* Variable *)
assert(match(Unit, Variable "x") = SOME [("x", Unit)]);
assert(match(Const 17, Variable "y") = SOME [("y", Const 17)]);

(* UnitP *)
assert(match(Unit, UnitP) = SOME []);

(* ConstP *)
assert(match(Const 42, ConstP 42) = SOME []);
assert(match(Const 42, ConstP 17) = NONE);

(* TupleP *)
assert(match(Tuple [Const 1, Unit], TupleP [ConstP 1, UnitP]) = SOME []);
assert(match(Tuple [Const 1, Unit], TupleP [ConstP 1, Variable "x"]) = SOME [("x", Unit)]);
assert(match(Tuple [Const 1, Unit], TupleP [Wildcard, Variable "x"]) = SOME [("x", Unit)]);
assert(match(Tuple [Const 1, Unit], TupleP [ConstP 2, UnitP]) = NONE);

(* ConstructorP *)
assert(match(Constructor ("A", Const 1), ConstructorP ("A", ConstP 1)) = SOME []);
assert(match(Constructor ("A", Tuple [Const 1, Unit]), ConstructorP ("A", TupleP [ConstP 1, UnitP])) = SOME []);
assert(match(Constructor ("A", Tuple [Const 1, Unit]), ConstructorP ("B", TupleP [ConstP 1, UnitP])) = NONE);

(* Nothing else matches *)
assert(match(Const 1, Variable "x") = SOME [("x", Const 1)]);
assert(match(Tuple [Const 1, Unit], Wildcard) = SOME []);
assert(match(Constructor ("A", Const 1), Wildcard) = SOME []);
assert(match(Const 1, ConstructorP ("A", Wildcard)) = NONE);


(* ------------ 3. whosWinner ------------ *)
(* test winner of a single player *)
val PLAYER(name1, _) = whosWinner(PLAYER("s", ref s));
assert(name1 = "s");

(* test winner of a match between two players with only one strategy *)
val PLAYER(name2, _) = whosWinner(MATCH(PLAYER("r", ref r), PLAYER("s", ref s)));
assert(name2 = "r");

(* Test winner of a match between two players with alterTwo strategies *)
val PLAYER(name3, _) = whosWinner(MATCH(PLAYER("rp", ref rp), PLAYER("ps", ref ps)));
assert(name3 = "ps");

(* Test winner of a match between four players with a mix of strategies *)
val PLAYER(name4, _) = whosWinner(MATCH(MATCH(PLAYER("r", ref r), PLAYER("s", ref s)), MATCH(PLAYER("rp", ref rp), PLAYER("ps", ref ps))));
assert(name4 = "r");

(* Test winner of a match between four players with only alterTwo strategies *)
val PLAYER(name5, _) = whosWinner(MATCH(MATCH(PLAYER("rp", ref rp), PLAYER("sr", ref sr)), MATCH(PLAYER("ps", ref ps), PLAYER("rp", ref rp))));
assert(name5 = "ps");

(* Test winner of a match between six players with only alterTwo strategies *)
val PLAYER(name8, _) = whosWinner(MATCH(PLAYER("rp", ref rp), MATCH(PLAYER("sr", ref sr), MATCH(PLAYER("ps", ref ps), PLAYER("rp", ref rp)))));
assert(name8 = "rp");