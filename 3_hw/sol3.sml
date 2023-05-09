datatype pattern = Wildcard | Variable of string | UnitP
| ConstP of int | TupleP of pattern list
| ConstructorP of string * pattern

datatype valu = Const of int | Unit | Tuple of valu list
| Constructor of string * valu

fun foldl(f, acc, xs) = 
    case xs of
       [] => acc
     | x::xs2 => foldl(f, (f (acc, x)), xs2)

fun map(f, xs) = 
    case xs of
        [] => []
      | x::xs2 => (f x)::map(f, xs2)

fun check_pat (p: pattern): bool =
    let fun filter_out_variable_strings(p: pattern): string list =
            case p of
               Variable v => v::[]
             | ConstructorP (_, p2) => filter_out_variable_strings(p2)
             | TupleP plist => foldl(fn (acc, x) => filter_out_variable_strings(x) @ acc, [], plist)
             | _ => []
        fun is_element_repeated(xs): bool =
            case xs of
               [] => false
             | target::xs2 => (List.exists (fn element => target = element) xs2) 
                              orelse is_element_repeated(xs2)
    in
        not (is_element_repeated(filter_out_variable_strings(p)))
    end

fun match (v:valu, p:pattern): (string * valu) list option =
    case (v, p) of
       (_, Wildcard) => SOME []
     | (_, Variable s) => SOME [(s, v)]
     | (Unit, UnitP) => SOME []
     | (Const vi, ConstP pi) => if vi = pi then SOME [] else NONE
     | (Tuple vlist, TupleP plist) => if List.length vlist = List.length plist
                                      then let val value_pattern_pair_list = ListPair.zip (vlist, plist)
                                               val filtered_list = List.filter (fn (v, p) => match(v, p) <> NONE) value_pattern_pair_list                                                                               
                                           in if List.length filtered_list = List.length value_pattern_pair_list
                                              then SOME (foldl((fn (acc, vp_pair) => valOf(match (vp_pair)) @ acc), [], value_pattern_pair_list))
                                              else NONE
                                           end
                                      else NONE
     | (Constructor (vstring, vval), ConstructorP (pstring, ppat)) => if vstring = pstring
                                                                      then match(vval, ppat) 
                                                                      else NONE
     | (_, _) => NONE

type name = string

datatype RSP =  ROCK | SCISSORS | PAPER
datatype 'a strategy = Cons of 'a * (unit -> 'a strategy)
datatype tournament = PLAYER of name * (RSP strategy ref)
                    | MATCH of tournament * tournament

fun onlyOne(one:RSP) = Cons(one, fn() => onlyOne(one))
fun alterTwo(one:RSP, two:RSP) = Cons(one, fn() => alterTwo(two, one))
fun alterThree(one:RSP, two:RSP, three:RSP) = Cons(one, fn() => alterThree(two, three, one))

val r = onlyOne(ROCK)
val s = onlyOne(SCISSORS)
val p = onlyOne(PAPER)
val rp = alterTwo(ROCK, PAPER)
val sr = alterTwo(SCISSORS, ROCK)
val ps = alterTwo(PAPER, SCISSORS)
val srp = alterThree(SCISSORS, ROCK, PAPER)
 
fun next(strategyRef) =
 let val Cons(rsp, func) = !strategyRef in
    strategyRef := func();
    rsp
 end

fun whosWinner(t: tournament): tournament = 
    let val lhs_win = true
        val rhs_win = false
        fun rock_paper_scissors(lhs, rhs) = 
            case (next(lhs), next(rhs)) of
                (ROCK, SCISSORS) => lhs_win
              | (ROCK, PAPER) => rhs_win
              | (SCISSORS, ROCK) => rhs_win
              | (SCISSORS, PAPER) => lhs_win
              | (PAPER, ROCK) => lhs_win
              | (PAPER, SCISSORS) => rhs_win
              | (_, _) => rock_paper_scissors(lhs, rhs) (* 무승부의 경우 다시 *)      
    in
      case t of
        PLAYER _ => t
      | MATCH (PLAYER (p1, s1), PLAYER(p2, s2)) => if rock_paper_scissors(s1, s2) = lhs_win
                                                   then PLAYER(p1, s1)
                                                   else PLAYER(p2, s2)
      | MATCH (t1, t2) => whosWinner(MATCH(whosWinner(t1), whosWinner(t2)))
    end

val winner = whosWinner(MATCH(PLAYER("s", ref s), MATCH(PLAYER("r", ref r), PLAYER("rp", ref rp))));

