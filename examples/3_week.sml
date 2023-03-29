datatype mytype = TwoInts of int * int
				| Str of string
				| Pizza

fun f(x:mytype):int =
		 case x of
			  Pizza => 3
			| TwoInts(i1, i2) => i1+i2
			| Str s => String.size s

datatype exp = Constant of int
			 | Negate of exp
			 | Add of exp * exp
			 | Multiply of exp * exp
			 | If of bool * exp * exp

fun eval(e:exp):int = 
  case e of
	  Constant(i) => i
	| Negate(e2) => ~(eval e2)
	| Add(e1, e2) => eval(e1) + eval(e2)
	| Multiply(e1, e2) => eval(e1) + eval(e2)
	| If(e1, e2, e3) => if e1 then eval(e2) else eval(e3)

fun max_constant(e:exp):int =
  let fun find_max(x:int, y:int) =
	if x > y
	then x
	else y
  in
  case e of
	  Constant(i) => i
	| Negate(e2) => eval e2
	| Add(e1, e2) => find_max(eval(e1), eval(e2))
	| Multiply(e1, e2) => find_max(eval(e1), eval(e2))
	| If(e1, e2, e3) => find_max(eval(e2), eval(e3))
  end

datatype my_int_list = Empty
					 | Cons of int * my_int_list

fun append_my_list(xs:my_int_list, ys:my_int_list):my_int_list =
  case xs of
	Empty => ys
  | Cons(x, xs2) => Cons(x, append_my_list(xs2, ys))

fun inc_or_zero(intoption : int option) : int =
  case intoption of
    NONE => 0
  | SOME i => i + 1

fun sum_list (xs : int list): int =
  case xs of
    [] => 0
  | x::xs2 => x + sum_list(xs2)


fun sum_list_1_and_2 (xs : int list): int =
  case xs of
    [] => 0
  | x::y::xs2 => x + y +sum_list(xs2) (* sum_list_1_and_2 (1::[2,3,4,5])로 주었을 때 이경우에는 1::2::[3,4,5]로 해석됨 *)
  | x::xs2 => x + sum_list(xs2)

fun append(xs:int list, ys:int list):int list =
  case xs of 
    [] => ys
  | x::xs2 => x::append(xs2, ys)

fun sum_triple (triple:(int * int * int)) : int = 
	let val (x,y,z) = triple
	in 
	  x+y+z
	end

fun full_name (r:{first:string, middle:string, last:string}):string =
	let val {first=x, middle=y, last=z} = r
	in
	  x ^ " " ^ y ^ " " ^ z
	end

(*function pattern matching을 쓰면 수학적 정의처럼 표현 가능*)
fun fact(1) = 1 (*1은 같은 int 형식이라도 그 자체로 value야*)
  | fact(n:int):int = n * fact(n-1) (*n은 int 형식이지만 value가 아니야 constructor야*)
  (*따라서 fact 함수에서 구분 가능!*)


