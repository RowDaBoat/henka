// Scoped enum (enum class) — values are namespaced in C++
enum class Color {
    Red = 0,
    Green = 1,
    Blue = 2
};

// Scoped enum with explicit backing type
enum class SmallFlag : unsigned char {
    None = 0,
    A = 1,
    B = 2,
    C = 4
};

// Scoped enum with int backing (default)
enum class Status : int {
    Ok = 0,
    Error = 1,
    Pending = 2
};

// Scoped enum with large values
enum class BigEnum : int {
    Small = 0,
    Large = 1000000,
    Max = 0x7FFFFFFF
};

// Scoped enum with negative values
enum class SignedEnum : int {
    Neg = -10,
    Zero = 0,
    Pos = 10
};

// Unscoped C++ enum (same as C)
enum Legacy {
    LegacyA = 0,
    LegacyB = 1,
    LegacyC = 2
};

// Scoped enum used in function signatures
Color get_color();
void set_color(Color c);

// Scoped enum used in struct fields
struct HasEnums {
    Color color;
    Status status;
    SmallFlag flags;
    int value;
};

// Scoped enum with single value
enum class Singleton {
    Only = 42
};

// Scoped enum with gaps
enum class Sparse : int {
    A = 1,
    B = 10,
    C = 100
};
