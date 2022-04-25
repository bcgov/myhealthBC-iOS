//
//  ScreenStateManager.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-25.
//

// Note: Screen state events:
// SessionExpiredWhileAppOpen
// InitialProtectedMedicalRecordsFetch
// SessionExpiredAuthenticatedFetch

// Need to find a way to update screen state at the appropriate time (IE, after a full medical fetch is completed, and not every time a record is added - as a user with 1000 records will reload their table view 1000 times, which will block the UI) - or maybe we reload after adding an entire record type

// Events should be:
// 1 - Manually deleted record
// 2 - Authenticated Fetch completed (manual or session refetch or background fetch)
// 3 - Session expired while user is in app
// 4 - InitialProtectedMedicalRecordsFetch
// 5 - User authenticates

import UIKit

