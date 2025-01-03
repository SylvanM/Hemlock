//
//  HLCore.swift
//  Hemlock
//
//  Created by Sylvan Martin on 7/25/24.
//

import Foundation

fileprivate var staticCallback: (Int32) -> () = { _ in }

fileprivate func makeCallback(v: Int32) {
    staticCallback(v)
}

fileprivate var callbackTable: [UInt : (UnsafeMutableRawPointer, (inout Bool, [Any]) -> ())] = [:]

/// This could use some explaining.
///
/// I'm trying to use callbacks, but C cannot handle functions that capture context. This is a silly workaround,
/// where we make all the context global! If there were only one thread doing this, we would have a global variable
/// store the closure, then we would just write to that global variable to update the closure we want to be called,
/// then we would have the C function pointer call the global function. Silly, but it works. However, if we want to
/// have an arbitrary amount of function calls going on at once, we need to be able to have multiple of these variables
/// going on at once. So, my attempt is to create something called a "callback table" which stores different closures
/// as long with an identifier to refer to them with. When we want to pass a function pointer, we add the closure to the table,
/// and we just have the function pointer call the specific handler.
///
/// Of course, this comes with additional overhead of managing the table, which is what `CallbackTableManager` does.
/// We also store a different tokio runtime for each callback, which is what the `UnsafeMutableRawPointer` is.
fileprivate struct CallbackTableManager {
    
    /// Sets up a callback to be called
    static func createCallback(closure: @escaping ([Any]) -> ()) -> (UnsafeMutableRawPointer, UInt) {
        #warning("This is ONLY for temporary purposes")
        // TODO: Figure out a way to support multiple calls at once!
        var identifier: UInt = 0
        
//        repeat {
//            identifier = UInt.random(in: UInt.min...UInt.max)
//        } while callbackTable.keys.contains { $0 == identifier }
        
        let runtimePointer = capi_create_runtime()!
        
        let callback: (inout Bool, [Any]) -> () = { threadInProgress, args in
            closure(args)
            threadInProgress = false
        }
        
        callbackTable[identifier] = (runtimePointer, callback)
        
        return (runtimePointer, identifier)
    }
    
    static func destroyCallback(identifier: UInt) {
        let (runtimePointer, _) = callbackTable[identifier]!
        capi_destroy_runtime(runtimePointer)
        callbackTable[identifier] = nil
    }
    
    /// Executes and then frees a callback, calling it with any arguments
    static func executeCallback(identifier: UInt, arguments: [Any]) {
        var callbackInProgress = true
        
        DispatchQueue.global().async {
            // go ahead and trigger the callback!
            let (_, callback) = callbackTable[identifier]!
            callback(&callbackInProgress, arguments)
        }
        
        DispatchQueue.global().async {
            
            while callbackInProgress {
                // do nothing! Wait for it to finish.
            }
            
            // callback is done, so destroy it!
            destroyCallback(identifier: identifier)
        }
    }
    
}

func cFunction(_ block: (@escaping @convention(block) () -> ())) -> (@convention(c) () -> ()) {
    return unsafeBitCast(imp_implementationWithBlock(block), to: (@convention(c) () -> ()).self)
}

/// `HLCore` is an object representing the "hemlock core," which is the underlying Rust binary that is used for all the main functionality.
struct HLCore {
    
    /// `Crypto` is just the collection of crypto routines provided by the core.
    struct Crypto {
        
        // MARK: Constants
        
        static var encryptedSecretKeyLength: Int {
            Int(ENCRYPTED_SECRET_KEY_LEN)
        }
        
        static var publicKeyLength: Int {
            Int(ENCRYPTED_SECRET_KEY_LEN)
        }
        
        static var secretKeyLength: Int {
            Int(SECRET_KEY_LEN)
        }
        
        static var speckKeyLength: Int {
            Int(SPECK_KEY_LEN)
        }
        
        static var digestLength: Int {
            Int(SHA512_DIGEST_LEN)
        }
        
        // MARK: Methods
        
