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
    void abortRequest();

private slots:
    void handleResponse();

signals:
    void requestSended();
    void sendingFailed(QString reason);

    void responseHandled();
    void responseErrorOccur(QString reason);

    void abortedRequest();

public:
    Q_INVOKABLE bool getLastDataIsHtml() const;
    Q_INVOKABLE int getLastStatusCode() const;
    Q_INVOKABLE QString getLastData() const;

private:
    QNetworkAccessManager * const m_networkManager;
    QNetworkReply *m_reply;

    bool m_lastDataIsHtml;
    int m_lastStatusCode;
    QString m_lastData;
};

#endif // BACKEND_H
