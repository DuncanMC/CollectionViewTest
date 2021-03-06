//
//  MyCollectionViewController.swift
//  CollectionViewTest
//
//  Created by Duncan Champney on 6/27/21.
//

import UIKit

private let reuseIdentifier = "Cell"


struct CellData: Hashable {
    var value: Int = 0
    let index: Int
    let section: Int
    let title: String
    var rowTotal: Int = 0
    var columnTotal: Int = 0

    static func == (lhs: CellData, rhs: CellData) -> Bool {
        return lhs.index == rhs.index && lhs.section == rhs.section
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(section)
    }
}
struct Section: Hashable {
    let title: String
    let index: Int
    var items =  [CellData]()

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.index == rhs.index
    }

}
class MyCollectionViewController: UICollectionViewController {

    var useNewSnapshot = true
    let gridColumns = 3
    public typealias SupplementaryViewProvider = (UICollectionView, String, IndexPath) -> UICollectionReusableView?

    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellData>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellData>

    var sections = [Section]()

    lazy private var dataSource = makeDataSource()

    func setCollectionLayout() {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0,left:0,bottom:0,right:0)
        layout.itemSize = CGSize(width: view.bounds.size.width / CGFloat(gridColumns) - 5, height: view.bounds.size.width / 4 - 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        collectionView.collectionViewLayout = layout
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.borderColor = UIColor.blue.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        for sectionIndex in 1...5 {
            var section = Section(title: "Section \(sectionIndex)", index: sectionIndex)
            let cellCount = Int.random(in: 7...12)
            for cellIndex in  1...cellCount {
                let cellData = CellData(index: cellIndex,
                                        section: sectionIndex,
                                        title: "Cell \(cellIndex)")
                section.items.append(cellData)
            }
            sections.append(section)
            applySnapshot(animatingDifferences: false)
        }



        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func newSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        return snapshot
    }

    func applySnapshot(animatingDifferences: Bool = true) {
        dataSource.apply(newSnapshot(), animatingDifferences: animatingDifferences)
    }

    func fizzBuzzColorFor(value: Int) -> UIColor {
        let isDivisibleBy5 = value != 0 && value.isMultiple(of: 5)
        let isDivisibleBy3 = value != 0 && value.isMultiple(of: 3)
        switch (isDivisibleBy5, isDivisibleBy3) {
        case (false, false):        // Not divisible by either
            return UIColor.white
        case (true, true):          // Divisible by both
            return UIColor.cyan
        case(true, false):          // Divisible by 5
            return UIColor.green
        case (false, true):         // Dvisiable by 3
            return UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
        }
    }
    func compareCellData(atIndexPath indexPath: IndexPath, dataIn: CellData, dataFromModel: CellData) {
        if dataIn.value != dataFromModel.value ||
            dataIn.rowTotal != dataFromModel.rowTotal ||
            dataIn.columnTotal != dataFromModel.columnTotal {
            print("At \(indexPath)")
            print(" data  in: \(dataIn)")
            print(" model   : \(dataFromModel)")
        }

    }
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, cellDataIn) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath)
                guard let myCell = cell as? MyCollectionViewCell else { return cell }
                let sectionData = self.sections[indexPath.section]
                let cellDataFromModel = sectionData.items[indexPath.row]

                let cellDataToUse = cellDataFromModel // Try using the model data given to the cellProvider closure
                self.compareCellData(atIndexPath: indexPath, dataIn: cellDataIn, dataFromModel: cellDataFromModel)
                myCell.titleLabel.text = cellDataToUse.title
                myCell.valueLabel.text = String(cellDataToUse.value)
                myCell.rowTotalLabel.text = String(cellDataToUse.rowTotal)
                myCell.columnTotalLabel.text = String(cellDataToUse.columnTotal)
                myCell.valueStackView.backgroundColor = self.fizzBuzzColorFor(value: cellDataToUse.value)
                myCell.rowTotalStackView.backgroundColor = self.fizzBuzzColorFor(value: cellDataToUse.rowTotal)
                myCell.columnTotalStackView.backgroundColor = self.fizzBuzzColorFor(value: cellDataToUse.columnTotal)
                return cell
            })
        dataSource.supplementaryViewProvider = { [weak self] collectionView, elementKind, indexPath in
            guard let self = self else { return nil }

            let cell = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "header",
                for: indexPath) as! HeaderView
            cell.headerTitleView.text = self.sections[indexPath.section].title
            return cell
        }

        return dataSource
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCollectionLayout()
    }
}

extension MyCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var snapshot: Snapshot


        sections[indexPath.section].items[indexPath.row].value += 1
        let gridRow = indexPath.row / gridColumns
        var items = Set<CellData>()
        for index in gridRow*gridColumns...min((gridRow+1) * gridColumns - 1,sections[indexPath.section].items.count-1)  {
            sections[indexPath.section].items[index].rowTotal += 1
            let item = sections[indexPath.section].items[index]
            items.insert(item)
        }
        let gridColumn =  indexPath.row % gridColumns
        for index in stride(from: gridColumn,
                            to: sections[indexPath.section].items.count,
                            by: gridColumns
        ) {
            sections[indexPath.section].items[index].columnTotal += 1
            let item = sections[indexPath.section].items[index]
            items.insert(item)
        }
        // MARK: - Create a new snapshot or use the old one?
        if useNewSnapshot {
            snapshot = newSnapshot()
        } else {
            snapshot = dataSource.snapshot()
        }
        // MARK: -

        snapshot.reloadItems(Array(items))
        self.dataSource.apply(snapshot)
    }
}




