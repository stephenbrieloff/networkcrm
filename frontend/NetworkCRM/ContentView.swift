import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            NavigationView {
                ContactListView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Contacts")
            }
            
            AnalyticsDashboardView(viewContext: viewContext)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
        }
        .accentColor(.accentColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
