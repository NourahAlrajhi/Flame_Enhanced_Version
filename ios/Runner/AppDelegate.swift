
import UIKit
import Flutter
import GoogleMaps
import Firebase
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     GMSServices.provideAPIKey("AIzaSyCNSCKybMgjaxZO_O_uqZWZpGfxKHsJ700")
        if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
/*FirebaseApp.configure()*/
    GeneratedPluginRegistrant.register(with: self)
 
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
