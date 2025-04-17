import SwiftUI
import LocalAuthentication

struct LoginView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    let primaryColor = Color(red: 28/255, green: 44/255, blue: 138/255)
    let screenWidth = UIScreen.main.bounds.width
    @State private var cpfCnpj: String = ""
    @State private var senha: String = ""
    @State private var rememberLogin: Bool = false
    @State private var isPasswordVisible = false
    @State var isLoading = false
    @State var showWebView = false
    @State var destinationWebView = WebViewDestination.esqueciMinhaSenha
    let maxCPFLength = 14
    let maxCNPJLength = 18
    @FocusState private var isTextFieldFocused: Bool
    @State var userEmpy                     = false
    @State var passEmpy                     = false
    @State var erroFaceID                   = false
    @State var errorLogin                   = false
    @State var errorMessage                 = ""
    @AppStorage("username") var username    = ""
    @AppStorage("password") var password    = ""
    @AppStorage("authAppkey") var authAppkey    = ""
    @AppStorage("authAppidU") var authAppidU    = ""
    @State var saveUser                     = true
    @State var novoLogin                    = true
    
    var body: some View {
        ZStack{
            if isLoading {
                LoadingView(text:"Carregando...")
                    .zIndex(1.5)
            }
            ZStack {
                primaryColor.ignoresSafeArea()
                VStack {
                    HStack{
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.title2)
                                .frame(width: 56, height: 56)
                        }
                        
                        Spacer()
                        
                        Text("Faça seu Login")
                            .font(.headline)
                            .foregroundColor( .white)
                        
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
                                    //TextField("123.456.789-10", text: $cpfCnpj)
                                    TextField("123.456.789-10", text:Binding(
                                        get: { cpfCnpj },
                                        set: { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            cpfCnpj = applyMask(filtered)
                                            
                                            if cpfCnpj.count <= maxCPFLength || cpfCnpj.count <= maxCNPJLength {
                                                cpfCnpj = String(cpfCnpj.prefix(maxCPFLength))
                                            }
                                        }
                                    ))
                                        .foregroundColor(.black)
                                        .focused($isTextFieldFocused)
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
                                        TextField("Senha", text: $senha)
                                            .focused($isTextFieldFocused)
                                            .autocapitalization(.none)
                                    } else {
                                        SecureField("Senha", text: $senha)
                                            .focused($isTextFieldFocused)
                                            .autocapitalization(.none)
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
                                if validateUsers() {
                                    saveUserAndPassword(rememberLogin)
                                    authFaceID()
                                }
                            }) {
                                Text("Entrar")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 48)
                            
                            Button(action: {
                                destinationWebView = .esqueciMinhaSenha
                                showWebView = true
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
                                    destinationWebView = .cadastro
                                    showWebView = true
                                }) {
                                    Text("Cadastre-se")
                                        .foregroundColor(primaryColor)
                                }
                            }
                            .padding(.top, 48)
                            
                            Spacer()
                        }
                        
                        .padding()
                        //.frame(width: .infinity,height: .infinity)
                    }
                }
            }
                //.frame(width: .infinity, height: .infinity)
                .zIndex(1)
                .fullScreenCover(isPresented: $showWebView){
                    WebView(url: DataInteractor.getURL(destinationWebView)) { errorDescription in
                        print(errorDescription)
                    }
                }
                .onAppear{
                    self.cpfCnpj = username
                    self.senha   = password
                    if self.cpfCnpj.isEmpty && self.senha.isEmpty{
                        self.rememberLogin = false
                    } else {
                        self.rememberLogin = true
                    }
                    DispatchQueue.main.async{
                        authFaceID(true)
                    }
                }
                .alert("Informe o usuário corretamente!", isPresented: $userEmpy ) {
                    Button("OK", role: .cancel) {
                        userEmpy = false
                    }
                }
                .alert("Informe a senha corretamente!", isPresented: $passEmpy ) {
                    Button("OK", role: .cancel) {
                        passEmpy = false
                    }
                }
                .alert("Erro ao validar o Face ID!", isPresented: $erroFaceID ) {
                    Button("OK", role: .cancel) {
                        erroFaceID = false
                    }
                }
                .alert("Erro no Login!\n\n\(errorMessage)", isPresented: $errorLogin ) {
                    Button("OK", role: .cancel) {
                        errorLogin = false
                        errorMessage = ""
                    }
                }
        }
        .environment(\.colorScheme, .light)
    }
}

extension LoginView {
    private func applyMask(_ text: String) -> String {
        var formattedText = ""
        let cpfLength = 11
        
        for i in 0..<text.count {
            if i < cpfLength {
                formattedText.append(text[text.index(text.startIndex, offsetBy: i)])
                if i == 2 || i == 5 {
                    formattedText.append(".")
                } else if i == 8 {
                    formattedText.append("-")
                }
            } else {
                formattedText.append(text[text.index(text.startIndex, offsetBy: i)])
                if i == 1 || i == 4 {
                    formattedText.append(".")
                } else if i == 7 {
                    formattedText.append("/")
                } else if i == 11 {
                    formattedText.append("-")
                }
            }
        }
        
        return formattedText
    }
    
    private func extractNumbers(from input: String) -> String {
        let numbersOnly = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return numbersOnly
    }
    
    func validateUsers(_ showError: Bool = true)-> Bool {
        if self.cpfCnpj.isEmpty {
            if showError {
                userEmpy = true
            }
            return false
        } else if self.senha.isEmpty {
            if showError {
                passEmpy = true
            }
            return false
        } else {
            return true
        }
    }
    
    func saveUserAndPassword(_ saveData: Bool){
        if saveData {
            if username == cpfCnpj && password == senha {
                self.novoLogin = authAppkey.isEmpty && authAppidU.isEmpty
            } else {
                self.username = self.cpfCnpj
                self.password = self.senha
                self.novoLogin = true
            }
        } else {
            self.novoLogin = true
            self.username = ""
            self.password = ""
        }
    }
    
    func authFaceID(_ firstTime: Bool = false){
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: .none) {

            guard validateUsers(!firstTime) else { return }

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Validação de seguraça") { success, error in
                if success {
                    login()
                } else {
                    erroFaceID = true
                }
            }
            
        } else {
            guard validateUsers(!firstTime) else { return }
            guard !firstTime else {return}
            
            login()
        }
        
    }
    
    func login(){
        dump("login!")
        isLoading = true
        if !self.novoLogin {
            print("Login sem request realizado com sucesso!")
            isLoading = false
            destinationWebView = .novoMenu
            showWebView = true
            return
        }
        DataInteractor.shared.login(user: self.extractNumbers(from: self.cpfCnpj), password: self.senha) { result in
            switch result{
            case .success():
                DispatchQueue.main.async{
                    print("Login realizado com sucesso!")
                    isLoading = false
                    destinationWebView = .novoMenu
                    showWebView = true
                }
            case .failure(let error):
                DispatchQueue.main.async{
                    print("erro no login: "+error.localizedDescription)
                    isLoading = false
                    errorLogin = true
                    
                    if !error.localizedDescription.contains("The request timed out.") {
                        errorMessage = "Usuário e/ou senha estão errados!"
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    //MARK: - Fechando o teclado
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isTextFieldFocused = false
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
