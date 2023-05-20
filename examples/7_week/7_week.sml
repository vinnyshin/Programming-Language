structure MyMathLib =
struct

fun fact x =
    if x = 0
    then 1
    else x * fact(x-1)

val half_pi = Math.pi / 2.0

fun doubler x = x * 2

end

signature MATHLIB =
sig

val fact: int -> int
val half_pi: real
val doubler: int -> int
(* val doubler: int -> int *)
(* 주석처리하면 top-level private function이 되는거야
   유저는 못쓰지만 function provider입장에서는 helper function 공유 가능 *)

end

structure MyMathLib2 :> MATHLIB =
struct

fun fact x =
    if x = 0
    then 1
    else x * fact(x-1)

val half_pi = Math.pi / 2.0

fun doubler x = x * 2
(* fun doubler x = x * 2 *) (* => 이렇게 주석처리하면 error! *)


end