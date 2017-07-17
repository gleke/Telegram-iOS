import Foundation
#if os(macOS)
    import PostboxMac
#else
    import Postbox
#endif

public enum PhoneCallDiscardReason: Int32 {
    case missed = 0
    case disconnect = 1
    case hangup = 2
    case busy = 3
}

public enum TelegramMediaActionType: Coding, Equatable {
    case unknown
    case groupCreated(title: String)
    case addedMembers(peerIds: [PeerId])
    case removedMembers(peerIds: [PeerId])
    case photoUpdated(image: TelegramMediaImage?)
    case titleUpdated(title: String)
    case pinnedMessageUpdated
    case joinedByLink(inviter: PeerId)
    case channelMigratedFromGroup(title: String, groupId: PeerId)
    case groupMigratedToChannel(channelId: PeerId)
    case historyCleared
    case historyScreenshot
    case messageAutoremoveTimeoutUpdated(Int32)
    case gameScore(gameId: Int64, score: Int32)
    case phoneCall(callId: Int64, discardReason: PhoneCallDiscardReason?, duration: Int32?)
    case paymentSent(currency: String, totalAmount: Int64)
    public init(decoder: Decoder) {
        let rawValue: Int32 = decoder.decodeInt32ForKey("_rawValue", orElse: 0)
        switch rawValue {
            case 1:
                self = .groupCreated(title: decoder.decodeStringForKey("title", orElse: ""))
            case 2:
                self = .addedMembers(peerIds: PeerId.decodeArrayFromBuffer(decoder.decodeBytesForKeyNoCopy("peerIds")!))
            case 3:
                self = .removedMembers(peerIds: PeerId.decodeArrayFromBuffer(decoder.decodeBytesForKeyNoCopy("peerIds")!))
            case 4:
                self = .photoUpdated(image: decoder.decodeObjectForKey("image") as? TelegramMediaImage)
            case 5:
                self = .titleUpdated(title: decoder.decodeStringForKey("title", orElse: ""))
            case 6:
                self = .pinnedMessageUpdated
            case 7:
                self = .joinedByLink(inviter: PeerId(decoder.decodeInt64ForKey("inviter", orElse: 0)))
            case 8:
                self = .channelMigratedFromGroup(title: decoder.decodeStringForKey("title", orElse: ""), groupId: PeerId(decoder.decodeInt64ForKey("groupId", orElse: 0)))
            case 9:
                self = .groupMigratedToChannel(channelId: PeerId(decoder.decodeInt64ForKey("channelId", orElse: 0)))
            case 10:
                self = .historyCleared
            case 11:
                self = .historyScreenshot
            case 12:
                self = .messageAutoremoveTimeoutUpdated(decoder.decodeInt32ForKey("t", orElse: 0))
            case 13:
                self = .gameScore(gameId: decoder.decodeInt64ForKey("i", orElse: 0), score: decoder.decodeInt32ForKey("s", orElse: 0))
            case 14:
                var discardReason: PhoneCallDiscardReason?
                if let value = decoder.decodeOptionalInt32ForKey("dr") {
                    discardReason = PhoneCallDiscardReason(rawValue: value)
                }
                self = .phoneCall(callId: decoder.decodeInt64ForKey("i", orElse: 0), discardReason: discardReason, duration: decoder.decodeInt32ForKey("d", orElse: 0))
            case 15:
                self = .paymentSent(currency: decoder.decodeStringForKey("currency", orElse: ""), totalAmount: decoder.decodeInt64ForKey("ta", orElse: 0))

            default:
                self = .unknown
        }
    }
    
