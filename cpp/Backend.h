#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QUrl>

#include <QUrlQuery>
#include <QJsonObject>
#include <QJsonDocument>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

    bool isUrlValid(const QString &urlString) const;

public slots:
    void sendRequest(QString urlString, QString data);

signals:
    void sendingFailed(QString reason);

private:

};

#endif // BACKEND_H
