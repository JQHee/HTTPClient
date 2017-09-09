//
//  HomeAPI.swift
//  YSBRXSwift
//
//  Created by HJQ on 2017/6/12.
//  Copyright © 2017年 HJQ. All rights reserved.
//

import UIKit
import Alamofire

enum HomeAPI {
    case homeList(cityName: String , page: NSInteger )
    case industryList
    case homeBannerData
}

// MARK: - 遵守的协议要实现
extension HomeAPI: Request {
    var path: String {
        switch self {
        case .homeList(_, _):
                return API.Home_hot_list
            
        case .industryList:
            return API.Home_industry_index
            
        case .homeBannerData:
            return API.Home_bannerList
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .homeList(_, _):
            return .get
            
        case .industryList:
            return .get
            
        case .homeBannerData:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .homeList(let cityName, let pageIndex):
            return [
                "city": cityName,
                "page": pageIndex
            ]
            
        case .industryList:
            return nil
            
        case .homeBannerData:
            return ["type": NSNumber.init(value: 1)]
        }
    }
    
    var host: String {
        return API.baseServer
    }
    
}
