#include "kmslayer.h"

static int drm_open(const char *path)
{
    int fd, flags;
    uint64_t has_dumb;
    int ret;

    fd = open(path, O_RDWR);
    if (fd < 0) {
        qFatal("cannot open \"%s\"\n", path);
        return -1;
    }

    /* set FD_CLOEXEC flag */
    if ((flags = fcntl(fd, F_GETFD)) < 0 ||
         fcntl(fd, F_SETFD, flags | FD_CLOEXEC) < 0) {
        qFatal("fcntl FD_CLOEXEC failed\n");
        goto err;
    }

    /* check capability */
    ret = drmGetCap(fd, DRM_CAP_DUMB_BUFFER, &has_dumb);
    if (ret < 0 || has_dumb == 0) {
        qFatal("drmGetCap DRM_CAP_DUMB_BUFFER failed or doesn't have dumb "
            "buffer\n");
        goto err;
    }

    return fd;
err:
    close(fd);
    return -1;
}

KMSLayer::KMSLayer()
{

}

void KMSLayer::play()
{
}

void KMSLayer::stop()
{

}
