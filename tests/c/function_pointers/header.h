void apply_callback(void (*cb)(int), int value);
int apply_binary(int (*op)(int, int), int a, int b);

struct Handler {
    void (*on_event)(int);
    int (*combine)(int, int);
};
