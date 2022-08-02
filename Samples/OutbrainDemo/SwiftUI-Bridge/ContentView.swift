//
//  ContentView.swift
//  SwiftUI-Bridge
//
//  Created by Oded Regev on 02/08/2022.
//  Copyright © 2022 Outbrain inc. All rights reserved.
//

import SwiftUI
import OutbrainSDK
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}

// Our CustomSFWidgetDelegate implementation class that expects to find a SFWidgetObservable object
// in the environment, and set if needed.
class MyCustomSFWidgetDelegate : NSObject {
    var sfWidgetObservable: SFWidgetObservable?
}

extension MyCustomSFWidgetDelegate : SFWidgetDelegate {
    func onRecClick(_ url: URL) {
        if let sfWidgetObservable = self.sfWidgetObservable {
            sfWidgetObservable.url = url
            sfWidgetObservable.showSafari = true
        }
    }
    
    func didChangeHeight() {
        //self.sfWidgetObservable.widgetHeight = 2000
    }
}

// Our observable object class
class SFWidgetObservable: ObservableObject {
    @Published var showSafari:Bool = false
    @Published var url:URL?
    @Published var widgetHeight:CGFloat?
}

struct SFWidgetWrapper: UIViewRepresentable {
    @EnvironmentObject var sfWidgetObservable: SFWidgetObservable
    
    let widgetId:String
    let baseURL:String
    let installationKey:String
    let myCustomDelegate = MyCustomSFWidgetDelegate()
    
    func updateUIView(_ uiView: SFWidget, context: Context) {
        uiView.configure(with: myCustomDelegate, url: baseURL, widgetId: widgetId, installationKey: installationKey)
        myCustomDelegate.sfWidgetObservable = sfWidgetObservable
    }
    
    func makeUIView(context: Context) -> SFWidget {
        SFWidget()
    }
}

struct ContentView: View {
    @StateObject var sfWidgetObservable = SFWidgetObservable()

    
    let widgetId = "MB_1"
    let baseURL = "https://mobile-demo.outbrain.com"
    let installationKey = "NANOWDGT01"
    
    init() {
        Outbrain.initializeOutbrain(withPartnerKey: "iOSSampleApp2014")
        
    }
    
    var body: some View {
            ScrollView(.vertical) {
                VStack(spacing:0) {
                    Image("article_image", bundle: Bundle.main)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                    Text("The Guardian")
                        .padding()
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 80.0)
                        .background(.blue)
                        .foregroundColor(.white)
                    
                    Text("Suarez: Messi Was Born Great, Ronaldo Made Himself Great")
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 0    ))
                    
                    ArticleBody()
                    ArticleBody()
                    ArticleBody()
                    
                    SFWidgetWrapper(widgetId: widgetId, baseURL: baseURL, installationKey: installationKey)
                        .frame(height: 1000)
                        .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
                    
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $sfWidgetObservable.showSafari) {
                SafariView(url: sfWidgetObservable.url!)
            }
            .environmentObject(sfWidgetObservable)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ArticleBody: View {
    let loremIpsem = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
    
    var body: some View {
        Text(loremIpsem)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 20, leading: 5, bottom: 0, trailing: 5    ))
    }
}