    public func encode(_ encoder: Encoder) {
        switch self {
            case .unknown:
                break
            case let .groupCreated(title):
                encoder.encodeInt32(1, forKey: "_rawValue")
                encoder.encodeString(title, forKey: "title")
            case let .addedMembers(peerIds):
                encoder.encodeInt32(2, forKey: "_rawValue")
                let buffer = WriteBuffer()
                PeerId.encodeArrayToBuffer(peerIds, buffer: buffer)
                encoder.encodeBytes(buffer, forKey: "peerIds")
            case let .removedMembers(peerIds):
                encoder.encodeInt32(3, forKey: "_rawValue")
                let buffer = WriteBuffer()
                PeerId.encodeArrayToBuffer(peerIds, buffer: buffer)
                encoder.encodeBytes(buffer, forKey: "peerIds")
            case let .photoUpdated(image):
                encoder.encodeInt32(4, forKey: "_rawValue")
                if let image = image {
                    encoder.encodeObject(image, forKey: "image")
                }
            case let .titleUpdated(title):
                encoder.encodeInt32(5, forKey: "_rawValue")
                encoder.encodeString(title, forKey: "title")
            case .pinnedMessageUpdated:
                encoder.encodeInt32(6, forKey: "_rawValue")
            case let .joinedByLink(inviter):
                encoder.encodeInt32(7, forKey: "_rawValue")
                encoder.encodeInt64(inviter.toInt64(), forKey: "inviter")
            case let .channelMigratedFromGroup(title, groupId):
                encoder.encodeInt32(8, forKey: "_rawValue")
                encoder.encodeString(title, forKey: "title")
                encoder.encodeInt64(groupId.toInt64(), forKey: "groupId")
            case let .groupMigratedToChannel(channelId):
                encoder.encodeInt32(9, forKey: "_rawValue")
                encoder.encodeInt64(channelId.toInt64(), forKey: "channelId")
            case .historyCleared:
                encoder.encodeInt32(10, forKey: "_rawValue")
            case .historyScreenshot:
                encoder.encodeInt32(11, forKey: "_rawValue")
            case let .messageAutoremoveTimeoutUpdated(timeout):
                encoder.encodeInt32(12, forKey: "_rawValue")
                encoder.encodeInt32(timeout, forKey: "t")
            case let .gameScore(gameId, score):
                encoder.encodeInt32(13, forKey: "_rawValue")
                encoder.encodeInt64(gameId, forKey: "i")
                encoder.encodeInt32(score, forKey: "s")
            case let .paymentSent(currency, totalAmount):
                encoder.encodeInt32(15, forKey: "_rawValue")
                encoder.encodeString(currency, forKey: "currency")
                encoder.encodeInt64(totalAmount, forKey: "ta")
            case let .phoneCall(callId, discardReason, duration):
                encoder.encodeInt32(14, forKey: "_rawValue")
                encoder.encodeInt64(callId, forKey: "i")
                if let discardReason = discardReason {
                    encoder.encodeInt32(discardReason.rawValue, forKey: "dr")
                } else {
                    encoder.encodeNil(forKey: "dr")
                }
                if let duration = duration {
                    encoder.encodeInt32(duration, forKey: "d")
                } else {
                    encoder.encodeNil(forKey: "d")
                }
        }
    }
    
    public var peerIds: [PeerId] {
        switch self {
            case let .addedMembers(peerIds):
                return peerIds
            case let .removedMembers(peerIds):
                return peerIds
            case let .joinedByLink(inviter):
                return [inviter]
            case let .channelMigratedFromGroup(_, groupId):
                return [groupId]
            case let .groupMigratedToChannel(channelId):
                return [channelId]
            default:
                return []
        }
    }
}

public func ==(lhs: TelegramMediaActionType, rhs: TelegramMediaActionType) -> Bool {
    switch lhs {
        case .unknown:
            if case .unknown = rhs {
                return true
            }
        case let .groupCreated(title):
            if case .groupCreated(title) = rhs {
                return true
            }
        case let .addedMembers(peerIds):
            if case let .addedMembers(rhsPeerIds) = rhs {
                if peerIds.count == rhsPeerIds.count {
                    for i in 0 ..< peerIds.count {
                        if peerIds[i] != rhsPeerIds[i] {
                            return false
                        }
                    }
                    return true
                }
            }
        case let .removedMembers(peerIds):
            if case let .removedMembers(rhsPeerIds) = rhs {
                if peerIds.count == rhsPeerIds.count {
                    for i in 0 ..< peerIds.count {
                        if peerIds[i] != rhsPeerIds[i] {
                            return false
                        }
                    }
                    return true
                }
            }
        case let .photoUpdated(image):
            if case let .photoUpdated(rhsImage) = rhs {
                if let image = image {
                    if let rhsImage = rhsImage {
                        return image == rhsImage
                    } else {
                        return false
                    }
                } else {
                    return rhsImage == nil
                }
            }
        case let .titleUpdated(title):
            if case .titleUpdated(title) = rhs {
                return true
            }
        case .pinnedMessageUpdated:
            if case .pinnedMessageUpdated = rhs {
                return true
            }
        case let .joinedByLink(inviter):
            if case .joinedByLink(inviter) = rhs {
                return true
            }
        case let .channelMigratedFromGroup(title, groupId):
            if case .channelMigratedFromGroup(title, groupId) = rhs {
                return true
            }
        case let .groupMigratedToChannel(channelId):
            if case .groupMigratedToChannel(channelId) = rhs {
                return true
            }
        case .historyCleared:
            if case .historyCleared = rhs {
                return true
            }
        case .historyScreenshot:
            if case .historyScreenshot = rhs {
                return true
            } else {
                return false
            }
        case let .messageAutoremoveTimeoutUpdated(timeout):
            if case .messageAutoremoveTimeoutUpdated(timeout) = rhs {
                return true
            } else {
                return false
            }
        case let .gameScore(gameId, score):
            if case .gameScore(gameId, score) = rhs {
                return true
            } else {
                return false
            }
        case let .paymentSent(currency, totalAmount):
            if case .paymentSent(currency, totalAmount) = rhs {
                return true
            } else {
                return false
            }
        case let .phoneCall(lhsCallId, lhsDiscardReason, lhsDuration):
            if case let .phoneCall(rhsCallId, rhsDiscardReason, rhsDuration) = rhs, lhsCallId == rhsCallId && lhsDiscardReason == rhsDiscardReason && lhsDuration == rhsDuration {
                return true
            } else {
                return false
            }
    }
    return false
}

