fun map (f, xs) =
  case xs of
      [] => []
    | x::xs' => f(x)::map(f, xs')

fun filter(f, xs) = 
  case xs of
    [] => [] 
  | x::xs' => if f x then x::filter(f, xs') 
                     else filter(f, xs')

fun fold(f, acc, xs) = 
    case xs of 
      []     => acc
    | x::xs' => fold(f, (f(acc,x)), xs')

(* use fold to find max in a list *)

val ints = [1,9,5,1]
val mymax = fold (fn (acc, x) =>  if x>acc then x else acc,
                          hd(ints), ints)
val allPositive = fold (fn(acc, x) => acc andalso x>0, true, ints)                          


(* 수조개의 nums_list가 있다고 해봐 *)
(* device가 여러개 있다고 할 때 각 device별로 쪼개서 
local max를 구한다음 global max를 구하면 끝날거야 *)
val nums_list = [[9, 40, 75, 7],
                 [64, 34, 88, 96],
                 [91, 92, 53, 31],
                 [50, 84, 73, 65],
                 [54, 44, 75, 11],
                 [91, 71, 48, 46],
                 [70, 72, 5, 42],
                 [25, 77, 49, 56],
                 [89, 4, 73, 52],
                 [36, 56, 61, 1]]
(* fun fold(f, acc, xs) *)

(* let's find local max by applying fold to each list *)

val local_max =  
    map(fn nums => fold (fn (acc, x) =>  if x>acc then x else acc, hd(nums), nums),
        nums_list)
                
                
(* [75, 96, ... ] *)

(* now apply fold again! *)

val global_max = 
  fold (fn (acc, x) =>  if x>acc then x else acc,
        hd(local_max), local_max)
              
              

(* given x, count the multiples of x in each list
 * x=11, num_list= [[1, 2, 11], [2, 3, 22, 33], [4, 5]]
 * ==>   [1, 2, 0]
 *)
(* 1. apply modular (filter) to *each* list
 * ==> [[11], [22, 33], []]
 * 2. count *each* list
 * ==> [1, 2, 0]
 *)
(* filter(f, xs) *)

fun count_multiples(x, nums_list) = 
    let 
    fun filter_multiples (xs) = filter(fn num => num mod x = 0, xs)
    val local_multiples = map(filter_multiples, nums_list)
    in
        map(List.length, local_multiples)
    end

(* similar to above, given x, count the multiples of x in each list
 * and returns the index of the list having the maximum count.
 * x=11, [[1, 2, 11], [11, 22, 33], [4, 5]]
 * ==>   1  
 *)

(* 1. call count_multiples above
 * 2. apply fold. acc = (max_index, curr_index, max_value)
 * hint: keep acc tuple containing (index of current max, current index, max multiples)
 *  e.g. x=11, [[1, 2, 11], [11, 22, 33], [4, 5], [11, 22, 33, 44]] 
 *       counts= [ 1,         3,             0,           4]
 *           (0, 0, 1) ==> (1, 1, 3) ==> (1, 2, 3) ==> (3, 3, 4)
 *                  (0, 1, 1)     (1, 2, 3)    (1, 3, 3)
 *)

 
fun index_of_max_multiple_count (x, nums_list) = 
let val counts = count_multiples(x, nums_list)
(*   [1, 3, 3] *)
in
    fold(fn (acc, y) => if (#3 acc) > y
                        then (#1 acc, 1+(#2 acc), #3 acc)
                        else (#2 acc, 1+(#2 acc), y),
        (0, 0, hd(counts)),
        counts)
end

(*
   (* the above implemented using record type instead of tuples*)
    fold(fn acc, y => if #maxVal acc > y
                        then 
                          {maxIdx=#maxIdx acc, 
                           currIdx=1+(#currIdx acc),
                           maxVal=#maxVal acc}
                        else
                          {maxIdx=#currIdx acc,
                           currIdx=1+(#currIdx acc),
                           maxVal=y}
        {maxIdx=0, currIdx=0, maxVal=hd(counts)},
        counts)
*)

(* {maxIdx:int, currIdx:int, maxVal:int} *)
