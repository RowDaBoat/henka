void take_void_ptr(void * p);
void take_int_ptr(int * p);
void take_float_ptr(float * p);
void take_string(char * s);
void take_const_string(const char * s);
void take_ptr_to_ptr(int ** pp);

struct Node {
    int value;
    struct Node * next;
};

int * return_int_ptr(void);
const char * return_string(void);
