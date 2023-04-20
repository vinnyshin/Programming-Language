fun swap(pr:int*bool) = 
    (#2 pr, #1 pr)

fun sum_two_pairs(pr1:int*int, pr2:int*int) =
    #1 pr1 + #2 pr1 + #1 pr2 + #2 pr2

fun div_mod (x:int, y:int) = 
    (x div y, x mod y)

fun sort_pair (pr:int*int) = 
    if #1 pr < #2 pr
    then pr
    else (#2 pr, #1 pr)

(* int * (bool * int) *)
val x1 = (7, (true,9))

(* true : bool *)
val x2 = #1 (#2 x1)

(* bool * int *)
val x3 = #2 x1

(* (int * int) * ((int * int) * (int * bool)) *)
val x4 = ((3, 5), ((4, 8), (0, false)))

fun sum_list (xs: int list) = 
    if null xs (* if xs is [], "null xs" evaluates to true *)
    then 0
    else hd xs + sum_list(tl xs)

fun countdown(x:int): int list = 
    if x = 0
    then []
    else x::countdown(x-1)

fun countup(from:int, to:int):int list = 
    if from = to
    then [to]
    else from::countup(from + 1, to)

fun append(xs:int list, ys:int list) =
    if null xs
    then ys
    else hd(xs)::append(tl(xs), ys)

fun getAt(idx:int, xs:int list) =
    if idx = 0
    then hd xs
    else getAt(idx - 1, tl xs)

(* 요놈을 tail recursion으로 바꾼다면? *)
fun sum_pair_list (xs:(int*int) list):int = 
	if null xs
	then 0
	else #1 (hd xs) + #2 (hd xs) + sum_pair_list(tl xs)

fun firsts (xs:(int*int) list) = 
	if null xs
	then []
	else #1 (hd xs)::firsts(tl xs)

fun seconds (xs:(int*int) list) = 
	if null xs
	then []
	else #2 (hd xs)::seconds(tl xs)

fun sum_pair_list2 (xs:(int*int) list):int = 
	if null xs
	then 0
	else sum_list(firsts xs) + sum_list(seconds xs)

fun countup_from1(x:int) = 
	let fun count(from:int, to:int) =
			if from = to
			then to::[] (* to match pattern used to::[], not [to] *)
			else from::count(from+1, to)
	in
		count(1, x)
	end
(* we can put out local helper function "count" to global scope *)

(* this is better in a sense of redundancy *)
fun countup_from1_better(x:int) =
	let fun count(from:int) =
			if from = x
			then x::[]
			else from::count(from+1)
	in
		count(x)
	end

fun bad_max(xs:int list) = 
	if null xs
	then 0 (* horrible style, we cannot tell whether output 0 is true max value of xs or null return *)
	else if null (tl xs)
	then hd xs
	else if hd xs > bad_max (tl xs)
	then hd xs
	else bad_max (tl xs)

fun good_max(xs: int list) =
	if null xs
	then 0
	else if	null (tl xs)
	then hd xs
	else (* There wasn't a local variable to store the result of bad_max, so we called it twice which brought the inefficiency *)
		let val tl_ans = good_max(tl xs) (* if we use a local variable, there's no need to call it twice *)
		in
			if hd xs > tl_ans (* same feature as "else if hd xs > bad_max(tl xs)" *)
			then hd xs
			else tl_ans (* same feature as "else bad_max(tl xs)" *)
		end

fun better_max(xs:int list): int option = 
	if null xs (* first empty checking *)
	then NONE
	else
		let val tl_ans = better_max(tl xs)
		in
			if isSome tl_ans (* doubly empty checked in this line for using valOf correctly*)
				andalso valOf tl_ans > hd xs (* If we don't prefer redundant valOf what should we do? *)
			then
				tl_ans
			else SOME (hd xs)
		end


(* pattern matching으로 Arrow-pattern을 없앨 수 있는 방법은? *)
fun better_max2(xs:int list) =
	if null xs
	then NONE
	else (* we eliminated redundant valOf calls using a helper function that guarantees nonemptyness of "xs" *)
		let fun max_nonempty(xs:int list) =
			if null (tl xs)
			then hd xs
			else
				let val tl_ans = max_nonempty(tl xs)
				in
					if hd xs > tl_ans
					then hd xs
					else tl_ans
				end
		in
			SOME (max_nonempty(xs))
		end


