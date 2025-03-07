#include <string>
#include <iostream>
#include <variant>
#include <map>
#include <exception>
#include <stdexcept>
#include "box.h"
#include "List.h"

using std::variant;
using std::string;

// Definition of Expr variants
struct Var {
    string name;
    Var(string _name): name(_name){};
    operator std::string() const { return "Var("+name+")"; }
};
struct Int {
    int val;
    Int(int _val): val(_val){};
    operator std::string() const { return "Int("+std::to_string(val)+")"; }
};
struct AUnit {
    AUnit() {};
    operator std::string() const { return "AUnit()"; }
};
using Expr = variant<Var, 
                     Int,
                     AUnit,
                     box<struct IsAUnit>, 
                     box<struct Add>, 
                     box<struct IfGreater>, 
                     box<struct MLet>,
                     box<struct Fun>, 
                     box<struct Closure>,
                     box<struct APair>,
                     box<struct Fst>,
                     box<struct Snd>,
                     box<struct Call>>; 

template<typename T> bool is(Expr e);

std::string toString(Expr e);

struct Add {
    Expr e1, e2;
    Add(Expr _e1, Expr _e2): e1(_e1), e2(_e2) {}; 
    operator std::string() const { 
        return "Add("+toString(e1)+", "+toString(e2)+")";
    }
};
struct IfGreater {
    Expr e1, e2, e3, e4;
    IfGreater(Expr _e1, Expr _e2, Expr _e3, Expr _e4): e1(_e1), e2(_e2), e3(_e3), e4(_e4) {};
    operator std::string() const {
        return "IfGreater("+toString(e1)+", "+toString(e2)+", "
                           +toString(e3)+", "+toString(e4)+")";
    }
};
struct MLet {
    string varName;
    Expr e1, e2;
    MLet(string _varName, Expr _e1, Expr _e2): varName(_varName), e1(_e1), e2(_e2) {}; 
    operator std::string() const { 
        return "MLet("+varName+", "+toString(e1)+", "+toString(e2)+")";
    }
};
struct APair {
    Expr e1, e2;
    APair(Expr _e1, Expr _e2): e1(_e1), e2(_e2) {};
    operator std::string() const { 
        return "APair("+toString(e1)+", "+toString(e2)+")";
    }
};
struct Fst {
    Expr e;
    Fst(Expr _e): e(_e) {};
    operator std::string() const { return "Fst("+toString(e)+")"; }
};
struct Snd {
    Expr e;
    Snd(Expr _e): e(_e) {};
    operator std::string() const { return "Snd("+toString(e)+")"; }
};
struct IsAUnit {
    Expr e;
    IsAUnit(Expr _e): e(_e) {};
    operator std::string() const { return "IsAUnit("+toString(e)+")"; }
};

struct Fun {
    string funName;
    string argName;
    Expr body;
    Fun(string _f, string _a, Expr _b): funName(_f), argName(_a), body(_b) {}; 
    operator std::string() const { 
        return "Fun("+funName+", "+argName+", "+toString(body)+")";
    }
};
struct Closure {
    std::map<string, Expr> env;
    Fun f;
    Closure(std::map<string, Expr> _env, Fun _f): env(_env), f(_f) {};
    operator std::string() const { 
        return "Closure(env, "+std::string(f)+")";
    }
};
struct Call {
    /* funExpr은 closure, 즉 env + code (function body)로 이루어져 있음 */
    /* actual은 argument */
    Expr funExpr, actual;
    Call(Expr _fe, Expr _a): funExpr(_fe), actual(_a) {};
    operator std::string() const { 
        return "Call("+toString(funExpr)+", "+toString(actual)+")";
    }
};
// End of Definition of Expr variants 

