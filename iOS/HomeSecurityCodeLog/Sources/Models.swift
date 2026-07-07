import Foundation

struct HomeSecurityCodeLogItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var codeName: String
    var codeValue: String
    var notes: String
    var createdAt: Date = Date()
}
