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
    if null xs
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