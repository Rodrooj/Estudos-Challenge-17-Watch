//
//  WRealWorkout.swift
//  Watch Teste Watch App
//
//  Created by Rodrigo Barbosa Pereira on 18/08/26.
//

import SwiftUI
import WorkoutKit
import HealthKit
// MARK: - 1. Builder do Treino Personalizado
struct PitchWorkoutBuilder {
    
    /// Constrói a estrutura de CustomWorkout baseada nos minutos definidos pelo usuário.
    static func buildPitchWorkout(
        warmupMinutes: Double,
        pitchMinutes: Double
    ) -> CustomWorkout {
        
        // 1. Etapa de Aquecimento / Preparação Mental
        let warmupStep = WorkoutStep(
            goal: .time(warmupMinutes, .minutes)
        )
        
        // 2. Etapa Principal: Apresentação do Pitch
        let pitchStep = WorkoutStep(
            goal: .time(pitchMinutes, .minutes)
        )
        
        // 3. Inclui a etapa principal em um bloco executado uma vez.
        let pitchInterval = IntervalStep(.work, step: pitchStep)
        let pitchBlock = IntervalBlock(steps: [pitchInterval], iterations: 1)

        // 4. Monta o treino com aquecimento e etapa principal.
        let customWorkout = CustomWorkout(
            activity: .mindAndBody,
            location: .indoor,
            displayName: "Treino de Pitch Deck",
            warmup: warmupStep,
            blocks: [pitchBlock],
            cooldown: nil // Sem desaquecimento
        )
        
        return customWorkout
    }
}
// MARK: - 2. View Principal da Interface no Apple Watch
struct WRealWorkout: View {
    
    // Parâmetros configuráveis da apresentação (em minutos)
    @State private var warmupDuration: Double = 2.0
    @State private var pitchDuration: Double = 5.0
    
    // Estado para controlar a exibição da tela nativa de treino do WorkoutKit
    @State private var workoutPlan: WorkoutPlan? = nil
    @State private var showingWorkoutPreview: Bool = false
    
    // Non-optional plan used by the workoutPreview modifier
    private var currentPlan: WorkoutPlan {
        if let plan = workoutPlan { return plan }
        // Fallback plan based on current durations so the modifier always has a value
        let fallback = PitchWorkoutBuilder.buildPitchWorkout(
            warmupMinutes: warmupDuration,
            pitchMinutes: pitchDuration
        )
        return WorkoutPlan(.custom(fallback))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                
                // Cabeçalho da View
                HeaderView
                
                Divider()
                
                // Controles de Seleção de Tempo
                WarmupControl
                
                PitchControl
                
//                Spacer(minLength: 10)
                
                // Botão para Iniciar o Treino no WorkoutKit
                StartWorkoutButton
            }
            .padding(.horizontal)
        }
        // Modifier nativo do WorkoutKit que exibe o resumo e permite disparar o treino no Apple Watch
        .workoutPreview(currentPlan, isPresented: $showingWorkoutPreview)
    }
}
// MARK: - 3. Componentes de UI Modulares
extension WRealWorkout {
    
    private var HeaderView: some View {
        VStack(spacing: 4) {
            Image(systemName: "mic.fill")
                .font(.title2)
                .foregroundStyle(.cyan)
            
            Text("Pitch & Entrevista")
                .font(.headline)
                .bold()
        }
    }
    
    private var WarmupControl: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Preparação: \(Int(warmupDuration)) min")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Stepper(value: $warmupDuration, in: 1...10, step: 1) {
                Text("\(Int(warmupDuration))m")
            }
        }
    }
    
    private var PitchControl: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Pitch: \(Int(pitchDuration)) min")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Stepper(value: $pitchDuration, in: 1...30, step: 1) {
                Text("\(Int(pitchDuration))m")
            }
        }
    }
    
    private var StartWorkoutButton: some View {
        Button(action: prepareAndStartWorkout) {
            HStack {
                Image(systemName: "play.fill")
                Text("Iniciar Pitch")
                    .bold()
            }
            .frame(maxWidth: .infinity)
        }
        .tint(.cyan)
        .buttonStyle(.borderedProminent)
    }
}
// MARK: - 4. Lógica de Disparo do WorkoutKit
extension WRealWorkout {
    
    private func prepareAndStartWorkout() {
        // 1. Gera o modelo do treino
        let workout = PitchWorkoutBuilder.buildPitchWorkout(
            warmupMinutes: warmupDuration,
            pitchMinutes: pitchDuration
        )
        
        // 2. Encapsula no objeto WorkoutPlan do WorkoutKit
        self.workoutPlan = WorkoutPlan(.custom(workout))
        
        // 3. Exibe o Preview Nativo do WorkoutKit no watchOS
        self.showingWorkoutPreview = true
    }
}
#Preview {
    WRealWorkout()
}

