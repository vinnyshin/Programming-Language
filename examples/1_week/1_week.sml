val x = 34
(* 
static env: x:int 
dynamic env: x->34
*)
val y = 17
val z = (x + y) + (y + 2)
val q = z + 1
val abs_of_z = if z < 0 then 0 - z else z
val abs_of_z_simpler = abs z

(* function binding *)
fun pow(x:int, y:int):int = 
    if y = 0
    then 1
    else x * pow(x, y-1)

fun cube (x:int):int = 
    pow(x, 3)

val sixtyfour = cube 4

(* 16 + 16 + 8 + 2 *)
val fortytwo = pow(2, 2+2) + pow(4,2) + cube(2) + 2

