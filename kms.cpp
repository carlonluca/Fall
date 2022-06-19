#include <QDebug>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
#include <libdrm/drm_fourcc.h>
#include <sys/time.h>
#include <getopt.h>

#include "kms.h"

#define ALIGN(x, a)		((x) + (a - 1)) & (~(a - 1))
#define DRM_ALIGN(val, align)	((val + (align - 1)) & ~(align - 1))

#define INBUF_SIZE 4096

struct drm_buffer {
	unsigned int fourcc;
	unsigned int bo_handle;
	unsigned int fb_handle;
	int dbuf_fd;
	void *mmap_buf;
	uint32_t pitches[4];
	uint32_t offsets[4];
	uint32_t bo_handles[4];
};

struct drm_dev {
	int fd;
	uint32_t conn_id, enc_id, crtc_id, fb_id, plane_id, crtc_idx;
	uint32_t width, height;
	uint32_t pitch, size, handle;
	drmModeModeInfo mode;
	drmModeCrtc *saved_crtc;
	struct drm_dev *next;
};

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

static struct drm_dev *drm_find_dev(int fd)
{
	int i;
	struct drm_dev *dev = NULL, *dev_head = NULL;
	drmModeRes *res;
	drmModeConnector *conn;
	drmModeEncoder *enc;
	drmModeCrtc *crtc = NULL;

	if ((res = drmModeGetResources(fd)) == NULL) {
		qFatal("drmModeGetResources() failed");
		return NULL;
	}

	if (res->count_crtcs <= 0) {
		qFatal("no Crtcs");
		goto free_res;
	}

	/* find all available connectors */
	for (i = 0; i < res->count_connectors; i++) {
		conn = drmModeGetConnector(fd, res->connectors[i]);

		if (conn) {
			if (conn->connection == DRM_MODE_CONNECTED) {
				qDebug("drm: connector: connected");
			} else if (conn->connection == DRM_MODE_DISCONNECTED) {
				qDebug("drm: connector: disconnected");
			} else if (conn->connection == DRM_MODE_UNKNOWNCONNECTION) {
				qDebug("drm: connector: unknownconnection");
			} else {
				qDebug("drm: connector: unknown");
			}
		}

		if (conn != NULL && conn->connection == DRM_MODE_CONNECTED
		    && conn->count_modes > 0) {
			dev = (struct drm_dev *) malloc(sizeof(struct drm_dev));
			memset(dev, 0, sizeof(struct drm_dev));

			dev->conn_id = conn->connector_id;
			dev->enc_id = conn->encoder_id;
			dev->next = NULL;

			memcpy(&dev->mode, &conn->modes[0], sizeof(drmModeModeInfo));
			dev->width = conn->modes[0].hdisplay;
			dev->height = conn->modes[0].vdisplay;

			if (conn->encoder_id) {
				enc = drmModeGetEncoder(fd, conn->encoder_id);
				if (!enc) {
					qFatal("drmModeGetEncoder() faild");
					goto free_res;
				}
				if (enc->crtc_id) {
					crtc = drmModeGetCrtc(fd, enc->crtc_id);
					if (crtc)
						dev->crtc_id = enc->crtc_id;
				}
			}

			drmModeFreeEncoder(enc);

			dev->saved_crtc = NULL;

			/* create dev list */
			dev->next = dev_head;
			dev_head = dev;
		}
		drmModeFreeConnector(conn);
	}

	dev->crtc_idx = -1;

	for (i = 0; i < res->count_crtcs; ++i) {
		if (dev->crtc_id == res->crtcs[i]) {
			dev->crtc_idx = i;
			break;
		}
	}

	if (dev->crtc_idx == -1)
		qFatal( "drm: CRTC %u not found\n");

free_res:
	drmModeFreeResources(res);

	return dev_head;
}

void Kms::play()
{
    qDebug() << "PLAY";

    const char* driPath = "/dev/dri/card0";
    int fd = drm_open(driPath);
    if (!fd)
        qFatal("Cannot open dri");
    
    struct drm_dev *dev_head = drm_find_dev(fd);
    if (!dev_head)
        qFatal("available drm devices not found\n");
    
    qDebug("available connector(s)");

    for (drm_dev* dev = dev_head; dev != NULL; dev = dev->next) {
		qDebug("connector id:%d", dev->conn_id);
		qDebug("\tencoder id:%d crtc id:%d fb id:%d", dev->enc_id,
		    dev->crtc_id, dev->fb_id);
		qDebug("\twidth:%d height:%d", dev->width, dev->height);
	}
}

void Kms::stop()
{
    qDebug() << "STOP";
}
