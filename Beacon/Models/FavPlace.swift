import SwiftData

@Model
final class FavPlace{
    var placeId: String
    var name: String
    init(placeId: String, name: String){
        self.placeId = placeId
        self.name = name
    }
}
