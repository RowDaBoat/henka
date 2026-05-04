template <typename T>
struct Ref {
    T *data;
    int count;
};

template <typename K, typename V>
struct Map {
    K *keys;
    V *values;
    int size;
};

template <typename T>
struct Vector {
    T *data;
    int size;
    int capacity;
};

// Simple instantiation
void use_ref(Ref<int> *r);

// Multi-arg instantiation
void use_map(Map<int, float> *m);

// Nested instantiation
void use_nested(Vector<Ref<int>> *v);

// Double nested
void use_deep(Vector<Map<int, Ref<float>>> *v);

// Type alias of template
typedef Vector<float> FloatVec;
typedef Map<int, Ref<float>> ComplexMap;

// Template as struct field
struct Container {
    Vector<int> items;
    Map<int, float> lookup;
    Vector<Ref<int>> nested;
};
