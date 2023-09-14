//
//  AppDelegate.swift
//  TracertPOD
//
//

import UIKit
import os
import OKTracer

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Private properties
    
    private let token = "Токен"
    private var tracerService: TracerServiceProtocol!
    private var isStarted = false

    // MARK: - Properties

    var window: UIWindow?

    // MARK: - Lifecycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure and start crash and assert services

//        tracerService = easyStartForCrashReporting()
//        tracerService.start(features: [.assertReporter, .crashReporter])
        // Configure and start all services
        tracerService = tracerWithCustomConfigurations()
        tracerService.start(features: [.systrace, .diskUsage, .crashReporter, .assertReporter])

        if checkCrashOnLaunch() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: { [ weak self] in
                self?.start()
            })
        } else {
            start()
        }
        
        return true
    }
}

extension AppDelegate: TracerServiceDelegate {
    
    // MARK: - TracerServiceDelegate fucntions
    
    func tracerDidStart(result: Result<FeatureType, Error>) {
        switch result {
        case let .success(feature):
            log(message: "AppDelegate tracerDidStart feature: \(feature)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidStart error: \(error)")
        }
    }
    
    func tracerDidStop(result: Result<FeatureType, Error>) {
        switch result {
        case let .success(feature):
            log(message: "AppDelegate tracerDidStop feature: \(feature)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidStop error: \(error)")
        }
    }
    
    func tracerDidEvent(feature: FeatureType, result: Result<String, Error>) {
        switch result {
        case let .success(description):
            log(message: "AppDelegate tracerDidEvent feature: \(feature) description: \(description)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidEvent feature: \(feature) error: \(error)")
        }
    }
    
    func tracerDidRegister(result: Result<FeatureType, Error>) {
        switch result {
        case let .success(feature):
            log(message: "AppDelegate tracerDidRegister feature: \(feature)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidRegister error: \(error)")
        }
    }
    
    func tracerDidRegisterObject(result: Result<FeatureObject, Error>) {
        switch result {
        case let .success(feature):
            log(message: "AppDelegate tracerDidRegisterObject feature: \(feature)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidRegisterObject error: \(error)")
        }
    }
    
    func tracerDidStartObject(result: Result<FeatureObject, Error>) {
        switch result {
        case let .success(feature):
            log(message: "AppDelegate tracerDidStartObject feature: \(feature)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidStartObject error: \(error)")
        }
    }

    func tracerDidStopObject(result: Result<FeatureObject, Error>) {
        switch result {
        case let .success(feature):
            log(message: "AppDelegate tracerDidStopObject feature: \(feature)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidStopObject error: \(error)")
        }
    }
    
    func tracerDidRemoveObject(result: Result<FeatureObject, Error>) {
        switch result {
        case let .success(feature):
            log(message: "AppDelegate tracerDidRemoveObject feature: \(feature)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidRemoveObject error: \(error)")
        }
    }
    
    func tracerDidUpload(feature: FeatureType, result: Result<String, Error>) {
        switch result {
        case let .success(description):
            log(message: "AppDelegate tracerDidUpload feature \(feature) success: \(description)")
        case let .failure(error):
            log(error: "AppDelegate tracerDidUpload feature \(feature) error: \(error)")
        }
        if feature == .crashReporter, !isStarted {
            start()
        }
    }
    
    func tracerDidAllUpload(feature: FeatureType) {
        log(message: "AppDelegate tracerDidAllUpload feature: \(feature)")
        if feature == .crashReporter, !isStarted {
            start()
        }
    }
}

private extension AppDelegate {

    // MARK: - Private functions

    /*
     Простой старт.
     Будут сконфигурированы и запущены сервисы .assertReporter, .crashReporter
     со стандартными настройками
     */
    func easyStartForCrashReporting() -> TracerServiceProtocol {
        TracerFactory.tracerServiceForCrashReporting(token: token, delegate: self)
    }
    
