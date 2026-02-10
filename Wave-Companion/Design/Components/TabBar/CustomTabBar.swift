import SwiftUI

struct CustomTabBar: View {

    @Binding var selectedTab: TabItem
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color("Background").ignoresSafeArea(edges: .bottom))
        .shadow(color: .black.opacity(0.05), radius: 10, y: -2)
    }

    private func tabButton(_ tab: TabItem) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? AppColors.action : AppColors.primary)
                    .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
                
                Text(tab.title)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? AppColors.action : AppColors.primary)
                    .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
                    .opacity(selectedTab == tab ? 1 : 0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
    }
}




#Preview {
    CustomTabBar(
        selectedTab: .constant(.home)
    )
}
