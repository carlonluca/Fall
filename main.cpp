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

#include "lqtutils/lqtutils_ui.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QSize __size = QGuiApplication::primaryScreen()->size()*0.5*0.5;
    QPoint pos(__size.width(), __size.height());

    QQuickView view;
    LQTFrameRateMonitor* monitor = new LQTFrameRateMonitor(&view);
    view.engine()->rootContext()->setContextProperty("fpsmonitor", monitor);
    view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    view.show();
    view.resize(QGuiApplication::primaryScreen()->size()/2);
    view.setPosition(pos);

    return app.exec();
}
