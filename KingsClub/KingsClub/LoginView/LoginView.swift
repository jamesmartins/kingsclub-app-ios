import SwiftUI

struct LoginView: View {
    
    let primaryColor = Color(red: 28/255, green: 44/255, blue: 138/255) // #1C2C8A
    let screenWidth = UIScreen.main.bounds.width
    
    @State private var cpfCnpj: String = ""
    @State private var password: String = ""
    @State private var rememberLogin: Bool = false
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        ZStack {
            primaryColor.ignoresSafeArea()
            VStack {
                HStack{
                    Button(action: {
                        
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                            .frame(width: 56, height: 56)
                    }
                    
                    Spacer()
                    
                    Text("Faça seu Login")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image("logo_icon")
                        .resizable()
                        .frame(width: 56, height: 56)
                }
                
                Text("Kings Sneakers")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Acesse agora nosso app e desbloqueie vantagens exclusivas Kings!")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                Spacer()
                
                ZStack{
                    
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 8){
                        
                        Text("CPF/CNPJ")
                            .foregroundColor(primaryColor)
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(primaryColor, lineWidth: 1)
                            HStack{
                                Image(systemName: "person")
                                    .foregroundColor(primaryColor)
                                TextField("123.456.789-10", text: $cpfCnpj)
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 48)
                            
                        Text("Senha")
                            .foregroundColor(primaryColor)
                            .padding(.top,16)
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(primaryColor, lineWidth: 1)
                            HStack{
                                Image(systemName: "key")
                                    .foregroundColor(primaryColor)
                                
                                if isPasswordVisible {
                                    TextField("Senha", text: $password)
                                } else {
                                    SecureField("Senha", text: $password)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                        .foregroundColor(primaryColor)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 48)
                        
                        
                        
                        Toggle("Lembrar informações de login", isOn: $rememberLogin)
                            .padding(.top, 8)
                            .tint(primaryColor)
                        
                        // Entrar Button
                        Button(action: {
                            print("Ação do botão Entrar")
                        }) {
                            Text("Entrar")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 48)
                        
                        // Cadastrar-se Button
                        Button(action: {
                            print("Ação do botão Cadastrar-se")
                        }) {
                            Text("Esqueci minha senha")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(primaryColor, lineWidth: 2)
                                )
                                .foregroundColor(primaryColor)
                        }
                        .padding(.top, 8)
                        
                        HStack {
                            Text("Não possui cadastro?")
                            Button(action: {
                                // Ação do botão "Cadastre-se"
                            }) {
                                Text("Cadastre-se")
                                    .foregroundColor(primaryColor)
                            }
                        }
                        .padding(.top, 48)
                        
                        Spacer()
                    }
                    
                    .padding()
                    .frame(width: .infinity,height: .infinity)
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
