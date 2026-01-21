import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack{
            Color.white.ignoresSafeArea()
            
            VStack{
                //Logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding()
                    
                
                
                
                    
                    
            }
        }
    }
}

#Preview {
    LoadingView()
}
