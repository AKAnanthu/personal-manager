import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var privacyView: UIView?

  // Cover content while inactive so the app switcher snapshot shows nothing.
  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)
    guard privacyView == nil, let window = window else { return }
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    blur.frame = window.bounds
    blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(blur)
    privacyView = blur
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    privacyView?.removeFromSuperview()
    privacyView = nil
  }
}
