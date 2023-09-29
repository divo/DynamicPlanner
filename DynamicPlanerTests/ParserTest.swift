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
}
