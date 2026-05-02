struct Point {
    int x;
    int y;
};

/* void return */
void no_return(void);

/* builtin returns */
int return_int(void);
float return_float(void);

/* builtin params */
int add(int a, int b);
float addf(float a, float b);

/* string params and return */
int string_length(const char *s);
const char *greeting(void);

/* struct param and return */
struct Point make_point(int x, int y);
int point_sum(struct Point p);
struct Point point_add(struct Point a, struct Point b);

/* function pointer callback */
int apply(int (*fn)(int), int value);
void foreach(int *arr, int len, void (*fn)(int));
