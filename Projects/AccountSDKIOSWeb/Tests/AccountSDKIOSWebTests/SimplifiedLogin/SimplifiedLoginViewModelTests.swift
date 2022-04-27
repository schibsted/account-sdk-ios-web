//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

final class SimplifiedLoginViewModelTests: XCTestCase {
    
    func testSimplifiedLoginModelCreation() {
        let imageData = ImageData()
        let userData = UserData()
        let localizationModel = SimplifiedLoginLocalizationModel()

        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageData, userDataModel: userData, localizationModel: localizationModel, visibleClientName: "Schibsted")
        
        XCTAssertEqual(viewModel.clientName, "Schibsted")
        XCTAssertEqual(viewModel.schibstedLogoName, imageData
                        .schibstedLogoName)
        XCTAssertEqual(viewModel.initials, "JW")
        XCTAssertEqual(viewModel.iconNames, imageData.iconNames)
        XCTAssertEqual(viewModel.displayName, "John White")
    }
    
    func testCallingLoginUserActions() {
        let imageData = ImageData()
        let userData = UserData()
        let localizationModel = SimplifiedLoginLocalizationModel()

        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageData, userDataModel: userData, localizationModel: localizationModel, visibleClientName: "Schibsted")
        
        let didCallPrivacyPolicy = self.expectation(description: "Correctly call privacy policy closure")
        let didCallContinueAsUser = self.expectation(description: "Correctly call continue as closure")
        let didCallContinueWithoutLogin = self.expectation(description: "Correctly call continue without login closure")
        let didCallLoginWithDifferentAccount = self.expectation(description: "Correctly call login with different account closure")

        viewModel.onClickedPrivacyPolicy = {
            didCallPrivacyPolicy.fulfill()
        }
        viewModel.onClickedSwitchAccount = {
            didCallLoginWithDifferentAccount.fulfill()
        }
        viewModel.onClickedContinueAsUser = {
            didCallContinueAsUser.fulfill()
        }
        viewModel.onClickedContinueWithoutLogin = {
            didCallContinueWithoutLogin.fulfill()
        }
        
        viewModel.send(action: .clickedClickPrivacyPolicy)
        viewModel.send(action: .clickedContinueAsUser)
        viewModel.send(action: .clickedContinueWithoutLogin)
        viewModel.send(action: .clickedLoginWithDifferentAccount)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testInitials () {
        let imageData = ImageData()
        let localizationModel = SimplifiedLoginLocalizationModel()
        
        let displayName = "Test Display name"
        let givenName = "A name"
        let familyName = "some familyName"
        let userData = buildUserProfileResponse(givenName: givenName, familyName: familyName, displayName: displayName)
        
        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageData,
                                                 userDataModel: userData,
                                                 localizationModel: localizationModel,
                                                 visibleClientName: "Schibsted")
        
        XCTAssertEqual(viewModel.initials, "AS", "Initials should come from displayname if givenName and FamilyName is empty")
    }
    
    func testInitials_emptyName () {
        let imageData = ImageData()
        let localizationModel = SimplifiedLoginLocalizationModel()
        
        let displayName = "Test Display name"
        let givenName = ""
        let familyName = ""
        let userData = buildUserProfileResponse(givenName: givenName, familyName: familyName, displayName: displayName)
        
        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageData,
                                                 userDataModel: userData,
                                                 localizationModel: localizationModel,
                                                 visibleClientName: "Schibsted")
        
        XCTAssertEqual(viewModel.initials, "T", "Initials should come from givenName and FamilyName if set")
    }
    
    func testInitials_emptyGivenName () {
        let imageData = ImageData()
        let localizationModel = SimplifiedLoginLocalizationModel()
        
        let displayName = "Test Display name"
        let givenName = ""
        let familyName = "Some name"
        let userData = buildUserProfileResponse(givenName: givenName, familyName: familyName, displayName: displayName)
        
        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageData,
                                                 userDataModel: userData,
                                                 localizationModel: localizationModel,
                                                 visibleClientName: "Schibsted")
        
        XCTAssertEqual(viewModel.initials, "T", "Initials should come from displayname if givenName is empty")
    }
    
    func testInitials_emptyFamilyName () {
        let imageData = ImageData()
        let localizationModel = SimplifiedLoginLocalizationModel()
        
        let displayName = "Test Display name"
        let givenName = "A given name"
        let familyName = ""
        let userData = buildUserProfileResponse(givenName: givenName, familyName: familyName, displayName: displayName)
        
        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageData,
                                                 userDataModel: userData,
                                                 localizationModel: localizationModel,
                                                 visibleClientName: "Schibsted")
        
        XCTAssertEqual(viewModel.initials, "T", "Initials should come from displayname if FamilyName is empty")
    }
}


fileprivate func buildUserProfileResponse(givenName: String, familyName: String, displayName: String) -> UserData {
    let userProfileResponse = UserProfileResponse(uuid: "uuid", userId: "12345", status: 0, email: nil, emailVerified: nil, emails: [], phoneNumber: "123456789", phoneNumberVerified: nil, phoneNumbers: [], displayName: "foo", name: Name(givenName: givenName, familyName: familyName, formatted: nil), addresses: [:], gender: nil, birthday: nil, accounts: [:], merchants: [], published: nil, verified: nil, updated: nil, passwordChanged: nil, lastAuthenticated: nil, lastLoggedIn: nil, locale: nil, utcOffset: nil)
    
    let context = UserContextFromTokenResponse(identifier: "foo", display_text: displayName, client_name: "bar")
    return UserData(userContext: context, userProfileResponse: userProfileResponse)
}

fileprivate struct ImageData: SimplifiedLoginNamedImageData {
    var env: ClientConfiguration.Environment = .pre
    var schibstedLogoName: String = "logo_name"
}

fileprivate struct UserData: SimplifiedLoginViewModelUserData {
    var userContext = Fixtures.userContext
    var userProfileResponse = Fixtures.userProfileResponse
}
