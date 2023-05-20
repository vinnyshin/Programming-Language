#include <exception> 
#include <functional> 
#include <utility> 
#include <iostream> 
#include <variant>
#include "List.h"
#include "box.h"

struct Constant { int val; };

using Expr = std::variant<Constant,
                          box<struct Negate>,
                          box<struct Add>,
                          box<struct Mult>>;

struct Negate { Expr e; };
struct Add { Expr e1; Expr e2; };
struct Mult { Expr e1; Expr e2; };

template<class F>
bool any(F test, Expr e) {
    static_assert(std::is_convertible<F, std::function<bool(int)>>::value,
                  "Requires a function type bool(int)");
    
    return std::visit(overload{
        [&](Constant& c) { return test(c.val); },
        [&](box<struct Negate>& e) { return any(test, e->e); },
        [&](box<struct Add>& e) { return any(test, e->e1) || any(test, e->e2); },
        [&](box<struct Mult>& e) { return any(test, e->e1) || any(test, e->e2); },
    }, e);
}

template<class T, class F>
bool ifall(F f, List<T> lst) {
  static_assert(std::is_convertible<F, std::function<bool(T)>>::value, 
                 "Requires a function type bool(T)");
  if (lst.isEmpty()) {
    return true;
  } 
  if (f(lst.head()))
    return ifall(f, lst.tail());
  else return false;
}

int main() {
  List<int> l;
  l = l.cons(3);
  l = l.cons(2);
  l = l.cons(1);
  l = l.cons(0);

  List<int> l3 = filter([](int x){ return x%2==0;}, l);
  std::cout << "l3:";
  print(l3);
 
  bool allOdd = ifall([](int x){ return x%2==1; }, l3);
 
  List<int> l2 = fmap<int>([](int x){ return x+1;}, l);
  std::cout << "l2:";
  print(l2);

  auto expr = Expr(Mult{Constant{2}, Constant{1}});

  std::function<bool(Expr)> any_even = [=](Expr e) {
    return any([](int v) { return v%2==0; }, e);
  };

  std::cout << any_even(expr);

  return 0;
}

