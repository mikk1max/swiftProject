import SwiftUI

struct RecommendationsView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                Text("Recommendations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                BlockView(imageName: "shanghai", title: "Shanghai, China", description: "Rich cultural heritage and urban life in China's most dynamic metropolis")
                BlockView(imageName: "toronto", title: "Toronto, Canada", description: "Discover featuring iconic landmarks in Toronto")
                BlockView(imageName: "stockholm", title: "Stockholm, Sweden", description: "Explore Stockholm's enchanting blend of historic charm and modern elegance")
            }
            .padding()
        }
    }
    
}


struct BlockView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var selectedTrip: Trip? = nil
    @State private var showingEditRecomendedView = false
    var imageName: String
    var title: String
    var description: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(title)
                .font(.headline)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
            Text(description)
                .font(.subheadline)
                .padding(.top, 5)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(10)
                Color.black.opacity(0.45)
            }
        )
        .cornerRadius(10)
        .shadow(radius: 5)
        .onTapGesture {
            showingEditRecomendedView.toggle()
        }
        .sheet(isPresented: $showingEditRecomendedView) {
            EditRecomendedView(trip: selectedTrip ?? Trip(context: viewContext),
                               country: title.split(separator: ",")[1].trimmingCharacters(in: .whitespaces),
                               city: title.split(separator: ",")[0].trimmingCharacters(in: .whitespaces),
                               isPresented: $showingEditRecomendedView)
            .environment(\.managedObjectContext, managedObjectContext)

        }
    }
}


