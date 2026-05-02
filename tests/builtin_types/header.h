#include <stdint.h>

_Bool return_bool(void);
char return_char(void);
short return_short(void);
int return_int(void);
long return_long(void);
float return_float(void);
double return_double(void);
unsigned int return_uint(void);
void * return_void_ptr(void);
char * return_string(void);

void take_bool(_Bool b);
void take_char(char c);
void take_short(short s);
void take_int(int i);
void take_long(long l);
void take_float(float f);
void take_double(double d);
void take_uint(unsigned int u);
void take_pointer(void *p);
void take_string(char *s);

int8_t return_int8(void);
int16_t return_int16(void);
int32_t return_int32(void);
int64_t return_int64(void);
uint8_t return_uint8(void);
uint16_t return_uint16(void);
uint32_t return_uint32(void);
uint64_t return_uint64(void);
size_t return_size(void);

void take_int8(int8_t v);
void take_int16(int16_t v);
void take_int32(int32_t v);
void take_int64(int64_t v);
void take_uint8(uint8_t v);
void take_uint16(uint16_t v);
void take_uint32(uint32_t v);
void take_uint64(uint64_t v);
void take_size(size_t v);
