//
//  ER_Save.swift
//  Pods
//
//  Created by Allan Vialatte on 23/11/16.
//
//

import Foundation
import RealmSwift

extension EasyRealm where T: Object {

  public func save(update: Realm.UpdatePolicy) throws {
    _ = try self.saved(update: update)
  }

  public func saved(update: Realm.UpdatePolicy) throws -> T {
    return (self.isManaged) ? try managed_save(update: update) : try unmanaged_save(update: update)
  }

  public func update(update: Realm.UpdatePolicy) throws {
    _ = (self.isManaged) ? try managed_save(update: update) : try unmanaged_save(update: update)
  }

}

fileprivate extension EasyRealm where T: Object {

  func managed_save(update: Realm.UpdatePolicy) throws -> T {
    let ref = ThreadSafeReference(to: self.base)
    guard let rq = EasyRealmQueue() else {
      throw EasyRealmError.RealmQueueCantBeCreate
    }
    return try rq.queue.sync {
      guard let object = rq.realm.resolve(ref) else { throw EasyRealmError.ObjectCantBeResolved }
      rq.realm.beginWrite()
      let ret = rq.realm.create(T.self, value: object, update: update)
      try rq.realm.commitWrite()
      return ret
    }
  }

  func unmanaged_save(update: Realm.UpdatePolicy) throws -> T {
    let realm = try Realm()
    realm.beginWrite()
    let ret = realm.create(T.self, value: self.base, update: update)
    try realm.commitWrite()
    return ret
  }

}