// Functions for check variants.
// e.g. is<APair>(e) or is<Int>(Expr(Int(42)))
template<typename T>
bool is(Expr e) { return std::holds_alternative<T>(e); }
template<>
bool is<Closure>(Expr e) { return std::holds_alternative<box<struct Closure>>(e); }
template<>
bool is<IsAUnit>(Expr e) { return std::holds_alternative<box<struct IsAUnit>>(e); }
template<>
bool is<Add>(Expr e) { return std::holds_alternative<box<struct Add>>(e); }
template<>
bool is<IfGreater>(Expr e) { return std::holds_alternative<box<struct IfGreater>>(e); }
template<>
bool is<MLet>(Expr e) { return std::holds_alternative<box<struct MLet>>(e); }
template<>
bool is<Fun>(Expr e) { return std::holds_alternative<box<struct Fun>>(e); }
template<>
bool is<APair>(Expr e) { return std::holds_alternative<box<struct APair>>(e); }
template<>
bool is<Fst>(Expr e) { return std::holds_alternative<box<struct Fst>>(e); }
template<>
bool is<Snd>(Expr e) { return std::holds_alternative<box<struct Snd>>(e); }
template<>
bool is<Call>(Expr e) { return std::holds_alternative<box<struct Call>>(e); }

// Converting Expr to std::string representation.
std::string toString(Expr e) {
    if (is<Int>(e)) {
        return std::get<Int>(e);
    } else if (is<Var>(e)) {
        return std::get<Var>(e);
    } else if (is<AUnit>(e)) {
        return std::get<AUnit>(e);
    } else if (is<IsAUnit>(e)) {
        return *std::get<box<struct IsAUnit>>(e);
    } else if (is<box<struct Add>>(e)) {
        Add add = *std::get<box<struct Add>>(e);
        return add;
    } else if (is<box<struct IfGreater>>(e)) {
        IfGreater ifgt = *std::get<box<struct IfGreater>>(e);
        return ifgt;
    } else if (is<box<struct MLet>>(e)) {
        MLet mlet = *std::get<box<struct MLet>>(e);
        return mlet;
    } else if (is<box<struct Fun>>(e)) {
        Fun fun = *std::get<box<struct Fun>>(e);
        return fun;
    } else if (is<box<struct Closure>>(e)) {
        Closure closure = *std::get<box<struct Closure>>(e);
        return closure;
    } else if (is<box<struct APair>>(e)) {
        return *std::get<box<struct APair>>(e);
    } else if (is<box<struct Fst>>(e)) {
        return *std::get<box<struct Fst>>(e);
    } else if (is<box<struct Snd>>(e)) {
        return *std::get<box<struct Snd>>(e);
    } else if (is<box<struct Call>>(e)) {
        Call call = *std::get<box<struct Call>>(e);
        return call;
    } else {
        throw std::runtime_error("toString(Expr): Unexpected Expr is given!");
    }
}

// Asserts that given Expr is a value in MUPL.
void assertValue(Expr e) {
    if (is<APair>(e)) {
        APair ap = *std::get<box<struct APair>>(e);
        assertValue(ap.e1);
        assertValue(ap.e2);
    } else if (!(is<Int>(e) || 
               is<Closure>(e) ||
               is<AUnit>(e))) {
        throw std::runtime_error(toString(e) + " is not a value!");
    }
}

// Make a new environment by copying from the passed environment.
std::map<string, Expr> makeNewEnvFrom(std::map<string, Expr> fromEnv) {
    std::map<string, Expr> newEnv(fromEnv);
    return newEnv;
}

Expr envlookup(std::map<string, Expr> env, Var v) {
    if (env.count(v.name) == 0) {
        throw std::runtime_error(toString(v)+" is not in the environment");
    } else {
        Expr val = env.at(v.name);
        assertValue(val);
        return val;
    }
}

