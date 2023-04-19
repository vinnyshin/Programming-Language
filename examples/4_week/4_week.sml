datatype exp = Constant of int
			 | Negate of exp
			 | Add of exp * exp
			 | Multiply of exp * exp
			 | If of bool * exp * exp

fun case_eval e = 
    case e of
        Constant i => i
      | Negate e => ~(case_eval(e))
      | Add(e1, e2) => case_eval(e1) + case_eval(e2)
      | Multiply(e1, e2) => case_eval(e1) * case_eval(e2)
      | If(e0, e1, e2) => if e0 then case_eval(e1) else case_eval(e2)

(*수학 함수 정의와 비슷하게 사용 가능*)
fun eval (Constant(i)) = i
  | eval (Negate(e)) = ~ (eval e)
  | eval (Add(e1, e2)) = (eval e1) + (eval e2)
  | eval (Multiply(e1, e2)) = (eval e1) * (eval e2)

fun fibo 0 = 0
  | fibo 1 = 1
  | fibo n = fibo (n-1) + fibo (n-2)

fun fibo_series 0 = [fibo(0)]
  | fibo_series n = fibo_series(n-1) @ [fibo(n)]

fun fast_fibo 0 = (1, 1)
  | fast_fibo n =
    let val (n_1, n_2) = fast_fibo (n-1)
    in (n_1 + n_2, n_1)
    end
(* acc를 활용했어 *)

exception ListLengthMismatch
(*
([1,2,3], [10,20,30], [100,200,300])
    => [(1,10,100), (2,20,200), (3,30,300)]
*)
fun zip3 lists = 
    case lists of
        ([], [], []) => []
       |(hd1::tl1, hd2::tl2, hd3::tl3) =>
            (hd1, hd2, hd3)::zip3(tl1, tl2, tl3)
       | _ => raise ListLengthMismatch (*for any default cases*)

(*
[(1,10,100), (2,20,200), (3,30,300)]
    =>([1,2,3], [10,20,30], [100,200,300])
*)
fun unzip3 triples = 
    case triples of 
        [] => ([], [], [])
       |(a,b,c)::tl =>
        let val (l1, l2, l3) = unzip3 tl
        in (a::l1, b::l2, c::l3)
        end

(* returns true if the list is nondecreasing.
* [1,2,3,4] => true
* [3,2,1] => false
*)
fun nondecreasing (xs:int list):bool = 
    case xs of
        [] => true
      | x::[] => true
      | x::y::xs2 => x < y andalso nondecreasing(y::xs2)

(* returns the sign of multiplying x1 and x2.
* P for positive, 
* N for negative, 
* Z for zero
* multsign(0, 1) => Z, multsign(~1, 1) => N
*)

datatype sgn = P | N | Z

fun multsign (x1, x2) = 
    let fun sign(x) =
        if x > 0
        then P
        else if x < 0
        then N
        else Z
    in
        case (sign(x1), sign(x2)) of
           (Z, _) => Z
         | (_, Z) => Z
         | (P, P) => P
         | (N, N) => P
         | (_, _) => N
    end

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

fun double x = x + x
fun increment x = x + 1
val x1 = n_times(double, 4, 7)
val x2 = n_times(increment, 4, 7)
val x3 = n_times(tl, 2, [4, 8, 12, 16])

fun double_n_times (n,x) = n_times(double, n, x)
fun nth_tail (n, x) = n_times(tl, n, x)

fun map (f, xs) =
    case xs of
        [] => []
      | x::xs1 => (f x)::map(f, xs1)

fun filter(f, xs) =
    case xs of
        [] => []
      | x::xs1 => if f x
                  then x::filter(f, xs1)
                  else filter(f, xs1)

(*silly example*)
fun double_or_triple f =
    if f 7
    then fn x => 2*x
    else fn x => 3*x

