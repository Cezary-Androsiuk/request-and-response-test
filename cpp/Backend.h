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
    void sendRequest(QString urlString, QString data, QString method);

private slots:
    void handleResponse();

signals:
    void requestSended();
    void sendingFailed(QString reason);

    void responseHandled(QString data, int status);
    void responseErrorOccur(QString data, int status, QString reason);

private:
    QNetworkAccessManager * const m_networkManager;
};

#endif // BACKEND_H
