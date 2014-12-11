#include <QApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QDebug>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon::fromTheme("media-playback-start"));
    app.setOrganizationName("KDE");
    app.setOrganizationDomain("kde.org");
    app.setApplicationName("Mediaman");

    // TODO load translations

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
