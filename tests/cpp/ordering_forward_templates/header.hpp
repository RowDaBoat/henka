template <typename T>
struct Vector;

struct Channel {
    Vector<int> *items;
};

template <typename T>
struct Vector {
    T *data;
    int size;
};
