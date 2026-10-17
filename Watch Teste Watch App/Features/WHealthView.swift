//
//  WHealthView.swift
//  Watch Teste Watch App
//
//  Created by Rodrigo Barbosa Pereira on 17/08/26.
//

import SwiftUI
import HealthKit

struct WHealthView: View {
    // Instância principal para acessar o banco de dados do HealthKit
    let healthStore = HKHealthStore()
    
    // variáveis para atualizar a UI
    @State private var stepCount: Double = 0.0
    @State private var isAuthorized = false
    @State private var authorizationError: String?
    
    var body: some View {
        VStack {
            Image(systemName: "figure.walk.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Passos Hoje")
                .font(.headline)
            
            if isAuthorized {
                Text("\(Int(stepCount))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
            } else if let authorizationError {
                Text("Não foi possível carregar os dados de saúde")
                    .foregroundColor(.gray)
                Text(authorizationError)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Aguardando acesso aos dados")
                    .foregroundColor(.gray)
            }            
        }
        .onAppear {
            requestAuthorization()
        }
    }
    
    func requestAuthorization() {
        // Verifica se o HealthKit está disponível no dispositivo
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // Define o tipo de dado lido
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        let readTypes: Set = [stepType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            guard success else {
                DispatchQueue.main.async {
                    self.authorizationError = error?.localizedDescription
                        ?? "A solicitação de autorização ao HealthKit falhou."
                }
                return
            }

            DispatchQueue.main.async {
                self.authorizationError = nil
                // O retorno positivo conclui a solicitação, mas não revela se a leitura
                // foi autorizada pelo usuário; o HealthKit preserva essa informação.
                self.isAuthorized = true
            }
            fetchSteps()
        }
    }
    
    func fetchSteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                let message = error?.localizedDescription ?? "O HealthKit não retornou dados de passos."
                print("Falha ao buscar passos: \(message)")
                DispatchQueue.main.async {
                    self.authorizationError = message
                }
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            
            // Atualiza a interface na thread principal
            DispatchQueue.main.async {
                self.stepCount = steps
            }
        }
        healthStore.execute(query)
    }
}

#Preview {
    WHealthView()
}
