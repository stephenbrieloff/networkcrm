import SwiftUI
import CoreData

struct AddContactView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var company = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var metAt = ""
    
    @State private var showingSuccessAlert = false
    @State private var isKeyboardVisible = false
    
    // Focus management for fast input
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, company, email, phone, metAt
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Details")) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Required fields
                        Group {
                            TextField("First Name", text: $firstName)
                                .focused($focusedField, equals: .firstName)
                                .textContentType(.givenName)
                                .submitLabel(.next)
                            
                            TextField("Last Name", text: $lastName)
                                .focused($focusedField, equals: .lastName)
                                .textContentType(.familyName)
                                .submitLabel(.next)
                            
                            TextField("Company", text: $company)
                                .focused($focusedField, equals: .company)
                                .textContentType(.organizationName)
                                .submitLabel(.next)
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Optional fields
                        Group {
                            TextField("Email (optional)", text: $email)
                                .focused($focusedField, equals: .email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .submitLabel(.next)
                            
                            TextField("Phone (optional)", text: $phone)
                                .focused($focusedField, equals: .phone)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                                .submitLabel(.next)
                            
                            TextField("Where did you meet? (optional)", text: $metAt)
                                .focused($focusedField, equals: .metAt)
                                .submitLabel(.done)
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .headerProminence(.increased)
                
                Section {
                    Button(action: saveContact) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Contact")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Color.accentColor : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canSave)
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
            .onSubmit {
                // Handle return key navigation
                switch focusedField {
                case .firstName:
                    focusedField = .lastName
                case .lastName:
                    focusedField = .company
                case .company:
                    focusedField = .email
                case .email:
                    focusedField = .phone
                case .phone:
                    focusedField = .metAt
                case .metAt:
                    if canSave {
                        saveContact()
                    }
                case .none:
                    break
                }
            }
            .onAppear {
                // Auto-focus first field for immediate typing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .firstName
                }
            }
            .alert("Contact Saved!", isPresented: $showingSuccessAlert) {
                Button("Add Another") {
                    clearForm()
                    focusedField = .firstName
                }
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Contact successfully added to your network!")
            }
        }
    }
    
    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveContact() {
        guard canSave else { return }
        
        let newContact = Contact(context: viewContext)
        newContact.id = UUID()
        newContact.firstName = firstName.trimmingCharacters(in: .whitespaces)
        newContact.lastName = lastName.trimmingCharacters(in: .whitespaces)
        newContact.company = company.trimmingCharacters(in: .whitespaces).isEmpty ? nil : company.trimmingCharacters(in: .whitespaces)
        newContact.email = email.trimmingCharacters(in: .whitespaces).isEmpty ? nil : email.trimmingCharacters(in: .whitespaces)
        newContact.phone = phone.trimmingCharacters(in: .whitespaces).isEmpty ? nil : phone.trimmingCharacters(in: .whitespaces)
        newContact.metAt = metAt.trimmingCharacters(in: .whitespaces).isEmpty ? nil : metAt.trimmingCharacters(in: .whitespaces)
        newContact.dateAdded = Date()
        newContact.interactionCount = 0
        newContact.quickTags = []
        newContact.conversationTopics = []
        
        do {
            try viewContext.save()
            showingSuccessAlert = true
        } catch {
            // Handle the error appropriately
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func clearForm() {
        firstName = ""
        lastName = ""
        company = ""
        email = ""
        phone = ""
        metAt = ""
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}