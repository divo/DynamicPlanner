//
//  ParserTest.swift
//  DynamicPlanerTests
//
//  Created by Steven Diviney on 28/09/2023.
//

import XCTest

@testable import Markdown_Planner
final class ParserTest: XCTestCase {
  
  let vm = ViewModel()
  
  // Minimal template requires at least 2 lines to parse correctly
  // Not a limitation I care about
  func testBasicModel() throws {
    let models = vm.decode(state: "# Test\n")
    
    XCTAssertEqual(models[0].type, ElementModel.ViewType.heading)
    XCTAssertEqual(models[1].type, ElementModel.ViewType.field)
    XCTAssertEqual(models.count, 2)
  }
  
  // MARK: CheckModel
  func testCheckModel() throws {
    let models = vm.decode(state: "- [ ] Testing\n")
    
    XCTAssertEqual(models.first?.type, .check)
    XCTAssertEqual(models.first?.text, "Testing")
    XCTAssertEqual(models.count, 2)
  }

  func testCheckModelValid() throws {
    XCTAssertEqual(vm.decode(state: "- [ ]\n").first?.type, .check)
    XCTAssertEqual(vm.decode(state: "- [x]\n").first?.type, .check)
    
    XCTAssertEqual(vm.decode(state: "- [ ] \n").first?.type, .check)
    XCTAssertEqual(vm.decode(state: "- [x] \n").first?.type, .check)
    XCTAssertEqual(vm.decode(state: "- [ ] Testing\n").first?.type, .check)
    XCTAssertEqual(vm.decode(state: "- [x] Testing\n").first?.type, .check)
  }

  func testInvalidCheckModel() throws {
    XCTAssertEqual(vm.decode(state: "-\n").first?.type, .empty)
    XCTAssertEqual(vm.decode(state: "- [\n").first?.type, .empty)
    XCTAssertEqual(vm.decode(state: "-[]\n").first?.type, .empty)
    XCTAssertEqual(vm.decode(state: "- []\n").first?.type, .empty)
    XCTAssertEqual(vm.decode(state: "-[ ]\n").first?.type, .empty)
    XCTAssertEqual(vm.decode(state: "-[ ] Testing\n").first?.type, .empty)
    XCTAssertEqual(vm.decode(state: "- [ ]Testing\n").first?.type, .empty)
    XCTAssertEqual(vm.decode(state: "- [C]Testing\n").first?.type, .empty)
  }

  func testLinkModel() throws {
    vm.date = Date(timeIntervalSince1970: 0)
    let models = vm.decode(state: "[8](08:00) Morning\n")

    XCTAssertEqual(models.first?.type, .notification)
    XCTAssertEqual(models.first?.date.description, "1970-01-01 08:00:00 +0000")
    XCTAssertEqual(models.first?.text, " Morning")
    XCTAssertEqual(models.first?.label, "8")
  }
  
  func testLinkModelDateFormats() throws {
    vm.date = Date(timeIntervalSince1970: 0)
    
    XCTAssertEqual(vm.decode(state: "[8](08:00)\n").first?.date.description, "1970-01-01 08:00:00 +0000")
    XCTAssertEqual(vm.decode(state: "[8](8:00)\n").first?.date.description, "1970-01-01 08:00:00 +0000")
    XCTAssertEqual(vm.decode(state: "[8](8)\n").first?.date.description, "1970-01-01 08:00:00 +0000")
    XCTAssertEqual(vm.decode(state: "[8](08)\n").first?.date.description, "1970-01-01 08:00:00 +0000")
  }
  
  func testLinkModelInvalidDates() throws {
    vm.date = Date(timeIntervalSince1970: 0)
    
  }
}
