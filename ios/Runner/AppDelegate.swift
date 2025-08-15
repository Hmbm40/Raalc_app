// ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

  private var resultCallback: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "native_country_picker",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else { return }
        switch call.method {
        case "present":
          guard
            let args = call.arguments as? [String: Any],
            let rawCountries = args["countries"] as? [[String: Any]]
          else {
            result(FlutterError(code: "bad_args", message: "Invalid arguments", details: nil))
            return
          }

          let initialDial = args["initialDialCode"] as? String
          let items: [CountryItem] = rawCountries.compactMap { dict in
            guard
              let name = dict["name"] as? String,
              let code = dict["code"] as? String,
              let dial = dict["dialCode"] as? String,
              !dial.isEmpty
            else { return nil }
            return CountryItem(name: name, code: code, dialCode: dial)
          }

          self.resultCallback = result
          self.presentList(items: items, initialDialCode: initialDial)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Presentation

  private func presentList(items: [CountryItem], initialDialCode: String?) {
    guard let presenter = topMostViewController() else {
      resultCallback?(FlutterError(code: "no_vc", message: "No presenter VC", details: nil))
      resultCallback = nil
      return
    }

    let list = CountryListController(items: items, initialDialCode: initialDialCode)
    list.onPick = { [weak self] item in
      defer { self?.resultCallback = nil }
      guard let cb = self?.resultCallback else { return }
      if let selected = item {
        cb(["name": selected.name, "code": selected.code, "dialCode": selected.dialCode])
      } else {
        cb(nil)
      }
    }

    let nav = UINavigationController(rootViewController: list)
    nav.modalPresentationStyle = .pageSheet
    if #available(iOS 15.0, *) {
      if let sheet = nav.sheetPresentationController {
        sheet.detents = [.medium(), .large()]
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
      }
    }
    presenter.present(nav, animated: true, completion: nil)
  }

  /// Backward‑compatible "top most" presenter finder (iOS 11+).
  private func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
    var root: UIViewController?

    if let base = base {
      root = base
    } else {
      if #available(iOS 13.0, *) {
        // Prefer the key window from any connected scene (no use of UIWindowScene.keyWindow)
        let windows = UIApplication.shared.connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .flatMap { $0.windows }
        root = (windows.first { $0.isKeyWindow } ?? windows.first)?.rootViewController
      } else {
        // iOS 12 and earlier
        root = UIApplication.shared.keyWindow?.rootViewController
        if root == nil {
          root = UIApplication.shared.windows.first?.rootViewController
        }
      }
    }

    // Walk the hierarchy
    if let nav = root as? UINavigationController {
      return topMostViewController(base: nav.visibleViewController)
    }
    if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
      return topMostViewController(base: selected)
    }
    if let presented = root?.presentedViewController {
      return topMostViewController(base: presented)
    }
    return root
  }
}

// MARK: - Models / Controller

fileprivate struct CountryItem {
  let name: String
  let code: String
  let dialCode: String
}

fileprivate final class CountryListController: UITableViewController, UISearchResultsUpdating {

  private let allItems: [CountryItem]
  private var filtered: [CountryItem]
  private let initialDial: String?
  var onPick: ((CountryItem?) -> Void)?

  private let search = UISearchController(searchResultsController: nil)

  init(items: [CountryItem], initialDialCode: String?) {
    self.allItems = items
    self.filtered = items
    self.initialDial = initialDialCode
    super.init(style: .insetGrouped)
    self.title = "Select Country"
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    navigationItem.searchController = search
    search.obscuresBackgroundDuringPresentation = false
    search.searchResultsUpdater = self

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(close)
    )
  }

  @objc private func close() { onPick?(nil); dismiss(animated: true) }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    filtered.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = filtered[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    var config = cell.defaultContentConfiguration()
    config.text = "\(item.dialCode)  •  \(item.name)"
    config.secondaryText = item.code
    cell.contentConfiguration = config
    if let target = initialDial, item.dialCode == target {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    onPick?(filtered[indexPath.row])
    dismiss(animated: true)
  }

  func updateSearchResults(for searchController: UISearchController) {
    let q = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    if q.isEmpty {
      filtered = allItems
    } else {
      filtered = allItems.filter {
        $0.name.localizedCaseInsensitiveContains(q)
        || $0.code.localizedCaseInsensitiveContains(q)
        || $0.dialCode.contains(q)
      }
    }
    tableView.reloadData()
  }
}
