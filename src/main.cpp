#include <QApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QTranslator>
#include <QQmlContext>
#include <QStandardPaths>
#include <QCommandLineParser>
#include <QDir>
#include <QDebug>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon::fromTheme("media-playback-start"));
    app.setOrganizationName("KDE");
    app.setOrganizationDomain("kde.org");
    app.setApplicationName("Mediaman");
    app.setApplicationVersion("0.1");

    QTranslator appTrans;
    appTrans.load(QStringLiteral(":/translations/mediaman_") + QLocale::system().name());
    app.installTranslator(&appTrans);

    QCommandLineParser parser;
    parser.setApplicationDescription(QApplication::tr("Simple mediaplayer based on QML"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("url", QApplication::tr("URL to open"), "[url]");
    parser.process(app);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("moviesPath",
                                             QUrl::fromLocalFile(QStandardPaths::standardLocations(QStandardPaths::MoviesLocation).first()));
    engine.rootContext()->setContextProperty("musicPath",
                                             QUrl::fromLocalFile(QStandardPaths::standardLocations(QStandardPaths::MusicLocation).first()));

    QUrl url;
    const QStringList args = parser.positionalArguments();
    if (!args.isEmpty()) {
        const QUrl tmp = args.first();
        if (args.first().startsWith('/')) { // local absolute path
            url = QUrl::fromLocalFile(args.first());
        } else if (tmp.scheme().isEmpty()) { // local relative path
            url = QUrl::fromLocalFile(QDir::currentPath() + '/' + args.first());
        } else { // fully-qualified url
            url = tmp;
        }
    }

    engine.rootContext()->setContextProperty("playUrl", url);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
