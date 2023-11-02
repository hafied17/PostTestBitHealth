//
//  MealService.swift
//  PostTestBitHealth
//
//  Created by Hafied on 02/11/23.
//

import Alamofire

struct MealService {
    func getMeal(slug: String, completion: @escaping (Result<MealModel, Error>) -> Void) {
        let request = AF.request(api + slug)
        request.responseDecodable(of: MealModel.self) { response in
            switch response.result {
            case .success(let success):
                completion(.success(success))
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }
}
