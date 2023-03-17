fun merge(xs:int list, ys:int list): int list =
	if null xs
	then ys
	else if hd xs < hd ys
	then (hd xs)::merge(tl xs, ys)
	else (hd ys)::merge(tl ys, xs)

fun reverse(xs:int list): int list =
	let fun rev_aux(remainder:int list, res:int list): int list =
		if null remainder
		then res
		else rev_aux(tl remainder, (hd remainder)::res)
	in
		rev_aux(xs, [])
	end

fun pi(a:int, b:int, f:int->int):int =
	if a>b
	then 1
	else if a=b
	then f(b)
	else f(a)*pi(a+1, b, f)

fun digits(x:int):int list = 
	let fun digits_with_res(x_help:int, res:int list): int list =
		if x_help=0
		then res
		else digits_with_res(x_help div 10, (x_help mod 10)::res)
	in
		digits_with_res(x, [])
	end

fun get_digit_sum_list(x:int):int list = 
	let fun sum_list(xs:int list):int =
		if null xs
		then 0
		else hd xs + sum_list(tl xs)
	in	
		if (x div 10)=0
		then x::[]
		else x::get_digit_sum_list(sum_list(digits(x)))
	end

fun additivePersistence(x:int):int =
	let val digit_sum_list = get_digit_sum_list(x)
		fun get_additivePersistence_num(xs:int list):int =
			if null (tl xs)
			then 0
			else 1 + get_additivePersistence_num(tl xs)
	in
		get_additivePersistence_num(digit_sum_list)
	end



fun digitalRoot(x:int):int = 
	let val digit_sum_list = get_digit_sum_list(x)
		fun get_last(xs:int list):int =
			if null (tl xs)
			then hd xs
			else get_last(tl xs)
	in
		get_last(digit_sum_list)
	end
