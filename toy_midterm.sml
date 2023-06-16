fun sum_list (xs:int list):int =
    case xs of
        [] => 0
      | x::xs' => x + sum_list(xs')

fun sum_list_tail (xs:int list):int =
    let fun aux_sum (acc:int, xs:int list):int =
        case xs of
            [] => acc
          | x::xs' => aux_sum(acc + x, xs')
    in
        aux_sum(0, xs)
    end

fun countdown(x:int): int list = 
    if x=0
    then []
    else x::countdown(x-1)

fun countdown_tail(x:int): int list = 
    let fun aux_countdown(acc:int list, curr:int): int list =
        if curr=x
        then curr::acc
        else aux_countdown(curr::acc, curr + 1)
    in
        aux_countdown([], 1)
    end

fun count_up(from:int, to:int):int list = 
    if from=to
    then [to]
    else from::count_up(from + 1, to)

(* from과 to가 올바르게 들어왔다는 전제 하 *)
fun count_up_tail(from:int, to:int):int list = 
    let fun aux_countup (acc:int list, curr:int) =
        if curr=from
        then curr::acc
        else aux_countup(curr::acc, curr - 1)
    in
        aux_countup([to], to - 1)
    end

fun append(xs:int list, ys:int list): int list = 
    case xs of
        [] => ys
      | x::xs' => x::append(xs', ys)

fun sum_pair_list (xs:(int*int) list):int = 
    case xs of
        [] => 0
      | x::xs' => #1 x + #2 x + sum_pair_list(xs')

fun sum_pair_list_tail (xs:(int*int) list):int = 
    let fun aux_sum_pair_list (acc:int, xs:(int*int) list):int = 
        case xs of
        [] => acc
      | x::xs' => aux_sum_pair_list (#1 x + #2 x + acc, xs')    
    in
        aux_sum_pair_list(0, xs)
    end

fun better_max(xs:int list):int option =
    let fun non_empty_max(xs:int list) =
        case xs of
        x::[] => x
      | x::xs' => let val tl_max:int = non_empty_max(xs')
                  in
                    if x > tl_max
                    then x
                    else tl_max
                  end 
    in
        case xs of
        [] => NONE
      | x::xs' => SOME (non_empty_max(xs))
    end

(*Hw1*)

fun merge(xs:int list, ys:int list): int list =
    case (xs, ys) of
        ([], _) => ys
      | (_, []) => xs
      | (x::xs', y::ys') => if x > y
                            then y::merge(xs, ys')
                            else x::merge(xs', ys)

fun reverse(xs:int list): int list =
    let fun rev_aux(acc:int list, curr:int list):int list =
        case curr of
            x::[] => x::acc
          | x::xs' => rev_aux(x::acc, xs')
    in
        rev_aux([], xs)
    end

fun digits(x:int):int list =
    let fun aux_digits(acc:int list, curr:int):int list =
        if curr = 0
        then acc
        else aux_digits((curr mod 10)::acc, curr div 10)
    in
        aux_digits([], x)
    end
         
fun get_digit_sum_list(x:int):int list =
    let fun aux_sum(acc:int, xs:int list):int = 
        case xs of
            [] => acc
          | x::xs' => aux_sum(acc + x, xs')
    in
        if x div 10 = 0
        then x::[]
        else x::get_digit_sum_list(aux_sum(0, digits(x)))
    end

datatype 'a lazyList = nullList 
                     | cons of 'a * (unit -> 'a lazyList) 

val myList = cons(1, fn () => cons(2, fn () => cons(3, fn () => cons(4, fn () => cons(5, fn () => cons(6, fn () => cons(7, fn () => cons(8, fn () => cons(9, fn () => cons(10, fn () => nullList))))))))));

fun seq(first:int, last:int): int lazyList =
    if first > last
    then nullList
    else cons(first, fn () => seq(first + 1, last))

fun infSeq(first:int): int lazyList =
    cons(first, fn() => infSeq(first + 1))

