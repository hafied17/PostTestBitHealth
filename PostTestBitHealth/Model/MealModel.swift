//
//  MealModel.swift
//  PostTestBitHealth
//
//  Created by Hafied on 01/11/23.
//

struct MealModel: Codable {
    let meals: [DataMealModel]
}

struct DataMealModel: Codable {
    let idMeal: String
    let strMeal: String
    let strCategory: String
    let strArea: String
    let strMealThumb: String
    let strInstructions: String
}
