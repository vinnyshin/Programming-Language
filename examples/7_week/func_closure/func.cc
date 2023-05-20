#include <exception> 
#include <functional> 
#include <utility> 
#include <iostream> 
#include "List.h"

float adder(float a, float b) {
  return a+b;
}

float applyFG(float a, std::function<float(float)> f,
                       std::function<float(float)> g) {
  return g(f(a));
}

int n_times(std::function<int(int)> f, int n, int x) {
  if (n==0) {
    return x;
  } else {
    return f(n_times(f, n-1, x));
  }
}


int main() {
  std::function<float(float, float)> f = adder;

  std::pair f_arg={f, std::pair{3.2,3.3}};
  f_arg.first(f_arg.second.first, f_arg.second.second);

  std::apply(f_arg.first, f_arg.second);
  
  int var1 = 42;
  auto addVar1 = [=](int arg) {
    return var1 + arg;
  };

  std::cout << "addVar1(10):" << addVar1(10) << std::endl;

  auto add1 = [](float a) { return a+1.0f;};
  auto add2 = [](float a) { return a+2.0f;};
  float res = applyFG(4.2f, add1, add2);

  std::cout << "applyFG(4.2f, add1, add2):" << res << std::endl;

  auto dbl = [](int x) { return x+x;};
  auto incr = [](int x) { return x+1;};
  
  std::cout << "n_times(dbl, 10, 1):" << n_times(dbl, 10, 1) << std::endl ;
  std::cout << "n_times(incr, 10, 2):" << n_times(incr, 10, 1) << std::endl ;
  auto dbl_ntimes = [=](int n, int x) { return n_times(dbl, n, x); };

  std::cout << "dbl_ntimes(10, 3):" << dbl_ntimes(10, 3) << std::endl ;
  return 0;
}

