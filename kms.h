#ifndef KMS_H
#define KMS_H

#include <QQuickItem>
#include <QDebug>
#include <QThread>

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

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavutil/hwcontext_drm.h>
}

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

class Kms
{
public:
    Kms(const QString filename, int id, QQuickItem* parent = nullptr) : m_filename(filename), m_id(id) {}

    int drm_dmabuf_set_plane(struct drm_buffer *buf, uint32_t width,
			 uint32_t height, int fullscreen);
    int drm_dmabuf_import(struct drm_buffer *buf, unsigned int width,
		      unsigned int height);
    int drm_dmabuf_addfb(struct drm_buffer *buf, uint32_t width, uint32_t height);
    int drm_init(unsigned int fourcc, const char *device);
    int display(struct drm_buffer *drm_buf, int width, int height);
    void decode_and_display(AVCodecContext *dec_ctx, AVFrame *frame,
			AVPacket *pkt, const char *device);

	int id() const { return m_id; }

public:
    void play();
    void stop();

private:
    QString m_filename;
    static drm_dev *pdev;
    unsigned int drm_format = 0;
	int m_id;
};

#endif // KMS_H
