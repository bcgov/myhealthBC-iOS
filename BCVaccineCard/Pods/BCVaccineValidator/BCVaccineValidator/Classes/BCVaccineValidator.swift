import Foundation

public class BCVaccineValidator {
    public static let shared = BCVaccineValidator()
    
    public var config: ValidatorConfig = .default

    public func initialize() {
#if DEBUG
        print("Initializing BCVaccineValidator using config: \(config)")
        print("Enable Remote rules: \(config.enableRemoteFetch)")
#endif
        loadData { [weak self] in
            guard let self = self, self.config.enableRemoteFetch else { return }
            self.setupReachabilityListener()
            self.setupUpdateListener()
        }
#if DEBUG
        print("\n\n")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("\(documentsDirectory)\n\n")
        print("\n\n")
#endif
    }
    
    private func loadData(completion: @escaping() -> Void) {
        let displatchGroup = DispatchGroup()
        displatchGroup.enter()
        IssuerManager.shared.getIssuers { issuers in
            displatchGroup.leave()
        }
        displatchGroup.enter()
        RulesManager.shared.getRules { rules in
            displatchGroup.leave()
        }
        
        displatchGroup.notify(queue: .main) {
            return completion()
        }
    }
    
    private func setupUpdateListener() {
        // When issuers list is updated, re-download keys for issuers
        Notification.Name.issuersUpdated.onPost(object: nil, queue: .main) { _ in
            IssuerManager.shared.getIssuers(completion: { res in
                if let issuers = res {
                    let issuerURLs = issuers.participatingIssuers.map({$0.iss})
                    KeyManager.shared.downloadKeys(forIssuers: issuerURLs, completion: {})
                }
            })
        }
    }
    
    /// When network status changes to online,
    /// and if a network call had failed and set shouldUpdateWhenOnline to true,
    /// re-fetch issuers.
    private func setupReachabilityListener() {
        Notification.Name.isReachable.onPost(object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if self.config.shouldUpdateWhenOnline {
                IssuerManager.shared.updateIssuers()
                RulesManager.shared.updateRules()
            }
        }
    }
    
    public func validate(code: String, completion: @escaping (CodeValidationResult)->Void) {
        CodeValidationService.shared.validate(code: code.lowercased(), completion: completion)
    }
}
