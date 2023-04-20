(* abstract data type using closures *)

(* int set 
 * with 3 methods: insert, member, size, 
 *             notice insert returns a set (a new set)
 *)

(* datatype set 대신에 record를 사용해도 좋아 편의를 위해 그냥 이거 사용함 *)
datatype set = S of { insert : int -> set, 
                  member : int -> bool,  
                  size   : unit -> int
                }

(* implementation of sets: this is the fancy stuff, but clients using
   this abstraction do not need to understand it *)
val empty_set =
  let 
    fun make_set xs =  (* make set을 밖에 노출하면 유저가 이거에 [1,1,2] 이렇게 맘대로 넣어서 쓸 수 있어 *)
                       (* 그러면 set의 invariant인 중복 불가가 깨져버려, 그것을 방지하기 위해 make set을 노출하지 않았어 *)
        let fun contains i = List.exists (fn x => i=x) xs
        in
            S({insert = fn i => if contains(i)
                                then make_set(xs)(* 우리 자신 S를 가리킬 방법이 없기에, 새로 만들어줘 *)
                                (* 물론 overhead가 있지만 *)
                                else make_set(i::xs),
                member = contains,
                size   = fn () => length(xs)
            })
        end
  in
    make_set [] (*  set value S{...}*)
  end 

(* example client *)
val s0 = empty_set; (* 얘는 set type *)
val S(s1) = empty_set;
(* 이렇게 하면 s1은 set type이 아닌 record type이야 *)

val S(s2) = (#insert s1) 34;  (* s2 has xs=[34] *)
val S(s3) = (#insert s2) 34;  (* s3 xs=[34] *)
val S(s4) = (#insert s3) 19;  (* s4 xs = [34, 19] *)
(#member s4) 19


