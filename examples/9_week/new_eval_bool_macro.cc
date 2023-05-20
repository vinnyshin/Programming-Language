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
struct Bool {
    bool val;
    Bool (bool _val): val(_val){};
    operator std::string() const { return "Bool("+std::to_string(val)+")"; }
};
using Expr = variant<Const,
                     Bool,
                     box<struct Add>, 
                     box<struct Multiply>,
                     box<struct IfThenElse>>;

/* 함수 선언 */
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
struct IfThenElse {
    Expr e1, e2, e3;
    IfThenElse(Expr _e1, Expr _e2, Expr _e3): e1(_e1), e2(_e2), e3(_e3) {};
    operator std::string() const { 
        return "IfThenElse("+toString(e1)+", "+toString(e2)+","+toString(e3)+")";
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
template<>
bool is<IfThenElse>(Expr e) { return std::holds_alternative<box<struct IfThenElse>>(e); }


// Converting Expr to std::string representation.
std::string toString(Expr e) {
    if (is<Const>(e)) {
        return std::get<Const>(e);
    } else if (is<Bool>(e)) {
        return std::get<Bool>(e);
    } else if (is<box<struct Add>>(e)) {
        Add add = *std::get<box<struct Add>>(e);
        return add;
    } else if (is<box<struct Multiply>>(e)) {
        Multiply mult = *std::get<box<struct Multiply>>(e);
        return mult;
    } else if (is<box<struct IfThenElse>>(e)) {
        IfThenElse ite = *std::get<box<struct IfThenElse>>(e);
        return ite;
    } else {
        throw std::runtime_error("toString(Expr): Unexpected Expr is given!");
    }
}

/*Expr addFromTo(int from, int to) {
    if (to == from+1) { 
        return Add(Const(from), Const(to));
    } else if (to > from+1) {
        return Add(Const(from), addFromTo(from+1, to));
    } else { // from >= to
        throw std::runtime_error("from >= to");
    }
}*/

Expr eval(Expr e) {
    return std::visit(overload {
        [&](Const& i) { return e;},
        [&](Bool& i) { return e;},
        [&](box<struct Add>& a) {
          Expr e1 = eval(a->e1);
          Expr e2 = eval(a->e2);
          if (is<Const>(e1) && is<Const>(e2)) {
            Const i1 = std::get<Const>(e1);
            Const i2 = std::get<Const>(e2);
            Expr res(Const(i1.val+i2.val));
            return res;
          } else {
            throw std::runtime_error("Unexpected types for sub-expressions of Add");
          }
        },
        [&](box<struct Multiply>& m) {
          Expr e1 = eval(m->e1);
          Expr e2 = eval(m->e2);
          if (is<Const>(e1) && is<Const>(e2)) {
            Const i1 = std::get<Const>(e1);
            Const i2 = std::get<Const>(e2);
            Expr res(Const(i1.val*i2.val));
            return res;
          } else {
            throw std::runtime_error("Unexpected types for sub-expressions of Multiply");
          }
        }, 
        [&](box<struct IfThenElse>& i) {
          Expr e1 = eval(i->e1);
          if (is<Bool>(e1)) {
            Bool b = std::get<Bool>(e1);
            if (b.val) {
                Expr e2 = eval(i->e2);
                return e2;
            } else {
                Expr e3 = eval(i->e3);
                return e3;
            }
          } else {
            throw std::runtime_error("Unexpected types for condition of IfThenElse");
          }
        },
      }, e);
}


Expr addThree(int a, int b, int c) {
    // TODO
    Expr e = Add(Const(a), Add(Const(b), Const(c)));
    return e;
}


Expr addFromTo(int from, int to) {
    // TODO
    if(to==from+1) {
        return Add(Const(from), Const(to));
    } else if(to>from+1) {
        return Add(Const(from), addFromTo(from+1, to));
    } else { // from >= to
        throw std::runtime_error("from >= to");
    }
}


int main() {
    std::cout << std::boolalpha;
    Expr e = Add(Const(-3), Const(2));
    Expr res = eval(e);
    Const ires = std::get<Const>(res);
    std::cout << "Add(Const(-3), Const(2)):" << std::string(ires) << std::endl;

    Expr e2 = Multiply(Add(Const(-3), Const(2)), Const(3));
    res = eval(e2);
    ires = std::get<Const>(res);
    std::cout << "Multiply(Add(Const(-3), Const(2)), Const(3))):" << std::string(ires)<< std::endl;

    Expr e3 = IfThenElse(Bool(false), Const(1), Const(2));
    res = eval(e3);
    ires = std::get<Const>(res);
    std::cout << toString(e3) << ": "  << std::string(ires)<< std::endl;

    /* Macros equivalent with target language syntax(code) */
    Expr e4 = addThree(1, 2, 3);
    res = eval(e4);
    ires = std::get<Const>(res);
    std::cout << toString(e4) << ": "  << std::string(ires)<< std::endl;

    Expr e5 = addFromTo(0, 10);
    res = eval(e5);
    ires = std::get<Const>(res);
    std::cout << toString(e5) << ": "  << std::string(ires)<< std::endl;

    return 0;
}
