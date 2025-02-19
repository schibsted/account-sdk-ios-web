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
            "phoneNumberVerified": false
        }
        """
        let parsed = try! JSONDecoder().decode(UserProfileResponse.self, from: json.data(using: .utf8)!)
        XCTAssertNil(parsed.emailVerifiedDate)
        XCTAssertNil(parsed.phoneNumberVerifiedDate)
    }
    
    func testUserProfileResponseFiltersEmptyBirthdayValue() {
        let json = """
        {
            "birthday": "0000-00-00"
        }
        """
        let parsed = try! JSONDecoder().decode(UserProfileResponse.self, from: json.data(using: .utf8)!)
        XCTAssertNil(parsed.birthdate)
    }
    
    func testFullProfileResponse() {
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
            utcOffset: "+02:00",
            pairId: "12345",
            sdrn: "sdrn:schibsted:user:12345"
        )
        
        let parsed = try! JSONDecoder().decode(UserProfileResponse.self, from: userProfileResponseJsonString.data(using: .utf8)!)
        print(String(data: try! JSONEncoder().encode(parsed), encoding: .utf8)!)
        print(String(data: try! JSONEncoder().encode(expectedResponse), encoding: .utf8)!)
        XCTAssertEqual(parsed, expectedResponse)
    }
}

private let userProfileResponseJsonString = """
{
    "published": "1970-01-01 00:00:00",
    "gender": "withheld",
    "utcOffset": "+02:00",
    "addresses": {
        "home": {
            "type": "home",
            "formatted": "12345 Test, Sverige",
            "streetAddress": "Test",
            "locality": "Test locality",
            "region": "Test region",
            "postalCode": "12345",
            "country": "Sverige"
        }
    },
    "phoneNumbers": [
        {
            "value": "+46123456",
            "type": "other",
            "primary": "false",
            "verified": "false"
        }
    ],
    "phoneNumber": "+46123456",
    "emailVerified": "1970-01-01 00:00:00",
    "phoneNumberVerified": false,
    "lastAuthenticated": "1970-01-01 00:00:00",
    "lastLoggedIn": "1970-01-01 00:00:00",
    "verified": "1970-01-01 00:00:00",
    "uuid": "96085e85-349b-4dbf-9809-fa721e7bae46",
    "userId": "12345",
    "displayName": "Unit test",
    "email": "test@example.com",
    "birthday": "1970-01-01 00:00:00",
    "name": {
        "familyName": "Test",
        "givenName": "Unit",
        "formatted": "Unit Test"
    },
    "accounts": {
        "client1": {
            "id": "client1",
            "domain": "example.com",
            "accountName": "Example",
            "connected": "1970-01-01 00:00:00"
        }
    },
    "merchants": [
        12345,
        54321
    ],
    "locale": "sv_SE",
    "emails": [
        {
            "value": "test@example.com",
            "type": "other",
            "primary": "true",
            "verified": "true",
            "verifiedTime": "1970-01-01 00:00:00"
        }
    ],
    "updated": "1971-01-01 00:00:00",
    "passwordChanged": "1970-01-01 00:00:00",
    "status": 1,
    "pairId": "12345",
    "sdrn": "sdrn:schibsted:user:12345"
}
"""
