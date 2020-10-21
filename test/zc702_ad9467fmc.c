
#define _DEFAULT_SOURCE
#define _XOPEN_SOURCE

#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <termios.h>
#include <unistd.h>

#define MM2S_CONTROL_REGISTER 0x00
#define MM2S_STATUS_REGISTER 0x04
#define MM2S_START_ADDRESS 0x18
#define MM2S_LENGTH 0x28

#define S2MM_CONTROL_REGISTER 0x30
#define S2MM_STATUS_REGISTER 0x34
#define S2MM_DESTINATION_ADDRESS 0x48
#define S2MM_LENGTH 0x58

unsigned int dma_get(unsigned int *dma_virtual_address, int offset);
unsigned int dma_s2mm_status(unsigned int *dma_virtual_address);
unsigned int dma_set(unsigned int *dma_virtual_address, int offset, unsigned int value);
void dma_mm2s_status(unsigned int *dma_virtual_address);
void dma_mm2s_sync(unsigned int *dma_virtual_address);
void dma_s2mm_sync(unsigned int *dma_virtual_address);
void memdump(void *addr, size_t size);

unsigned int dma_set(unsigned int *dma_virtual_address, int offset, unsigned int value) {
    dma_virtual_address[offset >> 2] = value;
}

unsigned int dma_get(unsigned int *dma_virtual_address, int offset) {
    return dma_virtual_address[offset >> 2];
}

void dma_mm2s_sync(unsigned int *dma_virtual_address) {
    unsigned int mm2s_status = dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);
    while (!(mm2s_status & (1 << 12)) && !(mm2s_status & (1 << 1))) {
        dma_s2mm_status(dma_virtual_address);
        dma_mm2s_status(dma_virtual_address);

        mm2s_status = dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);
    }
}

void dma_s2mm_sync(unsigned int *dma_virtual_address) {
    unsigned int s2mm_status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);
    while (!(s2mm_status & (1 << 12)) && !(s2mm_status & (1 << 1))) {
        s2mm_status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);
    }
}

unsigned int dma_s2mm_status(unsigned int *dma_virtual_address) {
    unsigned int control = dma_get(dma_virtual_address, S2MM_CONTROL_REGISTER);
    printf("Stream to memory-mapped control (0x%08x@0x%02x)\n", control, S2MM_CONTROL_REGISTER);
    unsigned int status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);
    printf("Stream to memory-mapped status (0x%08x@0x%02x):", status, S2MM_STATUS_REGISTER);
    if (status & 0x00000001)
        printf(" halted");
    else
        printf(" running");
    if (status & 0x00000002)
        printf(" idle");
    if (status & 0x00000008)
        printf(" SGIncld");
    if (status & 0x00000010)
        printf(" DMAIntErr");
    if (status & 0x00000020)
        printf(" DMASlvErr");
    if (status & 0x00000040)
        printf(" DMADecErr");
    if (status & 0x00000100)
        printf(" SGIntErr");
    if (status & 0x00000200)
        printf(" SGSlvErr");
    if (status & 0x00000400)
        printf(" SGDecErr");
    if (status & 0x00001000)
        printf(" IOC_Irq");
    if (status & 0x00002000)
        printf(" Dly_Irq");
    if (status & 0x00004000)
        printf(" Err_Irq");
    printf("\n");
    return status;
}

void dma_mm2s_status(unsigned int *dma_virtual_address) {
    unsigned int status = dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);
    printf("Memory-mapped to stream status (0x%08x@0x%02x):", status, MM2S_STATUS_REGISTER);
    if (status & 0x00000001)
        printf(" halted");
    else
        printf(" running");
    if (status & 0x00000002)
        printf(" idle");
    if (status & 0x00000008)
        printf(" SGIncld");
    if (status & 0x00000010)
        printf(" DMAIntErr");
    if (status & 0x00000020)
        printf(" DMASlvErr");
    if (status & 0x00000040)
        printf(" DMADecErr");
    if (status & 0x00000100)
        printf(" SGIntErr");
    if (status & 0x00000200)
        printf(" SGSlvErr");
    if (status & 0x00000400)
        printf(" SGDecErr");
    if (status & 0x00001000)
        printf(" IOC_Irq");
    if (status & 0x00002000)
        printf(" Dly_Irq");
    if (status & 0x00004000)
        printf(" Err_Irq");
    printf("\n");
}

void memdump(void *addr, size_t size) {
    u_int16_t *p = addr;
    size_t i, n;
    n = size / sizeof(u_int16_t);

    for (i = 0; i < n; i++) {
        if (i % 32 == 0) {
            printf("\n");
        }
        printf("%04x ", p[i]);
    }
    printf("\n");
}

// void memstdout(void *addr, size_t size) {
//     u_int16_t *p = addr;
//     size_t i, n;
//     n = size / sizeof(u_int16_t);
// }

int main(int argc, char **argv) {
    int n = 0;
    size_t dma_axi_size = 0x10000;
    size_t rs = 8192;
    size_t bs = rs;
    void *dst = (void *)0x0f000000;
    void *va_axi = NULL;
    void *va_dst = NULL;

    int dh = open("/dev/mem", O_RDWR | O_SYNC);
    if (dh == -1) {
        perror("open mem");
        exit(EXIT_FAILURE);
    }

    va_axi = mmap(NULL, dma_axi_size, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x40400000);
    if (va_axi == MAP_FAILED) {
        perror("mmap va_axi");
        exit(EXIT_FAILURE);
    }
    va_dst = mmap(NULL, bs, PROT_READ | PROT_WRITE, MAP_SHARED, dh, (off_t)dst);
    if (va_dst == MAP_FAILED) {
        perror("mmap va_dst");
        exit(EXIT_FAILURE);
    }

    memset(va_dst, 0, bs);
    printf("dst memory block: ");
    memdump(va_dst, 32);
    freopen(NULL, "wb", stdout);

    while (1) {
        dma_set(va_axi, S2MM_CONTROL_REGISTER, 4);
        dma_set(va_axi, S2MM_CONTROL_REGISTER, 0);
        dma_set(va_axi, S2MM_CONTROL_REGISTER, 0x0001);
        dma_set(va_axi, S2MM_DESTINATION_ADDRESS, (unsigned int)dst);
        dma_set(va_axi, S2MM_LENGTH, rs);
        dma_s2mm_sync(va_axi);
        if (1) {
            char *ptr = va_dst;
            for (n = 0; n < rs; n++) {
                ptr[n] += 127;
            }
            fwrite(va_dst, 1, rs, stdout);
        } else {
            fwrite(va_dst, 1, rs, stdout);
            usleep(10000);
        }
    }

    // memdump(va_dst, rs);

    n = munmap(va_axi, dma_axi_size);
    if (n != 0) {
        perror("unmap va_axi");
        exit(EXIT_FAILURE);
    }

    n = munmap(va_dst, bs);
    if (n != 0) {
        perror("unmap va_dst");
        exit(EXIT_FAILURE);
    }

    n = close(dh);
    if (n != 0) {
        perror("close dh");
        exit(EXIT_FAILURE);
    }

    return EXIT_SUCCESS;
}
