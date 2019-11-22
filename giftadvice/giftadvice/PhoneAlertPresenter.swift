//
//  PhoneAlertPresenter.swift
//  giftadvice
//
//  Created by George Efimenko on 07/09/2019.
//  Copyright © 2019 George Efimenko. All rights reserved.
//

import OwlKit
import ObjectMapper
import PhoneNumberKit

struct PhoneAlertPresenter {
    let viewController: GAViewController
    var isPhonePrefixHidden: Bool = false
    var itemSelected: ((_ item: Phone) -> Void)?

    static var countries: [Phone]? {
        let resource: String = "countryCodes"
        let jsonPath = Bundle.main.path(forResource: resource, ofType: "json")

        return try? Mapper<Phone>().mapArray(JSONString: String(contentsOf: URL(fileURLWithPath: jsonPath!), encoding: .utf8))!
    }

    func show() {
        var sections = [TableSection]()

        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value

        let letters: [Character] = (0..<26).map {
            i in Character(UnicodeScalar(aCode + i)!)
        }

        for letter in letters {
            let section = TableSection(elements: PhoneAlertPresenter.countries!.filter({$0.id.lowercased().first! == letter}), headerView: tableHeader, footerView: nil)
            section.headerTitle = String(letter).capitalized
            section.indexTitle = String(letter).capitalized

            sections.append(section)
        }

        viewController.showPopupView(title: "Phone.CountryCode.Title".localized, adapters: [phoneItemAdapter], sections: sections)
    }

    private var phoneItemAdapter: TableCellAdapterProtocol {
        let adapter = TableCellAdapter<Phone, PhoneTableViewCell>()
        adapter.reusableViewLoadSource = .fromXib(name: "PhoneTableViewCell", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.cell?.render(props: ctx.element)
            if self.isPhonePrefixHidden {
                ctx.cell?.prefixLabel.isHidden = true
            }
        }

        adapter.events.didSelect = { ctx in
            let model = ctx.element

            self.itemSelected?(model)

            self.viewController.hidePopupView()

            return .deselectAnimated
        }

        return adapter
    }

    private var tableHeader: TableHeaderFooterAdapterProtocol {
        let adapter = TableHeaderFooterAdapter<TableHeaderView>()

        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value

        let letters: [Character] = (0..<26).map {
            i in Character(UnicodeScalar(aCode + i)!)
        }

        adapter.reusableViewLoadSource = .fromXib(name: "TableHeaderView", bundle: nil)

        adapter.events.dequeue = { ctx in
            ctx.view?.titleLabel?.text = String(letters[ctx.section]).capitalized
            ctx.view?.backgroundColor = .white
        }

        adapter.events.height = { _ in
            return 24
        }

        return adapter
    }
}
