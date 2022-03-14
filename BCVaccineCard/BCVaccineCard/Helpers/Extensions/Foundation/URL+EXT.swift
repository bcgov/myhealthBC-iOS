//
//  URL+EXT.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-10.
//

import Foundation

extension URL {

    var uti: String {
        return (try? self.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier ?? "public.data"
    }

}
