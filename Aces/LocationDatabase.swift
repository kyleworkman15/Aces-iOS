//
//  LocationDatabase.swift
//  Aces
//
//  Description: Database of all the loctions able to be visited by Aces.
//
//  Created by Kyle Workman on 6/21/18.
//  Copyright © 2018 Kyle Workman. All rights reserved.
//

import Foundation

class LocationDatabase {
    
    fileprivate let abbey = MyPlace(name: "Abbey Art Studios", lat: 41.505297, long: -90.551476)
    fileprivate let aldi = MyPlace(name: "ALDI", lat: 41.491941, long: -90.548270)
    fileprivate let anderson = MyPlace(name: "Anderson/Bartholomew", lat: 41.502361, long: -90.551381)
    fileprivate let andreen = MyPlace(name: "Andreen Hall", lat: 41.501657, long: -90.548496)
    fileprivate let arbaugh = MyPlace(name: "Arbaugh TLA", lat: 41.499354, long: -90.552103)
    fileprivate let brodahl = MyPlace(name: "Brodahl", lat: 41.502800, long: -90.552291)
    fileprivate let carver = MyPlace(name: "Carver Center", lat: 41.506636, long: -90.550844)
    fileprivate let centennial = MyPlace(name: "Centennial Hall", lat: 41.505123, long: -90.548681)
    fileprivate let collegeCenter = MyPlace(name: "College Center", lat: 41.504351, long: -90.548201)
    fileprivate let denkmann = MyPlace(name: "Denkmann", lat: 41.504425, long: -90.550528)
    fileprivate let elflats = MyPlace(name: "11th Ave Flats", lat: 41.499988, long: -90.548975)
    fileprivate let erickson = MyPlace(name: "Erickson Hall", lat: 41.499363, long: -90.554705)
    fileprivate let evald = MyPlace(name: "Evald", lat: 41.505108, long: -90.550090)
    fileprivate let gerber = MyPlace(name: "Gerber Center", lat: 41.502285, long: -90.550688)
    fileprivate let hanson = MyPlace(name: "Hanson", lat: 41.503561, long: -90.551447)
    fileprivate let naeseth = MyPlace(name: "Naeseth TLA", lat: 41.499284, long: -90.553739)
    fileprivate let oldMain = MyPlace(name: "Old Main", lat: 41.504344, long: -90.549497)
    fileprivate let olin = MyPlace(name: "Olin", lat: 41.503118, long: -90.550591)
    fileprivate let parkanderN = MyPlace(name: "Parkander North", lat: 41.501175, long: -90.549681)
    fileprivate let parkanderS = MyPlace(name: "Parkander South", lat: 41.500545, long: -90.549934)
    fileprivate let pepsico = MyPlace(name: "PepsiCo Recreation", lat: 41.500332, long: -90.556294)
    fileprivate let pottery = MyPlace(name: "Pottery Studio", lat: 41.505721, long: -90.550474)
    fileprivate let seminary = MyPlace(name: "Seminary Hall", lat: 41.503043, long: -90.548144)
    fileprivate let sorensen = MyPlace(name: "Sorensen", lat: 41.505139, long: -90.547201)
    fileprivate let swanson = MyPlace(name: "Swanson Commons", lat: 41.500638, long: -90.548042)
    fileprivate let swenson = MyPlace(name: "Swenson Geoscience", lat: 41.503030, long: -90.549075)
    fileprivate let westerlin = MyPlace(name: "Westerlin Hall", lat: 41.500495, long: -90.554667)
    
    // Returns a dictionary of the Place's names mapped to an Array of the latitude and longitude.
    func getPlaces() -> Dictionary<String, Array<Double>> {
        return [abbey.name: [abbey.lat, abbey.long],
                aldi.name: [aldi.lat, aldi.long],
                anderson.name: [anderson.lat, anderson.long],
                andreen.name: [andreen.lat, andreen.long],
                arbaugh.name: [arbaugh.lat, arbaugh.long],
                brodahl.name: [brodahl.lat, brodahl.long],
                carver.name: [carver.lat, carver.long],
                centennial.name: [centennial.lat, centennial.long],
                collegeCenter.name: [collegeCenter.lat, collegeCenter.long],
                denkmann.name: [denkmann.lat, denkmann.long],
                elflats.name: [elflats.lat, elflats.long],
                erickson.name: [erickson.lat, erickson.long],
                evald.name: [evald.lat, evald.long],
                gerber.name: [gerber.lat, gerber.long],
                hanson.name: [hanson.lat, hanson.long],
                naeseth.name: [naeseth.lat, naeseth.long],
                oldMain.name: [oldMain.lat, oldMain.long],
                olin.name: [olin.lat, olin.long],
                parkanderN.name: [parkanderN.lat, parkanderN.long],
                parkanderS.name: [parkanderS.lat, parkanderS.long],
                pepsico.name: [pepsico.lat, pepsico.long],
                pottery.name: [pottery.lat, pottery.long],
                seminary.name: [seminary.lat, seminary.long],
                sorensen.name: [sorensen.lat, sorensen.long],
                swanson.name: [swanson.lat, swanson.long],
                swenson.name: [swenson.lat, swenson.long],
                westerlin.name: [westerlin.lat, westerlin.long]]
    }
    
    // Returns an Array of the Place's names
    func getNames() -> Array<String> {
        return ["Enter an Address", abbey.name, aldi.name, anderson.name, andreen.name, arbaugh.name, brodahl.name, carver.name, centennial.name, collegeCenter.name, denkmann.name, elflats.name, erickson.name, evald.name, gerber.name, hanson.name, naeseth.name, oldMain.name, olin.name, parkanderN.name, parkanderS.name, pepsico.name, pottery.name, seminary.name, sorensen.name, swanson.name, swenson.name, westerlin.name]
    }
}
