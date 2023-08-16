

Expr eval_under_env(Expr e, std::map<string, Expr> env) {
    return std::visit(overload {
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

template<class T, class U>
std::function<std::function<U(List<T>)>(U)>
cfoldl(std::function<U(U, T)> f) //f(acc, element)받기
{
    std::function<std::function<U(List<T>)>(U)> captured1; // acc 받기
    captured1 = [=](U acc) {
      std::function<U(List<T>)> captured2; // tail() 받기
      captured2 = [=](List<T> lst) {
        if (lst.isEmpty()) return acc;
        else return cfoldl(f) (f(acc, lst.head())) (lst.tail());
      };
      return captured2;
    };
    return captured1;
}

List<int> l = l.cons(0).cons(1).cons(2).cons(3).cons(4);
int sum = foldl([](int a, int b) { return a+b;}, 0, l);
int better_sum = foldl([](int a, int b) { return a+b; }, l.head(), l.tail());

int max = foldl([](int a, int b) { return a>b?a:b;}, 0, l);
int better_max = foldl([](int a, int b) { return a>b?a:b; }, l.head(), l.tail());

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

template<class T, class F>
bool ifany(F f, List<T> lst) {
  static_assert(std::is_convertible<F, std::function<bool(T)>>::value, 
                 "Requires a function type bool(T)");
  if (lst.isEmpty()) {
    return false;
  } 
  if (f(lst.head()))
    return true;
  else return ifany(f, lst.tail());;
}

int fib_normal(int n) {
    if (n == 0 || n == 1) { return 1; }
    else { return fib_normal(n-1) + fib_normal(n-2); }
}

int fib_tail_recursive(int n) {
    std::function<int(int, int, int)> _fib = [&] (int curr, int prev, int iter) {
        if (iter == n) { return curr + prev; }
        else { return _fib(curr+prev, curr, iter+1); }
    };

    if (n == 0 || n == 1) { return 1; }
    else { return _fib(1, 1, 2); }
}

int fib_memoization(int n) {
    static std::map<int, int> idxVal;
    if (idxVal.find(n) != idxVal.end()) { return idxVal[n]; }
    else {
        if (n == 0 || n == 1) { return 1; }
        int res = fib_memoization(n-1) + fib_memoization(n-2);
        idxVal[n] = res;
        return res;
    }
}

struct StreamPair {
    int val;
    std::function<struct StreamPair()> next;
    StreamPair(int x, std::function<struct StreamPair()> f) : val(x), next(f) {}
};

int numbers_until_loop(struct StreamPair s, std::function<bool(int)> tester) {
    int count = 0;
    while(!tester(s.val)) {
        count++;
        s = s.next();
    }
    return count;
}

auto numbers_until_functional = 
    [] (struct StreamPair s, std::function<bool(int)> tester) {
        std::function<int(struct StreamPair, int)> _numbers_until = 
            [&] (struct StreamPair s, int count) {
                if (tester(s.val)) { return count; }
                else { return _numbers_until(s.next(), count+1); }
            };
        return _numbers_until(s, 0);
    };

int main(int argc, char const *argv[])
{
    std::function<struct StreamPair(int)> f = [&] (int x) {
        auto _next = [=] () { return f(x+1); };
        struct StreamPair _p(x, _next);
        return _p;
    };

    struct StreamPair p(0, [=]() { return f(1); });

    struct StreamPair _p = p;
    for(int i=0; i<10; i++) {
        std::cout << _p.val << std::endl;
        _p = _p.next();
    }

    std::function<struct StreamPair(int, int)> f2 = [&] (int curr, int prev) {
        auto _next = [=] () { return f2(curr+prev, curr); };
        struct StreamPair _p(curr, _next);
        return _p;
    };

    struct StreamPair fibo(1, [=]() { return f2(1, 1); });

    _p = fibo;
    for(int i=0; i<10; i++) {
        std::cout << _p.val << std::endl;
        _p = _p.next();
    }

    int res = numbers_until_loop(p, [](int x) { return x > 25; });
    res = numbers_until_loop(fibo, [](int x) { return x > 100; });    
    res = numbers_until_functional(p, [](int x) { return x > 25; });
    res = numbers_until_functional(fibo, [](int x) { return x > 100; });
    
    return 0;
}

template<typename T>
class Stream {
    public:
        virtual T next() = 0;
};

class IntStream : public Stream<int> {
    public:
        IntStream() = default;
        int _n = 0;    
        virtual int next() {
            return _n++;
        }

};

class FiboStream : public Stream<int> {
    public:
        FiboStream() = default;

        int _prev = 0;
        int _curr = 1;

        virtual int next() {
            int res = _curr;
            _curr = _prev + _curr;
            _prev = res;
            return res;
        }
};

int main(int argc, char const *argv[])
{
    IntStream s;
    for(int i=0; i<10; i++) {
        std::cout << s.next() << std::endl;
    }

    FiboStream f;
    for(int i=0; i<10; i++) {
        std::cout << f.next() << std::endl;
    }

    return 0;
}
