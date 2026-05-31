struct Node {
    int value;
};

// `Node *&` — a non-const lvalue reference whose target is itself a pointer
// (an out-parameter that hands back a pointer). Header-only so the test can run.
// Returns a pointer to a single shared node, so writes through one acquired
// pointer are visible through the next.
inline void acquire(Node *&outNode) {
    static Node node{0};
    outNode = &node;
}
