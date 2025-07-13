//
//  LoginView.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 7/13/25.
//

import SwiftUI

import Observation

extension View {
    func lightGrayOutline() -> some View {
        self
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius : 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    func darkGrayForeground() -> some View {
        self
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius : 8)
                    .fill(Color.black)
            )
    }
}

@Observable class UserValidator {
    var email = ""
    var password = ""
    
    var isSubmitButtonDisabled : Bool {
        email.isEmpty || password.count < 8 || !isValidEmail(string : email)
    }
    
    // need to understand what's happening in this method
    func isValidEmail(string : String) -> Bool {
        let emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/
            .ignoresCase()
        return !string.ranges(of: emailRegex).isEmpty
    }
}

struct LoginView: View {
    @Bindable var userValidator : UserValidator
    
    var body: some View {
        VStack {
            Text("BaiBai")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .padding(.top, 60)

            Spacer()
            // Pushes everything below down

            VStack(spacing: 30) {
                VStack {
                    Text("Create an account")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    Text("Enter your email to sign up for this app")
                }

                VStack(spacing: 20) {
                    TextField(text: $userValidator.email) {
                        Text("email\u{200B}@domain.com")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                    SecureField(text: $userValidator.password) {
                        Text("Password")
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .lightGrayOutline()

                    Button {
                        print("Email: \(userValidator.email), Password \(userValidator.password)")
                    } label: {
                        Text("Create account")
                    }
                    .disabled(userValidator.isSubmitButtonDisabled)
                    .foregroundColor(.white)
                                .frame(maxWidth: .infinity) // fill the button horizontally
                                .padding(12) // vertical padding for height
                                .background(Color(.black)) // dark gray background
                                .cornerRadius(8)
                    
                    
                    Button {
                        
                    } label: {
                        Image("GoogleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                        Text("Continue with Google")
                    }
                    .foregroundColor(.black)
                                .frame(maxWidth: .infinity) // fill the button horizontally
                                .padding(12) // vertical padding for height
                                .background(Color(.gray.opacity(0.3))) // dark gray background
                                .cornerRadius(8)
                    
                    
                    Button {
                        
                    } label: {
                        Image("AppleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                        Text("Continue with Apple")
                    }
                    .foregroundColor(.black)
                                .frame(maxWidth: .infinity) // fill the button horizontally
                                .padding(12) // vertical padding for height
                                .background(Color(.gray.opacity(0.3))) // dark gray background
                                .cornerRadius(8)
                }
                .padding(.horizontal)
            }

            Spacer()
            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var userValidator = UserValidator()
    LoginView(userValidator : userValidator)
}
