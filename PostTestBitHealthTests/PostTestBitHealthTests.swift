//
//  PostTestBitHealthTests.swift
//  PostTestBitHealthTests
//
//  Created by Hafied on 02/11/23.
//

import XCTest
@testable import PostTestBitHealth

final class PostTestBitHealthTests: XCTestCase {

    let mealService = MealService()
    let mockData = MealModel(meals: [DataMealModel(idMeal: "1", strMeal: "Mie Lendir", strCategory: "Food", strArea: "Melayu", strMealThumb: "mie.com", strInstructions: "-")])
    
    func testMealModel() {
        XCTAssertEqual(mockData.meals[0].strMeal, "Mie Lendir")
        XCTAssertNotNil(mockData.meals)
    }
    
    func testGetAPI() {
        mealService.getMeal(slug: "search.php?f=a") { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
                let name: String = String(data.meals[0].strMeal.first!)
                XCTAssertEqual(name.lowercased(), "a")
            case .failure(let error):
                XCTFail("Failed \(error.localizedDescription)")
            }

        }
        
    }
    
    func testGetDetailAPI() {
        mealService.getMeal(slug: "lookup.php?i=52772") { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(let error):
                XCTFail("Failed \(error.localizedDescription)")
            }

        }
        
    }

}
