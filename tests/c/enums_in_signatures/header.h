enum Status {
    StatusOk    = 0,
    StatusError = 1
};

struct HasEnum {
    enum Status status;
    int value;
};

enum Status get_status(void);
void set_status(enum Status s);
