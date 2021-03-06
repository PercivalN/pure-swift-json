import XCTest
@testable import PureSwiftJSONCoding
@testable import PureSwiftJSONParsing

class JSONUnkeyedEncodingContainerTests: XCTestCase {
  
  // MARK: - NaN & Inf -
  
  struct DoubleInArrayBox: Encodable {
    let number: Double
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      try container.encode(number)
    }
  }
  
  func testEncodeDoubleNAN() {
    do {
      let result = try PureSwiftJSONCoding.JSONEncoder().encode(DoubleInArrayBox(number: .nan))
      XCTFail("Did not expect to have a result: \(result)")
    }
    catch Swift.EncodingError.invalidValue(let value as Double, let context) {
      XCTAssert(value.isNaN) // expected
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first?.stringValue, "Index 0")
      XCTAssertEqual(context.debugDescription, "Unable to encode Double.nan directly in JSON.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testEncodeDoubleInf() {
    do {
      let result = try PureSwiftJSONCoding.JSONEncoder().encode(DoubleInArrayBox(number: .infinity))
      XCTFail("Did not expect to have a result: \(result)")
    }
    catch Swift.EncodingError.invalidValue(let value as Double, let context) {
      XCTAssert(value.isInfinite) // expected
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first?.stringValue, "Index 0")
      XCTAssertEqual(context.debugDescription, "Unable to encode Double.inf directly in JSON.")
    }
    catch {
      // missing expected catch
       XCTFail("Unexpected error: \(error)")
    }
  }
  
  struct FloatInArrayBox: Encodable {
    let number: Float
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      try container.encode(number)
    }
  }
  
  func testEncodeFloatNAN() {
    do {
      let result = try PureSwiftJSONCoding.JSONEncoder().encode(FloatInArrayBox(number: .nan))
      XCTFail("Did not expect to have a result: \(result)")
    }
    catch Swift.EncodingError.invalidValue(let value as Float, let context) {
      XCTAssert(value.isNaN) // expected
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first?.stringValue, "Index 0")
      XCTAssertEqual(context.debugDescription, "Unable to encode Float.nan directly in JSON.")
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testEncodeFloatInf() {
    do {
      let result = try PureSwiftJSONCoding.JSONEncoder().encode(FloatInArrayBox(number: .infinity))
      XCTFail("Did not expect to have a result: \(result)")
    }
    catch Swift.EncodingError.invalidValue(let value as Float, let context) {
      XCTAssert(value.isInfinite) // expected
      XCTAssertEqual(context.codingPath.count, 1)
      XCTAssertEqual(context.codingPath.first?.stringValue, "Index 0")
      XCTAssertEqual(context.debugDescription, "Unable to encode Float.inf directly in JSON.")
    }
    catch {
      // missing expected catch
       XCTFail("Unexpected error: \(error)")
    }
  }

  
  // MARK: - Nested Container -
  
  func testNestedKeyedContainer() {
    struct ObjectInArray: Encodable {
      let firstName: String
      let surname: String

      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        var nestedContainer = container.nestedContainer(keyedBy: NameCodingKeys.self)
        try nestedContainer.encode(firstName, forKey: .firstName)
        try nestedContainer.encode(surname, forKey: .surname)
      }
      
      private enum NameCodingKeys: String, CodingKey {
        case firstName = "firstName"
        case surname = "surname"
      }
    }
    
    do {
      let object = ObjectInArray(firstName: "Adam", surname: "Fowler")
      let json = try PureSwiftJSONCoding.JSONEncoder().encode(object)
      
      let parsed = try JSONParser().parse(bytes: json)
      XCTAssertEqual(parsed, .array([.object(["firstName": .string("Adam"), "surname": .string("Fowler")])]))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testNestedUnkeyedContainer() {
    struct NumbersInArray: Encodable {
      let numbers: [Int]
      
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        var numbersContainer = container.nestedUnkeyedContainer()
        try numbers.forEach() { try numbersContainer.encode($0) }
      }

      private enum CodingKeys: String, CodingKey {
        case numbers
      }
    }

    do {
      let object = NumbersInArray(numbers: [1, 2, 3, 4])
      let json = try PureSwiftJSONCoding.JSONEncoder().encode(object)

      let parsed = try JSONParser().parse(bytes: json)
      XCTAssertEqual(parsed, .array([.array([.number("1"), .number("2"), .number("3"), .number("4")])]))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}



