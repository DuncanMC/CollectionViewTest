//
//  MyCollectionViewCell.swift
//  CollectionViewTest
//
//  Created by Duncan Champney on 6/27/21.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var rowTotalLabel: UILabel!
    @IBOutlet weak var columnTotalLabel: UILabel!

    @IBOutlet weak var valueStackView: UIStackView!
    @IBOutlet weak var rowTotalStackView: UIStackView!
    @IBOutlet weak var columnTotalStackView: UIStackView!
}
