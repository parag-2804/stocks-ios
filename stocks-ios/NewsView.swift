//
//  NewsView.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/10/24.
//



import SwiftUI
import Kingfisher

//struct NewsView: View {
//    @EnvironmentObject var webService: WebService
//    @State private var selectedArticle: NewsItem?
//    
//    var body: some View {
//        ZStack{
//            Text("News")
//                .font(.title2)
//            
//            
//            List {
//                Section(header: Text("News").font(.title2)) {
//                    ForEach(webService.filteredNewsItems) { item in
//                        NewsArticleRow(article: item)
//                            .onTapGesture {
//                                self.selectedArticle = item
//                            }
//                            .listRowBackground(Color.clear)
//                    }
//                }
//            }
//            .onAppear {
//                print("NewsView appeared with \(webService.filteredNewsItems.count) items.")
//            }
//            .sheet(item: $selectedArticle) { article in
//                NewsDetailsView(article: article)
//            }
//        
//            //.background(Color.clear)
//        }
//    }
//}

struct NewsView: View {
    @EnvironmentObject var webService: WebService
    @State private var selectedArticle: NewsItem?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("News")
                .font(.title2)
//
            
            ScrollView {
                VStack {
//                    ForEach(webService.filteredNewsItems.indices, id: \.self) { index in
//                        let item = webService.filteredNewsItems[index]
//                        NewsArticleRow(article: item, isFeatured: index == 0)
                    ForEach(webService.filteredNewsItems) { item in
                        NewsArticleRow(article: item)
                            .onTapGesture {
                                self.selectedArticle = item
                            }
                    }
                }
            }
            .sheet(item: $selectedArticle) { article in
                NewsDetailsView(article: article)
            }
        }

        .onAppear {
//            print("NewsView appeared with \(webService.filteredNewsItems.count) items.")
        }

    }
}


struct NewsArticleRow: View {
    @EnvironmentObject var webService: WebService
    let article: NewsItem
    
    
    var body: some View {
        
        if(article.id == webService.filteredNewsItems.first?.id){
            
            
            VStack(alignment: .leading) {
                let imageUrl = URL(string: article.image)
                    KFImage(imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(8)
                
                Text(article.source + "  " + timeAgoSince(article.datetime))
                    .font(.subheadline)
                    .foregroundColor(.gray)
               
                    Text(article.headline)
                        .font(.headline)
                    
              
                 Divider()
                
            }
        }
        else
        {
           
//                HStack(){
//                    
//                    VStack(alignment: .leading, spacing: 10.0){
//                        Text(article.source + "  " + timeAgoSince(article.datetime))
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        
//                        Text(article.headline)
//                            .font(.headline)
//                        
//                    }
//                    VStack(alignment: .trailing){
//                        let imageUrl = URL(string: article.image)
//                        KFImage(imageUrl)
//                            .resizable()
//                        //                        .scaledToFill()
//                            .frame(width: 80.0, height: 80)
//                            .clipped()
//                            .cornerRadius(8)
//                    }
//                
//                }
//                .padding(.top, 20.0)
            HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(article.source + "  " + timeAgoSince(article.datetime))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(article.headline)
                                .font(.headline)
                                .lineLimit(3) // Limit to 3 lines and truncate the rest
                        }
                        
                        Spacer() // Use a spacer to push the image to the edge
                        
                        if let imageUrl = URL(string: article.image), !article.image.isEmpty {
                            KFImage(imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill) // Maintain aspect ratio and fill the frame
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 10)
            
        }
        
        
//        VStack(alignment: .leading) {
//           
//            if let imageUrl = URL(string: article.image), !article.image.isEmpty {
//                KFImage(imageUrl)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(height: article.id == webService.filteredNewsItems.first?.id ? 200 : 100)
//                    .clipped()
//                    .cornerRadius(8)
//            }
//            Text(article.headline)
//                .font(.headline)
//            Text(article.source + "  " + timeAgoSince(article.datetime))
//                .font(.subheadline)
//                .foregroundColor(.gray)
//            Divider()
//        }
//        .padding(.vertical)
//        .padding(.horizontal, -20.0)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .listRowBackground(Color.clear) // Set individual row background to transparent
//        .background(Color.clear) // Another way to set the entire background to transparent
        
    }
    
    
    func timeAgoSince(_ unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: date, to: now)

        var timeComponents = [String]()

        if let hour = components.hour, hour > 0 {
            timeComponents.append("\(hour) hr")
        }

        if let minute = components.minute, minute > 0 {
            timeComponents.append("\(minute) min")
        }

        // If there are no time components (the event was less than a minute ago), just show "0 min"
        if timeComponents.isEmpty {
            timeComponents.append("0 min")
        }

        return timeComponents.joined(separator: ", ")
    }

}

struct NewsDetailsView: View {
    
   
    @EnvironmentObject var webService: WebService
    let article: NewsItem
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(article.source)
                        .font(.headline)
                    Text(formatDate(article.datetime))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(article.headline)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(article.summary)
                        .font(.body)
                    Link("Read More", destination: URL(string: article.url)!)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 10.0) {
                        Button(action: {
                            openURL(URL(string: "https://twitter.com/intent/tweet?text=\(article.headline)&url=\(article.url)")!)
                            
                        }){
                            Image ("twitter")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        
                        Button(action: {
                            openURL(URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(article.url)")!)
                            
                        }){
                            Image ("facebook")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                     
                    }
                }
            }
        }
        .padding(.horizontal, 20.0)
    }
    
    func formatDate(_ unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

//struct SocialButton: View {
//    let iconName: String
//    let label: String
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Label(label, systemImage: iconName)
//        }
//    }
//}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
            .environmentObject(WebService.service)
    }
}

//struct NewsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create an instance of WebService with mock data
//        let mockWebService = WebService()
//        mockWebService.filteredNewsItems = (1...10).map { i in
//            NewsItem(
//                id: i,
//                category: "Technology",
//                datetime: Date().timeIntervalSince1970 - Double(i * 60 * 60),
//                headline: "Article \(i)",
//                image: "https://placekitten.com/200/200", // Placeholder image URL
//                related: "AAPL",
//                source: "Mock Source",
//                summary: "Summary for article \(i)",
//                url: "https://example.com/article\(i)"
//            )
//        }
//        
//        return NewsView()
//            .environmentObject(mockWebService) // Provide the mock WebService
//    }
//}