fun firstN(lazyListVal:'a lazyList, n:int): 'a list = 
    if n = 0
    then []
    else case lazyListVal of 
            nullList => []
          | cons(element, lambda) => element::firstN(lambda(), n-1)

fun Nth(lazyListVal:'a lazyList, n:int):'a option =
    let fun aux_Nth(lazyListVal:'a lazyList, n:int):'a option =
        case lazyListVal of
            nullList => NONE
          | cons(element, lambda) => if n = 1
                                     then SOME element
                                     else aux_Nth(lambda(), n-1)
    in                               
        if n < 1
        then NONE
        else aux_Nth(lazyListVal, n)
    end

fun filter(f, xs) =
    case xs of
        x::xs' => if f x
                  then x::filter(f, xs')
                  else filter(f, xs')
      | _ => []
    
fun filterMultiples(lazyListVal:int lazyList, n:int): int lazyList =
    case lazyListVal of
        nullList => nullList
      | cons(element, lambda) => if (element mod n) = 0
                                 then filterMultiples(lambda(), n)
                                 else cons(element, fn () => filterMultiples(lambda(), n))                                

fun seive(lazyListVal: int lazyList):int lazyList =
    case lazyListVal of
        cons(element, lambda) => cons(element, fn () => filterMultiples(lambda(), element))
      | _ => nullList

fun primes():int lazyList = seive(infSeq(2))

(* variable binding *)
fun sum_triple (triple:(int * int * int)):int = 
    let val (x,y,z) = triple
    in
        x+y+z
    end

fun full_name (r:{first:string, middle:string, last:string}):string =
    let val {first=x, middle=y, last=z} = r
    in
        x ^ " " ^ y ^ " " ^ z
    end

datatype exp = Constant of int
             | Negate of exp
             | Add of exp * exp
             | Multiply of exp * exp
             | If of bool * exp * exp

fun eval(e: exp):int = 
    case e of
        Constant i => i
      | Negate e => ~(eval(e))
      | Add (e1, e2) => eval(e1) + eval(e2)
      | Multiply (e1, e2) => eval(e1) * eval(e2)
      | If(e0, e1, e2) => if e0 then eval(e1) else eval(e2)

fun eval2(Constant (i)) = i
  | eval2(Negate e) = ~(eval2(e))
  | eval2(Add (e1, e2)) = eval2(e1) + eval2(e2)
  | eval2(Multiply (e1, e2)) = eval2(e1) * eval2(e2)
  | eval2(If(e0, e1, e2)) = if e0 then eval2(e1) else eval2(e2)

fun fast_fibo 1 = (1,1)
  | fast_fibo n = let val (curr, prev) = fast_fibo(n-1)
                  in (curr + prev, curr)
                  end

exception ListLengthMismatch
(*
([1,2,3], [10,20,30], [100,200,300])
    => [(1,10,100), (2,20,200), (3,30,300)]
*)
fun zip3 lists =
    case lists of
        ([], [], []) => []
      | (x::xs', y::ys', z::zs') => (x,y,z)::(zip3 (xs', ys',zs'))
      | _ => raise ListLengthMismatch

(*
[(1,10,100), (2,20,200), (3,30,300)]
    =>([1,2,3], [10,20,30], [100,200,300])
*)
fun unzip3 (triples:(int * int * int) list) =
    case triples of 
        [] => ([], [], [])
      | (a,b,c)::tail => let val (tl1, tl2, tl3) = unzip3(tail)
                         in (a::tl1, b::tl2, c::tl3)
                         end

fun map(f, xs) = 
    case xs of
        [] => []
      | x::xs' => (f x)::map(f, xs')

fun n_times(f, n, x) =
    if n = 0
    then x
    else n_times(f, n-1, f x)

datatype suit = Club | Diamond | Heart | Spade
datatype card_value = Jack | Queen | King | Ace | Num of int
datatype card = Card of suit * card_value

val hands1 = [Card(Club, Jack), Card(Club, Queen), Card(Club, King)]
val hands2 = [Card(Club, Jack), Card(Club, Queen), Card(Club, Ace)]

fun is_straight (hand:card list) =
    let fun card_to_number(c:card):int =
        case c of
            Card(_, Jack) => 11
          | Card(_, Queen) => 12
          | Card(_, King) => 13
          | Card(_, Ace) => 1
          | Card(_, Num i) => i
        val hand_numbers:int list = map(card_to_number, hand)
        val sorted_hand_numbers:int list =
            ListMergeSort.sort(fn (x,y) => x > y) hand_numbers
        fun aux_is_straight (xs:int list):bool =
            case xs of
            [] => false
          | [x] => true
          | x::y::tail => if x+1 = y
                          then aux_is_straight(tl xs)
                          else false 
    in
        aux_is_straight(sorted_hand_numbers)
    end

fun curry_fold f acc xs =
    case xs of
        [] => acc
      | x::xs2 => curry_fold f (f(acc,x)) xs2

fun curry_exam f xs =
    case xs of
        [] => 0
      | x::xs2 => curry_exam f (f xs2)

(* high-order wrapper functions, we can change the argument order or wrap it with a tuple*)
fun other_curry1 f = fn x => fn y => f y x
fun other_curry2 f x y = f y x
fun curry_from_tuple f x y = f (x,y) (* curry function이 아닌걸 curry한것처럼 쓸 수 있어 *)
fun uncurry f (x,y) = f x y (* curry function을 tuple로 쓸 수 있어 *)

fun exists predicate xs = 
    case xs of
       [] => false
     | x::xs' => predicate x orelse exists predicate xs'

val no = exists (fn x => x=7) [4,11,23]
val hasZero = exists (fn x => x=0)

datatype set = S of {insert: int -> set,
                     member: int -> bool,
                     size: unit -> int
                    }

val empty_set = 
    let fun make_set xs =
        let fun contains i = List.exists (fn x => i=x) xs
        in
            S({insert = fn i => if contains i
                                then make_set(xs)
                                else make_set(i::xs),
            member = contains,
            size = fn () => length(xs)

            })
        end
    in
        make_set []
    end                    

val s0 = empty_set
val S(s1) = empty_set
val S(s2) = (#insert s1) 34

fun fold (f, acc, xs) =
    case xs of
        [] => acc
      | x::xs' => fold(f, f(acc, x), xs')

val ints = [10, 9, 5, ~1]
val mymax = fold(fn (acc, x) => if x > acc then x else acc, hd(ints), tl(ints))
val allPositive = fold(fn (acc, x) => acc andalso x > 0, true, ints)

val nums_list = [[9, 40, 75, 99],
                 [64, 34, 88, 96],
                 [91, 92, 53, 31],
                 [50, 84, 73, 65],
                 [54, 44, 75, 11],
                 [91, 71, 48, 46],
                 [70, 72, 5, 42],
                 [25, 77, 49, 56],
                 [89, 4, 73, 52],
                 [36, 56, 61, 1]]

val local_max =
    let fun find_max(xs) =
        fold(fn (acc, x) => if x > acc then x else acc, hd xs, tl xs)
    in
        map(fn (xs) => find_max(xs), nums_list)
    end

val global_max = 
    fold(fn(acc, x) => if x > acc then x else acc, hd local_max, tl local_max)

fun count_multiples(x, nums_list) = 
    let 
        fun filter_multiples (xs) = filter(fn num => num mod x = 0, xs)
        val local_multiples = map(filter_multiples, nums_list)
    in
        map(List.length, local_multiples)
    end

fun index_of_max_multiple_count (x, nums_list) = 
    let val counts = count_multiples(x, nums_list)
    in  fold(fn(acc, curr_count) => if (#3 acc) > curr_count
                                    then (#1 acc, 1 + (#2 acc), #3 acc)
                                    else (#2 acc, 1 + (#2 acc), curr_count),
            (0,0,hd(counts)),
            counts)
    end
