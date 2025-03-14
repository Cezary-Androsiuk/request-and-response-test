#include "Backend.h"

Backend::Backend(QObject *parent)
    : QObject{parent}
{}

bool Backend::isUrlValid(const QString &urlString) const
{
    QUrl url(urlString);
    return url.isValid() && !url.scheme().isEmpty() && !url.host().isEmpty();
}

void Backend::sendRequest(QString urlString, QString data)
{
    QNetworkAccessManager *manager = new QNetworkAccessManager();

    QUrl url(urlString);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonParseError jsonError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data.toUtf8(), &jsonError);

    if(jsonError.error != QJsonParseError::NoError) {
        emit this->sendingFailed("Request is not a valid JSON!");
        return;
    }

    if(!jsonDoc.isObject()){
        emit this->sendingFailed("Request is not a valid JSON (no object)!");
        return;
    }

    QNetworkReply *reply = manager->post(request, jsonDoc.toJson());

    // QEventLoop
}
