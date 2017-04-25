import protocol Foundation.NSLocking
import struct Foundation.pthread_mutex_t
import func Foundation.pthread_mutex_init
import func Foundation.pthread_mutex_destroy
import func Foundation.pthread_mutex_lock
import func Foundation.pthread_mutex_unlock

final class PosixThreadMutexLock: NSLocking {
    private var mutex = pthread_mutex_t()
    
    init() {
        let result = pthread_mutex_init(&mutex, nil)
        precondition(result == 0, "Failed to initialize mutex with error \(result).")
    }
    
    deinit {
        let result = pthread_mutex_destroy(&mutex)
        precondition(result == 0, "Failed to destroy mutex with error \(result).")
    }
    
    func lock() {
        let result = pthread_mutex_lock(&mutex)
        precondition(result == 0, "Failed to lock \(self) with error \(result).")
    }
    
    func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        precondition(result == 0, "Failed to unlock \(self) with error \(result).")
    }
}
