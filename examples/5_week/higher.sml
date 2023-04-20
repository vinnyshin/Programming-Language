fun map (f, xs) =
  case xs of
      [] => []
    | x::xs' => f(x)::map(f, xs')

val strlist = ["a", "bc", "def", "ghij"]

fun filter(f, xs) = 
  case xs of
    [] => [] 
  | x::xs' => if f x then x::filter(f, xs') 
                     else filter(f, xs')

(* returns true if for all element e in alist
 *    test(e) = true
 *)
fun ifall (test, alist) = 
    case alist of
        [] => true
      | a::[] => test(a) 
      | a::alist' => test(a) andalso ifall(test, alist')

(* returns true if for any element e in alist
 *    test(e) = true
 *)
fun ifany (test, alist) = 
    case alist of
        [] => true
      | a::[] => test(a) 
      | a::alist' => test(a) orelse ifany(test, alist')
(*
ifall: fold(fn acc, x => acc andalso test(x), true, xs)
ifany: fold(fn acc, x => acc orElse test(x), false, xs)
*)
(* ifany implemented using filter
 *)
(* fun filter(f, xs) = *)
fun ifany2(f, xs) =
  not (null(filter(f, xs)))
  
(* ifany implemented using filter
 *)
fun ifall2(f, xs) =
   length(xs)=length(filter(f, xs))
