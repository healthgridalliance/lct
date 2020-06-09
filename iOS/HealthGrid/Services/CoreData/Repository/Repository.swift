import Foundation
import CoreData
import RxSwift
import QueryKit
import RxCoreData

protocol AbstractRepository {
    associatedtype T
    func query(with predicate: NSPredicate?,
               sortDescriptors: [NSSortDescriptor]?) -> Observable<[T]>
    func save(entity: T) -> Observable<Void>
    func deleteAll() -> Observable<Void>
}

final class Repository<T: CoreDataRepresentable>: AbstractRepository where T == T.CoreDataType.DomainType {
    private let context: NSManagedObjectContext
    private let scheduler: ContextScheduler

    init(context: NSManagedObjectContext) {
        self.context = context
        self.scheduler = ContextScheduler(context: context)
    }

    func query(with predicate: NSPredicate? = nil,
               sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[T]> {
        let request = T.CoreDataType.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return context.rx.entities(fetchRequest: request)
            .mapToDomain()
            .subscribeOn(scheduler)
    }
    
    func save(entity: T) -> Observable<Void> {
        return keepDataForLastTwoWeeks()
            .flatMap({self.updateLastEntity()})
            .flatMap({entity.sync(in: self.context)
                .mapToVoid()
                .flatMapLatest(self.context.rx.save)
        })
    }
    
    func deleteAll() -> Observable<Void> {
        let request = T.CoreDataType.fetchRequest()
        request.sortDescriptors = []
        return context.rx.entities(fetchRequest: request)
            .map({$0.map({$0 as! NSManagedObject})})
            .flatMapLatest(context.rx.deleteAll)
    }
    
}

extension Repository {
    
    private func delete(entity: T) -> Observable<Void> {
        return entity.sync(in: context)
            .map({$0 as! NSManagedObject})
            .flatMapLatest(context.rx.delete)
    }
    
    private func keepDataForLastTwoWeeks() -> Observable<Void> {
        let request = T.CoreDataType.fetchRequest()
        request.sortDescriptors = [Location.CoreDataType.date.ascending()]
        request.predicate = NSPredicate(format: "date < %@", Date().lastTwoWeekDay() as NSDate)
        return context.rx.entities(fetchRequest: request)
            .map({$0.map({$0 as! NSManagedObject})})
            .flatMapLatest(context.rx.deleteAll)
    }
    
    private func updateLastEntity() -> Observable<Void> {
        let request = T.CoreDataType.fetchRequest()
        request.sortDescriptors = [Location.CoreDataType.date.ascending()]
        return context.rx
            .entities(fetchRequest: request)
            .mapToDomain()
            .map({ entities -> Observable<LocationEntity>? in
                var entity = entities.last as? Location
                entity?.checkOutTime = Date()
                return entity?.sync(in: self.context)
            })
            .mapToVoid()
            .flatMap(context.rx.save)
    }
    
}
