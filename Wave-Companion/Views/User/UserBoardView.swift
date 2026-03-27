import SwiftUI

struct UserBoardView: View {
    
    let boardType: String
    let boardColorHex: String
    
    var body: some View {
        ZStack {
            Image(boardType.lowercased())
                .resizable()
                .scaledToFit()
            
            Image(boardType.lowercased())
                .resizable()
                .scaledToFit()
                .colorMultiply(Color(hex: boardColorHex))
        }
        .frame(height: 120)
        .shadow(radius: 4)
    }
}
