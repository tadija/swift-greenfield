#if canImport(CoreData)

import CoreData

public extension NSFetchRequestResult where Self: NSManagedObject {

    // MARK: Queries

    static func findOrCreate(
        with predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext
    ) -> Self {
        find(with: predicate, in: context) ?? self.init(context: context)
    }

    static func find(
        key: String,
        value: Any,
        in context: NSManagedObjectContext?
    ) -> Self? {
        find(with: predicate(key: key, value: value), in: context)
    }

    static func find(
        with predicate: NSPredicate? = nil,
        in context: NSManagedObjectContext?
    ) -> Self? {
        if let objectFromMemory = context?.registeredObjects.first(where: {
            let isFulfilled = !$0.isFault
            let matchesPredicate = predicate?.evaluate(with: $0 as? Self) ?? false
            return isFulfilled && matchesPredicate
        }) as? Self {
            /// - Note: since object is already in memory
            /// this is way more performant than making a fetch request
            return objectFromMemory
        } else {
            return all(with: predicate, limit: 1, in: context).first
        }
    }

    static func incrementedInteger(
        for attribute: String,
        in context: NSManagedObjectContext?
    ) -> Int {
        let sortDescriptor = NSSortDescriptor(key: attribute, ascending: false)
        guard
            let object = all(orderedBy: [sortDescriptor], limit: 1, in: context).first,
            let max = object.value(forKey: attribute) as? Int
        else {
            return 0
        }
        return max + 1
    }

    static func all(
        with predicate: NSPredicate? = nil,
        orderedBy sortDescriptors: [NSSortDescriptor] = [],
        limit: Int? = nil,
        in context: NSManagedObjectContext?
    ) -> [Self] {
        guard let context = context else {
            return []
        }
        let request = fetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit
        )
        let result = try? fetch(request, in: context)
        return result ?? []
    }

    static func unmanaged() -> Self {
        self.init(
            entity: entity(),
            insertInto: nil
        )
    }

    func `in`(_ context: NSManagedObjectContext?) -> Self? {
        guard
            let context = context,
            let object = context.object(with: objectID) as? Self
        else {
            return nil
        }
        return object
    }

    // MARK: Predicate & Fetch Request

    static func predicate(key: String, value: Any) -> NSPredicate {
        NSPredicate(format: "%K = %@", argumentArray: [key, value])
    }

    static func predicate(
        attributes: [String: Any],
        type: NSCompoundPredicate.LogicalType = .and
    ) -> NSPredicate {
        let predicates = attributes.map {
            predicate(key: $0.key, value: $0.value)
        }
        let compoundPredicate = NSCompoundPredicate(type: type, subpredicates: predicates)
        return compoundPredicate
    }

    static func fetchRequest(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        limit: Int? = nil,
        offset: Int? = nil,
        batchSize: Int? = nil,
        relationshipKeyPathsForPrefetching: [String] = []
    ) -> NSFetchRequest<Self> {
        let entityName = String(describing: Self.self)
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = limit ?? request.fetchLimit
        request.fetchOffset = offset ?? request.fetchOffset
        request.fetchBatchSize = batchSize ?? request.fetchBatchSize
        request.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        return request
    }

    static func fetch(
        _ request: NSFetchRequest<Self> = fetchRequest(),
        in context: NSManagedObjectContext
    ) throws -> [Self] {
        try context.fetch(request)
    }

    // MARK: Batch Update & Delete

    @discardableResult
    static func batchUpdate(
        properties: [String: Any],
        predicate: NSPredicate? = nil,
        resultType: NSBatchUpdateRequestResultType = .updatedObjectsCountResultType,
        in context: NSManagedObjectContext
    ) -> NSBatchUpdateResult? {
        let request = NSBatchUpdateRequest(entityName: String(describing: Self.self))
        request.propertiesToUpdate = properties
        request.predicate = predicate
        request.resultType = resultType
        do {
            let result = try context.execute(request)
            return result as? NSBatchUpdateResult
        } catch {
            return nil
        }
    }

    @discardableResult
    static func batchDelete(
        with predicate: NSPredicate? = nil,
        resultType: NSBatchDeleteRequestResultType = .resultTypeCount,
        in context: NSManagedObjectContext
    ) -> NSBatchDeleteResult? {
        typealias FetchRequestResult = NSFetchRequest<NSFetchRequestResult>
        guard let request = fetchRequest(predicate: predicate) as? FetchRequestResult else {
            return nil
        }
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = resultType
        do {
            let result = try context.execute(deleteRequest)
            return result as? NSBatchDeleteResult
        } catch {
            return nil
        }
    }

}

#endif
