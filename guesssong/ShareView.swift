//
//  ShareView.swift
//  guesssong
//
//  Created by user06 on 2023/12/14.
//

import SwiftUI

struct ShareView: View {
    private let url = URL(string: "https://medium.com/@apppeterpan")!

       var body: some View {
           
           VStack {
               Image("peter")
                   .resizable()
                   .frame(width: 170,height: 150)
               ShareLink(item: url) {
                   Label("Tap me to share", systemImage:  "square.and.arrow.up")
               }
           }
       }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView()
    }
}
