import XCTest
@testable import AccountSDKIOSWeb

final class SimplifiedLoginViewModelTests: XCTestCase {
    
    fileprivate struct ImageData: SimplifiedLoginNamedImageData {
        var env: ClientConfiguration.Environment = .pre
        var schibstedLogoName: String = "logo_name"
    }
    
    fileprivate struct UserData: SimplifiedLoginViewModelUserData {
        var userContext = Fixtures.userContext
        var userProfileResponse = Fixtures.userProfileResponse
    }
    
    func testSimplifiedLoginModelCreation() {
        let imageData = ImageData()
        let userData = UserData()
        let localizationModel = SimplifiedLoginLocalizationModel()

        let model = SimplifiedLoginViewModel(imageDataModel: imageData, userDataModel: userData, localizationModel: localizationModel, visibleClientName: "Schibsted")
        
        XCTAssertEqual(model.clientName, "Schibsted")
        XCTAssertEqual(model.schibstedLogoName, imageData
                        .schibstedLogoName)
        XCTAssertEqual(model.initials, "JW")
        XCTAssertEqual(model.iconNames, imageData.iconNames)
        XCTAssertEqual(model.displayName, userData.userProfileResponse.displayName)
    }
    
    func testCallingLoginUserActions() {
        let imageData = ImageData()
        let userData = UserData()
        let localizationModel = SimplifiedLoginLocalizationModel()

        let model = SimplifiedLoginViewModel(imageDataModel: imageData, userDataModel: userData, localizationModel: localizationModel, visibleClientName: "Schibsted")
        
        let didCallPrivacyPolicy = self.expectation(description: "Correctly call privacy policy closure")
        let didCallContinueAsUser = self.expectation(description: "Correctly call continue as closure")
        let didCallContinueWithoutLogin = self.expectation(description: "Correctly call continue without login closure")
        let didCallLoginWithDifferentAccount = self.expectation(description: "Correctly call login with different account closure")

        model.onClickedPrivacyPolicy = {
            didCallPrivacyPolicy.fulfill()
        }
        model.onClickedSwitchAccount = {
            didCallLoginWithDifferentAccount.fulfill()
        }
        model.onClickedContinueAsUser = {
            didCallContinueAsUser.fulfill()
        }
        model.onClickedContinueWithoutLogin = {
            didCallContinueWithoutLogin.fulfill()
        }
        
        model.send(action: .clickedClickPrivacyPolicy)
        model.send(action: .clickedContinueAsUser)
        model.send(action: .clickedContinueWithoutLogin)
        model.send(action: .clickedLoginWithDifferentAccount)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}

