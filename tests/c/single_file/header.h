#ifdef __cplusplus
extern "C" {
#endif

void regular_c_function(void);

#ifdef __cplusplus
}
#endif

#undef hello
#ifdef hello
void should_not_be_defined(void);
#endif

void should_be_defined(void);
