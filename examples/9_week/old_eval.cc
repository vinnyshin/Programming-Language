#include <string>
#include <iostream>
#include <variant>
#include <map>
#include <exception>
#include <stdexcept>
#include "box.h"
using std::variant;
using std::string;

// Definition of Expr variants
struct Const {
    int val;
    Const(int _val): val(_val){};
    operator std::string() const { return "Const("+std::to_string(val)+")"; }
};
using Expr = variant<Const,
                     box<struct Add>, 
                     box<struct Multiply>>;

template<typename T> bool is(Expr e);

std::string toString(Expr e);

struct Add {
    Expr e1, e2;
    Add(Expr _e1, Expr _e2): e1(_e1), e2(_e2) {}; 
    operator std::string() const { 
        return "Add("+toString(e1)+", "+toString(e2)+")";
    }
};
struct Multiply {
    Expr e1, e2;
    Multiply(Expr _e1, Expr _e2): e1(_e1), e2(_e2) {}; 
    operator std::string() const { 
        return "Multiply("+toString(e1)+", "+toString(e2)+")";
    }
};

// End of Definition of Expr variants 

// Functions for check variants.
// e.g. is<APair>(e) or is<Const>(Expr(Const(42)))
template<typename T>
bool is(Expr e) { return std::holds_alternative<T>(e); }
template<>
bool is<Add>(Expr e) { return std::holds_alternative<box<struct Add>>(e); }
template<>
bool is<Multiply>(Expr e) { return std::holds_alternative<box<struct Multiply>>(e); }

// Converting Expr to std::string representation.
std::string toString(Expr e) {
    if (is<Const>(e)) {
        return std::get<Const>(e);
    } else if (is<box<struct Add>>(e)) {
        Add add = *std::get<box<struct Add>>(e);
        return add;
    } else if (is<box<struct Multiply>>(e)) {
        Multiply mult = *std::get<box<struct Multiply>>(e);
        return mult;
    } else {
        throw std::runtime_error("toString(Expr): Unexpected Expr is given!");
    }
}

int eval(Expr e) {
    return std::visit(overload {
        [&](Const& i) { return i.val;},
        [&](box<struct Add>& a) {
          int i1 = eval(a->e1);
          int i2 = eval(a->e2);
          return i1+i2;
/*          if (is<Const>(e1) && is<Const>(e2)) {
            Const i1 = std::get<Const>(e1);
            Const i2 = std::get<Const>(e2);
            return i1.val + i2.val;
          } else {
            throw std::runtime_error("Unexpected types for sub-expressions of Add");
          }*/
        },
        [&](box<struct Multiply>& m) {
          Expr e1 = eval(m->e1);
          Expr e2 = eval(m->e2);
          if (is<Const>(e1) && is<Const>(e2)) {
            Const i1 = std::get<Const>(e1);
            Const i2 = std::get<Const>(e2);
            return i1.val * i2.val;
          } else {
            throw std::runtime_error("Unexpected types for sub-expressions of Multiply");
          }
        }, 
      }, e);
}

int main() {

    Expr e = Add(Const(-3), Const(2));
    int res = eval(e);
    std::cout << "Add(Const(-3), Const(2)):" << res << std::endl;

    Expr e2 = Multiply(Add(Const(-3), Const(2)), Const(3));
    res = eval(e2);
    std::cout << "Multiply(Add(Const(-3), Const(2)), Const(3))):" << res << std::endl;


    return 0;
}