Expr eval_under_env(Expr e, std::map<string, Expr> env) {
    return std::visit(overload {
        [&](Int& i) { return e;},
        [&](Var& v) {
          Expr val = envlookup(env, v);
          return val;
        },
        [&](box<struct Add>& a) {
          Expr e1 = eval_under_env(a->e1, env);
          Expr e2 = eval_under_env(a->e2, env);
          if (is<Int>(e1) && is<Int>(e2)) {
            Int i1 = std::get<Int>(e1);
            Int i2 = std::get<Int>(e2);
            Expr res(Int(i1.val+i2.val));
            return res;
          } else {
            throw std::runtime_error("Unexpected types for sub-expressions of Add");
          }
        },
        [&](AUnit& au) { return e; /* AUnit은 value이기에 e return */ },
        [&](box<struct IsAUnit>& isa) {
            Expr e1 = eval_under_env(isa->e, env);

            if(is<AUnit>(e1)) {
                return Expr(Int(1));
            } else {
                return Expr(Int(0));
            }
        },  
        [&](box<struct IfGreater>& ifgt) {
            Expr e1 = eval_under_env(ifgt->e1, env);
            Expr e2 = eval_under_env(ifgt->e2, env);

            if (is<Int>(e1) && is<Int>(e2)) {
                Int i1 = std::get<Int>(e1);
                Int i2 = std::get<Int>(e2);
                
                if (i1.val > i2.val) {
                    Expr e3 = eval_under_env(ifgt->e3, env);
                    return e3;
                } else {
                    Expr e4 = eval_under_env(ifgt->e4, env);
                    return e4;
                }
            } else {
                throw std::runtime_error("Unexpected types for condition of IfThenElse");
            }
        }, 
        [&](box<struct MLet>& l) {
            /*
            fun test (x) = (let val x = e1 in e2 end) + (let val y = e1 in e2 end)
            가 있다고 하자.
            let이 Env를 copy하지 않고 x를 caller env에 등록하면
            ex) env[l->varName] = eval_under_env(l->e1, env);
            두번째 let 수행할 때 val x = e1을 쓰게 된다.
            말이 안되는거지.
            근데 C++에서는 기본적으로 map을 함수끼리 전달할 때 copy해서 전달하기 때문에
            makeNewEnvFrom을 사용하지 않아도 돼 (addtional copy가 생겨)
            */
            std::map<string, Expr> mLetEnv = makeNewEnvFrom(env);
            Expr val = eval_under_env(l->e1, mLetEnv);
            assertValue(val);
            mLetEnv.insert_or_assign(l->varName, val);

            Expr e2 = eval_under_env(l->e2, mLetEnv);
            return e2;
        },
        [&](box<struct Fun>& f) {
            Closure closure(makeNewEnvFrom(env), *f);
            
            /*
            std::cout << closure.f.funName << std::endl;
            if (!closure.f.funName.empty()) {
                // extending env of the closure to closure itself
                closure.env.insert_or_assign(closure.f.funName, closure);    
            }
            Closure closure2 = *std::get<box<struct Closure>>(envlookup(closure.env, Var("recursive_add")));
            std::cout << closure2.env.count("recursive_add") << std::endl;
            closure.env.insert_or_assign(closure.f.funName, closure);
            이 구문에서 우리가 만든 closure의 복사본의 env에 recursive_add가 추가되긴 하지만
            old closure을 env에 넣기 때문에 closure2에서 recursive_add가 있는지 보면 없는 것으로 나와
            이런 문제를 가지기에 closure을 evaluation할 때 그때 env를 extend하는거야 만들때 extend하는게 아니라
            */
                
            return Expr(closure);
        },
        [&](box<struct Closure>& c) {
            return e; /* Closure은 value이기에 e return */
        },
        [&](box<struct APair>& ap) {
            // After evaluating subexpression, apair needs to hold values
            Expr val1 = eval_under_env(ap->e1, env);
            assertValue(val1);
            Expr val2 = eval_under_env(ap->e2, env);
            assertValue(val2);
            
            return Expr(APair(val1, val2));
        },
        [&](box<struct Fst>& fst) { 
            Expr e1 = eval_under_env(fst->e, env);

            if(is<APair>(e1)) {
                APair ap = *std::get<box<struct APair>>(e1);
                return ap.e1;
            } else {
                throw std::runtime_error("Unexpected types for sub-expressions of fst");
            }
        },
        [&](box<struct Snd>& snd) { 
            Expr e1 = eval_under_env(snd->e, env);

            if(is<APair>(e1)) {
                APair ap = *std::get<box<struct APair>>(e1);
                return ap.e2;
            } else {
                throw std::runtime_error("Unexpected types for sub-expressions of snd");
            }
        },
        [&](box<struct Call>& call) {
            Expr funExpr = eval_under_env(call->funExpr, env);
            Expr argVal = eval_under_env(call->actual, env);
            assertValue(argVal);

            if(is<Closure>(funExpr)) {
                Closure closure = *std::get<box<struct Closure>>(funExpr);
                
                // extending env of the closure to argument
                closure.env.insert_or_assign(closure.f.argName, argVal);
                
                // if the closure is not anonymous non-recursive function
                if (!closure.f.funName.empty()) {
                    // extending env of the closure to closure itself
                    closure.env.insert_or_assign(closure.f.funName, closure);
                }
                // it evaluates the closure's function body in the extended environment
                return eval_under_env(closure.f.body, closure.env);
            } else {
                throw std::runtime_error("Unexpected types for sub-expressions of call");
            }
        },
      }, e);
}

