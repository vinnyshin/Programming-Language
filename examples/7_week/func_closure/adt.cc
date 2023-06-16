#include <exception> 
#include <functional> 
#include <utility> 
#include <iostream> 
#include "List.h"

template<class T>
bool contains(List<T> lst, T v)
{
    return !filter([&v](T val) { return val == v; }, lst).isEmpty();
}

struct set
{
    std::function<struct set(int)> insert;
    std::function<bool(int)> member;
    std::function<int()> size;
};

struct set make_set(List<int> xs) {
    struct set s;
    s.insert = [=](int x) {
        if (contains(xs, x)) return make_set(xs);
        else return make_set(xs.cons(x));
    };
    s.member = [=](int x) {
        return contains(xs, x);
    };
    s.size = [=]() {
        int size = 0;
        forEach(xs, [&size](int x) { size++; });
        return size;
    };
    return s;
}

int main() {
    auto s1 = make_set(List<int>().cons(1).cons(2).cons(3));
    auto s2 = s1.insert(4);
    auto s3 = s1.insert(5);

    std::cout << s1.size() << std::endl;
    std::cout << s2.size() << std::endl;
    std::cout << s3.size() << std::endl;
}
