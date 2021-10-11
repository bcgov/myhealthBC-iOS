//
//  RemoteFactory.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
//

import Foundation

/// This factory helps accessing all remote datasource objects.
protocol RemoteAccessFactory {
    var remoteAccessor: RemoteAccessor { get }
    var endpointsAccessor: EndpointsAccessor { get }
    var healthGatewayBCAccessor: HealthGatewayBCAccessor { get }
}

final class RemoteFactory: RemoteAccessFactory {

    let remoteAccessor: RemoteAccessor = {
        return NetworkAccessor()
    }()
    
    let endpointsAccessor: EndpointsAccessor = {
       return UrlAccessor()
    }()
    
    lazy var healthGatewayBCAccessor: HealthGatewayBCAccessor = {
        return RemoteRequestAccessor(accessor: self.remoteAccessor,
                                 endpointsAccessor: self.endpointsAccessor)
    }()    
}

