//
//  FirstTests.swift
//  
//
//  Created by Joseph Spadafora on 7/9/19.
//

import XCTest

#if OPENCOMBINE_COMPATIBILITY_TEST
import Combine
#else
import OpenCombine
#endif

@available(macOS 10.15, *)
final class FirstTests: XCTestCase {

    static let allTests = [
        ("testFirstFinishesAndReturnsFirstItem",
         testFirstFinishesAndReturnsFirstItem),
        ("testFirstFinishesWithError",
         testFirstFinishesWithError),
        ("testFirstFinishesFinishesImmediately", testFirstFinishesFinishesImmediately)
    ]

    // swiftlint:disable implicitly_unwrapped_optional
    var subscription: CustomSubscription!
    var publisher: CustomPublisher!
    var tracking: TrackingSubscriber!
    var sut: Publishers.First<CustomPublisher>!
    // swiftlint:enable implicitly_unwrapped_optional

    override func setUp() {
        super.setUp()
        subscription = CustomSubscription()
        publisher = CustomPublisher(subscription: subscription)
        tracking = TrackingSubscriber(receiveSubscription: { $0.request(.unlimited) })
        sut = publisher.first()
    }

    func testFirstFinishesAndReturnsFirstItem() {
        XCTAssertEqual(tracking.history, [])
        XCTAssertEqual(subscription.history, [])

        sut.subscribe(tracking)
        XCTAssertEqual(tracking.history, [.subscription("First")])
        XCTAssertEqual(subscription.history, [.requested(.unlimited)])

        let sentDemand = publisher.send(25)
        XCTAssertEqual(sentDemand, .none)
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .value(25),
                                          .completion(.finished)])

        publisher.send(completion: .finished)
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .value(25),
                                          .completion(.finished)])

        let afterFinishSentDemand = publisher.send(73)
        XCTAssertEqual(afterFinishSentDemand, .none)
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .value(25),
                                          .completion(.finished)])
    }

    func testFirstFinishesWithError() {
        XCTAssertEqual(tracking.history, [])
        XCTAssertEqual(subscription.history, [])

        sut.subscribe(tracking)
        XCTAssertEqual(tracking.history, [.subscription("First")])
        XCTAssertEqual(subscription.history, [.requested(.unlimited)])

        publisher.send(completion: .failure(.oops))
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .completion(.failure(.oops))])

        publisher.send(completion: .failure(.oops))
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .completion(.failure(.oops))])

        let afterFinishSentDemand = publisher.send(73)
        XCTAssertEqual(afterFinishSentDemand, .none)
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .completion(.failure(.oops))])
    }

    func testFirstFinishesFinishesImmediately() {
        XCTAssertEqual(tracking.history, [])
        XCTAssertEqual(subscription.history, [])

        sut.subscribe(tracking)
        XCTAssertEqual(tracking.history, [.subscription("First")])
        XCTAssertEqual(subscription.history, [.requested(.unlimited)])

        publisher.send(completion: .finished)
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .completion(.finished)])

        publisher.send(completion: .failure(.oops))
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .completion(.finished)])

        let afterFinishSentDemand = publisher.send(73)
        XCTAssertEqual(afterFinishSentDemand, .none)
        XCTAssertEqual(tracking.history, [.subscription("First"),
                                          .completion(.finished)])
    }
}