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
    
    var commentID:Int?
    
    lazy var keywordData:Observable<[String]> = {
        return Observable<[String]>.just(memory.keyword)
    }()
    
    let input = Input()
    let output = Output()
    
    
    struct Input {
        let refreshComment = PublishRelay<Void>()
        let deleteMemoryObserver = PublishRelay<Void>()
        let textFieldEditObserver = PublishRelay<String?>()
        let likeButtonClicked = PublishRelay<Comment?>()
        
        let commentEditObserver = PublishRelay<Comment>()
        let commentDeleteObserver = PublishRelay<Comment>()
        let blockMemoryObserver = PublishRelay<Void>()
        let blockCommentObserver = PublishRelay<Comment>()
        
        let reviseCommentObserver = PublishRelay<Comment>()
        
        
        
    }
    
    struct Output {
        let errorValue = PublishRelay<String>()
        let completeRefresh = PublishRelay<Void>()
        let commentCountValue = PublishRelay<Int>()
        let isDeleteMemory = PublishRelay<Void>()
        let completeDelete = PublishRelay<Void>()
        let commentEdit = PublishRelay<Comment>()
        let commentRevise = PublishRelay<Comment>()
        
    }
    
    
    
    init(_ memory: Memory) {
        self.memory = memory
        
        input.refreshComment
            .flatMap(getComment)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    
                    if let data = result.success as? CommentData {
                        self.comment = data.comments
                        self.output.commentCountValue.accept(data.comments.count)
                        self.output.completeRefresh.accept(())
                    }
                    
                }
                
            }).disposed(by: disposeBag)
        
        input.deleteMemoryObserver
            .flatMap(deleteMemory)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.completeDelete.accept(())
                }
                
                
            }).disposed(by: disposeBag)
        
        input.textFieldEditObserver
            .flatMap(addComment)
            .subscribe(onNext: { result in
                self.commentID = nil
                self.isRecommented = false
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.input.refreshComment.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.likeButtonClicked
            .flatMap(likeComment)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.input.refreshComment.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.commentEditObserver
            .subscribe(onNext: { value in
                self.output.commentEdit.accept(value)
            }).disposed(by: disposeBag)
        
        input.commentDeleteObserver
            .flatMap(deleteComment)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.input.refreshComment.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.blockMemoryObserver
            .flatMap(blockMemory)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.completeDelete.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.blockCommentObserver
            .flatMap(blockComment)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.input.refreshComment.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.reviseCommentObserver
            .subscribe(onNext: { value in
                
                self.commentID = value.id
                self.isRecommented = true
                self.output.commentRevise.accept(value)
            }).disposed(by: disposeBag)
        
    }
    
    
    /**
     해당 메모리에 기재되어 있는 댓글을 가져온다.
     - Parameters:None
     - Throws: MellyError
     - Returns:CommentData
     */
    func getComment() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
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
                                        
                                        if let comments = try? decoder.decode(CommentData.self, from: data) {
                                            result.success = comments
                                            observer.onNext(result)
                                        }
                                        
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                result.error = error
                                observer.onNext(result)
                            }
                        case .failure(let error):
                            let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    func deleteMemory() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/comment/\(self.memory.memoryId)", method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "메세지 삭제 완료" {
                                    observer.onNext(result)
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                result.error = error
                                observer.onNext(result)
                            }
                        case .failure(let error):
                            let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
                
                
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    func addComment(_ text: String?) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
            
            if let user = User.loginedUser,
               let text = text, text != ""{
                
                if let commentId = self.commentID {
                    
                    let header:HTTPHeaders = [
                        "Connection":"keep-alive",
                        "Content-Type": "application/json",
                        "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                    
                    let parameters:Parameters = [
                        "content": text
                    ]
                    
                    AF.request("https://api.melly.kr/api/comment/\(commentId)", method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                        .responseData { response in
                            switch response.result {
                            case .success(let data):
                                let decoder = JSONDecoder()
                                if let json = try? decoder.decode(ResponseData.self, from: data) {
                                    
                                    if json.message == "성공" {
                                        observer.onNext(result)
                                    } else {
                                        let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                        result.error = error
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            case .failure(let error):
                                let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                                result.error = mellyError
                                observer.onNext(result)
                            }
                        }
                    
                } else {
                    
                    let header:HTTPHeaders = [
                        "Connection":"keep-alive",
                        "Content-Type": "application/json",
                        "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                    
                    let parameters:Parameters = [
                        "content": text,
                        "memoryId": self.memory.memoryId
                    ]
                    
                    AF.request("https://api.melly.kr/api/comment", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                        .responseData { response in
                            switch response.result {
                            case .success(let data):
                                let decoder = JSONDecoder()
                                if let json = try? decoder.decode(ResponseData.self, from: data) {
                                    
                                    if json.message == "댓글 추가 완료" {
                                        observer.onNext(result)
                                    } else {
                                        let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                        result.error = error
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                            case .failure(let error):
                                let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                                result.error = mellyError
                                observer.onNext(result)
                            }
                        }
                    
                }
                
            } else {
                let error = MellyError(code: 999, msg: "댓글을 입력해주세요")
                result.error = error
                observer.onNext(result)
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    func likeComment(_ comment: Comment?) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
            
            if let user = User.loginedUser,
               let comment = comment {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                if comment.loginUserLike {
                    
                    AF.request("https://api.melly.kr/api/comment/\(comment.id)/like", method: .delete, headers: header)
                        .responseData { response in
                            switch response.result {
                            case .success(let data):
                                let decoder = JSONDecoder()
                                if let json = try? decoder.decode(ResponseData.self, from: data) {
                                    print(json)
                                    if json.message == "댓글에 좋아요 삭제 완료" {
                                        observer.onNext(result)
                                    } else {
                                        let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                        result.error = error
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                            case .failure(let error):
                                let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                                result.error = mellyError
                                observer.onNext(result)
                            }
                        }
                    
                } else {
                    let parameters:Parameters = [
                        "commentId": comment.id
                    ]
                    
                    AF.request("https://api.melly.kr/api/comment/like", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                        .responseData { response in
                            switch response.result {
                            case .success(let data):
                                let decoder = JSONDecoder()
                                if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                    if json.message == "댓글에 좋아요 추가 완료" {
                                        observer.onNext(result)
                                    } else {
                                        let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                        result.error = error
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                            case .failure(let error):
                                let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                                result.error = mellyError
                                observer.onNext(result)
                            }
                        }
                }
                
            } else {
                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                result.error = error
                observer.onNext(result)
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    func deleteComment(_ comment: Comment) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/comment/\(comment.id)", method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "댓글 삭제 완료" {
                                    observer.onNext(result)
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                result.error = error
                                observer.onNext(result)
                            }
                        case .failure(let error):
                            let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
                
                
            } else {
                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                result.error = error
                observer.onNext(result)
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    func blockMemory() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = [
                    "memoryId": self.memory.memoryId
                ]
                
                AF.request("https://api.melly.kr/api/block/memory", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "성공" {
                                    observer.onNext(result)
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                result.error = error
                                observer.onNext(result)
                            }
                        case .failure(let error):
                            let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
                
                
            }
            
            return Disposables.create()
        }
        
    }
    
    func blockComment(_ comment: Comment) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = [
                    "commentId": comment.id
                ]
                
                AF.request("https://api.melly.kr/api/block/comment", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "성공" {
                                    observer.onNext(result)
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                result.error = error
                                observer.onNext(result)
                            }
                        case .failure(let error):
                            let mellyError = MellyError(code: 999, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
                
                
            }
            
            return Disposables.create()
        }
        
    }
    
    
    
    
}
