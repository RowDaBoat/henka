template <typename First, typename... Values>
inline int combineArgs(const First &first, Values... values) {
    return (int)first + (int)sizeof...(values);
}

template <typename... Values>
inline int countArgs(Values... values) {
    return (int)sizeof...(values);
}
