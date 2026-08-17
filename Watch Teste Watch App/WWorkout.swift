//
//  WWorkout.swift
//  Watch Teste Watch App
//
//  Created by Rodrigo Barbosa Pereira on 17/08/26.
//

import SwiftUI
import HealthKit

struct WWorkout: View {
    let healthStore = HKHealthStore()
    
    @State private var stepCount: Double = 0.0
    @State private var isAuthorized = false
    
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
            } else {
                Text("Sem permissão")
                    .foregroundColor(.gray)
            }            
        }
        .onAppear {
            requestAuthorization()
        }
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        let readTypes: Set = [stepType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { sucess, error in
            if sucess {
                DispatchQueue.main.async {
                    self.isAuthorized = true
                }
                fetchSteps()
            }
        }
    }
    
    func fetchSteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Falha ao buscar passos: \(error?.localizedDescription ?? "Erro desconhecido")")
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            
            DispatchQueue.main.async {
                self.stepCount = steps
            }
        }
        healthStore.execute(query)
    }
}

#Preview {
    WWorkout()
}