    /*
     Можно сконфигурировать любой набор сервисов (в примере это .diskUsage, .systrace)
     со стандартными настройками
     объекты для отслеживания можно создавать самостоятельно, если список = nil, то создадутся объекты по умолчанию аналогично методу easyStart
     так же можно указат собственные провайдеры логов, информации о системе и прокси запросов
     */
    func startWithDefaultConfigrations() -> TracerServiceProtocol {
        let features: [FeatureConfiguration] = [
            .assertReporter(),
            .crashReporter(),
            .diskUsage(),
            .systrace(),
        ]
        let items: [FeatureObject] = [
            .diskUsage(objects: [.folder(path: NSHomeDirectory(), tag: "homeDirectory")]),
            .systrace(scenarios: ["launch"]),
        ]
        let tracerService = TracerFactory.tracerService(token: token,
                                                        features: features,
                                                        items: items,
                                                        delegate: self,
                                                        sysInfoProvider: CustomTracerSystemInfoProvider(),
                                                        logProvider: CustomTracerLogProvider())
        return tracerService
    }
    
    /*
     Можно сконфигурировать любой набор сервисов
     со собственными настройками
     */
    func tracerWithCustomConfigurations() -> TracerServiceProtocol {
        let objects: [DiskUsageObject] = [
            .directory(path: .documentDirectory, tag: ".documentDirectory"),
            .folder(path: NSHomeDirectory(), tag: "homeDirectory"),
            .folder(path: Bundle.main.bundlePath, tag: "mainBundle")
        ]
        let sysTraceScenarios: [SysTraceScenario] = ["launch", "urlSession"]
        let diskUsageConfiguration = DiskUsageConfiguration(autoStart: true,
                                                            excluded: ["TracerStorage", "SplashBoard"],
                                                            notifyIfEquals: false,
                                                            maxDepth: 200,
                                                            maxEntries: 8,
                                                            difference: 10000,
                                                            isRecursive: true,
                                                            observeMode: .timer(interval: 300))
        
        let sysTraceConfiguration = SysTraceConfiguration(autoStart: false, duration: 20)
        let features: [FeatureConfiguration] = [
            .diskUsage(probability: .zero),
            .systrace(probability: .zero),
            .crashReporter(shouldUseHack: true, maxUploadsCount: 3),
            .assertReporter(sendEvery: 2, maxUploadsCount: 10)
        ]

        let items: [FeatureObject] = [
            .diskUsage(objects: objects, configuration: diskUsageConfiguration),
            .systrace(scenarios: sysTraceScenarios, configuration: sysTraceConfiguration)
        ]


        let tracerService = TracerFactory.tracerService(token: token,
                                                        features: features,
                                                        items: items,
                                                        sysInfoProvider: CustomTracerSystemInfoProvider(),
                                                        logProvider: CustomTracerLogProvider())
        
        return tracerService
    }
    
    func log(message: String) {
        os_log(.default, "OKTracer TracerAppDelegate: %{public}s", message)
        print(message)
    }
    
    func log(error: String) {
        os_log(.default, "OKTracer TracerAppDelegate: %{public}s", error)
        print(error)
    }
    
    func start() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.isStarted {
                return
            }
            self.isStarted = true
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = ViewController(tracerService: self.tracerService)
            window.makeKeyAndVisible()
            self.window = window
        }
    }
    
    func checkCrashOnLaunch() -> Bool {
        switch tracerService.lastSessionState() {
        case let .normal(count):
            log(message: "didCrashInLastSessionOnLaunch normal \(count)")
            return false
        case let .crashed(count, result):
            switch result {
            case let .success(crashModel):
                guard let crashTime = crashModel.timestamp, let startTime = crashModel.startTime else {
                    log(message: "didCrashInLastSessionOnLaunch crashed false: \(crashModel.uuid) \(count)")
                    return false
                }
                let timeInterval = crashTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
                log(message: "didCrashInLastSessionOnLaunch crashed: \(timeInterval) \(timeInterval < 10) \(crashModel.uuid) \(count)")
                return crashTime.timeIntervalSince1970 - startTime.timeIntervalSince1970 < 10
            case let .failure(error):
                log(message: "didCrashInLastSessionOnLaunch failure: \(error) \(count)")
                return false
            }
        @unknown default:
            return false
        }
    }
}
