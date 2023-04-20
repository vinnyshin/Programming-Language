fun filter(f, xs) = 
  case xs of
    [] => [] 
  | x::xs' => if f x then x::filter(f, xs') 
                     else filter(f, xs')

fun allShorterThan1 (xs,s) =
    filter(fn x => String.size x < String.size s, xs)

fun allShorterThan2 (xs,s) =
    let
      val i = String.size s
    in
      filter(fn x => String.size x < i, xs)
    end

val strlist = ["a", "bc", "def", "ghij"]

fun foldl (f,acc,xs) =
    case xs of
        [] => acc
      | x::xs2 => foldl(f, f(acc,x), xs2)

fun foldr (f,acc,xs) =
    case xs of
        [] => acc
      | x::xs2 => f(foldr(f, acc, xs2),x)

fun f1 xs = foldl(fn (acc, y) => (acc + y), 0, xs)
fun f2 xs = foldl(fn (acc, y) => (acc andalso y >= 0), true, xs)
fun f3 (xs, hi, lo) =
    foldl(fn (acc,y) => 
                acc + (if y >= lo andalso y <= hi
                     then 1
                     else 0),
          0, xs)
fun f4 (g, xs) = foldl(fn (acc, y) => (acc andalso (g y) >= 0), true, xs)
                    
fun compose (f,g) = fn x => f(g x)
fun sqrt_of_abs1 i = Math.sqrt(Real.fromInt(abs i))
fun sqrt_of_abs2 i = (Math.sqrt o Real.fromInt o abs) i
val sqrt_of_abs3 = Math.sqrt o Real.fromInt o abs (* this is the best *)

(* can define pipelining *)
infix |>
fun x |> f = f x
(* x |> f 라는 pattern을 f x 로 해석해줘와 같은 의미 *)

fun sqrt_of_abs_pipe i =
    i |> abs |> Real.fromInt |> Math.sqrt

val sorted3 = fn x => fn y => fn z =>
                 z >= y andalso y >= x

fun sorted3_syntatic_sugar x y z = z >= y andalso y >= x

val t1 = ((sorted3 7) 9) 11
val t2 = sorted3 7 9 11

fun curry_fold f acc xs =
    case xs of
        [] => acc
      | x::xs2 => foldl(f, f(acc,x), xs2)

fun sum_inferior xs = curry_fold (fn (x,y) => x+y) 0 xs
val sum = curry_fold (fn (x,y) => x+y) 0

fun exists predicate xs = 
    case xs of
       [] => false
     | x::xs' => predicate x orelse exists predicate xs'

val no = exists (fn x => x=7) [4,11,23]
val hasZero = exists (fn x => x=0)

(* high-order wrapper functions, we can change the argument order or wrap it with a tuple*)
fun other_curry1 f = fn x => fn y => f y x
fun other_curry2 f x y = f y x
fun curry_from_tuple f x y = f (x,y) (* curry function이 아닌걸 curry한것처럼 쓸 수 있어 *)
fun uncurry f (x,y) = f x y (* curry function을 tuple로 쓸 수 있어 *)


