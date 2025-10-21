//
//  FollowersChartView.swift
//  IG analizer
//
//  Created by Tommy on 19/10/25.
//

import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
    let category: String
}

struct FollowersChartView: View {
    let history: FollowersHistory
    @State private var selectedTimeRange: TimeRange = .last7Days
    @State private var selectedDate: Date?
    @State private var selectedFollowers: Int?
    @State private var selectedFollowing: Int?
    
    enum TimeRange: String, CaseIterable {
        case last7Days = "7 giorni"
        case last30Days = "30 giorni"
        case all = "Tutto"
    }
    
    var filteredData: [(date: Date, followers: Int, following: Int)] {
        let chartData = history.getChartData()
        
        switch selectedTimeRange {
        case .last7Days:
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return chartData.filter { $0.date >= sevenDaysAgo }
        case .last30Days:
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return chartData.filter { $0.date >= thirtyDaysAgo }
        case .all:
            return chartData
        }
    }
    
    var chartDataPoints: [ChartDataPoint] {
        var points: [ChartDataPoint] = []
        
        for data in filteredData {
            // Punto per followers
            points.append(ChartDataPoint(
                date: data.date,
                value: data.followers,
                category: "Followers"
            ))
            
            // Punto per following
            points.append(ChartDataPoint(
                date: data.date,
                value: data.following,
                category: "Following"
            ))
        }
        
        return points
    }
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                
                Picker("", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            // Grafico sempre visibile con dati separati
            Chart(chartDataPoints) { point in
                LineMark(
                    x: .value("Data", point.date),
                    y: .value("Valore", point.value)
                )
                .foregroundStyle(by: .value("Categoria", point.category))
                .lineStyle(StrokeStyle(lineWidth: 4))
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Data", point.date),
                    y: .value("Valore", point.value)
                )
                .foregroundStyle(by: .value("Categoria", point.category))
                .symbolSize(60)
                
                // Linea verticale per il punto selezionato
                if let selectedDate = selectedDate {
                    RuleMark(x: .value("Data Selezionata", selectedDate))
                        .foregroundStyle(.gray.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
            }
            .chartForegroundStyleScale([
                "Followers": Color(red: 0.918, green: 0.247, blue: 0.808), // Fucsia principale
                "Following": Color(red: 0.961, green: 0.800, blue: 0.047)  // Giallo più brillante
            ])
            .chartLegend(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: filteredData.count > 10 ? 3 : 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartAngleSelection(value: $selectedDate)
            .frame(height: 200)
            .onChange(of: selectedDate) { oldValue, newValue in
                if let date = newValue {
                    // Trova i valori corrispondenti alla data selezionata
                    if let dataPoint = filteredData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                        selectedFollowers = dataPoint.followers
                        selectedFollowing = dataPoint.following
                    }
                } else {
                    selectedFollowers = nil
                    selectedFollowing = nil
                }
            }
            
            // Tooltip con i valori selezionati
            if let date = selectedDate, let followers = selectedFollowers, let following = selectedFollowing {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date, format: .dateTime.day().month().year())
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    HStack {
                        Circle()
                            .fill(Color(red: 0.918, green: 0.247, blue: 0.808))
                            .frame(width: 8, height: 8)
                        Text("Followers: \(followers)")
                            .font(.caption)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color(red: 0.961, green: 0.800, blue: 0.047))
                            .frame(width: 8, height: 8)
                        Text("Following: \(following)")
                            .font(.caption)
                    }
                    
                    // Calcola differenza
                    let difference = followers - following
                    HStack {
                        Image(systemName: difference >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(difference >= 0 ? .green : .red)
                        Text("Differenza: \(abs(difference))")
                            .font(.caption)
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 4)
                .transition(.opacity)
            }
            
            // Legenda integrata con dati attuali
            HStack(spacing: 30) {
                // Followers con dato integrato
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color(red: 0.918, green: 0.247, blue: 0.808)) // Fucsia
                        .frame(width: 20, height: 4)
                    if !filteredData.isEmpty, let latest = filteredData.last {
                        Text("Followers \(latest.followers)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else {
                        Text("Followers")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                // Following con dato integrato
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color(red: 0.961, green: 0.800, blue: 0.047)) // Giallo brillante
                        .frame(width: 20, height: 4)
                    if !filteredData.isEmpty, let latest = filteredData.last {
                        Text("Following \(latest.following)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else {
                        Text("Following")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.top, 8)

        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleHistory = FollowersHistory()
    return FollowersChartView(history: sampleHistory)
}