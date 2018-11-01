/*
This file is part of Paymon.

Paymon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Paymon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Paymon.  If not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import UIKit
import MBProgressHUD

class NetworkManager: NSObject, NetworkManagerDelegate {
    class FutureRequest {
        var id:Int64
        var packet:Packet
        var callback:PacketResponseFunc?

        public init(id:Int64, packet:Packet, callback:PacketResponseFunc?) {
            self.id = id
            self.packet = packet
            self.callback = callback
        }
    }

    static let shared = NetworkManager()

    var requestsMap: [Int64: PacketResponseFunc]
    var nm: NetworkManager_Wrapper!
    var handshaked = false
    var lastOutgoingMessageId: Int64 = 0
    var lastPacket: Packet?
    var lastKeepAlive: Int64 = 0
    var isConnected: Bool = false
    var queue: DispatchQueue?
    var futureRequests:[FutureRequest] = []
    var keepAliveThread: Thread!

    static func keepAliveProc() {
        let nm = NetworkManager.shared
        nm.lastKeepAlive = Utils.currentTimeMillis() + Int64(10 * 1000)
        var lastKeepAliveTime: Int64 = nm.lastKeepAlive / 1000

        while !nm.keepAliveThread.isCancelled {
            let curtime = Utils.currentTimeMillis() / 1000;
            if nm.isConnected {
                let d = curtime - lastKeepAliveTime
                if d >= 10 {
                    lastKeepAliveTime = Utils.currentTimeMillis() / 1000;
                    nm.sendPacket(RPC.PM_keepAlive(), onComplete: { (p, e) in
                        nm.lastKeepAlive = Utils.currentTimeMillis() / 1000;
                    })
                }
            } else {
                let d = curtime - nm.lastKeepAlive
                if d > 30 {
                    nm.reconnect();
                }
            }
            sleep(5)
        }

        nm.threadWillBeFinished()
    }

    func threadWillBeFinished() {
        if keepAliveThread == nil || isConnected && keepAliveThread.isCancelled {
            keepAliveThread = Thread(block: NetworkManager.keepAliveProc)
            keepAliveThread.start()
        }
    }

    private override init() {
        requestsMap = [:]
        queue = DispatchQueue(label: "netQueue")

        super.init()
        nm = NetworkManager_Wrapper(delegate: self)
    }

    deinit {

    }

    public func sendFutureRequests() {
        if futureRequests.isEmpty { return }

        let request = futureRequests.removeFirst()
        sendPacket(request.packet, onComplete: { p, e in
            request.callback?(p, e)
            self.sendFutureRequests()
        }, messageID: request.id)
    }
    
    public func generateMessageID() -> Int64 {
        var messageId = Int64(floor((((Double(Utils.currentTimeMillis() + Int64(1 * 1000))) * 4294967296.0) / 1000.0)))
        if messageId <= lastOutgoingMessageId {
            messageId = lastOutgoingMessageId + 1
        }
        while messageId % 4 != 0 {
            messageId += 1
        }
        lastOutgoingMessageId = messageId
        return messageId
    }

    private func processServerResponse(object: Packet!, messageID: Int64) {
        NetworkManager_Wrapper.netQueue().run {
            var packet: Packet! = object
            self.lastKeepAlive = 1 / 1000
            var error: RPC.PM_error! = nil

            let listener = self.requestsMap[messageID]
            self.requestsMap.removeValue(forKey: messageID)

            if (packet is RPC.Message) {
                let message = packet as! RPC.Message
                MessageDataManager.shared.updateMessage(messageObject: message)

            } else if (packet is RPC.PM_photoURL) {
                let update = packet as! RPC.PM_photoURL
                if let peerUser = update.peer as? RPC.PM_peerUser {
                    
                    UserDataManager.shared.updateUserPhotoUrl(id: peerUser.user_id, url: update.url)

                    ChatsDataManager.shared.updateChatsPhotoUrl(id: peerUser.user_id, url: update.url)

                    if User.currentUser?.id == peerUser.user_id {
                        User.currentUser?.photoUrl.url = update.url
                        User.saveConfig()
                    }

                } else if let peerGroup = update.peer as? RPC.PM_peerGroup {
                    GroupDataManager.shared.updateGroupUrl(id: peerGroup.group_id, url: update.url)
                }
            } else if (packet is RPC.PM_error) {
                error = packet as? RPC.PM_error
                packet = nil
                print("Paymon Error (\(error.code!)): \(error.message!)")

                switch error.code {
                case RPC.ERROR_KEY:
                    print("ERROR_KEY, reconnecting")
                    NetworkManager.shared.reconnect()
                case RPC.ERROR_AUTH_TOKEN:
                    print("ERROR_AUTH_TOKEN")
                    UserManager.shared.authByToken()
                case RPC.ERROR_AUTH:
                    
                    print("ERROR_AUTH")
                    NetworkManager.shared.reconnect()

                case RPC.ERROR_SPAMMING:
                    print("ERROR_SPAMMING")
                default:
                    break;

                }
            } else if (packet is RPC.PM_postConnectionData) {
                KeyGenerator.instance.setPostConnectionData(packet as! RPC.PM_postConnectionData)
                self.handshaked = true
            }
//            else if packet is RPC.PM_file {
//                let file = packet as! RPC.PM_file
//                if file.type == PMFileManager.FileType.PHOTO {
//                    PMFileManager.instance.acceptFileDownload(file: file, messageID: messageID)
//                } else if (file.type == PMFileManager.FileType.STICKER) {
////                    PMFileManager.instance.acceptStickerDownload(file: file, messageID: messageID)
//                }
//            }
            else if (packet is RPC.PM_filePart) {
//                PMFileManager.instance.continueFileDownload(part: packet as! RPC.PM_filePart, messageID: messageID)
            }

            if (listener != nil) {
                listener!(packet, error)
            }
        }
    }

    func onConnectionDataReceived(_ connection: NetworkManager_Wrapper!, buffer: SerializedBuffer_Wrapper!, length: UInt32) {

        let mark = buffer.position()

        var err = false
        let keyId = buffer.readInt64(&err)
        if err {
            print("onConnectionDataReceived: ERROR 1")
            connection?.reconnect()
            return
        }

        if keyId == 0 {
            let messageID = buffer.readInt64(&err)
            let messageLength = buffer.readUint32(&err)

            if err {
                print("onConnectionDataReceived: ERROR 2")
                connection?.reconnect()
                return
            }

            let rem = buffer.remaining()
            if messageLength != rem {
                print("connection received incorrect message length")
                connection?.reconnect()
                return
            }
            var err = false
            let object = ClassStore.deserialize(stream: buffer, svuid: buffer.readInt32(&err), error: &err)
            
            if !err && object != nil {
                print("connection received object " + String(describing: type(of: object!)) + ", len=\(messageLength), ID=\(messageID)")
                processServerResponse(object: object!, messageID: messageID)
            }
        } else {
            let i: UInt32 = 24 + 12
            let b = KeyGenerator.instance.decryptMessageWithKeyId(keyId, buffer: buffer, length: length - 24, mark: mark)
            if (length < i) || !b {
                print("Can't decrypt packet")
                connection?.reconnect()
                return
            }

            buffer.position(mark + 24)
            let messageID = buffer.readInt64(&err)
            let messageLength = buffer.readInt32(&err)
            if err {
                connection?.reconnect()
                return
            }

            var err = false
            let object = ClassStore.deserialize(stream: buffer, svuid: buffer.readInt32(&err), error: &err)
            if object != nil {
                print("connection received object " + String(describing: type(of: object!)) + ", len=\(messageLength), ID=\(messageID)")
                processServerResponse(object: object!, messageID: messageID)
            } else {
                print("Can't deserialize object")
            }
        }
    }

    func onConnectionStateChanged(_ connection: NetworkManager_Wrapper!, isConnected: Bool) {
        if self.isConnected == isConnected {
            return
        }

        if isConnected {
            NotificationManager.instance.postNotificationName(id: NotificationManager.didConnectedToServer)
            if keepAliveThread == nil || (!keepAliveThread.isExecuting && !keepAliveThread.isCancelled) || keepAliveThread.isFinished {
                keepAliveThread = Thread(block: NetworkManager.keepAliveProc)
                keepAliveThread.start()
            }

            KeyGenerator.instance.reset()
            reset()
            handshake()

        } else {
            keepAliveThread.cancel()
            NotificationManager.instance.postNotificationName(id: NotificationManager.didDisconnectedFromServer)
        }

        self.isConnected = isConnected

        print("onConnectionStateChanged \(isConnected)")
    }

    func onConnectionError(_ connection: NetworkManager_Wrapper!, error: Error!) {
//        let alert = UIAlertController(title: "Connection error", message: error.localizedDescription, preferredStyle: .alert)
//        let action = UIAlertAction(title: "OK", style: .default) { _ in
//            alert.dismiss(animated: true)
//        }
//        alert.addAction(action)
//        DispatchQueue.main.async {
//            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
//
//        }
    }

    func sendPacketNowOrLater(_ packet: Packet) {
        sendPacketNowOrLater(packet, onComplete: nil, messageID: generateMessageID())
    }

    func sendPacketNowOrLater(_ packet: Packet, onComplete: PacketResponseFunc?) {
        sendPacketNowOrLater(packet, onComplete: onComplete, messageID: generateMessageID())
    }

    func sendPacketNowOrLater(_ packet: Packet, onComplete: PacketResponseFunc?, messageID: Int64) {
        if User.isAuthenticated {
            sendPacket(packet, onComplete:onComplete)
        } else {
            futureRequests.append(FutureRequest(id: messageID, packet: packet, callback: onComplete))
        }
    }

    func sendPacket(_ packet: Packet) {
        sendPacket(packet, onComplete: nil, messageID: generateMessageID())
    }

    func sendPacket(_ packet: Packet, onComplete: PacketResponseFunc?) {
        sendPacket(packet, onComplete: onComplete, messageID: generateMessageID())
    }

    func sendPacket(_ packet: Packet, onComplete: PacketResponseFunc?, messageID: Int64) {
        if (requestsMap[messageID] != nil) {
            print("Packet with same ID has already been sent")
        }

        NetworkManager_Wrapper.netQueue().run({
            print("Sending request " + String(describing: type(of: packet)) + " with ID=\(messageID)")

            let n = packet.getSize()

            let data: SerializedBuffer_Wrapper! = SerializedBuffer_Wrapper(size: n)
            packet.serializeToStream(stream: data)
            data.position(0)

            let buffer = KeyGenerator.instance.wrapData(messageID, buffer: data)
            if (buffer != nil) {
                packet.freeResources()
                if (onComplete != nil) {
                    self.requestsMap[messageID] = onComplete
                }

                self.nm.sendData(buffer)
            } else {
                print("wrapData error")
            }
        }, sync: false)
    }

    func handshake() {
        NetworkManager_Wrapper.netQueue().run {
            if self.handshaked {
                return
            }

            func dhComplete(_ packet: Packet?, _ error: RPC.PM_error?) {
                if let postConnData = packet as! RPC.PM_postConnectionData? {
                    KeyGenerator.instance.setPostConnectionData(postConnData)
                    NotificationManager.instance.postNotificationName(id: NotificationManager.didEstablishedSecuredConnection)
                }
            }

            func serverDHComplete(_ packet: Packet?, _ error: RPC.PM_error?) {
                if let serverData = packet as! RPC.PM_serverDHdata? {
                    if KeyGenerator.instance.generateShared(key: serverData.key) {
                        KeyGenerator.instance.authKeyID = serverData.keyID

                        let result = RPC.PM_DHresult()
                        result.ok = true
                        let _ = self.sendPacket(result, onComplete: dhComplete)
                    }
                }
            }

            let requestDH = RPC.PM_requestDHParams()
            let _ = self.sendPacket(requestDH, onComplete: { packet, error in
                if let dhParams = packet as! RPC.PM_DHParams? {
                    if KeyGenerator.instance.generatePair(dhParams.p, dhParams.g) {
                        let clientData = RPC.PM_clientDHdata()
                        clientData.key = KeyGenerator_Wrapper.getInstance().getPublicKey()
                        let _ = self.sendPacket(clientData, onComplete: serverDHComplete)
                    }
                }
            })
        }
    }

    public func reset() {
        print("Reset")
        requestsMap.removeAll()
        handshaked = false
        lastOutgoingMessageId = 0
        lastPacket = nil
        lastKeepAlive = 0
        nm.reset()
        futureRequests.removeAll()
    }

    public func reconnect() {
        print("Reconnecting")
        NetworkManager_Wrapper.netQueue().run {
            self.nm.reconnect()
//            self.reset()
        }
    }
    public func disconnect() {
        print("Disconnecting")
        NetworkManager_Wrapper.netQueue().run {
            self.nm.stop()
            self.reset()
        }
    }
}
