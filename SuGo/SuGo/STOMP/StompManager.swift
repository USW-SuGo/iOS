////
////  StompClient.swift
////  SuGo
////
////  Created by 한지석 on 2022/10/03.
////
//
//import Foundation
//
//import StompClientLib
//
//// subscribe = 수신
//// topic = 방
//
//// 1. 채팅방 생성 : pub / sub 구현을 위한 Topic 생성
//// 2. 채팅방 입장 : Topic 구독
//// 3. 채팅방에서 메세지 송수신 : 해당 Topic으로 메세지를 송신(pub), 메세지를 수신(sub)
//
//class StompManager {
//
//    static let shared = StompManager()
//
//    private let url = URL(string: "")!
//    private var socketClient: StompClientLib? = nil
//
//    // 소켓 등록
//    func registerSocket() {
//        if socketClient == nil {
//            socketClient?.openSocketWithURLRequest(request: NSURLRequest(url: url as URL),
//                                                   delegate: self)
//        }
//    }
//
////    func subscribe() {
////        if socketClient != nil, socketClient?.isConnected() {
////            print("채팅방 입장 : SubScribe Topic")
////            // 구독할 토픽 - 채팅방 입장
////            socketClient?.subscribe(destination: "")
////        }
////    }
////
////    func disconnect() {
////        if socketClient != nil, socketClient?.isConnected() {
////            socketClient?.disconnect()
////        }
////    }
//
//}
//
//extension StompManager: StompClientLibDelegate {
//
//    func stompClient(client: StompClientLib!,
//                     didReceiveMessageWithJSONBody jsonBody: AnyObject?,
//                     akaStringBody stringBody: String?,
//                     withHeader header: [String : String]?,
//                     withDestination destination: String) {
//
//        print("Destination : \(destination)")
//        print("JSON Body : \(String(describing: jsonBody))")
//        print("String Body : \(stringBody ?? "nil")")
//
//    }
//
//    func stompClientDidDisconnect(client: StompClientLib!) {
//        print("Socket is Disconnected")
//    }
//
//    // 메세지 수신 = subscribe
//    func stompClientDidConnect(client: StompClientLib!) {
//        print("Socket is Connected")
//        socketClient?.subscribe(destination: "")
//    }
//
//    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
//        print("Receipt : \(receiptId)")
//    }
//
//    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
//        print("Error Send : \(String(describing: message))")
//        socketClient?.disconnect()
//        socketClient = nil
//        registerSocket()
//    }
//
//    func serverDidSendPing() {
//        print("Server Ping")
//    }
//
//}
