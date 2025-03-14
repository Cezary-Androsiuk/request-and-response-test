#include "Backend.h"

Backend::Backend(QObject *parent)
    : QObject{parent}
    , m_networkManager{new QNetworkAccessManager(this)}
{}

bool Backend::isUrlValid(const QString &urlString) const
{
    QUrl url(urlString);
    return url.isValid() && !url.scheme().isEmpty() && !url.host().isEmpty();
}

void Backend::sendRequest(QString urlString, QString data)
{
    qDebug() << "sending request";

    QUrl url(urlString);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonDocument jsonDoc;
    if(!data.isEmpty())
    {
        QJsonParseError jsonError;
        QJsonDocument::fromJson(data.toUtf8(), &jsonError);
        if(jsonError.error != QJsonParseError::NoError) {
            emit this->sendingFailed("Request is not a valid JSON!");
            return;
        }
        // if(!jsonDoc.isObject()){
        //     emit this->sendingFailed("Request is not a valid JSON (no object)!");
        //     return;
        // }
    }

    QByteArray jsonData = jsonDoc.toJson(QJsonDocument::JsonFormat::Compact);

    QNetworkReply *reply = m_networkManager->get(request, jsonData);
    QObject::connect(reply, &QNetworkReply::finished, this, &Backend::handleResponse);

    emit this->requestSended();
}

void Backend::handleResponse()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    /// sender is useful :3

    if(!reply)
    {
        emit this->responseErrorOccur("Response signal sender is a null!");
        return;
    }

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    QByteArray responseData = reply->readAll();

    QJsonDocument responseJson = QJsonDocument::fromJson(responseData);
    if(responseJson.isNull())
        emit this->responseHandled(responseData, statusCode);
    else
        emit this->responseHandled(responseJson.toJson(), statusCode);

    if(reply->error() != QNetworkReply::NoError)
    {
        emit this->responseErrorOccur(reply->errorString());
        qDebug() << reply->errorString();
        return;
    }

    reply->deleteLater();
}
