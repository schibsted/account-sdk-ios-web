//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

final class SchibstedAccountAPIResponsesTests: XCTestCase {
    func testStringOrIgnoreParsesStringValue() throws {
        let value = "testStringValue"
        let parsed = try! JSONDecoder().decode(StringOrIgnore.self, from: "\"\(value)\"".data(using: .utf8)!)
        XCTAssertEqual(parsed.value, value)
    }
    
    func testStringOrIgnoreIgnoresBoolValue() {
        let parsed = try! JSONDecoder().decode(StringOrIgnore.self, from: "false".data(using: .utf8)!)
        XCTAssertNil(parsed.value)
    }
    
    func testStringBool() {
        let jsonDecoder = JSONDecoder()
        func decode(_ value: String) -> StringBool? {
            return try! jsonDecoder.decode(StringBool.self, from: value.data(using: .utf8)!)
        }

        XCTAssertEqual(decode("false"), StringBool(value: false, asString: false))
        XCTAssertEqual(decode("true"), StringBool(value: true, asString: false))
        XCTAssertEqual(decode("\"false\""), StringBool(value: false, asString: true))
        XCTAssertEqual(decode("\"true\""), StringBool(value: true, asString: true))
        XCTAssertEqual(decode("\"notTrue\""), StringBool(value: false, asString: true))
    }
    
    func testUserProfileResponseHandleAddressesAsEmptyArray() {
        let json = """
        {
            "uuid": "4321",
            "userId": "1234",
            "status": 1,
            "email": "foo@bar.com",
            "emails": [],
            "displayName": "Foo Bar",
            "name": {},
            "gender": "undisclosed",
            "birthday": "0000-00-00",
            "published": "2022-06-13 14:05:22",
            "updated": "2022-06-13 14:09:00",
            "lastAuthenticated": "2022-06-13 15:30:40",
            "lastLoggedIn": "2022-06-13 15:30:40",
            "locale": "sv_SE",
            "utcOffset": "+02:00",
            "addresses": [],
        }
        """
        let parsed = try! JSONDecoder().decode(UserProfileResponse.self, from: json.data(using: .utf8)!)
        XCTAssertTrue(parsed.addresses?.isEmpty == true, "An empty array in addresses field should be converted to an empty dictionary in the UserProfileResponse struct")
    }
    
    func testUserProfileResponseHandlesBoolInStringFields() {
        let json = """
        {
            "emailVerified": false,
            "phoneNumberVerified": false,
            "uuid": "4321",
            "userId": "1234",
            "status": 1,
            "email": "foo@bar.com",
            "emails": [],
            "displayName": "Foo Bar",
            "name": {},
            "gender": "undisclosed",
            "birthday": "1910-04-10",
            "published": "2022-06-13 14:05:22",
            "updated": "2022-06-13 14:09:00",
            "lastAuthenticated": "2022-06-13 15:30:40",
            "lastLoggedIn": "2022-06-13 15:30:40",
            "locale": "sv_SE",
            "utcOffset": "+02:00",
            "addresses": [],
        }
        """
        let parsed = try! JSONDecoder().decode(UserProfileResponse.self, from: json.data(using: .utf8)!)
        XCTAssertNil(parsed.emailVerifiedDate)
        XCTAssertNil(parsed.phoneNumberVerifiedDate)
    }
    
    func testUserProfileResponseFiltersEmptyBirthdayValue() {
        let json = """
        {
            "emailVerified": false,
            "phoneNumberVerified": false,
            "uuid": "4321",
            "userId": "1234",
            "status": 1,
            "email": "foo@bar.com",
            "emails": [],
            "displayName": "Foo Bar",
            "name": {},
            "gender": "undisclosed",
            "birthday": "0000-00-00",
            "published": "2022-06-13 14:05:22",
            "updated": "2022-06-13 14:09:00",
            "lastAuthenticated": "2022-06-13 15:30:40",
            "lastLoggedIn": "2022-06-13 15:30:40",
            "locale": "sv_SE",
            "utcOffset": "+02:00",
            "addresses": [],
        }
        """
        let parsed = try! JSONDecoder().decode(UserProfileResponse.self, from: json.data(using: .utf8)!)
        XCTAssertNil(parsed.birthdate)
    }
    
    func testFullProfileResponse() {
        guard let filePath = Bundle(for: type(of: self)).path(forResource: "user-profile-response", ofType: "json"),
              let jsonString = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            XCTFail("Failed to read user_profile_response.json")
            return
        }

        let expectedResponse = UserProfileResponse(
            uuid: "96085e85-349b-4dbf-9809-fa721e7bae46",
            userId: "12345",
            status: 1,
            email: "test@example.com",
            emailVerified: StringOrIgnore(value: "1970-01-01 00:00:00"),
            emails: [
                Email(
                    value: "test@example.com",
                    type: "other",
                    primary: StringBool(value: true, asString: true),
                    verified: StringBool(value: true, asString: true),
                    verifiedTime: "1970-01-01 00:00:00"
                )
            ],
            phoneNumber: "+46123456",
            phoneNumberVerified: StringOrIgnore(value: nil),
            phoneNumbers: [
                PhoneNumber(
                    value: "+46123456",
                    type: "other",
                    primary: StringBool(value: false, asString: true),
                    verified: StringBool(value: false, asString: true)
                )
            ],
            displayName: "Unit test",
            name: Name(givenName: "Unit", familyName: "Test", formatted: "Unit Test"),
            addresses: [
                "home" : Address(
                    formatted: "12345 Test, Sverige",
                    streetAddress: "Test",
                    postalCode: "12345",
                    locality: "Test locality",
                    region: "Test region",
                    country: "Sverige",
                    type: .home
                )
            ],
            gender: "withheld",
            birthday: "1970-01-01 00:00:00",
            accounts: [
                "client1": Account(id: "client1", accountName: "Example", domain: "example.com", connected: "1970-01-01 00:00:00")
            ],
            merchants: [12345, 54321],
            published: "1970-01-01 00:00:00",
            verified: "1970-01-01 00:00:00",
            updated: "1971-01-01 00:00:00",
            passwordChanged: "1970-01-01 00:00:00",
            lastAuthenticated: "1970-01-01 00:00:00",
            lastLoggedIn: "1970-01-01 00:00:00",
            locale: "sv_SE",
            utcOffset: "+02:00"
        )
        
        let parsed = try! JSONDecoder().decode(UserProfileResponse.self, from: jsonString.data(using: .utf8)!)
        print(String(data: try! JSONEncoder().encode(parsed), encoding: .utf8)!)
        print(String(data: try! JSONEncoder().encode(expectedResponse), encoding: .utf8)!)
        XCTAssertEqual(parsed, expectedResponse)
    }
}
