# 3DS2 iOS SDK

With this SDK, you can accept 3D Secure 2.0 payments via Adyen.

## Installation

The SDK is available via [CocoaPods](http://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) or via manual installation.

### CocoaPods

1. Add `pod 'Adyen3DS2_Swift'` to your `Podfile`.
2. Run `pod install`.

### Carthage

1. Add `github "adyen/adyen-3ds2-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Link the framework with your target as described in [Carthage Readme](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

### Dynamic xcFramework

Drag the dynamic `XCFramework/Dynamic/Adyen3DS2_Swift.xcframework` to the `Frameworks, Libraries, and Embedded Content` section in your general target settings. Select "Copy items if needed" when asked.

### Static xcFramework

1. Drag the static `XCFramework/Static/Adyen3DS2_Swift.xcframework` to the `Frameworks, Libraries, and Embedded Content` section in your general target settings.
2. Make sure the static `Adyen3DS2_Swift.xcframework` is not embedded.
3. Select `Adyen3DS2.bundle` inside `Adyen3DS2_Swift.xcframework` and check "Copy items if needed", then select "Add".
4. The privacy manifest should be included/merged in your app bundle.

### Swift Package Manager

1. Follow Apple's [Adding Package Dependencies to Your App](
https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app
) guide on how to add a Swift Package dependency.
2. Use `https://github.com/Adyen/adyen-3ds2-ios-swift.git` as the repository URL.
3. Specify the version to be at least `3.0.0`.

:warning: _Please make sure to use Xcode 12.0+ when adding `Adyen3DS2_Swift` using Swift Package Manager._

:warning: _Swift Package Manager for Xcode 12.0 and 12.1 has a [know issue](https://bugs.swift.org/browse/SR-13343) when it comes to importing binary dependencies. A workaround is described [here](https://forums.swift.org/t/swiftpm-binarytarget-dependency-and-code-signing/38953)._

## Usage

### Creating a transaction

First, create an instance of `ServiceParameters` with the additional data retrieved from your call to `/authorise`.
Then, use the class method on `Transaction` to create a new transaction.
```swift
            let messageVersion = MessageVersion(rawValue: messageVersionString)
            let serviceParameters = try ServiceParameters(directoryServerIdentifier: directoryServerIdentifier, // Retrieved from Adyen
                                                          directoryServerPublicKey: directoryServerPublicKey, // Retrieved from Adyen
                                                          directoryServerRootCertificates: directoryServerRootCertificates) // Retrieved from Adyen

            Transaction.initialize(with: serviceParameters, messageVersion: messageVersion, securityDelegate: self, appearanceConfiguration: appearance) { result in
                switch result {
                case .success(let transaction):
                    self.transaction = transaction
                    let authenticationRequestParameters = transaction.authenticationRequestParameters // submit the authenticationRequestParameters to /authorise3ds2
                case .failure(let error):
                switch error.errorCode {
                    case "1001": 
                        // Handle cancellation
                    default: 
                        // Other error occurred
                        let errorRepresentation: String = error.base64Representation
                        // Submit `errorRepresentation` to [Adyen backend](https://docs.adyen.com/api-explorer/Payment/64/post/authorise3ds2)
                        // Submit the transactionStatus = "U" to [Adyen backend](https://docs.adyen.com/api-explorer/Payment/64/post/authorise3ds2).
                }
            }
        }
```

Use the `transaction`'s `authenticationRequestParameters` in your call to `/authorise3ds2`.

:warning: _`Transaction.initialize(ServiceParameters, MessageVersion, SecurityDelegate, AppearanceConfiguration)` requires the message version to be passed, please fill in the same message version as in the AReq, you should be able to get the message version decided by the 3DS server from its response when initiating the payment, if you use the Adyen 3DS server please see [the documentation](https://docs.adyen.com/api-explorer/#/Payment/v64/post/authorise__reqParam_threeDS2RequestData-messageVersion)._

:warning: _Keep a reference to your `Transaction` instance until the transaction is finished._

:warning: _If your application supports Mac catalyst or iPad OS multi-window/multi-scene, then its recommended to share the `Transaction` object between scenes for the case if the shopper starts a transaction on one window and switch to another while the transaction is in progress._

### Performing a challenge

In case a challenge is required, create an instance of `ChallengeParameters` with values from the additional data retrieved from your call to `/authorise3ds2`.

```swift
            internal struct ChallengeData: Decodable {
                var acsTransactionIdentifier: String
                var acsReferenceNumber: String
                var acsSignedContent: String
                var serverTransactionIdentifier: String
            }
            
        let challengeData: ChallengeData // Retrieved from Adyen.
        let challengeParameters = ChallengeParameters(serverTransactionIdentifier: challengeData.serverTransactionIdentifier,
                                                      threeDSRequestorAppURL: URL(string: "{YOUR_APP_URL}"), // Or nil if for example you're using protocol version 2.1.0
                                                      acsTransactionIdentifier: challengeData.acsTransactionIdentifier,
                                                      acsReferenceNumber: challengeData.acsReferenceNumber,
                                                      acsSignedContent: challengeData.acsSignedContent)                                                      
```

:warning: _Because of recent updates to the 3D Secure protocol, we strongly recommend that you provide the `threeDSRequestorAppURL` parameter as a [universal link](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content?language=objc)._

Use these challenge parameters to perform the challenge with the `transaction` you created earlier:
```swift

        transaction.performChallenge(with: challengeParameters,
                                          presenterViewController: presenterViewController) { result in
            switch result {
            case .success(let challengeResult):
                let transactionStatus: String = challengeResult.transactionStatus // Submit the transactionStatus to /authorise3ds2.
            case .failure(let error):
                // An error occurred.
            }
        }
```

When the challenge is completed successfully, submit the `transactionStatus` in the `result` in your second call to `/authorise3ds2`.

### Customizing the UI

The SDK provides some customization options to ensure the UI of the challenge flow fits your app's look and feel. These customization options are available through the `AppearanceConfiguration` class. To use them, create an instance of `AppearanceConfiguration`, configure the desired properties and pass it during initialization of the `Transaction`.

For example, to make the Continue button red and change its corner radius:
```swift
            var submitButtonAppearance: ButtonAppearance = ButtonAppearance(buttonType: .submit)
            submitButtonAppearance.cornerRadius = 24.0
            submitButtonAppearance.backgroundColor = .red
            submitButtonAppearance.textColor = .white

            let appearance = AppearanceConfiguration(submitButtonAppearance: submitButtonAppearance)
```

### Get the SDK version

If you want to get the currently used sdk version - for example to send to the [`/authorise` end point](https://docs.adyen.com/api-explorer/#/Payment/v64/post/authorise__reqParam_threeDS2RequestData-sdkVersion), you can get it using:

```
let version: String = SDKVersion();
```
### Compatibility with legacy interface

To accommodate the older interface, add the below typealias in your integration code. 
Note the older interface is deprecated and this interface will be removed in the next couple of versions. 
```
typealias ADYTransaction = LegacyInterface.ADYTransaction
typealias ADYService = LegacyInterface.ADYService
typealias ADYServiceParameters = LegacyInterface.ADYServiceParameters
typealias ADYChallengeParameters = LegacyInterface.ADYChallengeParameters
typealias ADYAppearanceConfiguration = LegacyInterface.ADYAppearanceConfiguration
typealias ADYChallengeResult = LegacyInterface.ADYChallengeResult
typealias ADYSecurityWarningsDelegate = LegacyInterface.ADYSecurityWarningsDelegate
typealias ADYRuntimeErrorCode = LegacyInterface.ADYRuntimeErrorCode
typealias ADYWarning = LegacyInterface.ADYWarning
typealias ADYAuthenticationRequestParameters = LegacyInterface.ADYAuthenticationRequestParameters

```

## See also

 * [Complete Documentation](https://docs.adyen.com/classic-integration/3d-secure-2-classic-integration/ios-sdk-integration/)
 * [SDK Reference](https://adyen.github.io/adyen-3ds2-ios/Docs/index.html)
 * [Reporting security issues](https://www.adyen.help/hc/en-us/articles/115001187330-How-do-I-report-a-possible-security-issue-to-Adyen-).
 * [Security best practices](https://docs.adyen.com/online-payments/classic-integrations/api-integration-ecommerce/3d-secure/native-3ds2/ios-sdk-integration/security-best-practices).
 * [Data security at Adyen](https://docs.adyen.com/development-resources/adyen-data-security).

## License

This repository is open source and available under the MIT license. For more information, see the LICENSE file.