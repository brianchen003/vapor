import Async

public struct QueryAggregate {
    public var field: QueryField?
    public var method: QueryAggregateMethod
}

/// Possible aggregation types.
public enum QueryAggregateMethod {
    case count
    case sum
    case average
    case min
    case max
    case custom(string: String)
}

extension QueryBuilder {
    /// Get the number of results for this query.
    /// Optionally specify a specific field to count.
    public func count() -> Future<Int> {
        let aggregate = QueryAggregate(field: nil, method: .count)
        return self.aggregate(aggregate)
    }

    /// Returns the sum of the supplied field
    public func sum<F: QueryFieldRepresentable>(_ field: F) -> Future<Double> {
        return aggregate(.sum, field: field)
    }

    /// Returns the average of the supplied field
    public func average<F: QueryFieldRepresentable>(_ field: F) -> Future<Double> {
        return aggregate(.average, field: field)
    }

    /// Returns the min of the supplied field
    public func min<F: QueryFieldRepresentable>(_ field: F) -> Future<Double> {
        return aggregate(.min, field: field)
    }

    /// Returns the max of the supplied field
    public func max<F: QueryFieldRepresentable>(_ field: F) -> Future<Double> {
        return aggregate(.max, field: field)
    }

    /// Perform an aggregate action on the supplied field
    /// on the supplied model.
    /// Decode as the supplied type.
    public func aggregate<D: Decodable, F: QueryFieldRepresentable>(
        _ method: QueryAggregateMethod,
        field: F?,
        as type: D.Type = D.self
    ) -> Future<D> {
        let aggregate = QueryAggregate(field: field?.makeQueryField(), method: method)
        return self.aggregate(aggregate)
    }

    /// Performs the supplied aggregate struct.
    public func aggregate<D: Decodable>(
        _ aggregate: QueryAggregate,
        as type: D.Type = D.self
    ) -> Future<D> {
        let promise = Promise(D.self)

        query.action = .read
        query.aggregates.append(aggregate)

        run(decoding: AggregateResult<D>.self) { res in
            promise.complete(res.fluentAggregate)
        }.catch { err in
            promise.fail(err)
        }.finally {
            promise.fail("no agggregate")
        }

        return promise.future
    }
}

/// Aggreagate result structure expected from DB.
internal struct AggregateResult<D: Decodable>: Decodable {
    var fluentAggregate: D
}