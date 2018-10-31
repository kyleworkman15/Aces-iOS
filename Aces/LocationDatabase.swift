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
    
    fileprivate let abbey = MyPlace(name: "Abbey Art Studios", lat: 41.505297, long: -90.551476);
    fileprivate let andeberg = MyPlace(name: "Andeberg - 738 34th St", lat: 41.503772, long: -90.553000);
    fileprivate let anderson = MyPlace(name: "Anderson/Bartholomew", lat: 41.502361, long: -90.551381);
    fileprivate let andreen = MyPlace(name: "Andreen Hall", lat: 41.501657, long: -90.548496);
    fileprivate let ansvar = MyPlace(name: "Ansvar - 3054 9th Ave", lat: 41.502387, long: -90.554907);
    fileprivate let arbaugh = MyPlace(name: "Arbaugh TLA", lat: 41.499354, long: -90.552103);
    fileprivate let asgard = MyPlace(name: "Asgard - 742 34th St", lat: 41.503647, long: -90.552875);
    fileprivate let asianPagoda = MyPlace(name: "Asian Pagoda", lat: 41.501930, long: -90.552834);
    fileprivate let austin = MyPlace(name: "Austin - 610 39th St", lat: 41.505788, long: -90.546521);
    fileprivate let baldur = MyPlace(name: "Baldur - 3410 9 1/2 Ave", lat: 41.501833, long: -90.552073);
    fileprivate let bellman = MyPlace(name: "Bellman - 602 39th St", lat: 41.506061, long: -90.546520);
    fileprivate let bergendoff = MyPlace(name: "Bergendoff", lat: 41.505680, long: -90.548908);
    fileprivate let bergman = MyPlace(name: "Bergman - 929 32nd St", lat: 41.502156, long: -90.554499);
    fileprivate let blackCulture = MyPlace(name: "Black Culture House", lat: 41.502689, long: -90.552829);
    fileprivate let bostad = MyPlace(name: "Bostad - 727 34th St", lat: 41.504003, long: -90.552286);
    fileprivate let branting = MyPlace(name: "Branting - 3429 7th Ave", lat: 41.505136, long: -90.552359);
    fileprivate let bremer = MyPlace(name: "Bremer - 3801 8th Ave", lat: 41.504004, long: -90.547384);
    fileprivate let brodahl = MyPlace(name: "Brodahl", lat: 41.502800, long: -90.552291);
    fileprivate let carver = MyPlace(name: "Carver Center", lat: 41.506636, long: -90.550844);
    fileprivate let casaLatina = MyPlace(name: "Casa Latina", lat: 41.501896, long: -90.551838);
    fileprivate let celsius = MyPlace(name: "Celsius - 808 34th St", lat: 41.503181, long: -90.552841);
    fileprivate let centennial = MyPlace(name: "Centennial Hall", lat: 41.505123, long: -90.548681);
    fileprivate let delling = MyPlace(name: "Delling - 721 34th St", lat: 41.504237, long: -90.552283);
    fileprivate let denkmann = MyPlace(name: "Denkmann", lat: 41.504425, long: -90.550528);
    fileprivate let elflats = MyPlace(name: "11th Ave Flats", lat: 41.499988, long: -90.548975);
    fileprivate let erfara = MyPlace(name: "Erfara - 3052 9th Ave", lat: 41.502349, long: -90.555128);
    fileprivate let erickson = MyPlace(name: "Erickson Hall", lat: 41.499363, long: -90.554705);
    fileprivate let esbjorn = MyPlace(name: "Esbjorn - 3025 10th Ave", lat: 41.501834, long: -90.556017);
    fileprivate let evald = MyPlace(name: "Evald", lat: 41.505108, long: -90.550090);
    fileprivate let forseti = MyPlace(name: "Forseti - 1126 35th St", lat: 41.499532, long: -90.551380);
    fileprivate let freya = MyPlace(name: "Freya - 3235 8th Ave", lat: 41.503724, long: -90.553357);
    fileprivate let gerber = MyPlace(name: "Gerber Center", lat: 41.502285, long: -90.550688);
    fileprivate let gustav = MyPlace(name: "Gustav - 608 39th St", lat: 41.505944, long: -90.546518);
    fileprivate let hanson = MyPlace(name: "Hanson", lat: 41.503561, long: -90.551447);
    fileprivate let heimdall = MyPlace(name: "Heimdall - 731 34th St", lat: 41.503885, long: -90.552284);
    fileprivate let houseOnHill = MyPlace(name: "House on the Hill", lat: 41.501186, long: -90.555065);
    fileprivate let idun = MyPlace(name: "Idun - 3233 8th Ave", lat: 41.503761, long: -90.553463);
    //fileprivate let international = MyPlace(name: "International House", lat: 41.500885, long: -90.555603); check coords
    fileprivate let karsten = MyPlace(name: "Karsten - 1119 35th St", lat: 41.499793, long: -90.550879);
    fileprivate let larsson = MyPlace(name: "Larsson - 3250 9th Ave", lat: 41.502319, long: -90.552838);
    fileprivate let levander = MyPlace(name: "Levander - 750 35th St", lat: 41.502794, long: -90.551581);
    fileprivate let lindgren = MyPlace(name: "Lindgren - 1206 35th St", lat: 41.499056, long: -90.551361);
    fileprivate let localCulture = MyPlace(name: "Local Culture - 1118 35th St", lat: 41.499868, long: -90.551358);
    fileprivate let lundholm = MyPlace(name: "Lundholm - 753 34th St", lat: 41.503281, long: -90.552262);
    fileprivate let martinson = MyPlace(name: "Martinson - 800 34th St", lat: 41.503374, long: -90.552839);
    fileprivate let milles = MyPlace(name: "Milles - 1113 35th St", lat: 41.500063, long: -90.550915);
    fileprivate let moberg = MyPlace(name: "Moberg - 3336 7th Ave", lat: 41.504683, long: -90.552785);
    fileprivate let naeseth123 = MyPlace(name: "Naeseth TLA 1-3", lat: 41.499284, long: -90.553739);
    fileprivate let naeseth456 = MyPlace(name: "Naeseth TLA 4-6", lat: 41.498787, long: -90.552714);
    fileprivate let nobel = MyPlace(name: "Nobel - 812 34th St", lat: 41.503060, long: -90.552838);
    fileprivate let oden = MyPlace(name: "Oden - 921 34th St", lat: 41.501640, long: -90.552342);
    fileprivate let olin = MyPlace(name: "Olin", lat: 41.503118, long: -90.550591);
    fileprivate let ostara = MyPlace(name: "Ostara - 1202 30th St", lat: 41.499452, long: -90.557377);
    fileprivate let parkanderN = MyPlace(name: "Parkander North", lat: 41.501175, long: -90.549681);
    fileprivate let parkanderS = MyPlace(name: "Parkander South", lat: 41.500545, long: -90.549934);
    fileprivate let pepsico = MyPlace(name: "PepsiCo Recreation", lat: 41.500332, long: -90.556294);
    fileprivate let pottery = MyPlace(name: "Pottery Studio", lat: 41.505721, long: -90.550474);
    fileprivate let roslin = MyPlace(name: "Roslin - 618 39th St", lat: 41.505650, long: -90.546498);
    fileprivate let ryden = MyPlace(name: "Ryden - 3400 10th Ave", lat: 41.501018, long: -90.552537);
    fileprivate let sanning = MyPlace(name: "Sanning - 3048 9th Ave", lat: 41.502385, long: -90.555274);
    fileprivate let seminary = MyPlace(name: "Seminary Hall", lat: 41.503043, long: -90.548144);
    fileprivate let skadi = MyPlace(name: "Skadi - 3437 7th Ave", lat: 41.505138, long: -90.551767);
    fileprivate let sorensen = MyPlace(name: "Sorensen", lat: 41.505139, long: -90.547201);
    fileprivate let swanson = MyPlace(name: "Swanson Commons", lat: 41.500638, long: -90.548042);
    fileprivate let swedenborg = MyPlace(name: "Swedenborg - 3443 7th Ave", lat: 41.505315, long: -90.551452);
    fileprivate let swenson = MyPlace(name: "Swenson Geoscience", lat: 41.503030, long: -90.549075);
    fileprivate let thor = MyPlace(name: "Thor - 816 34th St", lat: 41.502908, long: -90.552838);
    fileprivate let tyr = MyPlace(name: "Tyr - 1111 37th St", lat: 41.500012, long: -90.548547);
    fileprivate let vidar = MyPlace(name: "Vidar - 1200 32nd St", lat: 41.498606, long: -90.554914);
    fileprivate let viking = MyPlace(name: "Viking - 730 34th St", lat: 41.503960, long: -90.552839);
    fileprivate let westerlin = MyPlace(name: "Westerlin Hall", lat: 41.500495, long: -90.554667);
    fileprivate let wicksell = MyPlace(name: "Wicksell - 1120 35th St", lat: 41.499712, long: -90.551468);
    fileprivate let zander = MyPlace(name: "Zander - 3203 10th Ave", lat: 41.501782, long: -90.554557);
    fileprivate let zorn = MyPlace(name: "Zorn - 3051 10th Ave", lat: 41.501776, long: -90.555133);
    
    fileprivate var map: Dictionary<String, Array<Double>>
    
    init() {
        map = [String : Array<Double>]()
        map[abbey.name] = [abbey.lat, abbey.long]
        map[andeberg.name] = [andeberg.lat, andeberg.long]
        map[anderson.name] = [anderson.lat, anderson.long]
        map[andreen.name] = [andreen.lat, andreen.long]
        map[ansvar.name] = [ansvar.lat, ansvar.long]
        map[arbaugh.name] = [arbaugh.lat, arbaugh.long]
        map[asgard.name] = [asgard.lat, asgard.long]
        map[asianPagoda.name] = [asianPagoda.lat, asianPagoda.long]
        map[austin.name] = [austin.lat, austin.long]
        map[baldur.name] = [baldur.lat, baldur.long]
        map[bellman.name] = [bellman.lat, bellman.long]
        map[bergendoff.name] = [bergendoff.lat, bergendoff.long]
        map[bergman.name] = [bergman.lat, bergman.long]
        map[blackCulture.name] = [blackCulture.lat, blackCulture.long]
        map[bostad.name] = [bostad.lat, bostad.long]
        map[branting.name] = [branting.lat, branting.long]
        map[bremer.name] = [bremer.lat, bremer.long]
        map[brodahl.name] = [brodahl.lat, brodahl.long]
        map[carver.name] = [carver.lat, carver.long]
        map[casaLatina.name] = [casaLatina.lat, casaLatina.long]
        map[celsius.name] = [celsius.lat, celsius.long]
        map[centennial.name] = [centennial.lat, centennial.long]
        map[delling.name] = [delling.lat, delling.long]
        map[denkmann.name] = [denkmann.lat, denkmann.long]
        map[elflats.name] = [elflats.lat, elflats.long]
        map[erfara.name] = [erfara.lat, erfara.long]
        map[erickson.name] = [erickson.lat, erickson.long]
        map[esbjorn.name] = [esbjorn.lat, esbjorn.long]
        map[evald.name] = [evald.lat, evald.long]
        map[forseti.name] = [forseti.lat, forseti.long]
        map[freya.name] = [freya.lat, freya.long]
        map[gerber.name] = [gerber.lat, gerber.long]
        map[gustav.name] = [gustav.lat, gustav.long]
        map[hanson.name] = [hanson.lat, hanson.long]
        map[heimdall.name] = [heimdall.lat, heimdall.long]
        map[houseOnHill.name] = [houseOnHill.lat, houseOnHill.long]
        map[idun.name] = [idun.lat, idun.long]
        map[karsten.name] = [karsten.lat, karsten.long]
        map[larsson.name] = [larsson.lat, larsson.long]
        map[levander.name] = [levander.lat, levander.long]
        map[lindgren.name] = [lindgren.lat, lindgren.long]
        map[localCulture.name] = [localCulture.lat, localCulture.long]
        map[lundholm.name] = [lundholm.lat, lundholm.long]
        map[martinson.name] = [martinson.lat, martinson.long]
        map[milles.name] = [milles.lat, milles.long]
        map[moberg.name] = [moberg.lat, moberg.long]
        map[naeseth123.name] = [naeseth123.lat, naeseth123.long]
        map[naeseth456.name] = [naeseth456.lat, naeseth456.long]
        map[nobel.name] = [nobel.lat, nobel.long]
        map[oden.name] = [oden.lat, oden.long]
        map[olin.name] = [olin.lat, olin.long]
        map[ostara.name] = [ostara.lat, ostara.long]
        map[parkanderN.name] = [parkanderN.lat, parkanderN.long]
        map[parkanderS.name] = [parkanderS.lat, parkanderS.long]
        map[pepsico.name] = [pepsico.lat, pepsico.long]
        map[pottery.name] = [pottery.lat, pottery.long]
        map[roslin.name] = [roslin.lat, roslin.long]
        map[ryden.name] = [ryden.lat, ryden.long]
        map[sanning.name] = [sanning.lat, sanning.long]
        map[seminary.name] = [seminary.lat, seminary.long]
        map[skadi.name] = [skadi.lat, skadi.long]
        map[sorensen.name] = [sorensen.lat, sorensen.long]
        map[swanson.name] = [swanson.lat, swanson.long]
        map[swedenborg.name] = [swedenborg.lat, swedenborg.long]
        map[swenson.name] = [swenson.lat, swenson.long]
        map[thor.name] = [thor.lat, thor.long]
        map[tyr.name] = [tyr.lat, tyr.long]
        map[vidar.name] = [vidar.lat, vidar.long]
        map[viking.name] = [viking.lat, viking.long]
        map[westerlin.name] = [westerlin.lat, westerlin.long]
        map[wicksell.name] = [wicksell.lat, wicksell.long]
        map[zander.name] = [zander.lat, zander.long]
        map[zorn.name] = [zorn.lat, zorn.long]
    }
    
    // Returns a dictionary of the Place's names mapped to an Array of the latitude and longitude.
    func getPlaces() -> Dictionary<String, Array<Double>> {
        return map
    }
    
    // Returns an Array of the Place's names
    func getNames() -> Array<String> {
        var names: [String] = ["Enter an Address"]
        for name in map {
            names.append(name.key)
        }
        return names
    }
    
    func addLocation(name: String, lat: Double, lng: Double) {
        map[name] = [lat, lng]
    }
    
    func removeLocation(name: String) {
        map.removeValue(forKey: name)
    }
}
