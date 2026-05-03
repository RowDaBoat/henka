// Types used before they're defined (dearimgui pattern)

template <typename T>
struct Vector;

typedef unsigned short DrawIdx;
typedef void (*DrawCallback)(void);

struct DrawChannel {
    Vector<DrawCallback> cmds;
    Vector<DrawIdx> indices;
};

struct DrawCmd {
    unsigned int count;
    DrawCallback callback;
    DrawIdx offset;
};

struct DrawList {
    Vector<DrawCmd> commands;
    Vector<DrawChannel> channels;
    Vector<DrawIdx> indices;
};

// Vector defined AFTER it's used
template <typename T>
struct Vector {
    T *data;
    int size;
    int capacity;
};

void render(DrawList *list);
