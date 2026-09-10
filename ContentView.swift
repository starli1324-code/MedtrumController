import SwiftUI

struct ContentView: View {
    @StateObject var pumpManager = MedtrumPumpManager()
    @StateObject var healthManager = HealthKitManager()
    
    @State private var bolusAmount: String = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Карточка статуса
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Статус помпы:")
                        Spacer()
                        Text(pumpManager.status.isConnected ? "Подключено" : "Отключено")
                            .foregroundColor(pumpManager.status.isConnected ? .green : .red)
                            .bold()
                    }
                    
                    HStack {
                        Text("Глюкоза (HealthKit):")
                        Spacer()
                        Text(String(format: "%.1f ммоль/л", healthManager.latestGlucose))
                            .font(.title2)
                            .bold()
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Форма введения болюса
                VStack(alignment: .leading, spacing: 10) {
                    Text("Введение болюса")
                        .font(.headline)
                    
                    HStack {
                        TextField("0.0", text: $bolusAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Ед")
                    }
                    
                    Button(action: {
                        if let units = Double(bolusAmount), units > 0 {
                            pumpManager.deliverBolus(units: units)
                            showAlert = true
                        }
                    }) {
                        Text("Подать болюс")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(pumpManager.status.isConnected ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!pumpManager.status.isConnected)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .navigationTitle("Medtrum Controller")
            .onAppear {
                healthManager.requestAuthorization()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Команда отправлена"),
                    message: Text("Запрос на болюс \(bolusAmount) ЕД отправлен на базу Medtrum."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
