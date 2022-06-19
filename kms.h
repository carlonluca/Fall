#ifndef KMS_H
#define KMS_H

#include <QQuickItem>

class Kms : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
public:
    Kms(QQuickItem* parent = nullptr) : QQuickItem(parent) {}

public slots:
    void play();
    void stop();
};

#endif // KMS_H
