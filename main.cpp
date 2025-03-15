#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>
// WEB ENGINE STUFF
// #include <QtWebEngineQuick>

#include "cpp/Backend.h"

int main(int argc, char *argv[])
{
    // WEB ENGINE STUFF
    // QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    // QtWebEngineQuick::initialize();
    QGuiApplication app(argc, argv);

    Backend *backend = new Backend(&app);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("Backend", backend);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("RequestAndResponseTest", "Main");

    return app.exec();
}
