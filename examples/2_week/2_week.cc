#include <utility>

std::pair<bool, int> swap(std::pair<int, bool> pr) {
    return std::pair<bool, int> {pr.second, pr.first};
}

int sum_two_pairs(std::pair<int, bool> pr1, std::pair<int, bool> pr2) {
    return pr1.first + pr1.second + pr2.first + pr2.second;
}

std::pair<int, int> div_mod (int x, int y) {
    return std::pair<int, int>{x/y, x%y};
}

#include <tuple>
#include <iostream>
#include <list>
#include <functional>

int sum_list (std::list<int> xs) {
    if (xs.empty()) {
        return 0;
    } else {
        return xs.front() + sum_list(std::list<int>{++xs.begin(), xs.end()});
    }
}

int sum_list2 (std::list<int> xs) {
    std::function<int(std::list<int>::iterator)> sum_aux;
    sum_aux = [&](std::list<int>::iterator it) {
        if (it==xs.end()) {
            return 0;
        } else {
            return *it + sum_aux(++it);
        }
    };

    return sum_aux(xs.begin());
}

std::list<int> countdown (int x) {
    if (x == 0) {
        return std::list<int>{};
    } else {
        auto res = countdown(x-1);
        res.push_front(x);
        return res;
    }
}

std::list<int> append(std::list<int> xs, std::list<int> ys) {
    if (xs.empty()) {
        return std::list<int>{ys};
    } else {
        auto res = append(std::list<int>{++xs.begin(), xs.end()}, ys);
        res.push_front(xs.front());
        return res;
    }
}

int main(int argc, char const *argv[])
{    
    auto t1 = std::tuple{1, "abc", std::tuple{true, 42}};
    std::cout << std::get<1>(std::get<2>(t1)) << std::endl;

    auto p1 = std::pair{false, std::pair{true, 42}};
    std::cout << p1.second.first << std::endl;

    return 0;
}
