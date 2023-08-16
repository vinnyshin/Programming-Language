signature S =
sig
  val mylist: int list
end

structure M :> S =
struct
    val mylist = []
end

signature S2 =
sig
  val mylist: 'a list
end

structure M2 :> S2 =
struct
    val mylist = []
end