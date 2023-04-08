use "sol2.sml";

exception TestFailException;

val expr_3 = PLUS(NUM(1), NUM(2));
val expr_8 = MINUS(NUM(14), NUM(6));

val formula_list = [
    (* TRUE *)
    (TRUE, true),
    (* FALSE *)
    (FALSE, false),
    (* NOT *)
    (NOT(TRUE), false),
    (NOT(FALSE), true),
    (* ANDALSO *)
    (ANDALSO(TRUE, TRUE), true),
    (ANDALSO(TRUE, FALSE), false),
    (ANDALSO(FALSE, TRUE), false),
    (ANDALSO(FALSE, FALSE), false),
    (* ORELSE *)
    (ORELSE(TRUE, TRUE), true),
    (ORELSE(TRUE, FALSE), true),
    (ORELSE(FALSE, TRUE), true),
    (ORELSE(FALSE, FALSE), false),
    (* IMPLY *)
    (IMPLY(TRUE, TRUE), true),
    (IMPLY(TRUE, FALSE), false),
    (IMPLY(FALSE, TRUE), true),
    (IMPLY(FALSE, FALSE), true),
    (* LESS *)
    (LESS(expr_3, expr_8), true),
    (LESS(expr_8, expr_3), false),
    (LESS(expr_3, expr_3), false)
]

fun test_eval(formula_list: (formula * bool) list) =
    if null formula_list
    then ()
    else 
        if eval(#1 (hd formula_list)) = #2 (hd formula_list)
        then test_eval((tl formula_list))
        else raise TestFailException;

val metro_list = [
    (AREA("a", STATION "a"), true),
    (AREA("a", AREA("a", STATION "a")), true),
    (AREA("a", AREA("b", CONNECT(STATION "a", STATION "b"))), true),
    (AREA("a", CONNECT(STATION "a", AREA("b", STATION "a"))), true),
    (AREA("a", STATION "b"), false),
    (AREA("a", AREA("a", STATION "b")), false),
    (AREA("a", AREA("b", CONNECT(STATION "a", STATION "c"))), false),
    (AREA("a", CONNECT(STATION "b", AREA("b", STATION "a"))), false),
    (AREA("a", CONNECT(STATION "a", AREA("b", STATION "c"))), false)
]

fun test_checkMetro(metro_list: (metro * bool) list) = 
    if null metro_list
        then ()
        else 
            if checkMetro(#1 (hd metro_list)) = #2 (hd metro_list)
            then test_checkMetro((tl metro_list))
            else raise TestFailException;


val s = seq(1, 10);
val i = infSeq(11);
val f = filterMultiples(s, 2);

val firstNList = [
    ((s, 5), [1, 2, 3, 4, 5]),
    ((s, 10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
    ((i, 5), [11, 12, 13, 14, 15]),
    ((f, 5), [1, 3, 5, 7, 9]),
    ((primes(), 10), [2, 3, 5, 7, 11, 13, 17, 19, 23, 29])
];

fun verify_same_list(xs: int list, ys: int list) =
    if null xs andalso null ys
    then true
    else 
        if hd xs = hd ys
        then verify_same_list(tl xs, tl ys)
        else false;

fun test_firstN(firstN_list: ((int lazyList * int) * int list) list) =
    if null firstN_list
        then ()
        else 
            if verify_same_list(firstN(#1 (hd firstN_list)), #2 (hd firstN_list))
            then test_firstN((tl firstN_list))
            else raise TestFailException;

val nth_list = [
    ((i, 10), 20),
    ((primes(), 20), 71)
];

fun test_Nth(nth_list: ((int lazyList * int) * int) list) =
    if null nth_list
        then ()
        else 
            if valOf(Nth(#1 (hd nth_list))) = #2 (hd nth_list)
            then test_Nth((tl nth_list))
            else raise TestFailException;

print("\n\n---------- 테스트 시작 ----------\n\n");

print("\n\n`eval` 테스트 시작!\n\n");
test_eval(formula_list);
print("\n\n`eval` 테스트 완료!\n\n");
print("\n\n`checkMetro` 테스트 시작!\n\n");
test_checkMetro(metro_list);
print("\n\n`checkMetro` 테스트 완료!\n\n");
print("\n\n`firstN` 테스트 시작!\n\n");
test_firstN(firstNList);
print("\n\n`firstN` 테스트 완료!\n\n");
print("\n\n`Nth` 테스트 시작!\n\n");
test_Nth(nth_list);
print("\n\n`Nth` 테스트 완료!\n\n");