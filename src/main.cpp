#include <QApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QTranslator>
#include <QDebug>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon::fromTheme("media-playback-start"));
    app.setOrganizationName("KDE");
    app.setOrganizationDomain("kde.org");
    app.setApplicationName("Mediaman");

    QTranslator appTrans;
    appTrans.load(QStringLiteral(":/translations/mediaman_") + QLocale::system().name());
    app.installTranslator(&appTrans);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
