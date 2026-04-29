import SwiftUI

struct SessionHorizontalCard: View {
    
    let session: SurfSession
    let title: String?
    let titleColor: Color?
    
    let buttonTitle: String
    let buttonEnabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            MapSnapshotImageView(
                latitude: session.latitude,
                longitude: session.longitude,
                width: 260,
                height: 120
            )
            .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(session.spotName)
                    .font(.headline)
                
                Text(session.date.sessionFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let title, let titleColor {
                    Text(title)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(titleColor.opacity(0.15))
                        .foregroundColor(titleColor)
                        .clipShape(Capsule())
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: onTap) {
                        Text(buttonTitle)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                buttonEnabled
                                ? AppColors.action
                                : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(buttonEnabled ? .white : .gray)
                            .clipShape(Capsule())
                    }
                    .disabled(!buttonEnabled)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.primary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
