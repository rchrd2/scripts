// Most of this did not work for me

NSLog("NSLOG \(message)") // only thing that works


// let log = OSLog(subsystem: "medium_article", category: "basic")
// os_log(.info,  log: log, "NSLOG \(message)")
// os_log("NSLOG %@", message)
os_log(.info, "NSLOG \(message)")


let log = OSLog(subsystem: "medium_article", category: "basic")
let logger = Logger(log)
logger.info( "NSLOG \(message,  privacy: .public)")