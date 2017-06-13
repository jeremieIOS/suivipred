//
//  Database.swift
//  B.live
//
//  Created by Aiman on 14/12/2016.
//  Copyright © 2016 Bouygues Telecom. All rights reserved.
//
import Foundation
import CoreData

final class Database {

    
    static let shared = Database()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SuiviPred")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        return context
    }()
}
extension NSManagedObjectContext {
    func saveContext() {
        if self.hasChanges {
            do {
                try self.save()
            }
            catch {
                fatalError("error saving context \(error)")
            }
        }
    }
    
    func insertObjective(hour: Int16, month: NSDate){
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "FR-fr")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: month as Date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let objetiveDate = calendar.date(from: components)!
        
        let objective = NSEntityDescription.insertNewObject(forEntityName: "Objectif", into: self) as! Objectif
        objective.hour = hour
        objective.month = objetiveDate as NSDate
    }
    
    
    
    func fetchObjectifFromDate(date: NSDate) -> Objectif? {
        let request: NSFetchRequest<Objectif> = Objectif.fetchRequest()
        let predicate = NSPredicate(format: "month == %@" , date)
        request.predicate = predicate
        
        do {
            let fetchResult = try self.fetch(request)
            return fetchResult.last
        } catch {
            fatalError("Failed to fetch Objectif: \(error)")
        }
        return nil
    }
    
    func insertRapport(date: NSDate, duration: Int16, publication: Int16, video: Int16,
                       visite: Int16, coursB : Int16) {
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "FR-fr")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date as Date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let dateRapport = calendar.date(from: components)!
        
        print(dateRapport)
        
        let rapport = NSEntityDescription.insertNewObject(forEntityName: "Rapport", into: self) as! Rapport
        rapport.date = dateRapport as NSDate
        rapport.duration = duration
        rapport.publication = publication
        rapport.video = video
        rapport.visite = visite
        rapport.coursb = coursB
    }
    
    func updateRapport(date: NSDate, duration: Int16, publication: Int16, video: Int16,
                       visite: Int16, coursB : Int16) {
        let request: NSFetchRequest<Rapport> = Rapport.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date)
        
        do {
            if let rapport = try self.fetch(request).first {
                let rapportUpdate = rapport as NSManagedObject
                rapportUpdate.setValue(duration, forKey: "duration")
                rapportUpdate.setValue(publication, forKey: "publication")
                rapportUpdate.setValue(video, forKey: "video")
                rapportUpdate.setValue(visite, forKey: "visite")
                rapportUpdate.setValue(coursB, forKey: "coursb")
                
                print("UPDATE")
            }
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
    }
    //somme sur la PERIODE
    func getSumDurationOnGivenPeriod(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let durationExpression = NSExpressionDescription()
        durationExpression.name = "durationName"
        durationExpression.expression = NSExpression(forFunction: "sum:",
                                                     arguments: [NSExpression(forKeyPath: "duration")])
        durationExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [durationExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        let predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        fetchRequest.predicate = predicate
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Int16]
            let durationSum = result["durationName"]!
            
            return Int16(durationSum)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return 0
    }
    
    //somme sur la PERIODE
    func getSumPublicationsOnGivenPeriod(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let publicationExpression = NSExpressionDescription()
        publicationExpression.name = "publicationsName"
        publicationExpression.expression = NSExpression(forFunction: "sum:",
                                                        arguments: [NSExpression(forKeyPath: "publication")])
        publicationExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [publicationExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        let predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        fetchRequest.predicate = predicate
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let publications = result["publicationsName"]!
            
            return Int16(publications)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    //somme sur la PERIODE
    func getSumVideosOnGivenPeriod(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let videoExpression = NSExpressionDescription()
        videoExpression.name = "videosName"
        videoExpression.expression = NSExpression(forFunction: "sum:",
                                                  arguments: [NSExpression(forKeyPath: "video")])
        videoExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [videoExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        let predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        fetchRequest.predicate = predicate
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let videos = result["videosName"]!
            
            return Int16(videos)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    //somme sur la PERDIODE
    func getSumVisitesOnGivenPeriod(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let visitesExpression = NSExpressionDescription()
        visitesExpression.name = "visiteName"
        visitesExpression.expression = NSExpression(forFunction: "sum:",
                                                    arguments: [NSExpression(forKeyPath: "visite")])
        visitesExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [visitesExpression]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        fetchRequest.predicate = predicate
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let visites = result["visiteName"]!
            
            return Int16(visites)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    //somme sur la PERDIODE
    func getSumCoursBOnGivenPeriod(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let coursBExpression = NSExpressionDescription()
        coursBExpression.name = "coursbName"
        coursBExpression.expression = NSExpression(forFunction: "sum:",
                                                   arguments: [NSExpression(forKeyPath: "coursb")])
        coursBExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [coursBExpression]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        fetchRequest.predicate = predicate
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let coursBs = result["coursbName"]!
            
            return Int16(coursBs)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    
    //a dupliquer pour chacune des valeurs 
    func getSumDurationRapportToSend(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let durationExpression = NSExpressionDescription()
        durationExpression.name = "durationName"
        durationExpression.expression = NSExpression(forFunction: "sum:",
                                                     arguments: [NSExpression(forKeyPath: "duration")])
        durationExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [durationExpression]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Int16]
            let durationSum = result["durationName"]!
            
            return Int16(durationSum)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return 0
    }
    
    func getSumPublicationRapportToSend(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let expression = NSExpressionDescription()
        expression.name = "publicationsName"
        expression.expression = NSExpression(forFunction: "sum:",
                                                     arguments: [NSExpression(forKeyPath: "publication")])
        expression.expressionResultType = .doubleAttributeType
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [expression]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        do {
            let results = try self.fetch(fetchRequest)
            var result = results[0] as! [String:Int16]
            let Sum = result["publicationsName"]!
            return Int16(Sum)
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return 0
    }
    
    func getSumVideoRapportToSend(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let expression = NSExpressionDescription()
        expression.name = "videosName"
        expression.expression = NSExpression(forFunction: "sum:",
                                                     arguments: [NSExpression(forKeyPath: "video")])
        expression.expressionResultType = .doubleAttributeType
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [expression]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        do {
            let results = try self.fetch(fetchRequest)
            var result = results[0] as! [String:Int16]
            let Sum = result["videosName"]!
            return Int16(Sum)
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return 0
    }
    
    func getSumVisiteRapportToSend(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let expression = NSExpressionDescription()
        expression.name = "visitesName"
        expression.expression = NSExpression(forFunction: "sum:",
                                             arguments: [NSExpression(forKeyPath: "visite")])
        expression.expressionResultType = .doubleAttributeType
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [expression]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        do {
            let results = try self.fetch(fetchRequest)
            var result = results[0] as! [String:Int16]
            let Sum = result["visitesName"]!
            return Int16(Sum)
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return 0
    }
    
    func getSumCoursbRapportToSend(firstDay: NSDate, lastDay: NSDate) -> Int16 {
        let expression = NSExpressionDescription()
        expression.name = "coursbName"
        expression.expression = NSExpression(forFunction: "sum:",
                                             arguments: [NSExpression(forKeyPath: "coursb")])
        expression.expressionResultType = .doubleAttributeType
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [expression]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        do {
            let results = try self.fetch(fetchRequest)
            var result = results[0] as! [String:Int16]
            let Sum = result["coursbName"]!
            return Int16(Sum)
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return 0
    }
    
    
    //somme sur la durée totale
    func getSumDuration() -> Int16 {
        let durationExpression = NSExpressionDescription()
        durationExpression.name = "durationName"
        durationExpression.expression = NSExpression(forFunction: "sum:",
                                                     arguments: [NSExpression(forKeyPath: "duration")])
        durationExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [durationExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Int16]
            let durationSum = result["durationName"]!
            
            return Int16(durationSum)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return 0
    }
    
    //somme sur la durée totale
    func getSumPublications() -> Int16 {
        let publicationExpression = NSExpressionDescription()
        publicationExpression.name = "publicationsName"
        publicationExpression.expression = NSExpression(forFunction: "sum:",
                                                        arguments: [NSExpression(forKeyPath: "publication")])
        publicationExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [publicationExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let publications = result["publicationsName"]!
            
            return Int16(publications)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    //somme sur la durée totale
    func getSumVideos() -> Int16 {
        let videoExpression = NSExpressionDescription()
        videoExpression.name = "videosName"
        videoExpression.expression = NSExpression(forFunction: "sum:",
                                                  arguments: [NSExpression(forKeyPath: "video")])
        videoExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [videoExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let videos = result["videosName"]!
            
            return Int16(videos)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    //somme sur la durée totale
    func getSumVisites() -> Int16 {
        let visitesExpression = NSExpressionDescription()
        visitesExpression.name = "visiteName"
        visitesExpression.expression = NSExpression(forFunction: "sum:",
                                                    arguments: [NSExpression(forKeyPath: "visite")])
        visitesExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [visitesExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let visites = result["visiteName"]!
            
            return Int16(visites)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    //somme sur la durée totale
    func getSumCoursB() -> Int16 {
        let coursBExpression = NSExpressionDescription()
        coursBExpression.name = "coursbName"
        coursBExpression.expression = NSExpression(forFunction: "sum:",
                                                   arguments: [NSExpression(forKeyPath: "coursb")])
        coursBExpression.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rapport")
        fetchRequest.propertiesToFetch = [coursBExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let results = try self.fetch(fetchRequest)
            
            var result = results[0] as! [String:Double]
            let coursBs = result["coursbName"]!
            
            return Int16(coursBs)
            
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return 0
    }
    
    
    
    
    func clearTableRapport() {
        let fetch: NSFetchRequest<NSFetchRequestResult> = Rapport.fetchRequest()
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try self.execute(request)
        }
        catch {
            fatalError("Failed to clear table rapport: \(error)")
        }
    }
    
    func fetchRapports() -> [Rapport] {
        let request: NSFetchRequest<Rapport> = Rapport.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try self.fetch(request)
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return [Rapport]()
    }
    
    func removeOneRowFromCoreData(date: NSDate){
        let request: NSFetchRequest<Rapport> = Rapport.fetchRequest()
        let predicate = NSPredicate(format: "date == %@" , date)
        request.predicate = predicate
        
        do {
            let fetchResult = try self.fetch(request)
            self.delete(fetchResult.last!)
            
        } catch {
            fatalError("Failed to delete Rapport: \(error)")
        }
    
    }

    func fetchRapportFromDate(date: NSDate) -> Rapport? {
        let request: NSFetchRequest<Rapport> = Rapport.fetchRequest()
        let predicate = NSPredicate(format: "date == %@" , date)
        request.predicate = predicate
        
        do {
            let fetchResult = try self.fetch(request)
            return fetchResult.last
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return nil
    }
    
    func fetchRapportFromPeriod(firstDay: NSDate, lastDay: NSDate)-> [Rapport] {
        let request: NSFetchRequest<Rapport> = Rapport.fetchRequest()
        let predicate = NSPredicate(format: "date <= %@ AND date >= %@", lastDay, firstDay)
        request.predicate = predicate
        
        do {
            return try self.fetch(request)
        
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        return [Rapport]()
    }
    
    func fetchLastRapport() -> Rapport? {
        let request: NSFetchRequest<Rapport> = Rapport.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let result = try self.fetch(request)
            return result.last
        } catch {
            fatalError("Failed to fetch Rapport: \(error)")
        }
        
        return nil
    }
    
    
    //
    //    func insertEpg(eventId: String, externalId: String, title: String, genre: String, startTime: NSDate,
    //                   endTime: NSDate, duration: Int16, thumb: String, channel: Channel) {
    //        let epg = NSEntityDescription.insertNewObject(forEntityName: "Epg", into: self) as! Epg
    //        epg.eventId = eventId
    //        epg.externalId = externalId
    //        epg.title = title
    //        epg.genre = genre
    //        epg.startTime = startTime
    //        epg.endTime = endTime
    //        epg.duration = duration
    //        epg.thumb = thumb
    //        epg.channel = channel
    //    }
    //
    
    //
    //    func fetchOTTChannels() -> [Channel] {
    //        let request: NSFetchRequest<Channel> = Channel.fetchRequest()
    //        request.predicate = NSPredicate(format: "url != ''")
    //        request.sortDescriptors = [NSSortDescriptor(key: "positionId", ascending: true)]
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch channels: \(error)")
    //        }
    //
    //        return [Channel]()
    //    }
    //
    //    func fetchTNTChannels() -> [Channel] {
    //        let request: NSFetchRequest<Channel> = Channel.fetchRequest()
    //        request.predicate = NSPredicate(format: "positionId <= 27")
    //        request.sortDescriptors = [NSSortDescriptor(key: "positionId", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch channels: \(error)")
    //        }
    //
    //        return [Channel]()
    //    }
    //
    //    func findChannelByEpgChannelNumber(epgChannelNumber: Int16) -> Channel? {
    //        let request: NSFetchRequest<Channel> = Channel.fetchRequest()
    //        request.predicate = NSPredicate(format: "epgChannelNumber == %i", epgChannelNumber)
    //
    //        do {
    //            let channels = try self.fetch(request)
    //
    //            if(!channels.isEmpty) {
    //                return channels[0]
    //            }
    //        } catch {
    //            fatalError("Failed to findChannelByEpgChannelNumber: \(error)")
    //        }
    //
    //        return nil
    //    }
    //
    //    func findChannelsIP() -> [Channel] {
    //        var channels = [Channel]()
    //
    //        //        do {
    //        //            let query = self.channelTable.filter(self.type == "IP")
    //        //
    //        //            for item in try self.connection.prepare(query) {
    //        //                let channel = Channel()
    //        //                channel.id = item[self.channelId]
    //        //                channel.positionId = item[self.positionId]
    //        //                channel.epgChannelNumber = item[self.epgChannelNumber]
    //        //                channel.name = item[self.name]
    //        //                channel.logo = item[self.logo]
    //        //                channel.url = item[self.url]
    //        //                channel.type = item[self.type]
    //        //                channels.append(channel)
    //        //            }
    //        //        }
    //        //        catch {
    //        //            print("error findChannelsIP")
    //        //        }
    //
    //        return channels
    //    }
    //
    //    func findChannelsOTT() -> [Channel] {
    //        var channels = [Channel]()
    //
    //        //        do {
    //        //            let query = self.channelTable.filter(self.type == "OTT")
    //        //
    //        //            for item in try self.connection.prepare(query) {
    //        //                let channel = Channel()
    //        //                channel.id = item[self.channelId]
    //        //                channel.positionId = item[self.positionId]
    //        //                channel.epgChannelNumber = item[self.epgChannelNumber]
    //        //                channel.name = item[self.name]
    //        //                channel.logo = item[self.logo]
    //        //                channel.url = item[self.url]
    //        //                channel.type = item[self.type]
    //        //                channels.append(channel)
    //        //            }
    //        //        }
    //        //        catch {
    //        //            print("error findChannelsOTT")
    //        //        }
    //
    //        return channels
    //    }
    //
    //    func findChannelsByDeviceType(type: String) -> [Channel] {
    //        var channels = [Channel]()
    //
    //        //        do {
    //        //            let query = self.channelTable.filter(self.type.like("%".appending(type).appending("%")))
    //        //
    //        //            for item in try self.connection.prepare(query) {
    //        //                let channel = Channel()
    //        //                channel.id = item[self.channelId]
    //        //                channel.positionId = item[self.positionId]
    //        //                channel.epgChannelNumber = item[self.epgChannelNumber]
    //        //                channel.name = item[self.name]
    //        //                channel.logo = item[self.logo]
    //        //                channel.url = item[self.url]
    //        //                channel.type = item[self.type]
    //        //                channels.append(channel)
    //        //            }
    //        //        }
    //        //        catch {
    //        //            print("error findChannelByDeviceType")
    //        //        }
    //
    //        return channels
    //    }
    //
    //    func clearTableChannel() {
    //        //        do {
    //        //            try connection.run(self.channelTable.delete())
    //        //        }
    //        //        catch {
    //        //            print("error clear table channel")
    //        //        }
    //    }
    //
    //    func rowsEpg() -> Int {
    //        //        do {
    //        //            return try self.connection.scalar(self.epgTable.count)
    //        //        }
    //        //        catch {
    //        //            print("error row epg")
    //        //        }
    //
    //        return 0
    //    }
    //
    //    func findCurrentEpgByChannel(channelId: Int64) -> Epg? {
    //        //        do {
    //        //            let currentDate = Date()
    //        //
    //        //            let query = self.epgTable.join(self.channelTable, on: self.channelId == self.channel)
    //        //                .filter(
    //        //                    self.channel == channelId
    //        //                        && self.startTime <= currentDate
    //        //                        && self.endTime >=  currentDate)
    //        //                .order(self.startTime)
    //        //
    //        //            let result = try self.connection.pluck(query)
    //        //
    //        //            if(result != nil) {
    //        //                let epg = Epg()
    //        //                let channel = Channel()
    //        //                epg.eventId = result![self.eventId]
    //        //                epg.externalId = result![self.externalId]
    //        //                epg.startTime = result![self.startTime]
    //        //                epg.endTime = result![self.endTime]
    //        //                epg.duration = result![self.duration]
    //        //                epg.thumb = result![self.thumb]
    //        //
    //        //                channel.id = result![self.channelId]
    //        //                channel.positionId = result![self.positionId]
    //        //                channel.epgChannelNumber = result![self.epgChannelNumber]
    //        //                channel.name = result![self.name]
    //        //                channel.logo = result![self.logo]
    //        //                channel.url = result![self.url]
    //        //
    //        //                epg.channel = channel
    //        //                return epg
    //        //            }
    //        //        }
    //        //        catch {
    //        //            print("error findCurrentEpgByChannel")
    //        //        }
    //
    //        return nil
    //    }
    //
    //    func findEpgByEventId(eventId: String) -> Epg? {
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //
    //        request.predicate = NSPredicate(format: "eventId == %@", eventId)
    //
    //        do {
    //            return try self.fetch(request).first
    //        } catch {
    //            fatalError("Failed to fetch epg by event Id : \(error)")
    //        }
    //
    //        return nil
    //    }
    //
    //    func findCurrentEpg(genre: String?) -> [Epg] {
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //        let currentDate = NSDate()
    //
    //        if let genre = genre,
    //            !genre.isEmpty {
    //            request.predicate = NSPredicate(format: "genre == %@ AND startTime <= %@ AND endTime >= %@", genre, currentDate, currentDate)
    //        }
    //        else {
    //            request.predicate = NSPredicate(format: "startTime <= %@ AND endTime >= %@", currentDate, currentDate)
    //        }
    //
    //        request.sortDescriptors = [NSSortDescriptor(key: "channel.positionId", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch current epg : \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func findCurrentEpgTnt(genre: String?) -> [Epg] {
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //        let currentDate = NSDate()
    //
    //        if let genre = genre,
    //            !genre.isEmpty {
    //            request.predicate = NSPredicate(format: "genre == %@ AND channel.positionId <= 27 AND startTime <= %@ AND endTime >= %@", genre, currentDate, currentDate)
    //        }
    //        else {
    //            request.predicate = NSPredicate(format: "channel.positionId <= 27 AND startTime <= %@ AND endTime >= %@", currentDate, currentDate)
    //        }
    //
    //        request.sortDescriptors = [NSSortDescriptor(key: "channel.positionId", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch current epg tnt: \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func findCurrentEpgOTT(genre: String?) -> [Epg] {
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //        let currentDate = NSDate()
    //
    //        if let genre = genre,
    //            !genre.isEmpty {
    //            request.predicate = NSPredicate(format: "genre == %@ AND channel.url != '' AND startTime <= %@ AND endTime >= %@", genre, currentDate, currentDate)
    //        }
    //        else {
    //            request.predicate = NSPredicate(format: "channel.url != '' AND startTime <= %@ AND endTime >= %@", currentDate, currentDate)
    //        }
    //
    //        request.sortDescriptors = [NSSortDescriptor(key: "channel.positionId", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch current epg ott: \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func findTonightEpg(genre: String?) -> [Epg] {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.locale = Locale(identifier: "fr_FR")
    //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    //
    //        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    //
    //        components.hour = 20
    //        components.minute = 30
    //        components.second = 0
    //
    //        let date = NSDate(timeInterval: 0, since: Calendar.current.date(from: components)!)
    //
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //
    //        if let genre = genre,
    //            !genre.isEmpty {
    //            request.predicate = NSPredicate(format: "genre == %@ AND duration >= 20 AND startTime >= %@", genre, date, date)
    //        }
    //        else {
    //            request.predicate = NSPredicate(format: "duration >= 20 AND startTime >= %@", date)
    //        }
    //
    //        request.sortDescriptors = [NSSortDescriptor(key: "channel.positionId", ascending: true),
    //                                   NSSortDescriptor(key: "startTime", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch tonight epg : \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //    func findTonightEpgOTT(genre: String?) -> [Epg] {
    //        let dateFormatter = DateFormatter()
    //
    //        dateFormatter.locale = Locale(identifier: "fr_FR")
    //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    //
    //        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    //        var components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: Date())
    //
    //        components.hour = 20
    //        components.minute = 30
    //        components.second = 0
    //
    //        let date = NSDate(timeInterval: 0, since: Calendar.current.date(from: components)!)
    //
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //
    //        if let genre = genre,
    //            !genre.isEmpty {
    //            request.predicate = NSPredicate(format: "genre == %@ AND channel.url != '' AND duration >= 20 AND startTime >= %@", genre, date)
    //        }
    //        else {
    //            request.predicate = NSPredicate(format: "duration >= 20 AND channel.url != '' AND startTime >= %@", date)
    //        }
    //
    //        request.sortDescriptors = [NSSortDescriptor(key: "channel.positionId", ascending: true),
    //                                   NSSortDescriptor(key: "startTime", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch tonight epg : \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func findTonightEpgTnt(genre: String?) -> [Epg] {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.locale = Locale(identifier: "fr_FR")
    //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    //
    //        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    //
    //        components.hour = 20
    //        components.minute = 30
    //        components.second = 0
    //
    //        let date = NSDate(timeInterval: 0, since: Calendar.current.date(from: components)!)
    //
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //
    //        if let genre = genre,
    //            !genre.isEmpty {
    //            request.predicate = NSPredicate(format: "genre == %@ AND duration >= 20 AND channel.positionId <= 27 AND startTime >= %@", genre, date, date)
    //        }
    //        else {
    //            request.predicate = NSPredicate(format: "duration >= 20 AND channel.positionId <= 27 AND startTime >= %@", date)
    //        }
    //
    //        request.sortDescriptors = [NSSortDescriptor(key: "channel.positionId", ascending: true),
    //                                   NSSortDescriptor(key: "startTime", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch tonight epg : \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func findEpgIPByTitle(title: String) -> [Epg] {
    //        var epgs = [Epg]()
    //
    //        //        do {
    //        //            let query = self.epgTable.join(self.channelTable.filter(self.type == "IP"), on: self.epgChannelNumber == self.epgChannelNumberEpg)
    //        //                .filter(self.title.like("%".appending(title).appending("%")))
    //        //                .order(self.positionId)
    //        //
    //        //            for item in try self.connection.prepare(query) {
    //        //                let epg = Epg()
    //        //                let channel = Channel()
    //        //                epg.eventId = item[self.eventId]
    //        //                epg.externalId = item[self.externalId]
    //        //                epg.title = item[self.title]
    //        //                epg.genre = item[self.genre]
    //        //                epg.startTime = item[self.startTime]
    //        //                epg.endTime = item[self.endTime]
    //        //                epg.duration = item[self.duration]
    //        //                epg.thumb = item[self.thumb]
    //        //
    //        //                channel.id = item[self.channelId]
    //        //                channel.positionId = item[self.positionId]
    //        //                channel.epgChannelNumber = item[self.epgChannelNumber]
    //        //                channel.name = item[self.name]
    //        //                channel.logo = item[self.logo]
    //        //                channel.url = item[self.url]
    //        //
    //        //                epg.channel = channel
    //        //                epgs.append(epg)
    //        //            }
    //        //        }
    //        //        catch {
    //        //            print("error findEpgIPByTitle")
    //        //        }
    //
    //        return epgs
    //    }
    //
    //    func findEpgOTTByTitle(title: String) -> [Epg] {
    //        var epgs = [Epg]()
    //
    //        //        do {
    //        //            let query = self.epgTable.join(self.channelTable.filter(self.type == "OTT"), on: self.epgChannelNumber == self.epgChannelNumberEpg)
    //        //                .filter(self.title.like("%".appending(title).appending("%")))
    //        //                .order(self.positionId)
    //        //
    //        //            for item in try self.connection.prepare(query) {
    //        //                let epg = Epg()
    //        //                let channel = Channel()
    //        //                epg.eventId = item[self.eventId]
    //        //                epg.externalId = item[self.externalId]
    //        //                epg.title = item[self.title]
    //        //                epg.genre = item[self.genre]
    //        //                epg.startTime = item[self.startTime]
    //        //                epg.endTime = item[self.endTime]
    //        //                epg.duration = item[self.duration]
    //        //                epg.thumb = item[self.thumb]
    //        //
    //        //                channel.id = item[self.channelId]
    //        //                channel.positionId = item[self.positionId]
    //        //                channel.epgChannelNumber = item[self.epgChannelNumber]
    //        //                channel.name = item[self.name]
    //        //                channel.logo = item[self.logo]
    //        //                channel.url = item[self.url]
    //        //
    //        //                epg.channel = channel
    //        //                epgs.append(epg)
    //        //            }
    //        //        }
    //        //        catch {
    //        //            print("error findEpgOTTByTitle")
    //        //        }
    //
    //        return epgs
    //    }
    //
    //    func fetchNextEpg(epg: Epg) -> [Epg] {
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //        request.predicate = NSPredicate(format: "startTime >= %@ AND channel.epgChannelNumber == %i", epg.startTime, epg.channel.epgChannelNumber)
    //        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch fetchNextEpg: \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func fetchNextEpgOTT(epg: Epg) -> [Epg] {
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //
    //        request.predicate = NSPredicate(format: "channel.positionId <= 27 AND startTime >= %@ AND channel.epgChannelNumber == %i AND channel.url != ''", epg.startTime, epg.channel.epgChannelNumber)
    //        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch fetchNextEpgOTT: \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func fetchNextEpgTNT(epg: Epg) -> [Epg] {
    //        let request: NSFetchRequest<Epg> = Epg.fetchRequest()
    //
    //        request.predicate = NSPredicate(format: "channel.positionId <= 27 AND startTime >= %@ AND channel.epgChannelNumber == %i", epg.startTime, epg.channel.epgChannelNumber)
    //        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
    //
    //        do {
    //            return try self.fetch(request)
    //        } catch {
    //            fatalError("Failed to fetch fetchNextEpgTNT: \(error)")
    //        }
    //
    //        return [Epg]()
    //    }
    //
    //    func clearTableEpg() {
    //        let fetch: NSFetchRequest<NSFetchRequestResult> = Epg.fetchRequest()
    //        let request = NSBatchDeleteRequest(fetchRequest: fetch)
    //
    //        do {
    //            try self.execute(request)
    //        }
    //        catch {
    //            fatalError("Failed to clear table channel: \(error)")
    //        }
    //    }
}
