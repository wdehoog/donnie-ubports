#include <QApplication>
#include <QQuickView>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QtQml/QtQml>

#include "upnp.h"

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_DisableHighDpiScaling);
    //QQuickStyle::setStyle("donnie");
    //QQuickStyle::setFallbackStyle("Suru");
    QQuickStyle::setStyle("Suru");

    QCoreApplication::setApplicationName("donnie.wdehoog");
    QCoreApplication::setOrganizationName("donnie.wdehoog");
    QCoreApplication::setOrganizationDomain("donnie.wdehoog");

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QQmlContext* rootContext = engine.rootContext();

    UPNP upnp;
    rootContext->setContextProperty("upnp", &upnp);

    QString buildDateTime;
    buildDateTime.append(__DATE__);
    buildDateTime.append(" ");
    buildDateTime.append(__TIME__);
    rootContext->setContextProperty("BUILD_DATE_TIME", buildDateTime);

    engine.load(QStringLiteral("qml/Main.qml"));

    return app.exec();
}
