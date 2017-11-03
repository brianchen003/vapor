import Async

/// A database transaction. Work done inside the
/// transaction's closure will be rolled back if
/// any errors are thrown.
public struct DatabaseTransaction<Connection: Fluent.Connection> {
    /// Closure for performing the transaction.
    public typealias Closure = (Connection) -> Future<Void>

    /// Contains the transaction's work.
    public let closure: Closure
}