enum FontType {
    case academyEngravedLET
    case americanTypewriter
    case appleSDGothicNeo
    case arial
    case arialRoundedMTBold
    case avenir
    case avenirNext
    case avenirNextCondensed
    case baskerville
    case bodoni72
    case bodoni72Oldstyle
    case bodoni72Smallcaps
    case bodoniOrnaments
    case bradleyHand
    case chalkboardSE
    case chalkduster
    case charter
    case cochin
    case copperplate
    case courierNew
    case dinAlternate
    case dinCondensed
    case devanagariSangamMN
    case didot
    case futura
    case galvji
    case georgia
    case gillSans
    case helvetica
    case helveticaNeue
    case hiraginoMaruGothicProN
    case hiraginoMinchoProN
    case hiraginoSans
    case hoeflerText
    case impact
    case kaushanScript
    case kefa
    case markerFelt
    case menlo
    case noteworthy
    case optima
    case palatino
    case papyrus
    case partyLET
    case rockwell
    case savoyeLET
    case snellRoundhand
    case timesNewRoman
    case verdana
    case zapfino
}

extension FontType: CaseIterable {
    static var allCasesAlphabetically: [FontType] {
        return allCases.sorted { $0.displayName < $1.displayName }
    }

    var fontName: String {
        switch self {
        case .academyEngravedLET:
            return "Academy Engraved LET"
        case .americanTypewriter:
            return "American Typewriter"
        case .appleSDGothicNeo:
            return "Apple SD Gothic Neo"
        case .arial:
            return "Arial"
        case .arialRoundedMTBold:
            return "Arial Rounded MT Bold"
        case .avenir:
            return "Avenir"
        case .avenirNext:
            return "Avenir Next"
        case .avenirNextCondensed:
            return "Avenir Next Condensed"
        case .baskerville:
            return "Baskerville"
        case .bodoni72:
            return "Bodoni 72"
        case .bodoni72Oldstyle:
            return "Bodoni 72 Oldstyle"
        case .bodoni72Smallcaps:
            return "Bodoni 72 Smallcaps"
        case .bodoniOrnaments:
            return "Bodoni Ornaments"
        case .bradleyHand:
            return "Bradley Hand"
        case .chalkboardSE:
            return "Chalkboard SE"
        case .chalkduster:
            return "Chalkduster"
        case .charter:
            return "Charter"
        case .cochin:
            return "Cochin"
        case .copperplate:
            return "Copperplate"
        case .courierNew:
            return "Courier New"
        case .dinAlternate:
            return "DIN Alternate"
        case .dinCondensed:
            return "DIN Condensed"
        case .devanagariSangamMN:
            return "Devanagari Sangam MN"
        case .didot:
            return "Didot"
        case .futura:
            return "Futura"
        case .galvji:
            return "Galvji"
        case .georgia:
            return "Georgia"
        case .gillSans:
            return "Gill Sans"
        case .helvetica:
            return "Helvetica"
        case .helveticaNeue:
            return "HelveticaNeue-Light"
        case .hiraginoMaruGothicProN:
            return "Hiragino Maru Gothic ProN"
        case .hiraginoMinchoProN:
            return "Hiragino Mincho ProN"
        case .hiraginoSans:
            return "Hiragino Sans"
        case .hoeflerText:
            return "Hoefler Text"
        case .impact:
            return "Impact"
        case .kaushanScript:
            return "Kaushan Script"
        case .kefa:
            return "Kefa"
        case .markerFelt:
            return "Marker Felt"
        case .menlo:
            return "Menlo"
        case .noteworthy:
            return "Noteworthy"
        case .optima:
            return "Optima"
        case .palatino:
            return "Palatino"
        case .papyrus:
            return "Papyrus"
        case .partyLET:
            return "Party LET"
        case .rockwell:
            return "Rockwell"
        case .savoyeLET:
            return "Savoye LET"
        case .snellRoundhand:
            return "Snell Roundhand"
        case .timesNewRoman:
            return "Times New Roman"
        case .verdana:
            return "Verdana"
        case .zapfino:
            return "Zapfino"
        }
    }

    var displayName: String {
        switch self {
        case .academyEngravedLET:
            return "Academy Engraved LET"
        case .americanTypewriter:
            return "American Typewriter"
        case .appleSDGothicNeo:
            return "Apple SD Gothic Neo"
        case .arial:
            return "Arial"
        case .arialRoundedMTBold:
            return "Arial Rounded MT Bold"
        case .avenir:
            return "Avenir"
        case .avenirNext:
            return "Avenir Next"
        case .avenirNextCondensed:
            return "Avenir Next Condensed"
        case .baskerville:
            return "Baskerville"
        case .bodoni72:
            return "Bodoni 72"
        case .bodoni72Oldstyle:
            return "Bodoni 72 Oldstyle"
        case .bodoni72Smallcaps:
            return "Bodoni 72 Smallcaps"
        case .bodoniOrnaments:
            return "Bodoni Ornaments"
        case .bradleyHand:
            return "Bradley Hand"
        case .chalkboardSE:
            return "Chalkboard SE"
        case .chalkduster:
            return "Chalkduster"
        case .charter:
            return "Charter"
        case .cochin:
            return "Cochin"
        case .copperplate:
            return "Copperplate"
        case .courierNew:
            return "Courier New"
        case .dinAlternate:
            return "DIN Alternate"
        case .dinCondensed:
            return "DIN Condensed"
        case .devanagariSangamMN:
            return "Devanagari Sangam MN"
        case .didot:
            return "Didot"
        case .futura:
            return "Futura"
        case .galvji:
            return "Galvji"
        case .georgia:
            return "Georgia"
        case .gillSans:
            return "Gill Sans"
        case .helvetica:
            return "Helvetica"
        case .helveticaNeue:
            return "Helvetica Neue"
        case .hiraginoMaruGothicProN:
            return "Hiragino Maru Gothic"
        case .hiraginoMinchoProN:
            return "Hiragino Mincho ProN"
        case .hiraginoSans:
            return "Hiragino Sans"
        case .hoeflerText:
            return "Hoefler Text"
        case .impact:
            return "Impact"
        case .kaushanScript:
            return "Kaushan Script"
        case .kefa:
            return "Kefa"
        case .markerFelt:
            return "Marker Felt"
        case .menlo:
            return "Menlo"
        case .noteworthy:
            return "Noteworthy"
        case .optima:
            return "Optima"
        case .palatino:
            return "Palatino"
        case .papyrus:
            return "Papyrus"
        case .partyLET:
            return "Party LET"
        case .rockwell:
            return "Rockwell"
        case .savoyeLET:
            return "Savoye LET"
        case .snellRoundhand:
            return "Snell Roundhand"
        case .timesNewRoman:
            return "Times New Roman"
        case .verdana:
            return "Verdana"
        case .zapfino:
            return "Zapfino"
        }
    }
}
