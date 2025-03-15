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
        jsonDoc = QJsonDocument::fromJson(data.toUtf8(), &jsonError);
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
    if(method == "GET")
        m_reply = m_networkManager->get(request, requestData);
    else if(method == "POST")
        m_reply = m_networkManager->post(request, requestData);
    else if(method == "PUT")
        m_reply = m_networkManager->put(request, requestData);
    else if(method == "PATCH")
        m_reply = m_networkManager->sendCustomRequest(request, "PATCH", requestData);

    else if(method == "DELETE")
        m_reply = m_networkManager->sendCustomRequest(request, "DELETE", requestData);
    else if(method == "HEAD")
        m_reply = m_networkManager->sendCustomRequest(request, "HEAD", requestData);
    else if(method == "OPTIONS")
        m_reply = m_networkManager->sendCustomRequest(request, "OPTIONS", requestData);
    else if(method == "TRACE")
        m_reply = m_networkManager->sendCustomRequest(request, "TRACE", requestData);
    else if(method == "CONNECT")
        m_reply = m_networkManager->sendCustomRequest(request, "CONNECT", requestData);

    QObject::connect(m_reply, &QNetworkReply::finished, this, &Backend::handleResponse);

    emit this->requestSended();
}

void Backend::abortRequest()
{
    if(m_reply->isRunning())
        m_reply->abort();
}

void Backend::handleResponse()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    /// sender is useful :3

    if(!reply)
    {
        emit this->responseErrorOccur("", -1, "Response signal sender is a null!");
        return;
    }

    if(reply->error() == QNetworkReply::OperationCanceledError)
    {
        emit this->abortedRequest();
        return;
    }

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    QByteArray responseData = reply->readAll();

    QJsonDocument responseJson = QJsonDocument::fromJson(responseData);
    QString data = responseJson.isNull() ? responseData : responseJson.toJson();

    if(reply->error() != QNetworkReply::NoError)
    {
        emit this->responseErrorOccur(data, statusCode, reply->errorString());
        reply->deleteLater();
        return;
    }

    emit this->responseHandled(data, statusCode);

    reply->deleteLater();
}
