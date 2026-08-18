//
//  WWorkout.swift
//  Watch Teste Watch App
//
//  Created by Rodrigo Barbosa Pereira on 18/08/26.
//

import SwiftUI
import HealthKit
import Combine

@MainActor
class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    // variáveis para atualizar a UI
    @Published var isPresenting = false
    @Published var heartRate: Double = 0.0
    @Published var activeEnergy: Double = 0.0
    @Published var startDate: Date? = nil
    @Published var workoutState: HKWorkoutSessionState = .notStarted

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToShare: Set<HKSampleType> = [HKObjectType.workoutType()]
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            print("Erro na permissão do HealthKit: \(error.localizedDescription)")
        }
    }
    
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print("Erro ao criar sessão: \(error.localizedDescription)")
            return
        }
        
        // Define os delegates para receber os dados ao vivo
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        
        let now = Date()
        session?.startActivity(with: now)
        builder?.beginCollection(withStart: now) { [weak self] sucess, error in
            guard let self = self, sucess else { return }
            DispatchQueue.main.async {
                self.isPresenting = true
                self.startDate = now
            }
        }
    }
    
    // função não utilizada
//    func togglePauseResume() {
//        if workoutState == .running {
//            session?.pause()
//        } else if workoutState == .paused {
//            session?.resume()
//        }
//    }
    
    func endWorkout() {
        session?.end()
        let endDate = Date()

        builder?.finishWorkout() { [weak self] sucess, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isPresenting = false
                self.startDate = nil
                self.heartRate = 0
                self.activeEnergy = 0
            }
        }
    }
}

// MARK: - Delegates para receber os dados dos Sensores
extension WorkoutManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutSession (_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            self.workoutState = toState
        }
    }
    
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Sessão falhou: \(error.localizedDescription)")
    }
    
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            if let statistics = workoutBuilder.statistics(for: quantityType) {
                // Atualiza a interface na thread principal
                Task { @MainActor in
                    self.updateForStatistics(statistics)
                }
            }
        }
    }
    
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    
    // Atualiza as variáveis com base no sensor atual
    @MainActor
    private func updateForStatistics(_ statistics: HKStatistics) {
          guard let quantityType = statistics.quantityType as? HKQuantityType else { return }

          if quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) {
              let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
              self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
              return
          }

          if quantityType == HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
              let energyUnit = HKUnit.kilocalorie()
              self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
              return
          }
      }
}

struct WWorkout: View {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some View {
        VStack(spacing: 4) {
            if let startDate = workoutManager.startDate {
                Text(startDate, style: .timer)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.yellow)
            } else {
                Text("00:00")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(Int(workoutManager.heartRate))")
                        .font(.title2)
                    Text("BPM").font(.caption2).foregroundColor(.gray)
                }
                
                VStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(Int(workoutManager.activeEnergy))")
                        .font(.title2)
                    Text("KCAL").font(.caption2).foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                if workoutManager.isPresenting {
                    workoutManager.endWorkout()
                } else {
                    workoutManager.startWorkout()
                }
            }) {
                Text(workoutManager.isPresenting ? "Finalizar" : "Iniciar Treino")
                    .bold()
            }
            .tint(workoutManager.isPresenting ? .red : .green)
        }
        .task {
            await workoutManager.requestAuthorization()
        }
    }
}

#Preview {
    WWorkout()
}
