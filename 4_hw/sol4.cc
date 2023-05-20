#include <iostream>
#include <map>
#include <string>

struct Int {
    int val;
    Int(int _val): val(_val){};
};


std::map<std::string, Int> wrapper(std::map<std::string, Int> test1) {
    std::map<std::string, Int> newEnv(test1);
    newEnv["test1"].val = 2;
    return newEnv;
}


int main(int argc, char const *argv[])
{
    auto test1 = std::map<std::string, Int>{};
    test1["test1"] = Int(1);
    std::cout << test1["test1"].val << std::endl;
    std::cout << wrapper(test1)["test1"].val << std::endl;
    std::cout << test1["test1"].val << std::endl;

    return 0;
}
