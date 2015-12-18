#include <VPApplication>
#include <QApplication>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{

  QApplication app(argc, argv);

  VPApplication vplay;

  // QQmlApplicationEngine is the preferred way to start qml projects since Qt 5.2
  // if you have older projects using Qt App wizards from previous QtCreator versions than 3.1, please change them to QQmlApplicationEngine
  QQmlApplicationEngine engine;
  vplay.initialize(&engine);

  // use this during development
  // for PUBLISHING, use the entry point below
  vplay.setMainQmlFileName(QStringLiteral("qml/SquabyMain.qml"));

  // use this instead of the above call to avoid deployment of the qml files and compile them into the binary with qt's resource system qrc
  // this is the preferred deployment option for publishing games to the app stores, because then your qml files and js files are protected
  // to avoid deployment of your qml files and images, also comment the DEPLOYMENTFOLDERS command in the .pro file
  // thus only use the above non-qrc approach, during development on desktop
  // also see the .pro file for more details
//  vplay.setMainQmlFileName(QStringLiteral("qrc:/qml/SquabyMain.qml"));


  engine.load(QUrl(vplay.mainQmlFileName()));

  return app.exec();
}
