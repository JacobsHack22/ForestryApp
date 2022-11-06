////
////  NetworkManager.swift
////  Forestry
////
////  Created by Андрей on 06.11.2022.
////
//
//import Foundation
//import Alamofire
//
//final class NetworkManager {
//
//    private enum NetworkErrors: Error {
//        case errorDeserializingException(_ msg: String)
//    }
//
//    static let shared = NetworkManager()
//
//    private let interceptor = ApiRequestInterceptor()
//
//    private let session: Session = {
//        let manager = ServerTrustManager(
//            evaluators:
//                [
//                ApiEndpoint.apiDomen: DisabledTrustEvaluator()
//            ]
//        )
//        
//        let modelName = UIDevice.modelName
//        
//        let configuration = URLSessionConfiguration.af.default
//        configuration.headers.add(.userAgent(HTTPHeader.defaultUserAgent.value + " " + modelName))
//
//        return Session(configuration: configuration, serverTrustManager: manager)
//    }()
//
//    private var headers: HTTPHeaders {
//        let header: HTTPHeaders = [
//            "accept": "*/*",
//            "Content-Type": "*/*",
//            "X-CSRFTOKEN": AuthService.shared.randomizeNonceString()
//        ]
//
//        return header
//    }
//
//    private let decoder: JSONDecoder = {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        return decoder
//    }()
//
//    func uploadPhotos <T: Decodable> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters?,
//        type: T.Type,
//        progressHandler: ((Double) -> Void)? = nil,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        guard let parameters = parameters else { return }
//        let url = ApiEndpoint.apiUrl.appendingPath(path).appendingPath()
//
//        var headers: HTTPHeaders? = [:]
//        if let token = UserTokens.shared.getAccessToken() {
//            headers?["Authorization"] = "Bearer \(token)"
//        }
//
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        AF.upload(multipartFormData: { multipartFormData in
//            for (key, value) in parameters {
//                if let value = value as? Data {
//                    multipartFormData.append(value, withName: key, fileName: "photo.png", mimeType: "image/png")
//                }
//            }
//        },
//            to: url,
//            usingThreshold: UInt64.init(),
//            method: method,
//            headers: headers
//
//        ).uploadProgress(closure: { progress in
//            if let progressHandler = progressHandler {
//                progressHandler(progress.fractionCompleted)
//            }
//        })
//            .responseDecodable(of: type, decoder: decoder) { response in
//            self.parseJSONResponse(response: response) { result in
//                completion(result)
//            }
//        }
//    }
//
//    func uploadVideo <T: Decodable> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters,
//        type: T.Type,
//        progressHandler: ((Double) -> Void)? = nil,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        let url = ApiEndpoint.apiUrl.appendingPath(path).appendingPath()
//
//        var headers: HTTPHeaders? = [:]
//        if let token = UserTokens.shared.getAccessToken() {
//            headers?["Authorization"] = "Bearer \(token)"
//        }
//
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        AF.upload(multipartFormData: { multipartFormData in
//            for (key, value) in parameters {
//                if let value = value as? URL {
//                    multipartFormData.append(value, withName: key, fileName: "video.mp4", mimeType: "video/mp4")
//                }
//            }
//        },
//            to: url,
//            usingThreshold: UInt64.init(),
//            method: method,
//            headers: headers
//
//        ).uploadProgress(closure: { progress in
//            if let progressHandler = progressHandler {
//                progressHandler(progress.fractionCompleted)
//            }
//        })
//            .responseDecodable(of: type, decoder: decoder) { response in
//            self.parseJSONResponse(response: response) { result in
//                completion(result)
//            }
//        }
//    }
//
//    func uploadAudio <T: Decodable> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters,
//        type: T.Type,
//        progressHandler: ((Double) -> Void)? = nil,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        let url = ApiEndpoint.apiUrl.appendingPath(path).appendingPath()
//
//        var headers: HTTPHeaders? = [:]
//        if let token = UserTokens.shared.getAccessToken() {
//            headers?["Authorization"] = "Bearer \(token)"
//        }
//
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        AF.upload(multipartFormData: { multipartFormData in
//            for (key, value) in parameters {
//                if let value = value as? Data {
//                    multipartFormData.append(value, withName: key, fileName: "audio.m4a", mimeType: "audio/m4a")
//                }
//            }
//        },
//            to: url,
//            usingThreshold: UInt64.init(),
//            method: method,
//            headers: headers
//
//        ).uploadProgress(closure: { progress in
//            if let progressHandler = progressHandler {
//                progressHandler(progress.fractionCompleted)
//            }
//        })
//            .responseDecodable(of: type, decoder: decoder) { response in
//            self.parseJSONResponse(response: response) { result in
//                completion(result)
//            }
//        }
//    }
//
//    func uploadFile <T: Decodable> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters,
//        type: T.Type,
//        progressHandler: ((Double) -> Void)? = nil,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        let url = ApiEndpoint.apiUrl.appendingPath(path).appendingPath()
//
//        var headers: HTTPHeaders? = [:]
//        if let token = UserTokens.shared.getAccessToken() {
//            headers?["Authorization"] = "Bearer \(token)"
//        }
//
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        AF.upload(multipartFormData: { multipartFormData in
//            for (key, value) in parameters {
//                if let value = value as? Data {
//                    do {
//                        var isBookmarkDataStale = false
//                        guard let dataURL = try? URL(resolvingBookmarkData: value, bookmarkDataIsStale: &isBookmarkDataStale) else { return }
//                        let data = try Data(contentsOf: dataURL)
//                        let mimeType = dataURL.mimeType()
//                        multipartFormData.append(data, withName: key, fileName: "\(dataURL.lastPathComponent)", mimeType: mimeType)
//                    }
//                    catch(let error) {
//                        debugPrint(error)
//                    }
//                }
//            }
//        },
//            to: url,
//            usingThreshold: UInt64.init(),
//            method: method,
//            headers: headers
//
//        ).uploadProgress(closure: { progress in
//            if let progressHandler = progressHandler {
//                progressHandler(progress.fractionCompleted)
//            }
//        })
//            .responseDecodable(of: type, decoder: decoder) { response in
//            self.parseJSONResponse(response: response) { result in
//                completion(result)
//            }
//        }
//    }
//
//    private func parseJSONResponse <T: Decodable> (
//        response: DataResponse<T, AFError>,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        switch response.result {
//        case .success(let data):
//            print(String(data: response.data ?? Data(), encoding: .utf8) as Any)
//
//            completion(.success(data))
//        case .failure(let error):
//            print(response.debugDescription)
//
//            completion(.failure(error))
//        }
//    }
//
//    private func parseJSONResponseTest <T: Decodable> (
//        response: DataResponse<T, AFError>) throws -> T {
//        switch response.result {
//        case .success(let data): return data
//        case .failure(let AFError): throw AFError
//        }
//    }
//
//    func makeRequestToAPI<T: Decodable, Q: Decodable & HasStatusCode> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters? = nil,
//        requestType: T.Type,
//        errorType: Q.Type,
//        encoding: ParameterEncoding = JSONEncoding.default,
//        completion: @escaping (Result<T, Q>) -> Void
//    ) {
//        let url = ApiEndpoint.apiUrl.appendingPath(path)
//
//        print(headers)
//
//        session.request(
//            url,
//            method: method,
//            parameters: parameters,
//            encoding: encoding,
//            headers: headers,
//            interceptor: self.interceptor
//        ) { $0.timeoutInterval = 10 }.validate(statusCode: 200..<300).responseDecodable(of: requestType, decoder: decoder) { response in
//            do {
//                try self.request(response: response) { result in
//                    completion(result)
//                }
//            } catch {
//                debugPrint(error)
//            }
//        }
//    }
//
//    func makeRequestToAPIEmptyBody<Q: Decodable & HasStatusCode> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters? = nil,
//        errorType: Q.Type,
//        completion: @escaping (Result<Bool, Q>) -> Void
//    ) {
//        let url = ApiEndpoint.apiUrl.appendingPath(path)
//
//        session.request(
//            url,
//            method: method,
//            parameters: parameters,
//            encoding: JSONEncoding.default,
//            headers: headers,
//            interceptor: self.interceptor
//        ) { $0.timeoutInterval = 10 }.validate(statusCode: 200..<300).response { response in
//            switch(response.result) {
//            case .success(_):
//                completion(.success(true))
//            case .failure(let error):
//                debugPrint(error.errorDescription as Any)
//
//                let decoder = JSONDecoder()
//
//                do {
//                    var errorDecription = try decoder.decode(
//                        Q.self,
//                        from: response.data ?? Data()
//                    )
//                    errorDecription.statusCode = response.response?.statusCode
//                    completion(.failure(errorDecription))
//                } catch {
//                    debugPrint(NetworkErrors.errorDeserializingException(error.localizedDescription))
//                }
//            }
//        }
//    }
//
//    func refreshToken<T: Decodable, Q: Decodable & HasStatusCode> (
//        token: Parameters?,
//        requestType: T.Type,
//        errorType: Q.Type,
//        completion: @escaping (Result<T, Q>) -> Void
//    ) {
//        let path = ApiEndpoint.auth.appendingPath(ApiEndpoint.refresh)
//        let url = ApiEndpoint.apiUrl.appendingPath(path).appendingPath()
//
//        session.request(
//            url,
//            method: .post,
//            parameters: token,
//            encoding: JSONEncoding.default
//        ) { $0.timeoutInterval = 10 }.validate().responseDecodable(of: requestType, decoder: decoder) { response in
//            do {
//                try self.request(response: response) { result in
//                    completion(result)
//                }
//            } catch let error {
//                print(error)
//            }
//        }
//    }
//
//    private func request2Factor<T: Decodable, Q: Decodable & HasStatusCode> (
//        response: DataResponse<T, AFError>,
//        completion: @escaping (Result<T, Q>) -> Void
//    ) throws {
//        print(response.response?.statusCode ?? "")
//        switch response.result {
//        case .success(let data):
//            debugPrint("Success.")
//            completion(.success(data))
//        case .failure(let error):
//            debugPrint("Failure.")
//            debugPrint(error.errorDescription as Any)
//
//            let decoder = JSONDecoder()
//
//            do {
//                let errorDecription = try decoder.decode(
//                    Q.self,
//                    from: response.data ?? Data()
//                )
//                completion(.failure(errorDecription))
//            } catch {
//                throw NetworkErrors.errorDeserializingException(error.localizedDescription)
//            }
//        }
//    }
//
//    private func request<T: Decodable, Q: Decodable & HasStatusCode> (
//        response: DataResponse<T, AFError>,
//        completion: @escaping (Result<T, Q>) -> Void
//    ) throws {
//        switch response.result {
//        case .success(let data):
//            completion(.success(data))
//        case .failure(let error):
//            debugPrint(String(data: response.data ?? Data(), encoding: .utf8) as Any)
//            debugPrint(error.errorDescription as Any)
//
//            let decoder = JSONDecoder()
//
//            do {
//                var errorDecription = try decoder.decode(
//                    Q.self,
//                    from: response.data ?? Data()
//                )
//                errorDecription.statusCode = response.response?.statusCode
//                completion(.failure(errorDecription))
//            } catch {
//                throw NetworkErrors.errorDeserializingException(error.localizedDescription)
//            }
//        }
//    }
//}
//
//extension NetworkManager {
//
//    @discardableResult
//    func makeRequestToAPI<T: Decodable, Q: Decodable & HasStatusCode> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters? = nil,
//        requestType: T.Type,
//        errorType: Q.Type,
//        encoding: ParameterEncoding = JSONEncoding.default
//    ) async throws -> T {
//
//        let url = ApiEndpoint.apiUrl.appendingPath(path)
//
//        return try await withCheckedThrowingContinuation { continuation in
//            session.request(
//                url,
//                method: method,
//                parameters: parameters,
//                encoding: encoding,
//                headers: headers,
//                interceptor: self.interceptor
//            ) { $0.timeoutInterval = 10 }.validate(statusCode: 200..<300).responseDecodable(of: requestType, decoder: decoder) { response in
//
//                debugPrint(self.headers)
//
//                switch response.result {
//                case .success(let data):
//                    continuation.resume(returning: data)
//                case .failure(let error):
//                    debugPrint(error.errorDescription as Any)
//
//                    let decoder = JSONDecoder()
//
//                    do {
//                        var errorDecription = try decoder.decode(
//                            Q.self,
//                            from: response.data ?? Data()
//                        )
//                        errorDecription.statusCode = response.response?.statusCode
//                        guard let error = errorDecription as? Error else {
//                            continuation.resume(throwing: NetworkErrors.errorDeserializingException(error.localizedDescription))
//                            return
//                        }
//                        continuation.resume(throwing: error)
//                    } catch {
//                        continuation.resume(throwing: NetworkErrors.errorDeserializingException(error.localizedDescription))
//                    }
//                }
//            }
//        }
//    }
//
//    func makeRequestToAPIEncodable<T: Encodable, Q: Decodable & HasStatusCode> (
//        path: String,
//        method: HTTPMethod,
//        parameters: T? = nil,
//        errorType: Q.Type,
//        encoding: ParameterEncoding = JSONEncoding.default
//    ) async throws {
//        let url = ApiEndpoint.apiUrl.appendingPath(path)
//
//        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
//
//            session.request(url,
//                method: method,
//                parameters: parameters,
//                encoder: JSONParameterEncoder.default,
//                headers: headers,
//                interceptor: interceptor
//            ).validate(statusCode: 200..<300).response { responce in
//                do {
//                    let _ = try self.request(response: responce, errorType: errorType)
//                    continuation.resume()
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//
//    func makeRequestToAPIEmptyBody<Q: Decodable & HasStatusCode> (
//        path: String,
//        method: HTTPMethod,
//        parameters: Parameters? = nil,
//        errorType: Q.Type
//    ) async throws -> Void {
//
//        let url = ApiEndpoint.apiUrl.appendingPath(path)
//
//        return try await withCheckedThrowingContinuation { continuation in
//
//            var nillableContinuation: CheckedContinuation<Void, Error>? = continuation
//
//            session.request(
//                url,
//                method: method,
//                parameters: parameters,
//                encoding: JSONEncoding.default,
//                headers: headers,
//                interceptor: self.interceptor
//            ) { $0.timeoutInterval = 10 }.validate(statusCode: 200..<300).response { response in
//                switch response.result {
//                case .success(_):
//                    nillableContinuation?.resume()
//                    nillableContinuation = nil
//                case .failure(let error):
//                    debugPrint(error.errorDescription as Any)
//
//                    let decoder = JSONDecoder()
//
//                    do {
//                        var errorDecription = try decoder.decode(
//                            Q.self,
//                            from: response.data ?? Data()
//                        )
//                        errorDecription.statusCode = response.response?.statusCode
//                        guard let error = errorDecription as? Error else {
//                            continuation.resume(throwing: NetworkErrors.errorDeserializingException(error.localizedDescription))
//                            return
//                        }
//                        continuation.resume(throwing: error)
//                    } catch {
//                        continuation.resume(throwing: NetworkErrors.errorDeserializingException(error.localizedDescription))
//                    }
//                }
//            }
//        }
//    }
//
//    func refreshToken<T: Decodable, Q: Decodable & HasStatusCode> (
//        token: Parameters?,
//        requestType: T.Type,
//        errorType: Q.Type) async throws -> T {
//        let path = ApiEndpoint.auth.appendingPath(ApiEndpoint.refresh)
//        let url = ApiEndpoint.apiUrl.appendingPath(path).appendingPath()
//
//        return try await withCheckedThrowingContinuation { continuation in
//            session.request(
//                url,
//                method: .post,
//                parameters: token,
//                encoding: JSONEncoding.default
//            ) { $0.timeoutInterval = 10 }.validate().responseDecodable(of: requestType, decoder: decoder) { response in
//                do {
//                    let data = try self.request(response: response, errorType: errorType)
//                    continuation.resume(returning: data)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//
//    private func request<T: Decodable, Q: Decodable & HasStatusCode> (
//        response: DataResponse<T, AFError>,
//        errorType: Q.Type
//    ) throws -> T {
//
//        switch response.result {
//        case .success(let data):
//            return data
//        case .failure(let error):
//            debugPrint(error.asAFError?.errorDescription as Any)
//
//            let decoder = JSONDecoder()
//
//            do {
//                var errorDecription = try decoder.decode(
//                    Q.self,
//                    from: response.data ?? Data()
//                )
//                errorDecription.statusCode = response.response?.statusCode
//                guard let errorDecription = errorDecription as? Error else {
//                    throw NetworkErrors.errorDeserializingException(error.localizedDescription)
//                }
//                throw errorDecription
//            } catch {
//                throw NetworkErrors.errorDeserializingException(error.localizedDescription)
//            }
//        }
//    }
//}
//
