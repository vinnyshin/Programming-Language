#include <utility>
#include <iostream>
#include <tuple>
#include "List.h"
#include <optional>


using std::optional;
using std::string;

int main() {
  struct student {
    string name;
    optional<int> id;
  };

  student james = {"James Dean", 42};
  student jane = {"Jane Eyre", 31};
  auto students = {james, jane};

  for (auto s: students) {
    std::cout << "student:" << s.name << std::endl;
  }
  return 0;
}
