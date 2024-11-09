//
//  ContentView.swift
//  learning-app
//
//  Created by Alan Perez on 26/10/24.
//

import SwiftUI

/*
 validated states:
 -1 = not validated
  0 = validating
  1 = validated
*/

public var VALIDATED = 1
public var IN_PROGRESS = 0
public var NOT_VALIDATED = -1
public var NOT_SELECTED_INDEX = -1

struct ContentView: View {
    @State private var score: Int = 0
    @State private var attempt: Int = 1
    @State private var countries = [
        "Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain",
        "UK", "US",
    ].shuffled()
    @State private var showAlert: Bool = false
    @State private var validated: Int = NOT_VALIDATED
    @State private var selectedIndex: Int = NOT_SELECTED_INDEX

    var correctAnswer = Int.random(in: 0...2)

    private func isNotFlagSelected() -> Bool {
        return selectedIndex == NOT_SELECTED_INDEX && validated == NOT_VALIDATED
    }

    private func isPendingToValidate() -> Bool {
        return selectedIndex > NOT_SELECTED_INDEX && validated == NOT_VALIDATED
    }

    private func isValidated() -> Bool {
        return selectedIndex > NOT_SELECTED_INDEX && validated == VALIDATED
    }

    private func flagSelectedByUser(_ number: Int) -> Bool {
        return selectedIndex == number && !isValidated()
    }

    private func errorFlagSelectedByUser(_ number: Int) -> Bool {
        return selectedIndex == number && isValidated()
            && selectedIndex
                != correctAnswer
    }

    private func isGameScreen() -> Bool {
        return attempt != countries.count + 1
    }

    private func correctFlagAnswer(_ number: Int) -> Bool {
        return correctAnswer == number && isValidated()
    }

    var body: some View {

        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.95)
            VStack(spacing: 0) {
                HStack {
                    Text("Flag Quiz!")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding()

                    Spacer()

                    ZStack {

                        Text("\(attempt) / \(countries.count)")
                            .fontWeight( /*@START_MENU_TOKEN@*/.bold /*@END_MENU_TOKEN@*/)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    .padding(.trailing, 20)
                }

                .padding(.bottom, 110)
                .frame(height: UIScreen.main.bounds.height * 0.23)
                .background(Color.indigo)

                Spacer()

                if isGameScreen() {
                    HStack {
                        Button(action: {
                            showAlert = true
                        }) {
                            Label("Back", systemImage: "arrow.backward.square")
                        }.alert("Back to start", isPresented: $showAlert) {
                            Button("Back", role: .destructive) {}
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("R u sure?")
                        }
                        .fontWeight(.bold)
                        .buttonStyle(.borderless)
                        .foregroundStyle(.indigo)

                        Spacer()

                        Button(action: { resetStates() }) {
                            Label("Reset", systemImage: "arrow.clockwise")
                                .padding(.horizontal, 20)
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .fontWeight(.bold)
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 25)
                }
            }

            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Spacer()
                        Text(
                            isGameScreen()
                                ? "Select the Flag You Think Is the Flag of \(countries[correctAnswer])"
                                : "Your total score: "
                        )
                        .font(.title2)
                        .padding()
                        .multilineTextAlignment(.center)

                        Spacer()

                        if isGameScreen() {

                            VStack(spacing: 20) {
                                ForEach(0..<3) { number in
                                    Button {
                                        if validated == NOT_VALIDATED {
                                            selectedIndex = number
                                        }
                                    } label: {
                                        Image(countries[number])
                                            .renderingMode(.original)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .stroke(
                                                        flagSelectedByUser(number)
                                                            ? Color.indigo
                                                            : errorFlagSelectedByUser(number)
                                                                ? Color.red
                                                                : correctFlagAnswer(number)
                                                                    ? Color.green : Color.clear,
                                                        lineWidth: 3
                                                    )
                                            )
                                    }
                                    .shadow(
                                        color: flagSelectedByUser(number)
                                            ? Color.indigo.opacity(0.5)
                                            : errorFlagSelectedByUser(number)
                                                ? Color.red.opacity(0.5)
                                                : correctFlagAnswer(number)
                                                    ? Color.green.opacity(0.5)
                                                    : Color.black.opacity(0.2),
                                        radius: 5, x: 0, y: 3)
                                }
                            }
                        } else {
                            VStack(spacing: 10) {
                                Text("\(score) / \(countries.count)")
                                    .fontWeight(.bold)
                                    .font(.title)
                            }
                        }

                        Spacer()

                        HStack {
                            if isGameScreen() {
                                Button(action: {
                                    if isPendingToValidate() {
                                        flagMatchWithCorrectAnswer(selectedIndex)
                                    } else if isValidated() {
                                        nextStep()
                                    }
                                }) {
                                    if validated == IN_PROGRESS {
                                        ProgressView()
                                            .progressViewStyle(
                                                CircularProgressViewStyle()
                                            )
                                            .frame(width: 24, height: 24)
                                            .tint(.white)
                                    } else {
                                        Label(
                                            validated == VALIDATED ? "Next" : "Validate",
                                            systemImage: "checkmark.circle"
                                        )
                                        .padding(.horizontal, 70)
                                        .fontWeight(.bold)
                                    }
                                }
                                .tint(.indigo)
                                .font(.title3)
                                .disabled(isNotFlagSelected())
                                .buttonStyle(.borderedProminent)
                            }else{
                                Button(action: {
                                   resetStates()
                                }) {
                                    Label("Start again", systemImage: "arrow.clockwise")
                                        .padding(.horizontal, 20)
                                        .fontWeight(.bold)
                                }
                                .tint(.indigo)
                                .font(.title3)
                                .buttonStyle(.borderedProminent)
                            }
                        }

                        Spacer()

                    }
                }
            }
            .frame(
                width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 1.50
            )
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 3)
            )

        }.ignoresSafeArea(.all, edges: .bottom)
    }

    func flagMatchWithCorrectAnswer(_ number: Int) {
        validated = IN_PROGRESS
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if correctAnswer == number {
                score += 1
            }
            validated = VALIDATED
        }
    }

    func resetStates() {
        attempt = 1
        score = 0
        validated = NOT_VALIDATED
        countries = countries.shuffled()
        selectedIndex = NOT_SELECTED_INDEX
    }

    func nextStep() {
        attempt += 1
        validated = NOT_VALIDATED
        selectedIndex = NOT_SELECTED_INDEX
        countries = countries.shuffled()
    }
}

#Preview {
    ContentView()
}
