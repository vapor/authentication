#include <lifetimebound.h>
#include <ptrcheck.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#if defined(_WIN32)
typedef unsigned char uint8_t;
typedef uint8_t u_int8_t;
typedef unsigned short uint16_t;
typedef uint16_t u_int16_t;
typedef unsigned uint32_t;
typedef uint32_t u_int32_t;
typedef unsigned long long uint64_t;
typedef uint64_t u_int64_t;
#define snprintf _snprintf
#define __attribute__(unused)
#else
#include <stdint.h>
#endif

#define explicit_bzero(s, n) memset(s, 0, n)
#define DEF_WEAK(f)

/* This implementation is adaptable to current computing power.
 * You can have up to 2^31 rounds which should be enough for some
 * time to come.
 */

#define BCRYPT_VERSION '2'
#define BCRYPT_MAXSALT 16     /* Precomputation is just so nice */
#define BCRYPT_WORDS 6        /* Ciphertext words */
#define BCRYPT_MINLOGROUNDS 4 /* we have log2(rounds) in salt */

#define BCRYPT_SALTSPACE (7 + (BCRYPT_MAXSALT * 4 + 2) / 3 + 1)
#define BCRYPT_HASHSPACE 61

int vapor_auth_bcrypt_hashpass(const char *_Nonnull __counted_by(keysize) key __noescape,
                               const char *_Nonnull __counted_by(saltsize) salt __noescape,
                               char *_Nonnull __counted_by(encryptedlen)
                                   encrypted __noescape,
                               size_t keysize,
                               size_t saltsize,
                               size_t encryptedlen);
int vapor_auth_encode_base64(char *_Nonnull __counted_by(bufferlen) b64buffer __noescape,
                             const u_int8_t *_Nonnull __counted_by(len)
                                 data __noescape,
                             size_t bufferlen,
                             size_t len);
