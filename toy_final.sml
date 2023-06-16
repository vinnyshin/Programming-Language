(* 3. Lazy List *)
datatype 'a lazyList = nullList 
                     | cons of 'a * (unit -> 'a lazyList) 

fun seq(first:int, last:int): int lazyList =
    let
      fun aux_seq(iter:int): int lazyList =
        if iter = last
        then cons(last, fn() => nullList)
        else cons(iter, fn () => aux_seq(iter + 1))
    in
      if first > last
      then nullList
      else aux_seq(first)
    end

fun infSeq(first:int): int lazyList =
    cons(first, fn () => infSeq(first + 1))

fun firstN(lazyListVal:'a lazyList, n:int): 'a list = 
    case lazyListVal of
            nullList => []
          | cons(element, lambda) => if n = 0
                                     then []
                                     else element::firstN(lambda(), n-1)

fun Nth(lazyListVal:'a lazyList, n:int):'a option =
    let fun nonZeroNth(lazyListVal:'a lazyList, n:int) = 
            case lazyListVal of
                    nullList => NONE
                  | cons(element, lambda) => if n = 1
                                             then SOME element
                                             else nonZeroNth(lambda(), n-1)
    in
        if n < 1
        then NONE
        else nonZeroNth(lazyListVal, n)
    end

fun filterMultiples(lazyListVal:int lazyList, n:int): int lazyList =
    let
      fun nonZeroAndOneFilterMultiples(lazyListVal:int lazyList): int lazyList =
        case lazyListVal of
             nullList => nullList
           | cons(element, lambda) => if (element mod n) = 0
                                      then nonZeroAndOneFilterMultiples(lambda())
                                      else cons(element, fn () => nonZeroAndOneFilterMultiples(lambda()))
    in (* a = b + dk for some integer k라고 정의하면, mod d할때 d에 0이 들어가면 a = b니까 그대로 return*)
      if n < 1
      then lazyListVal
      else if n = 1 (* 1 이면 계산할 필요가 없음 전부 필터링 되니까 *)
      then nullList
      else nonZeroAndOneFilterMultiples(lazyListVal)
    end

fun seive(lazyListVal: int lazyList):int lazyList =
    case lazyListVal of
        (* element + 1 Sequence에서 e를 filtering한 친구를 seive *)
        cons(element, elementPlusOneSeqLambda) => cons(element, fn () => seive(filterMultiples(elementPlusOneSeqLambda(), element)))
      | _ => nullList (*무한이기에 안쓰임*)

(* 1은 소수가 아니기에 2부터 시작 *)
fun primes(): int lazyList = seive(infSeq(2))

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

(* Tail recursion *)
fun fact n =
    let fun aux (n, acc) =
        if n = 0
        then acc
        else aux(n-1, acc*n)
    in
        aux(n, 1)
    end

fun non_tail_sum xs =
    case xs of
        [] => 0
      | x::xs1 => x + non_tail_sum(xs1)

fun tail_sum xs = 
    let fun aux(xs, acc) =
        case xs of
            [] => acc
          | x::xs1 => aux(xs1, x+acc)
    in
        aux(xs, 0)
    end

fun non_tail_rev xs = 
    case xs of
        [] => []
      | x::xs1 => non_tail_rev(xs1) @ [x]

fun tail_rev xs = 
    let fun aux(xs, acc) =
        case xs of
            [] => acc
          | x::xs1 => aux(xs1, x::acc)
    in
        aux(xs, [])
    end

fun n_times(f, n, x) =
	if n=0
	then x
	else n_times(f, n-1, f x) (* made it tail recursive cf) f (n_times(f, n-1, x)) *)

(*acc를 써서 tail recursion을 사용함*)
fun blackjack (score: int, hand: card list) =
  case hand of
        Card (_, Ace)::rest => let val try1 = blackjack(score+11, rest)
                             in
                               if try1 <= 21 
                               then try1
                               else blackjack(score+1, rest)
                             end
      | Card (_, Num(i))::rest => blackjack(score+i, rest)
      | Card (_, _)::rest => blackjack(score+10, rest)
      | _ => score


(*이런식으로 예외사항을 나중에 처리할 수도 있겠네*)
(*blackjack을 try1 try2에서 2번 계산하지 않고, 1번만 계산하기에 효율적*)
fun blackjack2 (score: int, hand: card list) =
  case hand of
      Card (_, Ace)::rest => let val rest_score = blackjack2(score, rest)
                             in
                               if rest_score >= 11 
                               then rest_score+1
                               else rest_score+11
                             end
      | Card (_, Num(i))::rest => blackjack2(score+i, rest)
      | Card (_, _)::rest => blackjack2(score+10, rest)
      | _ => score
