
import Combine
import Foundation


class ErrorHandlerService: ObservableObject {
    @Published var errorMessage: String?

    /// Handles errors by formatting an error message and updating the `errorMessage` property.
    ///
    /// This service centralizes error management in the application, providing a user-friendly
    /// way to display errors that occur during operations. It formats error messages based on
    /// the type of error received, such as network or data errors, and stores them in the
    /// `errorMessage` property, which can be observed in the UI.
    ///
    /// The service also provides a method to clear the error message, ensuring that stale
    /// messages do not persist in the UI.
    ///
    /// - Parameters:
    ///   - error: The error object to handle. It can be any error type, and the function will extract
    ///     its localized description for the error message.
    ///   - prefix: A customizable string prefix that will be prepended to the error message.
    ///     Defaults to "Error: ".
    ///
    /// - Important: This function updates the `errorMessage` property, which is expected to be used
    ///   elsewhere in the code (such as in the UI) to display the error to the user. Ensure that the
    ///   `errorMessage` is properly observed or bound to update the interface when this function is called.
    ///
    /// - Example:
    /// ```swift
    /// do {
    ///     // Some operation that may throw an error
    /// } catch {
    ///     errorHandlerService.handleError(error, prefix: "Failed to load data: ")
    /// }
    /// ```
    ///
    /// In this example, if an error occurs, the error message will be formatted with the provided
    /// prefix and the localized description of the error.
    ///
    @MainActor
    func handleError(_ error: Error) {
        switch error {
        case let urlError as URLError:
            errorMessage = "Network error: \(urlError.localizedDescription)"
        case let decodingError as DecodingError:
            errorMessage = "Data error: \(decodingError.localizedDescription)"
        default:
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }

    /// Clears the current error message.
    ///
    /// This method resets the `errorMessage` property to `nil`, allowing the UI to
    /// reflect that there are no active errors.
    func clearError() {
        errorMessage = nil
    }
}
