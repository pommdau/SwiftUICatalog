//
//  AlertSample.swift
//  BasicViews
//
//  Created by satoutakeshi on 2020/02/10.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import SwiftUI

struct AlertSample: View {
    @State private var isShowOkAlert: Bool = false
    @State private var isShowErrorAlert: Bool = false
    @State private var isShowRetryAlert: Bool = false
    var okAlert: Alert = Alert(title: Text("Download Success!"))
    var errorAlert: Alert = Alert(title: Text("An error occurred"),
                                  message: Text("Retry later!"),
                                  dismissButton: .default(Text("Close")))
    var retryAlert: Alert = Alert(title: Text("Error"),
                                  message: Text("please wait a minute"),
                                  primaryButton:
            .default(Text("Retry"), action: {
                print("tapped retry button")
            }),
                                  secondaryButton: .cancel())
    var body: some View {
        VStack {
            Button(action: {
                isShowOkAlert = true
            }) {
                Image(systemName: "square.and.arrow.down")
                .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
            }
            .alert(isPresented: $isShowOkAlert) { () -> Alert in
                okAlert
            }
            Button(action: {
                isShowErrorAlert = true
            }) {
                Image(systemName: "play")
                .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
            }
            .alert(isPresented: $isShowErrorAlert) { () -> Alert in
                errorAlert
            }

            Button(action: {
                isShowRetryAlert = true
            }) {
                Image(systemName: "person.badge.plus")
                .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
            }
            .alert(isPresented: $isShowRetryAlert) { () -> Alert in
                retryAlert
            }
        }
    }
}

struct AlertSample_Previews: PreviewProvider {
    static var previews: some View {
        AlertSample()
    }
}
