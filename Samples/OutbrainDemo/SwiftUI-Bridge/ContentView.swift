//
//  ContentView.swift
//  SwiftUI-Bridge
//
//  Created by Oded Regev on 02/08/2022.
//  Copyright © 2022 Outbrain inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
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
                
                Spacer()
            }
        }
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
