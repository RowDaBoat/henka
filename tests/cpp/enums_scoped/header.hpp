enum class Color {
    Red = 0,
    Green = 1,
    Blue = 2
};

enum class SmallFlag : unsigned char {
    None = 0,
    A = 1,
    B = 2,
    C = 4
};

enum class Signed : int {
    Neg = -10,
    Zero = 0,
    Pos = 10
};

enum class Sparse : int {
    A = 1,
    B = 10,
    C = 100
};

Color get_color();
void set_color(Color c);

struct HasColor {
    Color color;
    int value;
};
