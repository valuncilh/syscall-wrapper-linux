# Stage 1: Build kernel with patched sys_open
FROM archlinux:base-devel AS builder

RUN pacman -Syu --noconfirm \
    gcc make bc flex bison openssl cpio kmod \
    xz wget python git qemu busybox cpio gzip \
    && pacman -Scc --noconfirm

WORKDIR /build

COPY patches/0001-add-open-wrapper.patch .
COPY src/kernel-config .config
COPY fix_stddef.py fix_types.py ./

RUN wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.235.tar.xz \
    && tar xf linux-5.10.235.tar.xz \
    && ln -s linux-5.10.235 linux-5.10.y

RUN python3 fix_stddef.py
RUN python3 fix_types.py

RUN cd linux-5.10.y && patch -p1 < ../0001-add-open-wrapper.patch

RUN cd linux-5.10.y \
    && cp ../.config . \
    && make olddefconfig \
    && make -j$(nproc) bzImage modules

RUN wget https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.1-x86_64.tar.gz \
    && mkdir -p /initramfs \
    && tar xzf alpine-minirootfs-3.19.1-x86_64.tar.gz -C /initramfs \
    && printf '#!/bin/sh\nmount -t proc none /proc\nmount -t sysfs none /sys\nmount -t devtmpfs none /dev\necho === SMOKE TEST ===\nuname -r\nexec /bin/sh\n' > /initramfs/init \
    && chmod +x /initramfs/init \
    && cd /initramfs \
    && find . | cpio -o -H newc 2>/dev/null | gzip > /build/initramfs.cpio.gz

# Stage 2: Runtime with QEMU
FROM archlinux:base

RUN pacman -Syu --noconfirm qemu && pacman -Scc --noconfirm

WORKDIR /app

COPY --from=builder /build/linux-5.10.y/arch/x86/boot/bzImage ./bzImage
COPY --from=builder /build/initramfs.cpio.gz ./initramfs.cpio.gz
COPY docs/diagrams/*.png ./docs/
COPY README.md .

RUN printf '#!/bin/bash\necho "Starting QEMU with patched Linux 5.10.235..."\necho "After boot, run: dmesg | grep MY_OPEN"\nqemu-system-x86_64 -enable-kvm -kernel /app/bzImage -initrd /app/initramfs.cpio.gz -append "console=ttyS0 init=/init" -nographic\n' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
