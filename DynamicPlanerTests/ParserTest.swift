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
  
  func testBasicModel() throws {
    let models = vm.decode(state: "### Test\n")
    
    XCTAssertEqual(models[0].type, ElementModel.ViewType.heading)
    XCTAssertEqual(models[1].type, ElementModel.ViewType.field)
    XCTAssertEqual(models.count, 2)
  }
  
}
