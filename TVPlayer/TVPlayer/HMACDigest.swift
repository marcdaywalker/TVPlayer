// Make sure you add #import <CommonCrypto/CommonCrypto.h> to the Xcode bridging header

import Foundation

enum HMACAlgorithm {
	case md5, sha1, sha224, sha256, sha384, sha512
	
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .md5:
            result = kCCHmacAlgMD5
        case .sha1:
            result = kCCHmacAlgSHA1
        case .sha224:
            result = kCCHmacAlgSHA224
        case .sha256:
            result = kCCHmacAlgSHA256
        case .sha384:
            result = kCCHmacAlgSHA384
        case .sha512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
	
	func digestLength() -> Int {
		var result: CInt = 0
		switch self {
		case .md5:
			result = CC_MD5_DIGEST_LENGTH
		case .sha1:
			result = CC_SHA1_DIGEST_LENGTH
		case .sha224:
			result = CC_SHA224_DIGEST_LENGTH
		case .sha256:
			result = CC_SHA256_DIGEST_LENGTH
		case .sha384:
			result = CC_SHA384_DIGEST_LENGTH
		case .sha512:
			result = CC_SHA512_DIGEST_LENGTH
		}
		return Int(result)
	}
}

extension String {
    func hmac(_ algorithm: HMACAlgorithm, key: String) -> Data {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(algorithm.toCCEnum(), cKey!, /*strlen(cKey!)*/ cKey!.count, cData!, cData!.count, &result)
        let hmacData:Data = Data(bytes: UnsafePointer<UInt8>(result), count: (Int(algorithm.digestLength())))
        let hmacBase64 = hmacData.base64EncodedData(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return hmacBase64
        
//        let theData = self.dataUsingEncoding(NSUTF8StringEncoding)!
//        
//        
//        var aa = UnsafeMutablePointer<NSData>()
//        CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5), key, key.characters.count, theData.bytes, theData.length, &aa)
////        let bb = NSData(aa)
//        return aa
        

    
    }
    
    
    func md5(_ key: String) -> Data {
        let inputData: Data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let keyData: Data = key.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        let algorithm = HMACAlgorithm.md5
        let digestLen = algorithm.digestLength()
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CCHmac(algorithm.toCCEnum(), (keyData as NSData).bytes, Int(keyData.count), (inputData as NSData).bytes, Int(inputData.count), result)
        let data = Data(bytes: UnsafePointer<UInt8>(result), count: digestLen)
        result.deinitialize()
        return data//.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
}
