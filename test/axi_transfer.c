
#define _DEFAULT_SOURCE
#define _XOPEN_SOURCE

#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <termios.h>
#include <unistd.h>

#define AXI_SPACE 0x10000
#define AXI_ADDRESS 0x43c00000

int main(int argc, char **argv) {
    int n = 0;
    uint32_t *va_axi = NULL;
    uint32_t offset = 0;
    uint32_t value = 0;

    if (argc < 2) {
        printf("usage: regnum [value]\n");
        exit(EXIT_FAILURE);
    } else {
        errno = 0;
        offset = strtoul(argv[1], NULL, 16);
        if (errno != 0) {
            perror("offset");
            exit(EXIT_FAILURE);
        }
        if (argc > 2) {
            errno = 0;
            value = strtoul(argv[2], NULL, 16);
            if (errno != 0) {
                perror("value");
                exit(EXIT_FAILURE);
            }
        }
    }

    int dh = open("/dev/mem", O_RDWR | O_SYNC);
    if (dh == -1) {
        perror("open mem");
        exit(EXIT_FAILURE);
    }

    va_axi = mmap(NULL, AXI_SPACE, PROT_READ | PROT_WRITE, MAP_SHARED, dh, AXI_ADDRESS);
    if (va_axi == MAP_FAILED) {
        perror("mmap va_axi");
        exit(EXIT_FAILURE);
    }
    if (argc > 2) {
        va_axi[offset] = value;
    }
    printf("reg[%02x] = %08x\n", offset, va_axi[offset]);

    n = munmap(va_axi, AXI_SPACE);
    if (n != 0) {
        perror("unmap va_axi");
        exit(EXIT_FAILURE);
    }

    n = close(dh);
    if (n != 0) {
        perror("close dh");
        exit(EXIT_FAILURE);
    }

    return EXIT_SUCCESS;
}
