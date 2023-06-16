#include <iostream>
#include <functional>

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
    std::cout << "fibo" << std::endl;
    for(int i=0; i<10; i++) {
        std::cout << _p.val << std::endl;
        _p = _p.next();
    }

    int res = numbers_until_loop(p, [](int x) { return x > 25; });
    std::cout << "numbers_until: " << res << std::endl;

    res = numbers_until_loop(fibo, [](int x) { return x > 100; });
    std::cout << "numbers_until(fibo): " << res << std::endl;
    
    res = numbers_until_functional(p, [](int x) { return x > 25; });
    std::cout << "numbers_until_functional: " << res << std::endl;

    res = numbers_until_functional(fibo, [](int x) { return x > 100; });
    std::cout << "numbers_until_functional(fibo): " << res << std::endl;
    
    return 0;
}
