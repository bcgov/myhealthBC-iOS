#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SPConfiguration.h"
#import "SPConfigurationBundle.h"
#import "SPEmitterConfiguration.h"
#import "SPGDPRConfiguration.h"
#import "SPGlobalContextsConfiguration.h"
#import "SPNetworkConfiguration.h"
#import "SPRemoteConfiguration.h"
#import "SPSessionConfiguration.h"
#import "SPSubjectConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPEmitter.h"
#import "SPEmitterConfigurationUpdate.h"
#import "SPEmitterController.h"
#import "SPEmitterControllerImpl.h"
#import "SPEmitterEvent.h"
#import "SPEmitterEventProcessing.h"
#import "SPRequest.h"
#import "SPRequestCallback.h"
#import "SPRequestResult.h"
#import "SNOWError.h"
#import "SPBackground.h"
#import "SPConsentDocument.h"
#import "SPConsentGranted.h"
#import "SPConsentWithdrawn.h"
#import "SPEcommerce.h"
#import "SPEcommerceItem.h"
#import "SPEvent.h"
#import "SPEventBase.h"
#import "SPForeground.h"
#import "SPPageView.h"
#import "SPPushNotification.h"
#import "SPScreenView.h"
#import "SPSelfDescribing.h"
#import "SPStructured.h"
#import "SPTiming.h"
#import "SPTrackerError.h"
#import "SPGDPRConfigurationUpdate.h"
#import "SPGdprContext.h"
#import "SPGDPRController.h"
#import "SPGDPRControllerImpl.h"
#import "SPGlobalContext.h"
#import "SPGlobalContextsController.h"
#import "SPGlobalContextsControllerImpl.h"
#import "SPSchemaRule.h"
#import "SPSchemaRuleset.h"
#import "SPLogger.h"
#import "SPLoggerDelegate.h"
#import "SPDefaultNetworkConnection.h"
#import "SPNetworkConfigurationUpdate.h"
#import "SPNetworkConnection.h"
#import "SPNetworkController.h"
#import "SPNetworkControllerImpl.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPConfigurationCache.h"
#import "SPConfigurationFetcher.h"
#import "SPConfigurationProvider.h"
#import "SPFetchedConfigurationBundle.h"
#import "SPScreenState.h"
#import "UIViewController+SPScreenView_SWIZZLE.h"
#import "SPSession.h"
#import "SPSessionConfigurationUpdate.h"
#import "SPSessionController.h"
#import "SPSessionControllerImpl.h"
#import "SPController.h"
#import "SPSnowplow.h"
#import "SPTrackerConstants.h"
#import "SPEventStore.h"
#import "SPMemoryEventStore.h"
#import "SPSQLiteEventStore.h"
#import "SPDevicePlatform.h"
#import "SPSubject.h"
#import "SPSubjectConfigurationUpdate.h"
#import "SPSubjectController.h"
#import "SPSubjectControllerImpl.h"
#import "SPInstallTracker.h"
#import "SPServiceProvider.h"
#import "SPServiceProviderProtocol.h"
#import "SPTracker.h"
#import "SPTrackerConfigurationUpdate.h"
#import "SPTrackerController.h"
#import "SPTrackerControllerImpl.h"
#import "SPTrackerEvent.h"
#import "NSDictionary+SP_TypeMethods.h"
#import "SNOWReachability.h"
#import "SPDataPersistence.h"
#import "SPJSONSerialization.h"
#import "SPUtilities.h"
#import "SPWeakTimerTarget.h"
#import "Snowplow-umbrella-header.h"

FOUNDATION_EXPORT double SnowplowTrackerVersionNumber;
FOUNDATION_EXPORT const unsigned char SnowplowTrackerVersionString[];

