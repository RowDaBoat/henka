struct Node {
    int value;
};

inline void acquire(Node *&outNode) {
    static Node node{0};
    outNode = &node;
}
