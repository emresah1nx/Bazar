import SwiftUI

struct tester: View {
    
    enum eethyr: String, CaseIterable ,Identifiable{
        case evet = "Evet"
        case hayir = "Hayır"
        var id: eethyr {self}
    }
    
    // Seçilen para birimi
    @State private var selectedTakas: eethyr = .evet
    
    var body: some View {
        VStack {
            List {
                Section {
                    Picker("Takas?",selection: $selectedTakas){
                        ForEach(eethyr.allCases) { takas in
                            Text(takas.rawValue.capitalized)
                            
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        tester()
    }
}
