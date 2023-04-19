
(* nice example of nested pattern.  *)

(* nondecreasing: int list -> bool
 *
 * e.g.  [1,1,2, 3, 4, 5, 5] => true
 *       [1, 2, 1, 3, 5] => false
 *)
fun nondecreasing xs =
    case xs of
	      [] => true
      | x::[] => true
      | head::(neck::rest) => (head <= neck andalso nondecreasing (neck::rest))

datatype sgn = P | N | Z

(* multsign: int * int -> sgn
 *
 * e.g. 1, 1 => P
 *      ~1, 10 => N
 *      ~10, ~42 => P
 *)
fun multsign (x1,x2) = 
  let fun sign x = if x=0 then Z else if x>0 then P else N 
  in
      case (sign x1,sign x2) of
	  (Z,_) => Z
	| (_,Z) => Z
	| (P,P) => P
	| (N,N) => P
	| _     => N (* many say bad style; I am okay with it *)
  end

fun len(l: 'a list) =
    case l of
         [] => 0
       | _::xs => 1+len(xs)

