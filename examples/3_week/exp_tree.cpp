#include <iostream>
#include <variant>
#include "box.h"

// define empty structs
template<class... Ts> struct overload : Ts... { using Ts::operator()...; };
template<class... Ts> overload(Ts...) -> overload<Ts...>;

struct Constant { int val; };

using Expr = std::variant<Constant,
                          box<struct Negate>,
                          box<struct Add>,
                          box<struct Mult>>;

struct Negate { Expr e; };
struct Add { Expr e1; Expr e2; };
struct Mult { Expr e1; Expr e2; };

int eval(Expr e) {
    return std::visit(overload{
        [](Constant& c) { return c.val; },
        [](box<struct Negate>& e) { return -eval(e->e); },
        [](box<struct Add>& e) { return eval(e->e1) + eval(e->e2); },
        [](box<struct Mult>& e) { return eval(e->e1) * eval(e->e2); },
    }, e);
}

int max_const(Expr e) {
    return std::visit(overload{
        [](Constant& c) { return c.val; },
        [](box<struct Negate>& e) { return max_const(e->e); },
        [](box<struct Add>& e) { return std::max(max_const(e->e1), max_const(e->e2)); },
        [](box<struct Mult>& e) { return std::max(max_const(e->e1), max_const(e->e2)); },
    }, e);
}

int count_adds(Expr e) {
    return std::visit(overload{
        [](Constant& c) { return 0; },
        [](box<struct Negate>& e) { return count_adds(e->e); },
        [](box<struct Add>& e) { return 1 + count_adds(e->e1) + count_adds(e->e2); },
        [](box<struct Mult>& e) { return count_adds(e->e1) + count_adds(e->e2); },
    }, e);
}

int main(int argc, char const *argv[])
{
    auto expr1 = Expr(Add{Constant{1}, Add{Constant{2}, Negate{Constant{3}}}});
    auto expr2 = Expr(Add{Constant{1}, Mult{Constant{2}, Negate{Constant{3}}}});
    /* 
    처음에 Add안의 Constant{1}과 Mult{...}을 봐 
    Constant{1}은 Expr variant에 있으니 implicit type conversion으로 Add e1에 잘 들어가
    Mult는 Compiler Copy elision으로 Rvalue 생성자를 부르게 될거야
    Negate의 경우도 Copy elision으로 Rvalue 생성자를 부르게 될거야
    R-value 생성자를 부르는 친구들은 만들자마자 사라져 for optimization
    */

    std::cout << "====expr1====" << std::endl;
    std::cout << eval(expr1) << std::endl;
    std::cout << max_const(expr1) << std::endl;
    std::cout << count_adds(expr1) << std::endl;
    
    std::cout << "====expr2====" << std::endl;
    std::cout << eval(expr2) << std::endl;
    std::cout << max_const(expr2) << std::endl;
    std::cout << count_adds(expr2) << std::endl;
    
    return 0;
}
