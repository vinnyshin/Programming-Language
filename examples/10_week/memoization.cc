#include <iostream>
#include <functional>
#include <map>

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

int main(int argc, char const *argv[])
{
    std::cout << fib_normal(42) << std::endl;
    std::cout << fib_tail_recursive(42) << std::endl;
    std::cout << fib_memoization(42) << std::endl;

    return 0;
}
