//
//  TableViewDataSource.swift
//  DPDataStorage
//
//  Created by Alex on 11/16/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

public protocol TableViewDataSourceDelegate: class {
    func dataSource(_ dataSource: TableViewDataSourceProtocol, cellIdentifierForObject object: Any, at indexPath: IndexPath) -> String?
    func dataSource(_ dataSource: TableViewDataSourceProtocol, didSelect object:Any, at indexPath: IndexPath)
    func dataSource(_ dataSource: TableViewDataSourceProtocol, willDispaly cell:DataSourceConfigurable, for object:Any, at indexPath: IndexPath)
}

public extension TableViewDataSourceDelegate {
    func dataSource(_ dataSource: TableViewDataSourceProtocol, cellIdentifierForObject object: Any, at indexPath: IndexPath) -> String? {
        return nil
    }
    
    func dataSource(_ dataSource: TableViewDataSourceProtocol, didSelect object:Any, at indexPath: IndexPath) { }

    func dataSource(_ dataSource: TableViewDataSourceProtocol, willDispaly cell:DataSourceConfigurable, for object:Any, at indexPath: IndexPath) { }
}

public protocol TableViewDataSourceProtocol {}

public class TableViewDataSource<ObjectType>: DataSource<ObjectType>, TableViewDataSourceProtocol, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet public weak var tableView: UITableView?
    @IBInspectable public var cellIdentifier: String?
    public weak var delegate: TableViewDataSourceDelegate?
    
    public init(tableView: UITableView,
         dataSourceContainer: DataSourceContainer<ObjectType>,
         delegate: TableViewDataSourceDelegate?,
         cellIdentifier: String?) {
        self.tableView = tableView
        self.delegate = delegate
        self.cellIdentifier = cellIdentifier
        
        super.init()
        self.container = dataSourceContainer
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let container = container, let numberOfSections = container.numberOfSections() else {
            return 0
        }
        return numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let container = container, let numberOfItems = container.numberOfItems(in: section) else {
            return 0
        }
        return numberOfItems
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String? = nil
        if let delegateCellIdentifier = delegate?.dataSource(self, cellIdentifierForObject: object, at: indexPath) {
            cellIdentifier = delegateCellIdentifier
        }
        if cellIdentifier == nil {
            cellIdentifier = self.cellIdentifier
        }
        guard let identifier = cellIdentifier else {
            fatalError("Cell identifier is empty")
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Cell is nil after dequeuring")
        }
        guard let configurableCell = cell as? DataSourceConfigurable else {
            fatalError("Cell is not implementing DataSourceConfigurable protocol")
        }
        guard let object = container?.object(at: indexPath) else {
            fatalError("Could not retrieve object at \(indexPath)")
        }
        configurableCell.configure(with: object)
        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let configurableCell = cell as? DataSourceConfigurable,
            let object = container?.object(at: indexPath) else {
                return
        }
        delegate?.dataSource(self, willDispaly: configurableCell, for: object, at: indexPath)
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let object = container?.object(at: indexPath) as Any? else {
            fatalError("Object non exists")
        }
        self.delegate?.dataSource(self, didSelect: object, at: indexPath)
    }
    
}
