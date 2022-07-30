#ifndef KMSLAYER_H
#define KMSLAYER_H

#include <QQuickItem>

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
#include <drm_fourcc.h>
#include <sys/time.h>
#include <getopt.h>

class KMSLayer : public QQuickItem
{
    Q_OBJECT
public:
    KMSLayer();

public slots:
    void play();
    void stop();
};

#endif // KMSLAYER_H
