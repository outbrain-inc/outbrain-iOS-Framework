//
//  ArticleBody.swift
//  demo
//
//  Created by Leonid Lemesev on 29/07/2024.
//

import Foundation
import SwiftUI


struct ArticleBody: View {
    private let articleText = "The Uruguay international says his team-mate was one of the game\'s best players from the minute he made his first team debut.\n\nBarcelona attacker Luis Suarez feels Lionel Messi was born a great player, whereas Real Madrid star Cristiano Ronaldo has had to work to reach his current level.\n\nMessi and Ronaldo are widely regarded as the two best players of their generation, with the pair winning the Ballon d\'Or seven times between them in as many years.\n\nSuarez feels his Barcelona team-mate is the better of the two, though, because of his consistency from the first minute he made his debut.\n\n\"Messi is a natural. It's in his character,\" the Uruguay international told Le Buteur.\n\n\"Messi is the best player in the world. He was born with his qualities.\n"
    
    var body: some View {
        Text(articleText)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 20, leading: 5, bottom: 0, trailing: 5    ))
    }
}

