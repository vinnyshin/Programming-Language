#include <memory>

template <typename T>

#include <stdio.h>
class box {
    std::unique_ptr<T> _impl;
public:
    box(T &&obj) : _impl(new T(std::move(obj))) {} // R-value 생성자, obj의 소유권 이동 -> 0 copy
    box(const T &obj) : _impl(new T(obj)) {} // Reference를 이용하여 copy해서 생성 -> 1 copy
    box(const box & other) : box(*other._impl) {} // box(const T &obj)를 불러서 복사 생성 -> 1 copy
    box &operator=(const box &other) { // copy operator
        *_impl = *other._impl;
        return *this;
    }
    box(box &&other) : box(std::move(*other._impl)) {} // R-value로 box를 받을 시 box(T &&obj)를 불러서 생성 -> 0 copy
    box &operator=(box &&other) { // R-value 0-copy operator
        *_impl = std::move(*other._impl);
        return *this;
    }
    ~box() = default;
    T &operator*() { return *_impl; }
    const T &operator*() const { return *_impl; }
    T *operator->() { return _impl.get(); }
    const T *operator->() const { return _impl.get(); }
};