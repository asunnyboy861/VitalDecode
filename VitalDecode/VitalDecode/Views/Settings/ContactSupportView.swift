import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false

    private let topics = ["General", "Bug Report", "Feature Request", "Subscription", "Data Issue", "Other"]
    private let backendURL = URL(string: "https://feedback-board.iocompile67692.workers.dev")!

    var body: some View {
        NavigationStack {
            Form {
                Section("Topic") {
                    Picker("Topic", selection: $topic) {
                        ForEach(topics, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                }

                Section("Your Info") {
                    TextField("Name (optional)", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                }

                Section {
                    Button {
                        submitFeedback()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Submit")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                    .disabled(email.isEmpty || message.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your message has been sent. We'll get back to you soon.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Failed to send message. Please try again later.")
            }
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        let body: [String: Any] = [
            "topic": topic,
            "name": name,
            "email": email,
            "message": message,
            "app": "VitalDecode"
        ]

        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    showError = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    showSuccess = true
                } else {
                    showError = true
                }
            }
        }.resume()
    }
}
