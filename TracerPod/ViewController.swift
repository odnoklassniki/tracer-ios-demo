//
//  ViewController.swift
//  Tracer
//
//

import OKTracer
import UIKit

import os

final class ViewController: UIViewController {

    // MARK: - Private properties

    private let tracerService: TracerServiceProtocol
    private lazy var customAssertSender = CustomAssertSender(tracerService: tracerService)
    private var task: URLSessionDataTask?
    private let dispatchQueue = DispatchQueue(label: "ru.tracer.test.queue.\(ViewController.self)", qos: .utility)

    // MARK: - Initializations
    
    init(tracerService: TracerServiceProtocol) {
        self.tracerService = tracerService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tracerService.beginSysTrace(scenario: "launch", section: "\(ViewController.self)")
        dispatchQueue.async { [weak self] in
            self?.getDataFrom(url: URL(string: "https://github.com/orgs/odnoklassniki/repositories"))
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 1)
            }
        }
        Thread.sleep(forTimeInterval: 2)
        tracerService.endSysTrace(scenario: "launch", section: "\(ViewController.self)")
        if #available(iOS 14.0, *) {
            createButton(point: CGPoint(x: 50, y: 50), title: "Generate UICollection crash", handler: { [weak self] _ in
                self?.collectionCrash()
            })
            createButton(point: CGPoint(x: 50, y: 110), title: "Generate \"out of bounds\" crash", handler: { _ in
                let array = [0, 1, 2]
                let isError = array[5] == 0
                os.os_log(.default, isError ? "" : "")
            })
            createButton(point: CGPoint(x: 50, y: 170), title: "Generate \"unwrap\" crash", handler: { _ in
                let value: ViewController! = nil
                let isError = value.isViewLoaded
                os.os_log(.default, isError ? "" : "")
            })
            createButton(point: CGPoint(x: 50, y: 230), title: "Generate fatalError crash", handler: { _ in
                fatalError("Generate fatalError crash")
            })
            createButton(point: CGPoint(x: 50, y: 290), title: "Generate ObjC crash", handler: { _ in
                objc_terminate()
            })
            createButton(point: CGPoint(x: 50, y: 350), title: "Generate NSObject crash", handler: { _ in
                let nsArray = NSArray()
                nsArray.adding(NSNumber(value: 1))
                let isError = nsArray.object(at: 10) as? NSNumber != nil
                os.os_log(.default, isError ? "" : "")
            })
            createButton(point: CGPoint(x: 50, y: 410), title: "Assert as service", handler: { [weak self] _ in
                self?.tracerService.send(nonFatal: .init(message: "AssertButton pressed as service"))
            })
            createButton(point: CGPoint(x: 50, y: 470), title: "Assert as extension of protocol", handler: { [weak self] _ in
                self?.tracerService.send(TracerNonFatalModel(message: "AssertButton pressed as protocol"))
            })
            createButton(point: CGPoint(x: 50, y: 530), title: "Custom AssertButton pressed with symbols", handler: { [weak self] _ in
                let callStackReturnAddresses = Thread.callStackReturnAddresses
                let callStackSymbols = Thread.callStackSymbols
                self?.tracerService.send(TracerNonFatalModel(message: "Custom AssertButton pressed with symbols",
                                                             traceType: .custom(callStackAddresses: callStackReturnAddresses,
                                                                                callStackSymbols: callStackSymbols)))
            })
            createButton(point: CGPoint(x: 50, y: 590), title: "Custom AssertButton pressed without symbols", handler: { [weak self] _ in
                self?.tracerService.send(TracerNonFatalModel(message: "Custom AssertButton pressed without symbols",
                                                             traceType: .custom(callStackAddresses: Thread.callStackReturnAddresses)))
            })
        }
    }
}

private extension ViewController {

    // MARK: - Private functions
    
    func collectionCrash() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 20, height: 20), collectionViewLayout: UICollectionViewLayout())
        viewController.view.addSubview(collectionView)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Test", for: IndexPath(row: 0, section: 0))
        let isError = "\(cell.self)" == "Test1"
        os.os_log(.default, isError ? "" : "")
    }
    
    func createButton(point: CGPoint, title: String, handler: @escaping UIActionHandler) {
        if #available(iOS 14.0, *) {
            let button = UIButton(type: .system, primaryAction: UIAction(handler: handler))
            button.backgroundColor = .lightGray
            button.setTitle(title, for: .normal)
            button.frame = CGRect(x: point.x, y: point.y, width: view.frame.width - 100, height: 50)
            view.addSubview(button)
        }
    }
    
    func getDataFrom(url: URL?) {
        guard let url = url else {
            return
        }
        customAssertSender.send(message: "CustomAssertSender getDataFrom assert")
        tracerService.beginSysTrace(scenario: "launch", section: "\(ViewController.self)-getDataFrom")
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { [weak self] _, _, _ in
            guard let self = self else {
                return
            }
            self.tracerService.beginSysTrace(scenario: "launch", section: "\(ViewController.self)-complete")
            Thread.sleep(forTimeInterval: 3)
            self.tracerService.endSysTrace(scenario: "launch", section: "\(ViewController.self)-complete")
            self.customAssertSender.send(message: "getDataFrom assert")
        })
        task.resume()
        self.task = task
        Thread.sleep(forTimeInterval: 4)
        tracerService.endSysTrace(scenario: "main", section: "\(ViewController.self)-getDataFrom")
    }
}
