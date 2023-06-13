//
//  ContentView.swift
//  BetterRest
//
//  Created by Dr Cpt Blackbeard on 6/9/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var suggestedBedtime = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 5) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    // Even though we hide the label here, we still put in a helpful title for screen readers
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .onChange(of: wakeUp) { _ in
                    calculateBedtime()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                .onChange(of: sleepAmount) { _ in
                    calculateBedtime()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("Cups", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { num in
                            Text("\(num)")
                        }
                    }
                }
                .onChange(of: coffeeAmount) { _ in
                    calculateBedtime()
                }
                
                Section {
                    Text(suggestedBedtime)
                } header: {
                    Text("Suggested Bedtime")
                }
                .font(.title2)
                .onAppear(perform: calculateBedtime)
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok") {}
            } message: {
                Text("Error")
            }
        }
    }

    func calculateBedtime() {
        do {
            // The default configuration (usually this is all you need...any more parameters are just super advanced)
            let config = MLModelConfiguration()
            // Model instance that reads in all the data we want (coffee intake, when you want to sleep etc...) and outputs a prediction
            // We use Try because loading the model might fail (could be incompatable etc..)
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60 // hours -> minutes -> seconds
            let minute = (components.minute ?? 0) * 60 // minutes -> seconds
            let totalSeconds = hour + minute // total seconds from 0 AKA midnight
            
            // Prediction is how much sleep they need...this was not part of our training data, it's something totally new
            let prediction = try model.prediction(wake: Double(totalSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            suggestedBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error, unable to calculate your bedtime."
            showingAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




//
//
////
////  ContentView.swift
////  BetterRest
////
////  Created by Dr Cpt Blackbeard on 6/9/23.
////
//import CoreML
//import SwiftUI
//
//struct ContentView: View {
//    @State private var wakeUp = defaultWakeTime
//    @State private var sleepAmount = 8.0
//    @State private var coffeeAmount = 1
//
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var showingAlert = false
//
//    static var defaultWakeTime: Date {
//        var components = DateComponents()
//        components.hour = 7
//        components.minute = 0
//        return Calendar.current.date(from: components) ?? Date.now
//
//    }
//
//    var body: some View {
//        NavigationView {
//            Form {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("When do you want to wake up?")
//                        .font(.headline)
//
//                    // Even though we hide the label here, we still put in a helpful title for screen readers
//                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
//                        .labelsHidden()
//                }
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Desired amount of sleep")
//                        .font(.headline)
//
//                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
//                }
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Daily coffee intake")
//                        .font(.headline)
//
//                    Picker("Cups", selection: $coffeeAmount) {
//                        ForEach(1...20, id: \.self) { num in
//                            Text("\(num)")
//                        }
//                    }
//                }
//            }
//            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("Ok") {}
//            } message: {
//                Text(alertMessage)
//            }
//        }
//    }
//
//    func calculateBedtime() {
//        do {
//            // The default configuration (usually this is all you need...any more parameters are just super advanced)
//            let config = MLModelConfiguration()
//            // Model instance that reads in all the data we want (coffee intake, when you want to sleep etc...) and outputs a prediction
//            // We use Try because loading the model might fail (could be incompatable etc..)
//            let model = try SleepCalculator(configuration: config)
//
//            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
//            let hour = (components.hour ?? 0) * 60 * 60 // hours -> minutes -> seconds
//            let minute = (components.minute ?? 0) * 60 // minutes -> seconds
//            let totalSeconds = hour + minute // total seconds from 0 AKA midnight
//
//            // Prediction is how much sleep they need...this was not part of our training data, it's something totally new
//            let prediction = try model.prediction(wake: Double(totalSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
//
//            let sleepTime = wakeUp - prediction.actualSleep
//            alertTitle = "Your ideal bedtime is..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
////            print("wakeup: \(wakeUp)")
////            print("prediction: \(prediction.actualSleep)")
////            print("sleep time: \(sleepTime)")
//
//        } catch {
//            alertTitle = "Error"
//            alertMessage = "Sorry, unable to calculate your bedtime."
//        }
//
//        showingAlert = true
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
