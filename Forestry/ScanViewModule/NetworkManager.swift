//
//  NetworkManager.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import Alamofire

final class NetworkManager {
    private enum Constants {
        static let endpoint = "https://forestry-367712.ey.r.appspot.com"
    }
    
    private enum NetworkErrors: Error {
        case errorDeserializingException(_ msg: String)
    }

    static let shared = NetworkManager()

    private var headers: HTTPHeaders {
        let header: HTTPHeaders = [
            "accept": "*/*",
            "Content-Type": "*/*"
        ]

        return header
    }

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()

    func uploadPhotos <T: Decodable> (
        path: String,
        method: HTTPMethod,
        parameters: Parameters?,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let parameters = parameters else { return }
        let url = Constants.endpoint.appendingPath(path).appendingPath()

        let headers: HTTPHeaders? = [:]

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                if let value = value as? Data {
                    multipartFormData.append(value, withName: key, fileName: "photo.png", mimeType: "image/png")
                }
            }
        },
            to: url,
            usingThreshold: UInt64.init(),
            method: method,
            headers: headers

        ).responseDecodable(of: type, decoder: decoder) { response in
            self.parseJSONResponse(response: response) { result in
                completion(result)
            }
        }
    }
    
    private func parseJSONResponse <T: Decodable> (
        response: DataResponse<T, AFError>,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch response.result {
        case .success(let data):
            print(String(data: response.data ?? Data(), encoding: .utf8) as Any)

            completion(.success(data))
        case .failure(let error):
            print(response.debugDescription)

            completion(.failure(error))
        }
    }

    private func parseJSONResponseTest <T: Decodable> (
        response: DataResponse<T, AFError>) throws -> T {
        switch response.result {
        case .success(let data): return data
        case .failure(let AFError): throw AFError
        }
    }

    func makeRequestToAPI<T: Decodable, Q: Decodable> (
        path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        requestType: T.Type,
        errorType: Q.Type,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Result<T, Q>) -> Void
    ) {
        let url = Constants.endpoint.appendingPath(path)

        print(headers)

        AF.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        ) { $0.timeoutInterval = 10 }.validate(statusCode: 200..<300).responseDecodable(of: requestType, decoder: decoder) { response in
            do {
                try self.request(response: response) { result in
                    completion(result)
                }
            } catch {
                debugPrint(error)
            }
        }
    }

    private func request<T: Decodable, Q: Decodable> (
        response: DataResponse<T, AFError>,
        completion: @escaping (Result<T, Q>) -> Void
    ) throws {
        switch response.result {
        case .success(let data):
            completion(.success(data))
        case .failure(let error):
            debugPrint(String(data: response.data ?? Data(), encoding: .utf8) as Any)
            debugPrint(error.errorDescription as Any)

            let decoder = JSONDecoder()

            do {
                let errorDecription = try decoder.decode(
                    Q.self,
                    from: response.data ?? Data()
                )
                completion(.failure(errorDecription))
            } catch {
                throw NetworkErrors.errorDeserializingException(error.localizedDescription)
            }
        }
    }
}

extension NetworkManager {

    @discardableResult
    func makeRequestToAPI<T: Decodable, Q: Decodable> (
        path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        requestType: T.Type,
        errorType: Q.Type,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async throws -> T {

        let url = Constants.endpoint.appendingPath(path)

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            ) { $0.timeoutInterval = 10 }.validate(statusCode: 200..<300).responseDecodable(of: requestType, decoder: decoder) { response in

                debugPrint(self.headers)

                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    debugPrint(error.errorDescription as Any)

                    let decoder = JSONDecoder()

                    do {
                        let errorDecription = try decoder.decode(
                            Q.self,
                            from: response.data ?? Data()
                        )
                        guard let error = errorDecription as? Error else {
                            continuation.resume(throwing: NetworkErrors.errorDeserializingException(error.localizedDescription))
                            return
                        }
                        continuation.resume(throwing: error)
                    } catch {
                        continuation.resume(throwing: NetworkErrors.errorDeserializingException(error.localizedDescription))
                    }
                }
            }
        }
    }

    func makeRequestToAPIEncodable<T: Encodable, Q: Decodable> (
        path: String,
        method: HTTPMethod,
        parameters: T? = nil,
        errorType: Q.Type,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async throws {
        let url = Constants.endpoint.appendingPath(path)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in

            AF.request(url,
                method: method,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: headers
            ).validate(statusCode: 200..<300).response { responce in
                do {
                    let _ = try self.request(response: responce, errorType: errorType)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func request<T: Decodable, Q: Decodable> (
        response: DataResponse<T, AFError>,
        errorType: Q.Type
    ) throws -> T {

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            debugPrint(error.asAFError?.errorDescription as Any)

            let decoder = JSONDecoder()

            do {
                let errorDecription = try decoder.decode(
                    Q.self,
                    from: response.data ?? Data()
                )
                guard let errorDecription = errorDecription as? Error else {
                    throw NetworkErrors.errorDeserializingException(error.localizedDescription)
                }
                throw errorDecription
            } catch {
                throw NetworkErrors.errorDeserializingException(error.localizedDescription)
            }
        }
    }
}

