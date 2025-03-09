import SwiftUI

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(.bottom, isKeyboardVisible ? keyboardHeight - getSafeAreaBottomInset() : 0) // ✅ Safe area’yı çıkararak padding’i düzeltiyoruz
            .onAppear {
                addKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
            .animation(.easeOut(duration: 0.16), value: keyboardHeight)
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                DispatchQueue.main.async {
                    withAnimation {
                        self.keyboardHeight = keyboardFrame.height - 15
                        self.isKeyboardVisible = true
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async {
                withAnimation {
                    self.keyboardHeight = 0
                    self.isKeyboardVisible = false
                }
            }
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// **📌 Güvenli alan alt yüksekliğini almak için fonksiyon**
    private func getSafeAreaBottomInset() -> CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.bottom ?? 0
    }
}

// Kullanımı kolaylaştırmak için View'e extension ekleyelim
extension View {
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
}
