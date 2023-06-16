#include <iostream>

template<typename T>
class Stream {
    public:
        virtual T next() = 0;
};

class IntStream : public Stream<int> {
    public:
        IntStream() = default;

        int _n = 0;
        
/*
The difference between these two code snippets lies in the use of the virtual keyword.

In the first piece of code, the next() method in the IntStream class is not declared as virtual. This means that if we have a pointer or reference to a Stream<int> object that actually points to an IntStream object, calling next() on that pointer or reference will invoke Stream<int>::next(), not IntStream::next(). This is known as static binding.

In the second piece of code, the next() method in the IntStream class is declared as virtual. This means that if we have a pointer or reference to a Stream<int> object that actually points to an IntStream object, calling next() on that pointer or reference will invoke IntStream::next(). This is known as dynamic binding, or runtime polymorphism. The virtual keyword enables this behavior.

So in summary, the difference between these two pieces of code is that the first uses static binding for the next() method, while the second uses dynamic binding.
*/

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

    std::cout << "IntStream" << std::endl;
    for(int i=0; i<10; i++) {
        std::cout << s.next() << std::endl;
    }
    std::cout << std::endl;

    FiboStream f;

    std::cout << "FiboStream" << std::endl;
    for(int i=0; i<10; i++) {
        std::cout << f.next() << std::endl;
    }
    std::cout << std::endl;

    return 0;
}