Expr eval(Expr e) {
    std::map<string, Expr> env;
    return eval_under_env(e, env);
}

Expr makeIntList(int from, int to) {
    Expr next = AUnit();
    Expr res = AUnit();
    for (int i=to-1; i>=from; i--) {
        Expr tmp = APair(Int(i), next);
        res = tmp;
        next = tmp;
    }
    return res;
}

Expr IfAUnit(Expr e1, Expr e2, Expr e3) {
    /* e1이 AUnit일 경우 e2, 아니면 e3 계산후 return */
    return IfGreater(IsAUnit(e1), Int(0), e2, e3);
}

Expr MuplMap() {
    // pseudo code in ML:
    // fn fun_arg =>
    //    let fun muplrec(lst) =
    //           if IsAUnit(lst)
    //           then AUnit()
    //           else APair(fun_arg(Fst(lst)),
    //                      muplrec(Snd(lst)))             
    //    in
    //      muplrec /* UPDATED */
    //    end

    Expr expr = Fun("", "fun_arg",
                    Fun("muplrec", "lst", 
                        IfAUnit(Var("lst"),
                                AUnit(),
                                APair(
                                    Call(Var("fun_arg"), Fst(Var("lst"))),
                                    Call(Var("muplrec"), Snd(Var("lst")))
                                )
                        )
                    )
                );
    return expr;
}

Expr MuplMapAddN() {
    // pseudo code in ML:
    // let val map = MuplMap() in
    //    fn I => map(fn x => x+I)
    // end
    
    Expr map = MuplMap();
    Expr expr2 = Fun("", "I", Call(map, Fun("", "x", Add(Var("x"), Var("I")))));
    return expr2;
}

Expr ToMuplList(List<Expr> exprs) {
    if (exprs.tail().isEmpty()) {
        return Expr(APair(exprs.head(), AUnit()));
    } else {
        return Expr(APair(exprs.head(), ToMuplList(exprs.tail())));
    }
}

List<Expr> FromMuplList(Expr muplList) {
    if (is<APair>(muplList)) {
        APair pair = *std::get<box<struct APair>>(muplList);
        if (is<AUnit>(pair.e2)) {
            return makeList<Expr>(pair.e1);
        } else {
            return cons<Expr>(pair.e1, FromMuplList(pair.e2));
        }
    } else {
        throw std::runtime_error(toString(muplList) + " is not a APair(MuplList)!");
    }
}

void TestMuplListAndFromMuplList() {
    List<Expr> exprs = makeList<Expr, Expr, Expr, Expr>(Add(Int(5), Int(2)), AUnit(), Int(3), Add(Int(0), Int(4)));
    Expr muplList = ToMuplList(exprs);
    
    std::cout << "==========TestMuplList==========" << std::endl;
    std::cout << toString(muplList) << std::endl;
    std::cout << "================================" << std::endl;
    
    List<Expr> exprs2 = FromMuplList(muplList);

    std::cout << "==========FromMuplList==========" << std::endl;
    forEach(exprs2, [](Expr v) 
    {
        std::cout << toString(v) << ", "; 
    });
    std::cout << std::endl;
    std::cout << "================================" << std::endl;
}

