(* 1. Simple Eval *)
datatype expr = NUM of int
              | PLUS of expr * expr
              | MINUS of expr * expr

datatype formula = TRUE
                 | FALSE
                 | NOT of formula
                 | ANDALSO of formula * formula
                 | ORELSE of formula * formula
                 | IMPLY of formula * formula
                 | LESS of expr * expr 
 (* LESS(a, b) is true if a < b *)

fun eval_expr (e: expr): int =
    case e of
       NUM(i) => i
     | PLUS(e1, e2) => eval_expr(e1) + eval_expr(e2)
     | MINUS(e1, e2) => eval_expr(e1) - eval_expr(e2)

fun eval (f: formula): bool =
    case f of
       TRUE => true
     | FALSE => false
     | NOT(f) => not (eval(f))
     | ANDALSO(f1, f2) => eval(f1) andalso eval(f2)
     | ORELSE(f1, f2) => eval(f1) orelse eval(f2)
     | IMPLY(f1, f2) => (not (eval(f1))) orelse eval(f2)
     | LESS(e1, e2) => eval_expr(e1) < eval_expr(e2)

(* 2. Check MetroMap *)
type name = string

datatype metro = STATION of name
               | AREA of name * metro
               | CONNECT of metro * metro

fun checkMetro(m: metro): bool =
    let fun is_contains(n:name, l:name list):bool =
        case l of
            [] => false
            |x::l2 => if x=n then true else is_contains(n, l2)
            
        fun aux_checkMetro(m:metro, name_acc:name list): bool = 
        case m of
           STATION(n) => is_contains(n, name_acc)
         | AREA(n, m) => aux_checkMetro(m, n::name_acc)
         | CONNECT(m1, m2) => aux_checkMetro(m1, name_acc) andalso aux_checkMetro(m2, name_acc)
    in aux_checkMetro(m, [])
    end

(* 3. Lazy List *)
datatype 'a lazyList = nullList 
                     | cons of 'a * (unit -> 'a lazyList) 

val myList = cons(1, fn () => cons(2, fn () => cons(3, fn () => cons(4, fn () => cons(5, fn () => cons(6, fn () => cons(7, fn () => cons(8, fn () => cons(9, fn () => cons(10, fn () => nullList))))))))));

(* 이건 lazy하게 생성하지 않고, 전부 생성해서 return해, 우리가 원하는게 아니야*)
fun seq_2(first:int, last:int): int lazyList =
    let
      fun aux_seq(first:int, last:int, acc: int lazyList): int lazyList =
        if first = last
        then acc
        else aux_seq(first, last - 1, cons(last - 1, fn () => acc))
    in
      if first > last
      then nullList
      else aux_seq(first, last, cons(last, fn () => nullList))
    end

(* 이건 lazy하게 생성해, 우리가 원하는거야 *)
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

(* 
Q) 어떻게 가능한거지..?

어차피 람다라는건 저걸 진짜로 실행시킨다기보단, 
실행시키기 전까지는 이렇게 할거야~를 보여주는거니까
가능한듯
*)

fun infSeq(first:int): int lazyList =
    cons(first, fn () => infSeq(first + 1))

fun firstN(lazyListVal:'a lazyList, n:int): 'a list = 
    case lazyListVal of
            nullList => []
          | cons(element, lambda) => if n = 0
                                     then []
                                     else element::firstN(lambda(), n-1)
    
(* 이건 tail recursive하더라도 @의 overhead가 너무 커서 더 비효율적 *)
fun firstN_tail_recursive(lazyListVal:'a lazyList, n:int): 'a list = 
    let
      fun aux_firstN(lazyListVal:'a lazyList, iterCnt:int, acc:'a list): 'a list =
        case lazyListVal of
            nullList => acc
          | cons(element, lambda) => if iterCnt = n
                                     then acc
                                     else aux_firstN(lambda(), iterCnt+1, acc @ [element])
    in
      aux_firstN(lazyListVal, 0, [])
    end

(* nonZeroNth를 tail point에서 계속 부르니까 tail recursion *)
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
