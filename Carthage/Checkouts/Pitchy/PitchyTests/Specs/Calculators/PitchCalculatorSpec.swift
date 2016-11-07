@testable import Pitchy
import Quick
import Nimble

class PitchCalculatorSpec: QuickSpec {

  override func spec() {
    let offsets = [
      (frequency: 445.0,
        lower: Pitch.Offset(note: try! Note(index: 0), frequency: 5,
          percentage: 19.1, cents: 19.56),
        higher: Pitch.Offset(note: try! Note(index: 1), frequency: -21.164,
          percentage: -80.9, cents: -80.4338),
        closest: "A4"
      ),
      (frequency: 108.0,
        lower: Pitch.Offset(note: try! Note(index: -25), frequency: 4.174,
          percentage: 67.6, cents: 68.2333),
        higher: Pitch.Offset(note: try! Note(index: -24), frequency: -2,
          percentage: -32.39, cents: -31.76),
        closest: "A2"
      )
    ]

    describe("PitchCalculator") {
      describe(".isValidFrequency") {
        it("is invalid if frequency is higher than maximum") {
          let frequency = 5000.0
          expect(PitchCalculator.isValidFrequency(frequency)).to(beFalse())
        }

        it("is invalid if frequency is lower than minimum") {
          let frequency = 10.0
          expect(PitchCalculator.isValidFrequency(frequency)).to(beFalse())
        }

        it("is invalid if frequency is zero") {
          let frequency = 0.0
          expect(PitchCalculator.isValidFrequency(frequency)).to(beFalse())
        }

        it("is valid if frequency is within valid bounds") {
          let frequency = 440.0
          expect(PitchCalculator.isValidFrequency(frequency)).to(beTrue())
        }
      }

      describe(".offsets") {
        it("returns a correct offsets for the specified frequency") {
          offsets.forEach {
            let result = try! PitchCalculator.offsets($0.frequency)

            expect(result.lower.frequency) ≈ ($0.lower.frequency, 0.01)
            expect(result.lower.percentage) ≈ ($0.lower.percentage, 0.1)
            expect(result.lower.note.index).to(equal($0.lower.note.index))
            expect(result.lower.cents) ≈ ($0.lower.cents, 0.1)

            expect(result.higher.frequency) ≈ ($0.higher.frequency, 0.01)
            expect(result.higher.percentage) ≈ ($0.higher.percentage, 0.1)
            expect(result.higher.note.index).to(equal($0.higher.note.index))
            expect(result.higher.cents) ≈ ($0.higher.cents, 0.1)

            expect(result.closest.note.string).to(equal($0.closest))
          }
        }
      }
    }
  }
}
