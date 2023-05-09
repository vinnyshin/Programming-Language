datatype pattern = Wildcard | Variable of string | UnitP
| ConstP of int | TupleP of pattern list
| ConstructorP of string * pattern

datatype valu = Const of int | Unit | Tuple of valu list
| Constructor of string * valu

fun foldl(f, acc, xs) = 
    case xs of
       [] => acc
     | x::xs2 => foldl(f, (f (acc, x)), xs2)

fun check_pat (p: pattern): bool =
    let fun filter_out_variable_strings(p: pattern): string list =
            case p of
               Variable v => v::[]
             | ConstructorP (_, p2) => filter_out_variable_strings(p2)
             | TupleP plist => foldl(fn (acc, x) => filter_out_variable_strings(x) @ acc, [], plist)
             | _ => []
        fun is_element_repeated(xs): bool =
            case xs of
               [] => false
             | target::xs2 => (List.exists (fn element => target = element) xs2) 
                              orelse is_element_repeated(xs2)
    in
        not (is_element_repeated(filter_out_variable_strings(p)))
    end

datatype pattern = Wildcard | Variable of string | UnitP
| ConstP of int | TupleP of pattern list
| ConstructorP of string * pattern

datatype valu = Const of int | Unit | Tuple of valu list
| Constructor of string * valu

fun match (v:valu, p:pattern): (string * valu) list option =
    case (v, p) of
       (_, Wildcard) => SOME []
     | (_, Variable s) => SOME [(s, v)]
     | (Unit, UnitP) => SOME []
     | (Const vi, ConstP pi) => if vi = pi then SOME [] else NONE
     | (Tuple vlist, TupleP plist) => SOME (List.filter (fn (p, v) => if check_pat(p)
                                                                      then isSome match(v, p)
                                                                      else )
                                                        (ListPair.zip (plist, vlist)))
                          (* val res = match(val, pat)
                        in
                          if isSome res
                          then not null valOf res
                          else false
                        end) 
                        ListPair.zip (plist, vlist) *)

     | (Constructor (vstring, vval), ConstructorP (pstring, ppat)) => if vstring = pstring
                                                                      then match(vval, ppat) 
                                                                      else NONE
     | (_, _) => NONE
