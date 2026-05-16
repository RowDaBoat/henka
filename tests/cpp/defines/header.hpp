#undef hello
#ifdef hello
void should_not_be_declared(void);
#endif

void should_be_declared(void);