        /// Performs SHA-512 on a byte vector
        static func hash(_ bytes: [UInt8]) -> [UInt8] {
            var digest = [UInt8](repeating: 0, count: 64)
            assert(capi_hash_bytes(bytes, Int32(bytes.count), &digest) == 0)
            return digest
        }
        
        /// Performs SHA-512 on a String
        static func hash(_ string: String) -> [UInt8] {
            var digest = [UInt8](repeating: 0, count: 64)
            assert(capi_hash_str(string, &digest) == 0)
            return digest
        }
        
        /// Performs Speck encryption on bytes
        static func enc(_ plaintext: [UInt8], key: [UInt8]) -> [UInt8] {
            var len: Int32 = 0
            let ciphertextBasePointer = capi_enc(plaintext, Int32(plaintext.count), key, &len)
            let buffer = UnsafeBufferPointer(start: ciphertextBasePointer, count: Int(len))
            return Array(buffer)
        }
        
        /// Performs Speck decyption on bytes
        static func dec(_ ciphertext: [UInt8], key: [UInt8]) -> [UInt8] {
            var len: Int32 = 0
            let ciphertextBasePointer = capi_dec(ciphertext, Int32(ciphertext.count), key, &len)
            let buffer = UnsafeBufferPointer(start: ciphertextBasePointer, count: Int(len))
            return Array(buffer)
        }
        
    }
    
    // MARK: Web
    
    /// A collection of helpful hemlock web API calls
    struct Web {
        
        /// A result code that will occur on the web side
        enum Result: Error {
            
            case success
            case emailTaken
            case connectionError
            case emailDoesNotExist
            case userDoesNotExist
            
            case unknownError
            
            init(_ rawValue: Int) {
                switch Int32(rawValue) {
                case SUCCESS:
                    self = .success
                case EMAIL_TAKEN:
                    self = .emailTaken
                case CONNECTION_ERROR:
                    self = .connectionError
                case USER_DOES_NOT_EXIST:
                    self = .userDoesNotExist
                case EMAIL_DOES_NOT_EXIST:
                    self = .emailDoesNotExist
                default:
                    print("Initializing Result to .uknownError for code: \(rawValue)")
                    self = .unknownError
                }
            }
            
            
        }
        
        // MARK: Users
        
        struct User {
            var userID: UInt64
            var email: String
            var publicKey: [UInt8]
            var encryptedSecretKey: [UInt8]
            var masterKeyHash: [UInt8]
        }
        
        static func createUser(email: String, completion: @escaping (Result, UInt64, [UInt8]) -> ()) {
            completion(.success, 0, [UInt8](repeating: 0, count: 32))
            return
            
            #warning("Callback id is zero")
            let (runtime, id) = CallbackTableManager.createCallback { args in
                
                let (errorCode, userID, masterKey) = (
                    args[0] as! Int,
                    args[1] as! UInt64,
                    args[2] as! [UInt8]
                )
                
                completion(Result(errorCode), userID, masterKey)
            }
            
            capi_create_user(runtime, email.cString) { errorCode, userID, masterKeyBasePointer in
                print("User thing done")
                let masterKeyBuffer = UnsafeBufferPointer(start: masterKeyBasePointer, count: 32)
                let masterKey = Array(masterKeyBuffer)
                
                CallbackTableManager.executeCallback(identifier: 0, arguments: [Int(errorCode), UInt64(userID), masterKey])
            }
        }
        
        static func downloadUser(userID: UInt64, completion: @escaping (Result, User?) -> ()) {
            let (runtime, id) = CallbackTableManager.createCallback { args in
                let (errorCode, user) = (
                    args[0] as! Int,
                    args[1] as! User?
                )
                
                completion(Result(errorCode), user)
            }
            
            capi_download_user(runtime, userID) { errorCode, userID, emailPtr, publicKeyPointer, encryptedSecretKeyPointer, masterKeyHashPointer in
                let email = String(cString: emailPtr!)
                let publicKey = [UInt8](fromPointer: publicKeyPointer!, count: Crypto.publicKeyLength)
                let encryptedSecretKey = [UInt8](fromPointer: encryptedSecretKeyPointer!, count: Crypto.encryptedSecretKeyLength)
                let masterKeyHash = [UInt8](fromPointer: masterKeyHashPointer!, count: Crypto.digestLength)
                
                var user: User?
                
                if errorCode == SUCCESS {
                    user = User(
                        userID: userID,
                        email: email,
                        publicKey: publicKey,
                        encryptedSecretKey: encryptedSecretKey,
                        masterKeyHash: masterKeyHash
                    )
                }
                
                CallbackTableManager.executeCallback(identifier: 0, arguments: [Int(errorCode), user as Any])
            }
        }
        
