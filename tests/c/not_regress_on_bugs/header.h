// long double
long double precise_value(void);

// IncompleteArray as parameter
struct FlexArray {
    int count;
    int data[];
};

// volatile/restrict qualifiers
void process(volatile int *buf, int * restrict out);
