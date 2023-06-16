#include <iostream>
#include <functional>

template<typename T>
class Promise {
    public:
        bool _computed;
        T _value;
        std::function<T()> _f;

        Promise(std::function<T()> f) : _f(f), _computed(false) {}

        T force() {
            if (!_computed) {
                _value = _f();
                _computed = true;
            }
            return _value;
        }
};

int main(int argc, char const *argv[])
{
    Promise<float> mult1to10b([]() {
        float res = 1;
        for(int i=1; i<=1000000000; i++) {
            res *= i;
        }
        return res;
     });

    std::cout << "calling force" << std::endl;
    std::cout << mult1to10b.force() << std::endl;
    
    std::cout << "calling force again" << std::endl;
    std::cout << mult1to10b.force() << std::endl;

    return 0;
}
