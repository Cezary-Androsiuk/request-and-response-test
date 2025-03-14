#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>

#include "cpp/Backend.h"

int main(int argc, char *argv[])
{
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
