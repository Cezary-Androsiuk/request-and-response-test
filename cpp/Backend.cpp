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

void Backend::sendRequest(QString urlString, QString data, QString method)
{
    qDebug() << "sending request";

    QUrl url(urlString);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QByteArray requestData;

#define USE_JSON true
#if USE_JSON
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
    requestData = jsonDoc.toJson(QJsonDocument::JsonFormat::Compact);
#else
    requestData = data.toLatin1();
#endif


    QNetworkReply *reply;

    if(method == "GET")
        reply = m_networkManager->get(request, requestData);
    else if(method == "POST")
        reply = m_networkManager->post(request, requestData);
    else if(method == "PUT")
        reply = m_networkManager->post(request, requestData);
    else if(method == "PATCH")
        reply = m_networkManager->sendCustomRequest(request, "PATCH", requestData);

    else if(method == "DELETE")
        reply = m_networkManager->sendCustomRequest(request, "DELETE", requestData);
    else if(method == "HEAD")
        reply = m_networkManager->sendCustomRequest(request, "HEAD", requestData);
    else if(method == "OPTIONS")
        reply = m_networkManager->sendCustomRequest(request, "OPTIONS", requestData);
    else if(method == "TRACE")
        reply = m_networkManager->sendCustomRequest(request, "TRACE", requestData);
    else if(method == "CONNECT")
        reply = m_networkManager->sendCustomRequest(request, "CONNECT", requestData);

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
