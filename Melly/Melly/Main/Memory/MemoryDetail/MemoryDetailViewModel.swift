//
//  MemoryDetailViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class MemoryDetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    var isRecommented:Bool = false
    var comment:[Comment] = []
    
    var memory:Memory
    
    lazy var keywordData:Observable<[String]> = {
        return Observable<[String]>.just(memory.keyword)
    }()
    
    let input = Input()
    let output = Output()
    
    
    struct Input {
        let refreshComment = PublishRelay<Void>()
    }
    
    struct Output {
        let errorValue = PublishRelay<String>()
        let completeRefresh = PublishRelay<Void>()
        let commentCountValue = PublishRelay<Int>()
    }
    
    init(_ memory: Memory) {
        self.memory = memory
        
        input.refreshComment
            .flatMap(getComment)
            .subscribe({ event in
                switch event {
                case .next(let data):
                    self.comment = data.comments
                    self.output.commentCountValue.accept(data.commentCount)
                    self.output.completeRefresh.accept(())
                case .completed:
                    break
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
    }
    
    
    /**
     해당 메모리에 기재되어 있는 댓글을 가져온다.
     - Parameters:None
     - Throws: MellyError
     - Returns:CommentData
     */
    func getComment() -> Observable<CommentData> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/comment/memory/\(self.memory.memoryId)"
                
                AF.request(url, method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "댓글 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data as Any) {
                                        
                                        if let result = try? decoder.decode(CommentData.self, from: data) {
                                            
                                            observer.onNext(result)
                                        }
                                        
                                    }
                                   
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    observer.onError(error)
                                }
                            }
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    
    
    
}
