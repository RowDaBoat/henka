#include "header.h"
#include <string.h>

void no_return(void) {}

int return_int(void) { return 42; }
float return_float(void) { return 3.14f; }

int add(int a, int b) { return a + b; }
float addf(float a, float b) { return a + b; }

int string_length(const char *s) { return (int)strlen(s); }
const char *greeting(void) { return "hello"; }

struct Point make_point(int x, int y) {
    struct Point p = {x, y};
    return p;
}

int point_sum(struct Point p) { return p.x + p.y; }

struct Point point_add(struct Point a, struct Point b) {
    struct Point p = {a.x + b.x, a.y + b.y};
    return p;
}

int apply(int (*fn)(int), int value) { return fn(value); }

void foreach(int *arr, int len, void (*fn)(int)) {
    for (int i = 0; i < len; i++) fn(arr[i]);
}