public final class TelegramMediaAction: Media {
    public let id: MediaId? = nil
    public var peerIds: [PeerId] {
        return self.action.peerIds
    }
    
    public let action: TelegramMediaActionType
    
    public init(action: TelegramMediaActionType) {
        self.action = action
    }
    
    public init(decoder: Decoder) {
        self.action = TelegramMediaActionType(decoder: decoder)
    }
    
    public func encode(_ encoder: Encoder) {
        self.action.encode(encoder)
    }
    
    public func isEqual(_ other: Media) -> Bool {
        if let other = other as? TelegramMediaAction {
            return self.action == other.action
        }
        return false
    }
}

func telegramMediaActionFromApiAction(_ action: Api.MessageAction) -> TelegramMediaAction? {
    switch action {
        case let .messageActionChannelCreate(title):
            return TelegramMediaAction(action: .groupCreated(title: title))
        case let .messageActionChannelMigrateFrom(title, chatId):
            return TelegramMediaAction(action: .channelMigratedFromGroup(title: title, groupId: PeerId(namespace: Namespaces.Peer.CloudGroup, id: chatId)))
        case let .messageActionChatAddUser(users):
            return TelegramMediaAction(action: .addedMembers(peerIds: users.map({ PeerId(namespace: Namespaces.Peer.CloudUser, id: $0) })))
        case let .messageActionChatCreate(title, _):
            return TelegramMediaAction(action: .groupCreated(title: title))
        case .messageActionChatDeletePhoto:
            return TelegramMediaAction(action: .photoUpdated(image: nil))
        case let .messageActionChatDeleteUser(userId):
            return TelegramMediaAction(action: .removedMembers(peerIds: [PeerId(namespace: Namespaces.Peer.CloudUser, id: userId)]))
        case let .messageActionChatEditPhoto(photo):
            return TelegramMediaAction(action: .photoUpdated(image: telegramMediaImageFromApiPhoto(photo)))
        case let .messageActionChatEditTitle(title):
            return TelegramMediaAction(action: .titleUpdated(title: title))
        case let .messageActionChatJoinedByLink(inviterId):
            return TelegramMediaAction(action: .joinedByLink(inviter: PeerId(namespace: Namespaces.Peer.CloudUser, id: inviterId)))
        case let .messageActionChatMigrateTo(channelId):
            return TelegramMediaAction(action: .groupMigratedToChannel(channelId: PeerId(namespace: Namespaces.Peer.CloudChannel, id: channelId)))
        case .messageActionHistoryClear:
            return TelegramMediaAction(action: .historyCleared)
        case .messageActionPinMessage:
            return TelegramMediaAction(action: .pinnedMessageUpdated)
        case let .messageActionGameScore(gameId, score):
            return TelegramMediaAction(action: .gameScore(gameId: gameId, score: score))
        case let .messageActionPhoneCall(_, callId, reason, duration):
            var discardReason: PhoneCallDiscardReason?
            if let reason = reason {
                discardReason = PhoneCallDiscardReason(apiReason: reason)
            }
            return TelegramMediaAction(action: .phoneCall(callId: callId, discardReason: discardReason, duration: duration))
        case .messageActionEmpty:
            return nil
        case let .messageActionPaymentSent(currency, totalAmount):
            return TelegramMediaAction(action: .paymentSent(currency: currency, totalAmount: totalAmount))
        case .messageActionPaymentSentMe:
            return nil
        case .messageActionScreenshotTaken:
            return TelegramMediaAction(action: .historyScreenshot)
    }
}

extension PhoneCallDiscardReason {
    init(apiReason: Api.PhoneCallDiscardReason) {
        switch apiReason {
            case .phoneCallDiscardReasonBusy:
                self = .busy
            case .phoneCallDiscardReasonDisconnect:
                self = .disconnect
            case .phoneCallDiscardReasonHangup:
                self = .hangup
            case .phoneCallDiscardReasonMissed:
                self = .missed
        }
    }
}
