// Basic sequential enum (implicit values 0,1,2)
enum Direction {
    North,
    East,
    South,
    West
};

// Explicit values, sequential
enum ExplicitSeq {
    ExplicitA = 0,
    ExplicitB = 1,
    ExplicitC = 2
};

// Explicit values with holes (non-ordinal in Nim)
enum Holed {
    HoledA = 2,
    HoledB = 4,
    HoledC = 89
};

// Duplicate values (aliases)
enum Dupes {
    DupeFirst  = 0,
    DupeSecond = 1,
    DupeAlias0 = 0,
    DupeAlias1 = 1
};

// Negative values
enum Signed {
    SignedNeg  = -1,
    SignedZero = 0,
    SignedPos  = 1
};

// Bit flags (powers of 2)
enum BitFlag {
    FlagA = 1,
    FlagB = 2,
    FlagC = 4,
    FlagD = 8,
    FlagAll = 15
};

// typedef enum (most common C pattern)
typedef enum {
    OptionNone = 0,
    OptionSome = 1,
    OptionAll  = 2
} OptionEnum;

// Anonymous enum (constants only, no type name)
enum {
    ANON_CONST_A = 42,
    ANON_CONST_B = 100
};

// Large values (int32 max, sentinel pattern)
enum Sentinel {
    SentinelA = 0,
    SentinelB = 1,
    SentinelForce32 = 0x7FFFFFFF
};

// Enum used in function signatures
enum Status {
    StatusOk    = 0,
    StatusError = 1
};
enum Status get_status(void);
void set_status(enum Status s);

// Enum used in struct fields
struct HasEnum {
    enum Direction dir;
    enum Status status;
    int value;
};

// Single value enum
enum Single {
    OnlyOne = 0
};

// Enum starting from non-zero
enum Offset {
    OffsetA = 10,
    OffsetB = 11,
    OffsetC = 12
};

// Mixed implicit and explicit
enum Mixed {
    MixedA,
    MixedB = 5,
    MixedC,
    MixedD = 20,
    MixedE
};
