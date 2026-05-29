struct Vec3 {
    float x;
    float y;
    float z;
};

struct Num {
    int value;
};
Num  operator+ (const Num& a, const Num& b);
Num  operator- (const Num& a, const Num& b);
Num  operator* (const Num& a, const Num& b);
Num  operator/ (const Num& a, const Num& b);
bool operator==(const Num& a, const Num& b);
bool operator!=(const Num& a, const Num& b);
bool operator< (const Num& a, const Num& b);
bool operator>=(const Num& a, const Num& b);

struct Flags {
    int bits;
    Flags& operator|= (const Flags& o);
    Flags& operator&= (const Flags& o);
    Flags& operator^= (const Flags& o);
    Flags& operator<<=(int n);
    Flags& operator>>=(int n);
    Flags& operator%= (int n);
};

struct Callable {
    int operator()(int x) const;
};

struct Buffer {
    int data[8];
    int& operator[](int i);
};

struct Point {
    float x;
    float y;
    float z;
    operator Vec3() const;
};

void* operator new[](unsigned long size);
void  operator delete[](void* ptr) noexcept;

double operator"" _r(long double value);
