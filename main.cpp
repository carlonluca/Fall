/**
 * GPLv3 license
 *
 * Copyright (c) 2021 Luca Carlon
 *
 * This file is part of Fall
 *
 * Fall is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Fall is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Fall.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQuickView>
#include <QElapsedTimer>
#include <QDateTime>
#include <QQmlContext>
#include <QScreen>
#include <QFontDatabase>
#include <QCommandLineParser>
#include <QDirIterator>

#ifdef BUILD_PIAV
#include <QtAVPlayer/qavplayer.h>
#include <QtAVPlayer/qavvideoframe.h>
#include <QtAVPlayer/qavaudioframe.h>
#include <QtAVPlayer/pavrender.h>
#endif

#include "lqtutils/lqtutils_ui.h"
#include "lqtutils/lqtutils_string.h"

int main(int argc, char** argv)
{
    qputenv("QSG_INFO", "1");

    QGuiApplication app(argc, argv);
    QCommandLineParser parser;
    parser.setApplicationDescription("Fall");
    parser.addHelpOption();

    QCommandLineOption chooseBkgOption(
                QSL("b"),
                QSL("Background type: image,qtvideo,potvl,piav"),
                QSL("type"),
                QSL("image"));
    parser.addOption(chooseBkgOption);
    QCommandLineOption mediaPathOption(
                QSL("p"),
                QSL("Media path"),
                QSL("path"),
                QString());
    parser.addOption(mediaPathOption);
    parser.process(app);

    if (parser.value(chooseBkgOption) == QSL("qtvideo") && parser.value(mediaPathOption).isEmpty())
        qFatal("Set video path please");

    QSize __size = QGuiApplication::primaryScreen()->size()*0.5*0.5;
    QPoint pos(__size.width(), __size.height());
    QFont fixedFont = QFontDatabase::systemFont(QFontDatabase::FixedFont);

    QQuickView view;
    LQTFrameRateMonitor* monitor = new LQTFrameRateMonitor(&view);
    view.engine()->rootContext()->setContextProperty("fpsmonitor", monitor);
    view.engine()->rootContext()->setContextProperty("qt_major", QT_VERSION_MAJOR);
    view.engine()->rootContext()->setContextProperty("monospaceFont", fixedFont);
    view.engine()->rootContext()->setContextProperty("btype", parser.value(chooseBkgOption));
    view.engine()->rootContext()->setContextProperty("mpath", parser.value(mediaPathOption));
    view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
#if QT_VERSION_MAJOR <= 5
    view.setClearBeforeRendering(true);
#endif
    view.setColor(Qt::transparent);
    view.show();
    view.resize(QGuiApplication::primaryScreen()->size()/2);
    view.setPosition(pos);

#ifdef BUILD_PIAV
    QAVPlayer p;
    PAVRender r;
    r.setRenderRect(QRect(50, 50, 500, 500));
    QObject::connect(&p, &QAVPlayer::audioFrame, [&](const QAVAudioFrame &frame) { qDebug() << "audioFrame" << bool(frame); });
    QObject::connect(&p, &QAVPlayer::videoFrame, [&](const QAVVideoFrame &frame) {
        QSharedPointer<QAVVideoFrame> f(new QAVVideoFrame(frame));
        r.present(f);
    });
    p.setSource(parser.value(mediaPathOption));
    p.play();

    QObject::connect(&p, &QAVPlayer::stateChanged, [&](auto s) { qDebug() << "stateChanged" << s << p.mediaStatus(); });
    QObject::connect(&p, &QAVPlayer::mediaStatusChanged, [&](auto s){ qDebug() << "mediaStatusChanged"<< s << p.state(); });
    QObject::connect(&p, &QAVPlayer::durationChanged, [&](auto d) { qDebug() << "durationChanged" << d; });
#endif

    return app.exec();
}
