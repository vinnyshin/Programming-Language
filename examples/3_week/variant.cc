#include <string>
#include <iostream>
#include <variant>

using std::variant;

// define empty structs
template<class... Ts> struct overload : Ts... { using Ts::operator()...; };
template<class... Ts> overload(Ts...) -> overload<Ts...>;



struct P {};
struct N {};
struct Z {};

variant<P,N,Z> multsign(int x, int y) {
    auto sign = [](int v) { 
        if (v>0) { return variant<P,N,Z>(P{}); 
        } else if (v<0) { return variant<P,N,Z>(N{}); 
        } else { return variant<P,N,Z>(Z{});}
    };
  struct MyCase {
  variant<P,N,Z> operator()(const P& v1, const P& v2) { return variant<P,N,Z>(P{});}
  variant<P,N,Z> operator()(const P& v1, const N& v2) { return variant<P,N,Z>(N{});}
  variant<P,N,Z> operator()(const P& v1, const Z& v2) { return variant<P,N,Z>(Z{});}
  variant<P,N,Z> operator()(const N& v1, const P& v2) { return variant<P,N,Z>(N{});}
  variant<P,N,Z> operator()(const N& v1, const N& v2) { return variant<P,N,Z>(P{});}
  variant<P,N,Z> operator()(const N& v1, const Z& v2) { return variant<P,N,Z>(Z{});}
  variant<P,N,Z> operator()(const Z& v1, const P& v2) { return variant<P,N,Z>(Z{});}
  variant<P,N,Z> operator()(const Z& v1, const N& v2) { return variant<P,N,Z>(Z{});}
  variant<P,N,Z> operator()(const Z& v1, const Z& v2) { return variant<P,N,Z>(Z{});}
  };
    /*
    auto res = std::visit(overload{
            [](P& v1, P& v2) { return variant<P,N,Z>(P{});},
            [](N& v1, N& v2) { return variant<P,N,Z>(P{});},
            [](P& v1, N& v2) { return variant<P,N,Z>(N{});},
            [](N& v1, P& v2) { return variant<P,N,Z>(N{});},
            [](auto, auto) { return variant<P,N,Z>(Z{});},
        },
        sign(x), sign(y));
    */

    return std::visit(MyCase{}, sign(x), sign(y));
}

struct SampleVisitor
{
    void operator()(int i) const { 
        std::cout << "int: " << i << "\n"; 
    }
    void operator()(float f) const { 
        std::cout << "float: " << f << "\n"; 
    }
    void operator()(const std::string& s) const { 
        std::cout << "string: " << s << "\n"; 
    }
};


int main()
{
    std::variant<int, float, std::string> intFloatString;
    static_assert(std::variant_size_v<decltype(intFloatString)> == 3);

    // default initialized to the first alternative, should be 0
    std::visit(SampleVisitor{}, intFloatString);

    // index will show the currently used 'type'
    std::cout << "index = " << intFloatString.index() << std::endl;
    intFloatString = 100.0f;
    std::cout << "index = " << intFloatString.index() << std::endl;
    intFloatString = "hello super world";
    std::cout << "index = " << intFloatString.index() << std::endl;

    // try with get_if:
    if (const auto intPtr (std::get_if<int>(&intFloatString)); intPtr) 
        std::cout << "int!" << *intPtr << "\n";
    else if (const auto floatPtr (std::get_if<float>(&intFloatString)); floatPtr) 
        std::cout << "float!" << *floatPtr << "\n";

    auto strPtr1 = std::get_if<std::string>(&intFloatString);
    if (strPtr1 != nullptr) {
        std::cout << "]]] strPtr1:" << *strPtr1 << std::endl;
    } 
    
    if (std::holds_alternative<int>(intFloatString))
        std::cout << "the variant holds an int!\n";
    else if (std::holds_alternative<float>(intFloatString))
        std::cout << "the variant holds a float\n";
    else if (std::holds_alternative<std::string>(intFloatString))
        std::cout << "the variant holds a string\n";  

    // try/catch and bad_variant_access
    try 
    {
        auto f = std::get<float>(intFloatString); 
        std::cout << "float! " << f << "\n";
    }
    catch (std::bad_variant_access&) 
    {
        std::cout << "our variant doesn't hold float at this moment...\n";
    }

    std::variant<std::string, std::string> var42;
    var42.emplace<1>("abc");

    // visit:
    std::visit(SampleVisitor{}, intFloatString);
    intFloatString = 10;
    std::visit(SampleVisitor{}, intFloatString);
    intFloatString = 10.0f;
    std::visit(SampleVisitor{}, intFloatString);

    std::cout << "\n\n\n";
    std::variant<int, float, std::string> intOrFloatOrStr="42";
    struct MyCase {
        void operator()(int i) const {
            std::cout << "int:" << i << std::endl;
        }
        void operator()(float f) const {
            std::cout << "float:" << f << std::endl;
        }
        void operator()(const std::string& s) const {
            std::cout << "str:" << s << std::endl;
        }
    };
    std::visit(MyCase{}, intOrFloatOrStr);

    auto res = multsign(1, 0);
    if (std::holds_alternative<P>(res)) {
      std::cout << "multsign(1, 0): P" << std::endl;
    } else if (std::holds_alternative<N>(res)) {
      std::cout << "multsign(1, 0): N" << std::endl;
    } else {
      std::cout << "multsign(1, 0): Z" << std::endl;
    }
}