void TestMuplMapAndMuplMapAddN() {
    Expr muplList = makeIntList(0, 5);

    std::cout << "============MuplMap============" << std::endl;
    std::map<string, Expr> env;
    Expr expr1 = MuplMap();
    Expr expr2 = Call(expr1, Fun("addOne", "x", Add(Var("x"), Int(1))));
    Expr res = eval_under_env(expr2, env);
    std::cout << toString(expr2) << std::endl;
    std::cout << toString(res) <<std::endl;
    Expr expr3 = Call(res, muplList);
    res = eval_under_env(expr3, env);
    std::cout << toString(expr3) << std::endl;
    std::cout << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
    
    std::cout << "==========MuplMapAdd===========" << std::endl;
    Expr expr4 = Call(Call(MuplMapAddN(), Int(10)), makeIntList(0, 5));
    res = eval(expr4);
    std::cout << toString(expr4) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

void TestAdd() {
    std::map<string, Expr> env;
    env.insert_or_assign("a", Expr(Int(40)));
    Expr e = Add(Var("a"), Int(2));
    Expr res = eval_under_env(e, env);

    std::cout << "==============Add==============" << std::endl;
    std::cout << toString(e) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

void TestIsAUnit() {
    std::map<string, Expr> env;   
    Expr expr1 = IsAUnit(Add(Add(Int(2), Int(3)), Int(3)));
    Expr expr2 = IsAUnit(AUnit());
    
    std::cout << "==============IsAUnit==============" << std::endl;
    Expr res = eval_under_env(expr1, env);
    std::cout << toString(expr1) << " = " << toString(res) << std::endl;
    
    res = eval_under_env(expr2, env);
    std::cout << toString(expr2) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

void TestMLet() {
    std::map<string, Expr> env;
    Expr expr1 = MLet("x", 3, Add(Var("x"), Int(3)));
    Expr expr2 = Add(MLet("x", 3, Add(Var("x"), Int(3))), MLet("x", 4, Add(Var("x"), Int(4))));
    Expr expr3 = MLet("x", 3, MLet("x", 4, Add(Var("x"), Int(4))));
    Expr expr4 = MLet("a", Int(5), MLet("b", Int(10), Add(Var("a"), Var("b"))));
    Expr expr5 = MLet("a", Int(5), Add(Var("a"), MLet("a", Int(10), Add(Var("a"), Int(1)))));
    
    std::cout << "==============MLet==============" << std::endl;
    Expr res = eval_under_env(expr1, env);
    std::cout << toString(expr1) << " = " << toString(res) << std::endl;
    
    res = eval_under_env(expr2, env);
    std::cout << toString(expr2) << " = " << toString(res) << std::endl;
    
    res = eval_under_env(expr3, env);
    std::cout << toString(expr3) << " = " << toString(res) << std::endl;

    res = eval_under_env(expr4, env);
    std::cout << toString(expr4) << " = " << toString(res) << std::endl;
    
    res = eval_under_env(expr5, env);
    std::cout << toString(expr5) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

void TestAPair() {
    std::map<string, Expr> env;

    std::cout << "==============APair==============" << std::endl;
    Expr expr = APair(Add(Int(0), Int(10)), APair(Int(1), AUnit()));
    Expr res = eval_under_env(expr, env);
    std::cout << toString(expr) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

void TestFstAndSnd() {
    std::map<string, Expr> env;

    Expr ap = APair(Add(Int(0), Int(10)), APair(Int(1), AUnit()));
    Expr expr1 = Fst(ap);
    Expr res = eval_under_env(expr1, env);
    
    std::cout << "==============Fst==============" << std::endl;
    std::cout << toString(expr1) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;

    Expr expr2 = Snd(ap);
    res = eval_under_env(expr2, env);
    
    std::cout << "==============Snd==============" << std::endl;
    std::cout << toString(expr2) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

void TestIfGreater() {
    std::map<string, Expr> env;
    
    Expr expr = IfGreater(Int(1), Int(0), Int(42), Int(-42));
    Expr res = eval_under_env(expr, env);
    
    std::cout << "==============IfGreater==============" << std::endl;
    std::cout << toString(expr) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

void TestCall() {
    std::map<string, Expr> env;
    
    Expr expr1 = Call(Fun("add1", "x", Add(Var("x"), Int(1))), Int(41));
    Expr expr2 = Call(Fun("recursive_add", "x",
                IfGreater(Int(5), Var("x"), Add(Int(1), Call(Var("recursive_add"), Add(Var("x"), Int(1)))), Int(0))),
                Int(0));
    Expr expr3 = Call(Fun("", "x", Add(Var("x"), Int(5))), Int(10));
    
    std::cout << "==============Call==============" << std::endl;
    Expr res = eval_under_env(expr1, env);
    std::cout << toString(expr1) << " = " << toString(res) << std::endl;

    res = eval_under_env(expr2, env);
    std::cout << toString(expr2) << " = " << toString(res) << std::endl;
    
    res = eval_under_env(expr3, env);
    std::cout << toString(expr3) << " = " << toString(res) << std::endl;
    std::cout << "================================" << std::endl;
}

int main() {
    return 0;
}
