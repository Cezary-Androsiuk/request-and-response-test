#include "Backend.h"

Backend::Backend(QObject *parent)
    : QObject{parent}
    , m_networkManager{new QNetworkAccessManager(this)}
    , m_lastDataIsHtml{false}
    , m_lastStatusCode{-1}
{}

bool Backend::isUrlValid(const QString &urlString) const
{
    QUrl url(urlString);
    return url.isValid() && !url.scheme().isEmpty() && !url.host().isEmpty();
}

void Backend::sendRequest(QString urlString, QString data, QString method)
{
    m_lastDataIsHtml = false;

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
    if(!m_reply)
    {
        m_lastData.clear();
        m_lastStatusCode = -1;
        emit this->responseErrorOccur("Reply does not exist!");
        return;
    }

    if(m_reply->error() == QNetworkReply::OperationCanceledError)
    {
        emit this->abortedRequest();
        return;
    }

    m_lastStatusCode = m_reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    QByteArray responseData = m_reply->readAll();

    QJsonDocument responseJson = QJsonDocument::fromJson(responseData);
    QString data = responseJson.isNull() ? responseData : responseJson.toJson();

    if(!data.isEmpty())
    {
        if(data[0] == '<')
            m_lastDataIsHtml = true;
    }

    m_lastData = data;

    if(m_reply->error() != QNetworkReply::NoError)
    {
        emit this->responseErrorOccur(m_reply->errorString());
        m_reply->deleteLater();
        return;
    }

    emit this->responseHandled();

    m_reply->deleteLater();
}

bool Backend::getLastDataIsHtml() const
{
    return m_lastDataIsHtml;
}

int Backend::getLastStatusCode() const
{
    return m_lastStatusCode;
}

QString Backend::getLastData() const
{
    return m_lastData;
}
