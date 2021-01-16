class DataSourceManager extends ComponentServiceBase {
    primaryDataSourceKey := ""

    __New(primaryKey := "", primaryDataSource := "") {
        InvalidParameterException.CheckTypes("DataSourceManager", "primaryKey", primaryKey, "", "primaryDataSource", primaryDataSource, "")

        if (primaryKey != "" && primaryDataSource != "") {
            this.primaryDataSourceKey := primaryKey
            this.dataSources[primaryKey] := primaryDataSource
        }

        super.__New()
    }

    GetItem(key := "") {
        if (key == "") {
            key := this.primaryDataSourceKey
        }

        return super.GetItem(key)
    }

    SetItem(key, dataSourceObj, makePrimary := false) {
        if (makePrimary) {
            this.primaryDataSourceKey := key
        }

        return super.SetItem(key, dataSourceObj)
    }

    ReadListing(path, dataSourceKey := "") {
        dataSource := this.GetItem(dataSourceKey)
        return dataSource.ReadListing(path)
    }

    ReadJson(key, path := "", dataSourceKey := "") {
        dataSource := this.GetItem(dataSourceKey)
        return dataSource.ReadJson(key, path)
    }
}
