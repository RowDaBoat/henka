/* builtin aliases */
typedef int Int32;
typedef float Float32;
typedef unsigned int UInt32;
typedef char Byte;

/* enum */
typedef enum {
    Low,
    Medium,
    High
} Priority;

typedef enum Named {
    On,
    Off
} Named;

/* pointers */
typedef int *IntPtr;
typedef const char *String;
typedef void *Handle;

/* function pointers */
typedef int (*Comparator)(int, int);
typedef void (*Callback)(void);

/* CDTs */
typedef struct {
    int x;
    int y;
} Point;

typedef struct Vec3 {
    float x;
    float y;
    float z;
} Vec3;

typedef union {
    int i;
    float f;
} Number;

typedef union Tagged {
    int i;
    float f;
    char c;
} Tagged;

/* ADTs */
typedef struct Node {
    int value;
    struct Node *next;
} *List;

typedef struct TreeNode {
    int value;
    struct TreeNode *left;
    struct TreeNode *right;
} *Tree;