        static func downloadUser(email: String, completion: @escaping (Result, User?) -> ()) {
            let (runtime, id) = CallbackTableManager.createCallback { args in
                let (errorCode, user) = (
                    args[0] as! Int,
                    args[1] as! User?
                )
                
                completion(Result(errorCode), user)
            }
            
            capi_download_user_email(runtime, email.cString) { errorCode, userID, emailPtr, publicKeyPointer, encryptedSecretKeyPointer, masterKeyHashPointer in
                let email = String(cString: emailPtr!)
                let publicKey = [UInt8](fromPointer: publicKeyPointer!, count: Crypto.publicKeyLength)
                let encryptedSecretKey = [UInt8](fromPointer: encryptedSecretKeyPointer!, count: Crypto.encryptedSecretKeyLength)
                let masterKeyHash = [UInt8](fromPointer: masterKeyHashPointer!, count: Crypto.digestLength)
                
                var user: User?
                
                if errorCode == SUCCESS {
                    user = User(
                        userID: userID,
                        email: email,
                        publicKey: publicKey,
                        encryptedSecretKey: encryptedSecretKey,
                        masterKeyHash: masterKeyHash
                    )
                }
                
                CallbackTableManager.executeCallback(identifier: 0, arguments: [Int(errorCode), user as Any])
            }
        }
        
        // MARK: Testing
        
        static func testHeaderConstants() {
            print(ENCRYPTED_SECRET_KEY_LEN)
        }
        
        static func testDownloadUser() {
            
            let sylvanUserID: UInt64 = 15893677956707774784
            let sylvanEmail = "sylvan.martin@gmail.com"
            let sylvanMasterKey: [UInt8] = [
                0xBB, 0xF2, 0xA7, 0x58, 0xAD, 0x34, 0x9B, 0x95,
                0x38, 0xCD, 0x3E, 0x26, 0xF2, 0x6C, 0x92, 0xD7,
                0x6B, 0xE4, 0xDD, 0xC1, 0x5C, 0x69, 0x56, 0x4F,
                0x8C, 0x9B, 0x4D, 0xEA, 0x08, 0xFF, 0x8C, 0x93
            ]
            
            HLCore.Web.downloadUser(email: sylvanEmail) { result, user in
                print(result)
                print(user)
            }
            
            do {
                sleep(4)
            }
        }
        
        static func testAsync() {
            
            let thisIsALocalLet = 2354
            var closureIsDone = false
            
            let (runtime, id) = CallbackTableManager.createCallback { args in
                print("Successfully called closure with args: \(args)")
                print("AND WE CAPTURED CONTEXT")
                print("Local number: \(thisIsALocalLet)")
            }
            
            capi_test_async(runtime) { result in
                cFunction {
                    CallbackTableManager.executeCallback(identifier: 0, arguments: [result])
                }()
            }
            
//            staticCallback = { _ in
//                print("HAHHH I got it to do local stuff!")
//                print(thisIsALocalLet)
//                closureIsDone = true
//            }
//
//            capi_test_async(globalRuntime) { result in
//                print("Result is \(result)")
//                closureIsDone = true
//                makeCallback(v: result)
//            }
//
//            DispatchQueue.global().async {
//                while !closureIsDone {
//                    // wait!
//                }
//
//                capi_destroy_runtime(globalRuntime)
//                print("RUNTIME DESTROYED.")
//            }
            
            do {
                sleep(4)
            }
        }
        
    }
}
