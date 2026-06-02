namespace JPH {

class Float3 {
public:
    float x, y, z;
};

class Container {
public:
    using size_type = unsigned int;
    size_type size() const;
    void resize(size_type count);
};

class Color {
public:
    enum Type { Red, Green, Blue };
    operator Type() const;
};

template <typename T>
class Array {
public:
    T data;
};

template <typename T>
struct Traits {
    typedef Array<T> Storage;
};

class Body {
public:
    Traits<Float3>::Storage storage;
    Array<Float3> points;
};

}
