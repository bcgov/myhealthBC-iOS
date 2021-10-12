//
//  WorkerFactory.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
//

/// The access-point for assembling the workers needed for particular tasks.
///
/// Different data sources (local, remote, etc.) may be accessed,
/// but the caller need not concern itself with those details.
///  To be clear, this GatewayAccess is a generic term, not to be confused with the HealthGatewayAccessor - may have to look at a different naming convention
struct GatewayAccess {
    
    static private(set) var factory: GatewayFactory!
    
    static func initialize(withFactory factory: GatewayFactory) {
        guard self.factory == nil else { return }
        self.factory = factory
    }
    
    private init() {}
    
}

protocol GatewayFactory {
    func makeHealthGatewayBCGateway() -> HealthGatewayBCGateway
}

struct WorkerFactory {
    
//    let localFactory: LocalAccessFactory
    let remoteFactory: RemoteAccessFactory
    
    init(remoteFactory: RemoteAccessFactory) {
//        self.localFactory = localFactory
        self.remoteFactory = remoteFactory
    }
    
}

extension WorkerFactory: GatewayFactory {
    func makeHealthGatewayBCGateway() -> HealthGatewayBCGateway {
        return HealthGatewayBCWorker(remoteAccess: self.remoteFactory.healthGatewayBCAccessor)
    }
}
